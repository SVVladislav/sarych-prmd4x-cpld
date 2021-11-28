`timescale 1ns / 1ps

module 
main(

//Шина процессора
  
  input [5:0] D,    // Данные
  input [3:0] ADR,  // Адрес
  input NWR,        // WE active Low
  input CLK,
  input F_2M,MCO,                           // Входы 2 МГц синхронизации импульсных источников питания с синтезатора и процессора
  output SYNC_2M,                           // Выход 2 МГц синхронизации источников питания
  input STRTX,STRRX,TRG,                    // Входы раздельных стробов ПРД и ПРМ с LVDS
  input  STRSH,    //Вход задержанного строба на схему выборки хранения
  output STR_ADC,  //Выход строба TX на CPU
    
  output STR_RX,STR_TX,STR_SH,STR_PA,STR_LNA,STR_INT, // Выходы стробов
  output D_IN_IF,D_IN_RF,CLK_RF,CLK_IF,LE_RF,LE_IF,    // Выходы SPI для загрузки микросхем

  input LE,                                 // Вход LE с микроконтроллера
  input TM_M5V                              // Вход телеметрии -5В
);

// Регистры управления
  reg [5:0] STR_EN;                       // Разрешение стробов
  reg [1:0] SYNC_SRC;     // Источник синхронизации импульсных источников питания
                          // 0-отключено, 1-MCO/8 , 3 - синтезатор 
  reg [5:0] DIF;   // Регистры для быстрой загрузки
  reg [5:0] DRF;   // Регистры для быстрой загрузки

// Загрузка данных от микроконтроллера
always @(negedge CLK) begin
  if(~NWR)
    case (ADR)
     0:  STR_EN[5:0] <= D[5:0];
     1:  SYNC_SRC[1:0] <= D[1:0];
     2:  DIF[5:0] <= ~D[5:0];      // Загрузка 6-бит с инверсией HMC542 на сдвиг IF
     3:  DRF[4:0] <= ~D[4:0];      // Загрузка 1 пустой бит + 5-бит с инверсией HMC1018 на сдвиг в RX1	  
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

// Формирование стробов (затычки, выбор источника и защита по -5В)
//assign STR_TX  = ((STR_EN[0] & STRTX) | STR_EN[5]) & TM_M5V; // С режимом постоянного строба
assign STR_TX  = (STR_EN[0] & STRTX)  & TM_M5V;
assign STR_PA  = STR_EN[1] & STRTX;
assign STR_RX  = STR_EN[2] & STRRX & TM_M5V;
assign STR_LNA = STR_EN[3] & STRRX;
//assign STR_LNA = MCO;   //Завернуть MCO на синтезатор 
assign STR_ADC  = STRTX;
assign STR_SH  = STRSH;
assign STR_INT  = TRG;

// Делитель MCO/8 МГц
//reg [2:0] MCO_COUNTER;
//always @(posedge MCO) MCO_COUNTER<=MCO_COUNTER+1;

// Выбор истосника тактирования стабилизаторов с делителем MCO
//assign SYNC_2M = SYNC_SRC[0]? (SYNC_SRC[1]? F_2M : MCO_COUNTER[2]) : 1'b0;

// Выбор истосника тактирования стабилизаторов без делителя MCO
assign SYNC_2M = SYNC_SRC[0]? (SYNC_SRC[1]? F_2M : MCO) : 1'b0;

endmodule


