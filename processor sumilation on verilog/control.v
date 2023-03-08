module control(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite,j_format, branch, aluop1, aluop2, cpsr_reset, cpsr_update, b_format,ben,bvf);
input [5:0] in;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite,j_format, branch, aluop1, aluop2,b_format,cpsr_update, ben, bvf,cpsr_reset;

wire b_format,r_format,lw,sw,beq,itype,addi;


assign r_format =~| in;

assign lw = in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];

assign sw = in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];

assign addi = (~in[5])& (~in[4])&(in[3])&(~in[2])&(~in[1])&(~in[0]);

assign beq = ~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);

//assign bvf to 0x5
assign bvf = (~in[5])& (~in[4])&(~in[3])&in[2]&(~in[1])&in[0];
//assign ben to 0x6
assign ben = (~in[5])& (~in[4])&(~in[3])&in[2]&in[1]&(~in[0]);

assign regdest = r_format;
assign itype= addi|lw|sw;
assign b_format = bvf|ben;
assign j_format = (~in[5])& (~in[4])&(~in[3])&(~in[2])&in[1]&(~in[0]);

assign alusrc = lw|sw|addi;
assign memtoreg = lw;
assign regwrite = r_format|lw|addi;
assign memread = lw;
assign memwrite = sw;
assign branch = beq;

assign aluop1 = r_format;
assign aluop2 = beq;


assign cpsr_update = r_format|itype; 
assign cpsr_reset = b_format | branch | (~cpsr_update) | j_format;
endmodule
