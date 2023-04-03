module VGAMod
(
    input                   nRST,

    input                   PixelClk,

    output                  LCD_DE,
    output                  LCD_HSYNC,
    output                  LCD_VSYNC,

	output          [4:0]   LCD_B,
	output          [5:0]   LCD_G,
	output          [4:0]   LCD_R
);

    reg         [15:0]  PixelCount;
    reg         [15:0]  LineCount;

	localparam      V_BackPorch = 16'd0; //6
	localparam      V_Pluse 	= 16'd5; 
	localparam      HightPixel  = 16'd480;
	localparam      V_FrontPorch= 16'd45; //62

	localparam      H_BackPorch = 16'd182; 	//NOTE: 高像素时钟时，增加这里的延迟，方便K210加入中断
	localparam      H_Pluse 	= 16'd1; 
	localparam      WidthPixel  = 16'd800; 
	localparam      H_FrontPorch= 16'd210;


    localparam      Width_bar   =   45;

    reg         [15:0]  BarCount;
    
 
    localparam      PixelForHS  =   WidthPixel + H_BackPorch + H_FrontPorch;  	
    localparam      LineForVS   =   HightPixel + V_BackPorch + V_FrontPorch;

    always @(  posedge PixelClk or negedge nRST  )begin
        if( !nRST ) begin
            LineCount       <=  16'b0;    
            PixelCount      <=  16'b0;
            end
        else if(  PixelCount  ==  PixelForHS ) begin
            PixelCount      <=  16'b0;
            LineCount       <=  LineCount + 1'b1;
            end
        else if(  LineCount  == LineForVS  ) begin
            LineCount       <=  16'b0;
            PixelCount      <=  16'b0;
            end
        else
            PixelCount      <=  PixelCount + 1'b1;
    end

	//注意这里HSYNC和VSYNC负极性
    assign  LCD_HSYNC = (( PixelCount >= H_Pluse)&&( PixelCount <= (PixelForHS-H_FrontPorch))) ? 1'b0 : 1'b1;
    
	assign  LCD_VSYNC = ((( LineCount  >= V_Pluse )&&( LineCount  <= (LineForVS-0) )) ) ? 1'b0 : 1'b1;
    

    assign  LCD_DE = (  ( PixelCount >= H_BackPorch )&&
                        ( PixelCount <= PixelForHS-H_FrontPorch ) &&
                        ( LineCount >= V_BackPorch ) &&
                        ( LineCount <= LineForVS-V_FrontPorch-1 ))&& PixelClk ? 1'b1 : 1'b0;

    assign  LCD_R   =   ( PixelCount < Width_bar * BarCount )?  5 'b00000 :  
                        ( PixelCount < (Width_bar * (BarCount +1 ))  ? 5'b00001 :    
                        ( PixelCount < (Width_bar * (BarCount +2 ))  ? 5'b00010 :    
                        ( PixelCount < (Width_bar * (BarCount +3 ))  ? 5'b00100 :    
                        ( PixelCount < (Width_bar * (BarCount +4 ))  ? 5'b01000 :    
                        ( PixelCount < (Width_bar * (BarCount +5 ))  ? 5'b10000 :  5'b00000 )))));
                        
    assign  LCD_G   =   ( PixelCount < (Width_bar * (BarCount +5 )))?  6'b000000 : 
                        ( PixelCount < (Width_bar * (BarCount +6 ))  ? 6'b000001 :    
                        ( PixelCount < (Width_bar * (BarCount +7 ))  ? 6'b000010 :    
                        ( PixelCount < (Width_bar * (BarCount +8 ))  ? 6'b000100 :    
                        ( PixelCount < (Width_bar * (BarCount +9 ))  ? 6'b001000 :    
                        ( PixelCount < (Width_bar * (BarCount +10 ))  ? 6'b010000 :  
                        ( PixelCount < (Width_bar * (BarCount +11 ))  ? 6'b100000 : 6'b000000 ))))));

    assign  LCD_B   =   ( PixelCount < (Width_bar * (BarCount +11 )))?  5'b00000 : 
                        ( PixelCount < (Width_bar * (BarCount +12 ))  ? 5'b00001 :    
                        ( PixelCount < (Width_bar * (BarCount +13 ))  ? 5'b00010 :    
                        ( PixelCount < (Width_bar * (BarCount +14 ))  ? 5'b00100 :    
                        ( PixelCount < (Width_bar * (BarCount +15 ))  ? 5'b01000 :    
                        ( PixelCount < (Width_bar * (BarCount +16 ))  ? 5'b10000 :  5'b00000 )))));

endmodule