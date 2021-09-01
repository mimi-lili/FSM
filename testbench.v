module testbench ;

reg clk, reset, cancel, inputCoin, hasChosen ;
reg [7:0] coin, drink_choose ;


parameter tea = 8'd10,
          coke = 8'd15,
		  coffee = 8'd20,
		  milk = 8'd25;

FSM fsm( clk, reset, coin, drink_choose, cancel, inputCoin, hasChosen ) ;


always #5  clk = ~clk ;
initial begin
    clk = 1 ;
	// init
	reset = 1 ;
	drink_choose = 0 ;
	cancel = 0 ;
	inputCoin = 0 ; // 沒投錢=0, 投錢了=1
	hasChosen = 0 ; // 尚未選擇飲料=0, 已選擇飲料 = 1

	// B1
	$display( "Start B1\n" );
	#10 reset = 0; 
	#10 coin = 8'd10 ; inputCoin = 1 ; // 代表投錢了
	#10 coin = 8'd1 ;
	#10 coin = 8'd10 ;
	#30 drink_choose = coffee ; hasChosen = 1 ; // 選擇咖啡
	#10 inputCoin = 0 ; 
	#30 $display( "END B1\n" );
		$display( "-------------------------------------------------------------------------" );
	
	
	
	
	// init
	reset = 1 ; 
	hasChosen = 0 ;
	drink_choose = 0 ;
	cancel = 0 ;
	inputCoin = 0 ;
	#10 $display( "Start B2\n" );
	//start now!
	#10 reset = 0; 
	#10 coin = 8'd5 ; inputCoin = 1 ; 
	#10 coin = 8'd10 ;
	#10 cancel = 1 ; inputCoin = 0 ;
	#30 cancel = 0 ; coin = 8'd10 ; inputCoin = 1 ; 
	#10 coin = 8'd10 ;
	#10 coin = 8'd1 ;
	#20 coin = 8'd1 ;
	#20 coin = 8'd1 ;
	#20 coin = 8'd1 ;
	#20 coin = 8'd1 ;
	#20 drink_choose = milk ; hasChosen = 1 ;
	#10 inputCoin = 0 ;
	#30 $display( "END B2\n" );
		$display( "-------------------------------------------------------------------------" );
	
	
	
	
	
	// init
	reset = 1 ; 
	hasChosen = 0 ;
	drink_choose = 0 ;
	cancel = 0 ;
	inputCoin = 0 ;
	#10 $display( "Start B3\n" );
	//start now!
	#10 reset = 0; 
	#10 coin = 8'd5 ; inputCoin = 1 ; 
	#10 coin = 8'd10 ;
	#10 cancel = 1 ; inputCoin = 0 ;
	#30 cancel = 0 ; coin = 8'd10 ; inputCoin = 1 ; 
	#10 coin = 8'd10 ;
	#20 drink_choose = coke ; hasChosen = 1 ; // 可樂
	#10 inputCoin = 0 ; hasChosen = 0 ;
	#10 coin = 8'd10 ; inputCoin = 1 ; 
	#10 coin = 8'd10 ;
	#20 drink_choose = milk ; hasChosen = 1 ; // 牛奶
	#10 inputCoin = 0 ;hasChosen = 0;
	#10 coin = 8'd10 ; inputCoin = 1 ; 
	#10 drink_choose = tea ; hasChosen = 1 ; // 茶
	#10 inputCoin = 0 ; hasChosen = 0;
	#20 coin = 8'd50 ; inputCoin = 1 ; 	
	#10 drink_choose = coffee ; hasChosen = 1 ; // 咖啡
	#10 inputCoin = 0 ;
	#30 $display( "END B3\n" );
		
end


endmodule