module tb ;

reg clk=0,reset=1;
reg [63:0] A,B;
wire [199:0]Final_out ;

MAC_CSLA_USING_DKG uut(clk,reset,A,B,Final_out);

always #5 clk = !clk ;

initial
begin
#10 reset =0 ;
 A = 10 ;
 B = 20 ;
 #50;
$stop ;
end

endmodule 

module MAC_CSLA_USING_DKG(clk,reset,A,B,Final_out);

input clk,reset;
input [63:0] A,B;
output  reg [199:0]Final_out ;

wire [127 :0] Product;
wire [199:0] add_out ;
VEDIC_MULTIPLIER_CSLA_USING_DKG sm1(.A(A),.B(B),.PRODUCT(Product));

assign add_out  = Final_out + Product ;

always @(posedge clk )
begin
	if(reset) Final_out <= 200'd0 ;
	else Final_out <= add_out ;
end
endmodule
//MULTIPLIER

module VEDIC_MULTIPLIER_CSLA_USING_DKG(A,B,PRODUCT);

input [63:0]A,B ;
output [127:0]PRODUCT ;
wire [63:0]W1,W2,W3,W4,S1,S2 ;

 vedic_multiplier32bit m1(.A(A[31:0]),.B(B[31:0]),.P(W1));
 vedic_multiplier32bit m2(.A(A[31:0]),.B(B[63:31]),.P(W2));
 vedic_multiplier32bit m3(.A(A[63:31]),.B(B[31:0]),.P(W3));
 vedic_multiplier32bit m4(.A(A[63:31]),.B(B[63:31]),.P(W4));

DKG64BIT ad0(.A(W2),.B(W3),.Cin(1'b0),.SUM(S1),.CARRY(Ca1));
DKG64BIT ad1(.A(S1),.B({32'd0,W1[63:32]}),.Cin(1'b0),.SUM(S2),.CARRY(gc11));
DKG64BIT ad2(.A(W4),.B({31'd0,Ca1,S2[63:32]}),.Cin(1'b0),.SUM(PRODUCT[127:64]),.CARRY(gc21));


assign PRODUCT[31:0] = W1[31:0] ;
assign PRODUCT[63:32] = S2[31:0] ;

endmodule

//////DKG64BIT//////////
module DKG64BIT(A,B,Cin,SUM,CARRY);
input [63:0]A,B;
input Cin;
output [63:0]SUM;
output CARRY ;

DKG32BIT ADD1(A[31:0],B[31:0],Cin,SUM[31:0],CARRY1);
DKG32BIT ADD2(A[63:32],B[63:32],CARRY1,SUM[63:32],CARRY);
 
endmodule
//32 BIT VEDIC MULTIPLIER
module vedic_multiplier32bit(A,B,P);

input [31:0]A,B ;
output [63:0] P ;

wire [31:0]W1,W2,W3,W4,S1 ,S2;

 vedic_multiplier16bit m1(.A(A[15:0]),.B(B[15:0]),.P(W1));
 vedic_multiplier16bit m2(.A(A[15:0]),.B(B[31:16]),.P(W2));
 vedic_multiplier16bit m3(.A(A[31:16]),.B(B[15:0]),.P(W3));
 vedic_multiplier16bit m4(.A(A[31:16]),.B(B[31:16]),.P(W4));

DKG32BIT ad0(.A(W2),.B(W3),.Cin(1'b0),.SUM(S1),.CARRY(Ca1));
DKG32BIT ad1(.A(S1),.B({16'd0,W1[31:16]}),.Cin(1'b0),.SUM(S2),.CARRY(gc11));
DKG32BIT ad2(.A(W4),.B({15'd0,Ca1,S2[31:16]}),.Cin(1'b0),.SUM(P[63:32]),.CARRY(gc21));


assign P[15:0] = W1[15:0] ;
assign P[31:16] =S2[15:0] ;

endmodule

//////DKG32BIT//////////
module DKG32BIT(A,B,Cin,SUM,CARRY);
input [31:0]A,B;
input Cin;
output [31:0]SUM;
output CARRY ;
DKG16BIT ADD1(A[15:0],B[15:0],Cin,SUM[15:0],CARRY1);
DKG16BIT ADD2(A[31:16],B[31:16],CARRY1,SUM[31:16],CARRY);
 
endmodule
//16 BIT VEDIC MULTIPLIER
module vedic_multiplier16bit(A,B,P);

input [15:0]A,B ;
output [31:0] P ;

wire [15:0]W1,W2,W3,W4,S1,S2 ;

 vedic_multiplier8bit m1(.A(A[7:0]),.B(B[7:0]),.P(W1));
 vedic_multiplier8bit m2(.A(A[7:0]),.B(B[15:8]),.P(W2));
 vedic_multiplier8bit m3(.A(A[15:8]),.B(B[7:0]),.P(W3));
 vedic_multiplier8bit m4(.A(A[15:8]),.B(B[15:8]),.P(W4));

DKG16BIT ad0(.A(W2),.B(W3),.Cin(1'b0),.SUM(S1),.CARRY(Ca1));
DKG16BIT ad1(.A(S1),.B({8'd0,W1[15:8]}),.Cin(1'b0),.SUM(S2),.CARRY(gc11));
DKG16BIT ad2(.A(W4),.B({7'd0,Ca1,S2[15:8]}),.Cin(1'b0),.SUM(P[31:16]),.CARRY(gc21));


assign P[7:0] = W1[7:0] ;
assign P[15:8] = S2[7:0] ;
endmodule

//////DKG16BIT//////////
module DKG16BIT(A,B,Cin,SUM,CARRY);
input [15:0]A,B;
input Cin;
output [15:0]SUM;
output CARRY ;

DKG8BIT ADD1(A[7:0],B[7:0],Cin,SUM[7:0],CARRY1);
DKG8BIT ADD2(A[15:8],B[15:8],CARRY1,SUM[15:8],CARRY);
 
endmodule
//8BIT VEDIC MULTIPLIER
module vedic_multiplier8bit(A,B,P);

input [7:0]A,B ;
output [15:0] P ;

wire [7:0]W1,W2,W3,W4,S1,S2 ;

 vedic_multiplier4bit m1(.A(A[3:0]),.B(B[3:0]),.P(W1));
 vedic_multiplier4bit m2(.A(A[3:0]),.B(B[7:4]),.P(W2));
 vedic_multiplier4bit m3(.A(A[7:4]),.B(B[3:0]),.P(W3));
 vedic_multiplier4bit m4(.A(A[7:4]),.B(B[7:4]),.P(W4));

//DKG8BIT(A,B,Cin,SUM,CARRY);
DKG8BIT ad0(.A(W2),.B(W3),.Cin(1'b0),.SUM(S1),.CARRY(Ca1));
DKG8BIT ad1(.A(S1),.B({4'd0,W1[7:4]}),.Cin(1'b0),.SUM(S2),.CARRY(gc11));
DKG8BIT ad2(.A(W4),.B({3'd0,Ca1,S2[7:4]}),.Cin(1'b0),.SUM(P[15:8]),.CARRY(gc21));


assign P[3:0] = W1[3:0] ;
assign P[7:4] = S2[3:0] ;

endmodule

////// DKG8BIT//////////
module DKG8BIT(A,B,Cin,SUM,CARRY);
input [7:0]A,B;
input Cin;
output [7:0]SUM;
output CARRY ;

CSLA_USING_DKG4BIT ADD1(A[3:0],B[3:0],Cin,SUM[3:0],CARRY1);
CSLA_USING_DKG4BIT ADD2(A[7:4],B[7:4],CARRY1,SUM[7:4],CARRY);
 
endmodule

///4BIT VEDIC MULTIPLIER
module vedic_multiplier4bit(A,B,P);

input [3:0]A,B ;
output [7:0] P ;

wire [3:0]W1,W2,W3,W4 ;
wire [3:0] S1 ,S2;

 MULTIPLIER2BIT m1(.A(A[1:0]),.B(B[1:0]),.P(W1));
 MULTIPLIER2BIT m2(.A(A[1:0]),.B(B[3:2]),.P(W2));
 MULTIPLIER2BIT m3(.A(A[3:2]),.B(B[1:0]),.P(W3));
 MULTIPLIER2BIT m4(.A(A[3:2]),.B(B[3:2]),.P(W4));
///DKG4BIT(A,B,Cin,SUM,CARRY);
CSLA_USING_DKG4BIT ad0(.A(W2),.B(W3),.Cin(1'b0),.SUM(S1),.CARRY(Ca1));
CSLA_USING_DKG4BIT ad1(.A(S1),.B({2'd0,W1[3:2]}),.Cin(1'b0),.SUM(S2),.CARRY(gc11));
CSLA_USING_DKG4BIT ad2(.A(W4),.B({1'd0,Ca1,S2[3:2]}),.Cin(1'b0),.SUM(P[7:4]),.CARRY(gc21));

assign P[1:0] = W1[1:0] ;
assign P[3:2] = S2[1:0] ;
endmodule

//////4BIT DKG//////////

module CSLA_USING_DKG4BIT(A,B,Cin,SUM,CARRY);

input [3:0]A,B;
input Cin;
output [3:0]SUM;
output CARRY ;
wire [3:1] SUM1,SUM2 ;
//DKG dkg1(A,B,C,D,P,Q,R,S); 
DKG dkg1(.A(1'b0),.B(A[0]),.C(B[0]),.D(Cin),.P(g1),.Q(g2),.R(C1),.S(SUM[0])); 

DKG dkg2(.A(1'b0),.B(A[1]),.C(B[1]),.D(1'b0),.P(g01),.Q(g02),.R(C2),.S(SUM1[1])); 
DKG dkg3(.A(1'b0),.B(A[2]),.C(B[2]),.D(C2),.P(g11),.Q(g12),.R(C3),.S(SUM1[2])); 
DKG dkg4(.A(1'b0),.B(A[3]),.C(B[3]),.D(C3),.P(g21),.Q(g22),.R(CARRY1),.S(SUM1[3])); 

DKG dkg12(.A(1'b0),.B(A[1]),.C(B[1]),.D(1'b1),.P(g011),.Q(g021),.R(C12),.S(SUM2[1])); 
DKG dkg13(.A(1'b0),.B(A[2]),.C(B[2]),.D(C12),.P(g111),.Q(g121),.R(C13),.S(SUM2[2])); 
DKG dkg14(.A(1'b0),.B(A[3]),.C(B[3]),.D(C13),.P(g211),.Q(g221),.R(CARRY2),.S(SUM2[3])); 

assign SUM[3:1] = C1 ? SUM2 : SUM1 ;
assign CARRY = C1 ? CARRY2 : CARRY1 ;

endmodule
///DKG LOGIC
module DKG(A,B,C,D,P,Q,R,S);  
input A,B,C,D ;
output P,Q,R,S ;

assign P = B ;
assign Q = (!A&C)|(A&!D) ;
assign R = (A ^ B)&(C ^ D)^(C&D) ;
assign S = B ^ C ^ D ;  

endmodule 

//2 BIT MULTIPLIER
module MULTIPLIER2BIT(A,B,P);

input [1:0] A,B ;
output [3:0] P ;

assign  P[0] = A[0] && B[0] ;

half_adder ha1(.a(A[0] && B[1]), .b(A[1] && B[0]), .sum (P[1]), .carry(hc1));

half_adder ha2(.a(A[1] && B[1]), .b(hc1), .sum (P[2]), .carry(P[3]));

endmodule

//HALF ADDER

module half_adder(a,b,sum,carry) ;

input a,b ;
output sum,carry ;

assign sum = a ^ b ;
assign carry = a && b ;

endmodule
