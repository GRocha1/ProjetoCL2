module piano( CLOCK_27, KEY, SW, I2C_SDAT, I2C_SCLK, AUD_ADCDAT, AUD_DACLRCK, AUD_DACDAT, AUD_BCLK, AUD_ADCLRCK, AUD_XCK, LEDR, LEDG );

	// Entradas:
		input CLOCK_27;
		input [3:0] KEY;
		input [17:0] SW;
		input AUD_ADCDAT;  // Entrada de audio.
	
	// Inout:
		inout I2C_SDAT;
	
	// Saidas:
		output I2C_SCLK;
		output AUD_DACDAT, AUD_ADCLRCK, AUD_DACLRCK; // Saidas de Audio.
		output [7:0] LEDG;
		output [17:0] LEDR;
		output reg AUD_BCLK, AUD_XCK; // Clocks, da Audio CODEC.
		
	// Parametros:
		parameter REF_CLK = 18432000; // MCLK, 18.432MHz.
		parameter SAMPLE_RATE = 48000; // 48KHz.
		parameter CHANNEL_NUM = 2; // Dual Channel.
		parameter SIN_SAMPLE_DATA = 48;
		parameter DATA_WIDTH = 16; //16 bits
	
	//Frequencia Notas Musicais: Natural ~ Afinada
			parameter DO = 2000;  // 132,000 ~ 132,000 Hz.
			parameter RE = 1900;  // 148,500 ~ 148,104 Hz.
			parameter MI = 1805;  // 165,000 ~ 166,320 Hz.
			parameter FA = 1760;  // 175,956 ~ 176,220 Hz.
			parameter SOL = 1675; // 198,000 ~ 197,736 Hz.
			parameter LA = 1595;  // 220,044 ~ 222,024 Hz.
			parameter SI = 1520;  // 247,500 ~ 249,216 Hz.
			parameter DO1 = 1485; // 264,000 ~ 264,000 Hz.
			
	// Regs:
		reg [19:0] count20;
		reg Reset;
		reg [3:0] BCK_DIV;
		reg [8:0] LRCK_1X_DIV;
		reg LRCK_1X;
		reg [3:0] SEL_Count;
		reg [11:0] count12;
		reg [7:0] Notas;
		reg SING;
		reg [DATA_WIDTH - 1:0] SOUND1, SOUND2, SOUND3;
		reg [1:0] count2;
		reg [7:0] Octave, Song1;
		reg [3:0] volume;
		
	// Funcao ... :
		i2c_codec_control u1(CLOCK_27, KEY[0], I2C_SCLK, I2C_SDAT, LEDG[7:4]);
	
	// Clock do Codec:
		always @( posedge CLOCK_27 or negedge Reset) begin
			if(!Reset)
				AUD_XCK <= 0;
			else
				AUD_XCK <= ~AUD_XCK;
		end
	
	// Delay do Reset:
		always @(posedge CLOCK_27) begin
			if( count20 != 20'hFFFFF) begin
				count20 <= count20+1;
				Reset <= 0;
			end
			else
				Reset <= 1;
		end
	
	always @( posedge AUD_XCK or negedge Reset ) begin
		if(!Reset) begin
			BCK_DIV <= 4'b0;
			AUD_BCLK <= 0;			
		end
		else begin
			if( BCK_DIV >= (REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2) - 1 ))
			begin
				BCK_DIV <= 4'b0;
				AUD_BCLK <= ~AUD_BCLK;
			end
			else 
				BCK_DIV <= BCK_DIV + 1;
		end
	end
	// Modificado aqui
	always @(posedge AUD_XCK or negedge Reset) begin
		if(!Reset) begin
			Notas <= 8'b00000000;
		end
		else begin 
			if(SW[16]) begin // SWITCH 16 = Brilha Brilha Estrelinha: 
				// line 1:
					#2  Notas <= 8'b00000001; // do
					#4  Notas <= 8'b00000001; // do
					#6  Notas <= 8'b00010000; // SOL
					#8  Notas <= 8'b00010000; // SOL
					#10 Notas <= 8'b00100000; // LA
					#12 Notas <= 8'b00100000; // LA
					#14 Notas <= 8'b00010000; // SOL
				// line 2:
					#16 Notas <= 8'b00001000; // FA
					#18 Notas <= 8'b00001000; // FA
					#20 Notas <= 8'b00000100; // MI
					#22 Notas <= 8'b00000100; // MI
					#24 Notas <= 8'b00000010; // RE
					#26 Notas <= 8'b00000010; // RE
					#28 Notas <= 8'b00000001; // do
				// line 3:
					#30 Notas <= 8'b00001000; // FA
					#32 Notas <= 8'b00001000; // FA
					#34 Notas <= 8'b00000100; // MI
					#36 Notas <= 8'b00000100; // MI
					#38 Notas <= 8'b00000010; // RE
					#40 Notas <= 8'b00000010; // RE
					#42 Notas <= 8'b00000001; // do
				// line 4:
					#44 Notas <= 8'b00001000; // FA
					#46 Notas <= 8'b00001000; // FA
					#48 Notas <= 8'b00000100; // MI
					#50 Notas <= 8'b00000100; // MI
					#52 Notas <= 8'b00000010; // RE
					#54 Notas <= 8'b00000010; // RE
					#56 Notas <= 8'b00000001; // do
				// line 5:
					#58 Notas <= 8'b00001000; // FA
					#60 Notas <= 8'b00001000; // FA
					#62 Notas <= 8'b00000100; // MI
					#64 Notas <= 8'b00000100; // MI
					#66 Notas <= 8'b00000010; // RE
					#68 Notas <= 8'b00000010; // RE
					#70 Notas <= 8'b00000001; // do
				// line 6:
					#72 Notas <= 8'b00000001; // do
					#74 Notas <= 8'b00000001; // do
					#76 Notas <= 8'b00010000; // SOL
					#78 Notas <= 8'b00010000; // SOL
					#80 Notas <= 8'b00100000; // LA
					#82 Notas <= 8'b00100000; // LA
					#84 Notas <= 8'b00010000; // SOL
			end
			
			if(SW[15]) begin // SW15 = Jingle Bells
				// line 1:
					#2  Notas <= 8'b01000000; // SI
					#4  Notas <= 8'b01000000; // SI
					#6  Notas <= 8'b01000000; // SI
				// line 2:
					#8  Notas <= 8'b01000000; // SI
					#10 Notas <= 8'b01000000; // SI
					#12 Notas <= 8'b01000000; // SI
				// line 3:
					#14 Notas <= 8'b01000000; // SI
					#16 Notas <= 8'b00000010; // RE
					#18 Notas <= 8'b00010000; // SOL
					#20 Notas <= 8'b00100000; // LA
					#22 Notas <= 8'b01000000; // SI
				// line 4:
					#24 Notas <= 8'b00000001; // DO
					#26 Notas <= 8'b00000001; // DO
					#28 Notas <= 8'b00000001; // DO
				// line 5
					#30 Notas <= 8'b00000001; // DO
					#32 Notas <= 8'b01000000; // SI
					#34 Notas <= 8'b01000000; // SI
					#36 Notas <= 8'b01000000; // SI
					#38 Notas <= 8'b01000000; // SI
					#40 Notas <= 8'b00100000; // LA
					#42 Notas <= 8'b00100000; // LA
					#44 Notas <= 8'b00010000; // SOL 
					#46 Notas <= 8'b00100000; // LA
					#48 Notas <= 8'b00000010; // RE
				// line 6:
					#50 Notas <= 8'b01000000; // SI
					#52 Notas <= 8'b01000000; // SI
					#54 Notas <= 8'b01000000; // SI
				// line 7:
					#56 Notas <= 8'b01000000; // SI
					#58 Notas <= 8'b01000000; // SI
					#60 Notas <= 8'b01000000; // SI
				// line 8:
					#62 Notas <= 8'b01000000; // SI
					#64 Notas <= 8'b00000010; // RE
					#66 Notas <= 8'b00010000; // SOL 
					#68 Notas <= 8'b00100000; // LA
					#70 Notas <= 8'b01000000; // SI
				// line 9:
					#72 Notas <= 8'b00000001; // DO
					#74 Notas <= 8'b00000001; // DO
					#76 Notas <= 8'b00000001; // DO
				// line 10:
					#78 Notas <= 8'b00000001; // DO
					#80 Notas <= 8'b00000001; // DO
					#82 Notas <= 8'b01000000; // SI
					#84 Notas <= 8'b01000000; // SI
					#86 Notas <= 8'b01000000; // SI
				// line 11:
					#88 Notas <= 8'b00000010; // RE
					#90 Notas <= 8'b00000010; // RE
					#92 Notas <= 8'b00000001; // DO
					#94 Notas <= 8'b00100000; // LA
					#96 Notas <= 8'b00010000; // SOL 
			end
		end
	end
	
	always @(posedge AUD_XCK or negedge Reset) begin
		if(!Reset) begin
			LRCK_1X_DIV <= 9'b0;
			LRCK_1X <= 1'b0;
		end 
		else begin
			if(LRCK_1X_DIV >= (REF_CLK/(SAMPLE_RATE*2) - 1)) begin
				LRCK_1X_DIV <= 9'b0;
				LRCK_1X <= ~LRCK_1X;
			end
			else
				LRCK_1X_DIV <= LRCK_1X_DIV + 1;
		end
	end
	
	assign AUD_ADCLRCK = LRCK_1X;
	assign AUD_DACLRCK = LRCK_1X;
	
	
	
	always @(negedge AUD_BCLK or negedge Reset) begin
		if( !Reset)begin
			Octave  <= 8'b00000000;
			//Octave2 <= 8'b00000000;
		end
		else
			if(SW[7:0])
				Octave <= Notas;
			else
				Octave <= SW[7:0];
	end
	
	always @(posedge AUD_BCLK or negedge Reset) begin
		if(!Reset)
			count12 <= 12'h000;
		else begin // Ah eu tirei o if daqui  e coloquei ele pra linha 233 junto com um else.
			if(Octave == 8'b00000001) begin
				if(count12 == DO)
					count12 <= 12'h00;
				else
					count12 <= count12 + 1;
			end
			if(Octave == 8'b00000010) begin
				if( count12 == RE)
					count12 <= 12'h00;
				else
					count12 <= count12 + 1;
			end
			if(Octave == 8'b00000100) begin
				if( count12 == MI)
					count12 <= 12'h00;
				else
					count12 <= count12 + 1;
			end
			if(Octave == 8'b00001000) begin
				if( count12 == FA)
					count12 <= 12'h00;
				else
					count12 <= count12 + 1;
			end
			if(Octave == 8'b00010000) begin
				if( count12 == SOL)
					count12 <= 12'h00;
				else
					count12 <= count12 + 1;
			end
			if(Octave == 8'b00100000) begin
				if( count12 == LA)
					count12 <= 12'h00;
				else
					count12 <= count12 + 1;
			end
			if(Octave == 8'b01000000) begin
				if( count12 == SI)
					count12 <= 12'h00;
				else
					count12 <= count12 + 1;
			end
			if(Octave == 8'b10000000) begin
				if( count12 == DO1)
					count12 <= 12'h00;
				else
					count12 <= count12 + 1;
			end
		end
	end
	
	assign LEDR = Octave;
	
	always @(negedge AUD_BCLK or negedge Reset) begin
		if(!Reset) begin
			SOUND1 <= 0;
			SOUND2 <= 0;
			SOUND3 <= 0;
			SING <= 1'b0;
		end
		else begin
			if(count12 == 12'h001) begin
				SOUND1 <= (SING == 1'b1)?32768+29000:32768-29000;
				SOUND2 <= (SING == 1'b1)?32768+16000:32768-16000;
				SOUND3 <= (SING == 1'b1)?32768+3000 : 32768-3000;
				SING <= ~SING;
			end
		end
	end
	
	always @(negedge KEY[3] or negedge Reset) begin
		if(!Reset)
			count2 <= 2'b00;
		else
			count2 <= count2 + 1;
	end
	
	always @(negedge AUD_BCLK or negedge Reset) begin
		if(!Reset)
			SEL_Count <= 4'b0000;
		else
			SEL_Count <= SEL_Count + 1;
	end
	
	assign AUD_DACDAT = (count2 == 2'd1)?SOUND1[~SEL_Count]:
						(count2 == 2'd2)?SOUND2[~SEL_Count]:
						(count2 == 2'd3)?SOUND3[~SEL_Count]:1'b0;
						
	always @(count2) begin
		case(count2)
			0: volume <= 4'b0000;
			1: volume <= 4'b0001;
			2: volume <= 4'b0011;
			3: volume <= 4'b1111;
			default: volume <= 4'b0000;
		endcase
	end

	assign LEDG[3:0] = volume;
	
endmodule
