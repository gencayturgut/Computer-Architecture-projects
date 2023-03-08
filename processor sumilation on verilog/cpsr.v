module cpsr(ben,bvf,sout,vout, zout , out, reset, update);
input ben, bvf, sout, vout, zout,reset,update;
reg [2:0] flags;
output reg out;
reg clk;

always@(posedge clk)
begin
if (reset)
//sout = 0 , vout = 0 , zout = 0
flags = 3'b000;
else if (update)
flags = {sout, vout, zout};
end

always @(ben|bvf)
begin
if (ben&&flags[0])
out = flags[0];
else if (bvf&&flags[1])
out = flags[1];
else if (ben&&flags[2])
out = flags[2];
else
out = 0;
end

initial
begin
clk=0;
end

always #5 clk = ~clk;

endmodule
