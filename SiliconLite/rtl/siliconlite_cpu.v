
`timescale 1ns/1ps
// SiliconLite: compact RV32I-subset, five-stage pipelined CPU.
// Supported: ADD, SUB, AND, OR, XOR, SLT, ADDI, LW, SW, BEQ, BNE.

module siliconlite_cpu(
    input wire clk,
    input wire reset,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_wb_value,
    output wire debug_wb_write
);

    reg [31:0] pc;
    reg [31:0] imem [0:255];
    reg [31:0] dmem [0:255];
    reg [31:0] regs [0:31];
    integer i;

    localparam [31:0] NOP = 32'h00000013;

    // IF/ID pipeline registers
    reg [31:0] ifid_pc, ifid_instr;

    // ID/EX pipeline registers
    reg [31:0] idex_pc, idex_rs1_val, idex_rs2_val, idex_imm;
    reg [4:0] idex_rs1, idex_rs2, idex_rd;
    reg [2:0] idex_funct3;
    reg [6:0] idex_opcode, idex_funct7;
    reg idex_regwrite, idex_memread, idex_memwrite, idex_memtoreg;
    reg idex_alusrc, idex_branch, idex_bne;

    // EX/MEM pipeline registers
    reg [31:0] exmem_alu_result, exmem_store_data;
    reg [4:0] exmem_rd;
    reg exmem_regwrite, exmem_memread, exmem_memwrite, exmem_memtoreg;

    // MEM/WB pipeline registers
    reg [31:0] memwb_mem_data, memwb_alu_result;
    reg [4:0] memwb_rd;
    reg memwb_regwrite, memwb_memtoreg;

    wire [6:0] dec_opcode = ifid_instr[6:0];
    wire [2:0] dec_funct3 = ifid_instr[14:12];
    wire [6:0] dec_funct7 = ifid_instr[31:25];
    wire [4:0] dec_rs1 = ifid_instr[19:15];
    wire [4:0] dec_rs2 = ifid_instr[24:20];
    wire [4:0] dec_rd = ifid_instr[11:7];

    reg dec_regwrite, dec_memread, dec_memwrite, dec_memtoreg;
    reg dec_alusrc, dec_branch, dec_bne;
    reg [31:0] dec_imm;

    always @* begin
        dec_regwrite = 0;
        dec_memread = 0;
        dec_memwrite = 0;
        dec_memtoreg = 0;
        dec_alusrc = 0;
        dec_branch = 0;
        dec_bne = 0;
        dec_imm = 32'b0;

        case (dec_opcode)
            7'b0110011: begin
                dec_regwrite = 1;
            end

            7'b0010011: begin
                dec_regwrite = 1;
                dec_alusrc = 1;
                dec_imm = {{20{ifid_instr[31]}}, ifid_instr[31:20]};
            end

            7'b0000011: begin
                dec_regwrite = 1;
                dec_memread = 1;
                dec_memtoreg = 1;
                dec_alusrc = 1;
                dec_imm = {{20{ifid_instr[31]}}, ifid_instr[31:20]};
            end

            7'b0100011: begin
                dec_memwrite = 1;
                dec_alusrc = 1;
                dec_imm = {{20{ifid_instr[31]}},
                           ifid_instr[31:25], ifid_instr[11:7]};
            end

            7'b1100011: begin
                dec_branch = 1;
                dec_bne = (dec_funct3 == 3'b001);
                dec_imm = {{19{ifid_instr[31]}}, ifid_instr[31],
                           ifid_instr[7], ifid_instr[30:25],
                           ifid_instr[11:8], 1'b0};
            end

            default: begin
            end
        endcase
    end

    wire load_use_stall =
        idex_memread && (idex_rd != 0) &&
        ((idex_rd == dec_rs1) ||
         ((dec_opcode == 7'b0110011 ||
           dec_opcode == 7'b0100011 ||
           dec_opcode == 7'b1100011) && idex_rd == dec_rs2));

    wire [31:0] wb_value =
        memwb_memtoreg ? memwb_mem_data : memwb_alu_result;

    reg [31:0] ex_rs1, ex_rs2, alu_b, alu_result;

    always @* begin
        ex_rs1 = idex_rs1_val;
        ex_rs2 = idex_rs2_val;

        if (exmem_regwrite && !exmem_memtoreg &&
            exmem_rd != 0 && exmem_rd == idex_rs1)
            ex_rs1 = exmem_alu_result;
        else if (memwb_regwrite && memwb_rd != 0 &&
                 memwb_rd == idex_rs1)
            ex_rs1 = wb_value;

        if (exmem_regwrite && !exmem_memtoreg &&
            exmem_rd != 0 && exmem_rd == idex_rs2)
            ex_rs2 = exmem_alu_result;
        else if (memwb_regwrite && memwb_rd != 0 &&
                 memwb_rd == idex_rs2)
            ex_rs2 = wb_value;

        alu_b = idex_alusrc ? idex_imm : ex_rs2;
        alu_result = 32'b0;

        case (idex_opcode)
            7'b0110011: begin
                case (idex_funct3)
                    3'b000:
                        alu_result =
                            (idex_funct7 == 7'b0100000) ?
                            ex_rs1 - ex_rs2 : ex_rs1 + ex_rs2;
                    3'b111: alu_result = ex_rs1 & ex_rs2;
                    3'b110: alu_result = ex_rs1 | ex_rs2;
                    3'b100: alu_result = ex_rs1 ^ ex_rs2;
                    3'b010:
                        alu_result =
                            ($signed(ex_rs1) < $signed(ex_rs2)) ?
                            32'd1 : 32'd0;
                    default: alu_result = 32'b0;
                endcase
            end

            7'b0010011, 7'b0000011, 7'b0100011:
                alu_result = ex_rs1 + alu_b;

            default:
                alu_result = ex_rs1 - ex_rs2;
        endcase
    end

    wire branch_taken =
        idex_branch &&
        ((idex_bne && ex_rs1 != ex_rs2) ||
         (!idex_bne && ex_rs1 == ex_rs2));

    wire [31:0] branch_target = idex_pc + idex_imm;

    always @(posedge clk) begin
        if (reset) begin
            pc <= 0;
            ifid_pc <= 0;
            ifid_instr <= NOP;

            idex_pc <= 0;
            idex_rs1_val <= 0;
            idex_rs2_val <= 0;
            idex_imm <= 0;
            idex_rs1 <= 0;
            idex_rs2 <= 0;
            idex_rd <= 0;
            idex_funct3 <= 0;
            idex_opcode <= NOP[6:0];
            idex_funct7 <= 0;

            idex_regwrite <= 0;
            idex_memread <= 0;
            idex_memwrite <= 0;
            idex_memtoreg <= 0;
            idex_alusrc <= 0;
            idex_branch <= 0;
            idex_bne <= 0;

            exmem_alu_result <= 0;
            exmem_store_data <= 0;
            exmem_rd <= 0;
            exmem_regwrite <= 0;
            exmem_memread <= 0;
            exmem_memwrite <= 0;
            exmem_memtoreg <= 0;

            memwb_mem_data <= 0;
            memwb_alu_result <= 0;
            memwb_rd <= 0;
            memwb_regwrite <= 0;
            memwb_memtoreg <= 0;

            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 0;
        end else begin
            regs[0] <= 0;

            if (memwb_regwrite && memwb_rd != 0)
                regs[memwb_rd] <= wb_value;

            // MEM/WB stage
            memwb_alu_result <= exmem_alu_result;
            memwb_mem_data <= exmem_memread ?
                              dmem[exmem_alu_result[9:2]] : 32'b0;
            memwb_rd <= exmem_rd;
            memwb_regwrite <= exmem_regwrite;
            memwb_memtoreg <= exmem_memtoreg;

            if (exmem_memwrite)
                dmem[exmem_alu_result[9:2]] <= exmem_store_data;

            // EX/MEM stage
            exmem_alu_result <= alu_result;
            exmem_store_data <= ex_rs2;
            exmem_rd <= idex_rd;
            exmem_regwrite <= idex_regwrite;
            exmem_memread <= idex_memread;
            exmem_memwrite <= idex_memwrite;
            exmem_memtoreg <= idex_memtoreg;

            // ID/EX stage
            if (load_use_stall || branch_taken) begin
                idex_pc <= 0;
                idex_rs1_val <= 0;
                idex_rs2_val <= 0;
                idex_imm <= 0;
                idex_rs1 <= 0;
                idex_rs2 <= 0;
                idex_rd <= 0;
                idex_funct3 <= 0;
                idex_opcode <= NOP[6:0];
                idex_funct7 <= 0;

                idex_regwrite <= 0;
                idex_memread <= 0;
                idex_memwrite <= 0;
                idex_memtoreg <= 0;
                idex_alusrc <= 0;
                idex_branch <= 0;
                idex_bne <= 0;
            end else begin
                idex_pc <= ifid_pc;
                idex_rs1_val <= regs[dec_rs1];
                idex_rs2_val <= regs[dec_rs2];
                idex_imm <= dec_imm;
                idex_rs1 <= dec_rs1;
                idex_rs2 <= dec_rs2;
                idex_rd <= dec_rd;
                idex_funct3 <= dec_funct3;
                idex_opcode <= dec_opcode;
                idex_funct7 <= dec_funct7;

                idex_regwrite <= dec_regwrite;
                idex_memread <= dec_memread;
                idex_memwrite <= dec_memwrite;
                idex_memtoreg <= dec_memtoreg;
                idex_alusrc <= dec_alusrc;
                idex_branch <= dec_branch;
                idex_bne <= dec_bne;
            end

            // IF/ID and PC
            if (branch_taken) begin
                pc <= branch_target;
                ifid_pc <= 0;
                ifid_instr <= NOP;
            end else if (load_use_stall) begin
                pc <= pc;
                ifid_pc <= ifid_pc;
                ifid_instr <= ifid_instr;
            end else begin
                ifid_pc <= pc;
                ifid_instr <= imem[pc[9:2]];
                pc <= pc + 4;
            end
        end
    end

    assign debug_pc = pc;
    assign debug_wb_value = wb_value;
    assign debug_wb_write = memwb_regwrite;

endmodule
