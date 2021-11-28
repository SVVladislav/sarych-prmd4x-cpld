`timescale 1ns / 1ps

module 
main(

//���� ����������
  
  input [5:0] D,    // ������
  input [3:0] ADR,  // �����
  input NWR,        // WE active Low
  input CLK,
  input F_2M,MCO,                           // ����� 2 ��� ������������� ���������� ���������� ������� � ����������� � ����������
  output SYNC_2M,                           // ����� 2 ��� ������������� ���������� �������
  input STRTX,STRRX,TRG,                    // ����� ���������� ������� ��� � ��� � LVDS
  input  STRSH,    //���� ������������ ������ �� ����� ������� ��������
  output STR_ADC,  //����� ������ TX �� CPU
    
  output STR_RX,STR_TX,STR_SH,STR_PA,STR_LNA,STR_INT, // ������ �������
  output D_IN_IF,D_IN_RF,CLK_RF,CLK_IF,LE_RF,LE_IF,    // ������ SPI ��� �������� ���������

  input LE,                                 // ���� LE � ����������������
  input TM_M5V                              // ���� ���������� -5�
);

// �������� ����������
  reg [5:0] STR_EN;                       // ���������� �������
  reg [1:0] SYNC_SRC;     // �������� ������������� ���������� ���������� �������
                          // 0-���������, 1-MCO/8 , 3 - ���������� 
  reg [5:0] DIF;   // �������� ��� ������� ��������
  reg [5:0] DRF;   // �������� ��� ������� ��������

// �������� ������ �� ����������������
always @(negedge CLK) begin
  if(~NWR)
    case (ADR)
     0:  STR_EN[5:0] <= D[5:0];
     1:  SYNC_SRC[1:0] <= D[1:0];
     2:  DIF[5:0] <= ~D[5:0];      // �������� 6-��� � ��������� HMC542 �� ����� IF
     3:  DRF[4:0] <= ~D[4:0];      // �������� 1 ������ ��� + 5-��� � ��������� HMC1018 �� ����� � RX1	  
    endcase
  else
    begin
      DIF <= {DIF[4:0],1'b0};
      DRF <= {DRF[4:0],1'b0};		
    end
end

assign D_IN_IF = DIF[5];
assign D_IN_RF = DRF[5];
assign CLK_RF = NWR?CLK:1'b0;
assign CLK_IF = NWR?CLK:1'b0;
  
assign LE_IF = LE;  //| TRG;
assign LE_RF = LE;  //| TRG;

// ������������ ������� (�������, ����� ��������� � ������ �� -5�)
//assign STR_TX  = ((STR_EN[0] & STRTX) | STR_EN[5]) & TM_M5V; // � ������� ����������� ������
assign STR_TX  = (STR_EN[0] & STRTX)  & TM_M5V;
assign STR_PA  = STR_EN[1] & STRTX;
assign STR_RX  = STR_EN[2] & STRRX & TM_M5V;
assign STR_LNA = STR_EN[3] & STRRX;
//assign STR_LNA = MCO;   //��������� MCO �� ���������� 
assign STR_ADC  = STRTX;
assign STR_SH  = STRSH;
assign STR_INT  = TRG;

// �������� MCO/8 ���
//reg [2:0] MCO_COUNTER;
//always @(posedge MCO) MCO_COUNTER<=MCO_COUNTER+1;

// ����� ��������� ������������ �������������� � ��������� MCO
//assign SYNC_2M = SYNC_SRC[0]? (SYNC_SRC[1]? F_2M : MCO_COUNTER[2]) : 1'b0;

// ����� ��������� ������������ �������������� ��� �������� MCO
assign SYNC_2M = SYNC_SRC[0]? (SYNC_SRC[1]? F_2M : MCO) : 1'b0;

endmodule


