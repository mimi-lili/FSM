module FSM( clk, reset, coin, drink_choose, cancel, inputCoin, hasChosen ) ;

input clk, reset, cancel, inputCoin, hasChosen ;
input [7:0] coin, drink_choose ;

reg [2:0] state ;
reg [2:0] next_state ;
reg [2:0] last_state ;
reg [7:0] total ; // 總金額
reg [7:0] new_total ; // 上一state的total
wire [7:0] tempTotal ;
reg [7:0] drink ; // drink_choose的另一個port 
reg done ; // 判斷加完這次的coin了沒
reg [7:0] last_coin ; // 上一個coin 尚未印出的coin
reg [7:0] print_coin ;  // 用來印coin的變數
reg enough ;
parameter tea = 8'd10,
          coke = 8'd15,
		  coffee = 8'd20,
		  milk = 8'd25;
		  
parameter 
		  S0 = 3'd0,
          S1 = 3'd1,
		  S2 = 3'd2,
		  S3 = 3'd3;
		  
assign tempTotal = new_total ;

always@( posedge clk ) begin
	if ( cancel ) begin
		total = tempTotal ;
		drink = total ;
		state = next_state ;
	end
	else if ( reset ) begin
		total = 0 ;
		drink = 0 ;
		state = S0 ;
		last_state = S0 ;
		next_state = S0 ;
		done = 0 ;// 判斷加完這次的coin了沒
		last_coin = -1 ;
		new_total = 0 ;
	end
	else begin
		state = next_state ;
		drink = drink_choose ;
		done = 0 ;// 判斷加完這次的coin了沒
		//last_coin <= coin ; // 要晚一round
		total = new_total ;
		//$display( "%d  (1). state: %d coin: %d, last_coin: %d, total : %d, new_total %d\n", $time/10, state, coin, total, last_coin, new_total );
	end
end

always@( state ) begin // 該state要做什麼事
	case( state ) 
		S0: begin 
				
				//$display( "%d  (2) coin: %d, total : %d\n", $time/10, coin, total );
				
			end
		S1: begin
				// 顯示可選擇的飲料有哪些
				if ( total >= milk ) $display( "tea | coke | coffee | milk\n" );
				else if ( total >= coffee ) $display( "tea | coke | coffee\n", );
				else if ( total >= coke ) $display( "tea | coke\n",  );
				else if ( total >= tea ) $display( "tea\n" );
				last_coin = coin ;
				//$display( "%d  (300) coin: %d	last_coin %d dollars", $time/10, coin, last_coin  ) ;
				total = new_total ;
		    end
		S2: begin 
				// 給飲料
				enough = 1 ;
				if ( drink_choose == tea && total >= tea ) $display( "tea out\n" );
				else if ( drink_choose == coke && total >= coke ) $display( "coke out\n" );
				else if ( drink_choose == coffee && total >= coffee ) $display( "coffee out\n" );
				else if ( drink_choose == milk && total >= milk ) $display( "milk out\n" );
				else begin // 選了 但錢不夠
					$display( "money is not enough" );	
					enough = 0 ;
				end
		    end
		S3: begin 
				// 找零
				if ( last_state == S0 || !enough ) begin
					$display( "enchange %d dollars\n", total );
					total = 0 ;
					new_total = total ;
				end
				
				else begin
					total = total - drink ;
					$display( "enchange %d dollars\n", total );
					total = 0 ;
					new_total = total ;
				end
		    end
			
	endcase
	
end
always@( state or coin or drink_choose or total or new_total ) begin // 決定下一個state
	
	case (state) 
		
		S0: begin 
				if ( last_coin == -1 ) last_coin = coin ;
				
				if ( last_state == S1 && !cancel ) begin 
					new_total = total + last_coin ; // 回來加錢
					print_coin = last_coin ;
					//$display("last_state: %d, IF! ", last_state ) ;
				end
				else if ( inputCoin && done == 0 ) begin// 有投錢 但尚未加coin
					//total = new_total ;
					new_total = total + coin ;
					done = 1 ;	// coin加完了
					print_coin = coin ;
					//$display("last_state: %d, else IF! ", last_state ) ;
				end
				else if ( done == 1 ) ;// 加完coin了
				else begin // 最開始沒投$的狀態
					new_total = total ;
					//$display("ELSE! ") ;
				end
				
				//$display( "%d  (4) new_total %d, total : %d, inputCoin: %d, done: %d\n",$time/10, new_total, total, inputCoin, done );
				
				last_state = S0 ;
				if ( cancel == 1 ) next_state = S3 ; // 如果取消 
				else if ( new_total >= tea ) next_state = S1 ; // 如果目前金額達飲料最低金額
				else next_state = S0 ; // 繼續投錢
				//$display( "%d  (5)  state: %d, next_state: %d\n", $time/10, state, next_state );
				if ( !cancel && inputCoin ) begin
					$display( "coin: %d, total: %d dollars\n", print_coin, new_total );
					//$display( "%d	coin: %d, total: %d dollars\n", $time/10, print_coin, new_total );
				end
			end
		S1: begin 
				total = new_total ;
				last_state = S1 ;
				if ( hasChosen ) begin
					if ( drink_choose > total ) begin
					    next_state = S0 ;
					end
					else begin
				        next_state = S2 ;
					end
				end
				else begin
				    next_state = S0 ;
			    end
				//$display( "%d  (5)  state: %d, next_state: %d\n", $time/10, state, next_state );
			end
		S2: begin
				last_state = S2;
				next_state = S3 ;
				//$display( "%d  (5)  state: %d, next_state: %d\n", $time/10, state, next_state );
			end
		S3: begin
				last_state = S3;
				next_state = S0 ;
				//$display( "%d  (5)  state: %d, next_state: %d\n", $time/10, state, next_state );
			end
	endcase
	
end
/*always@( state or coin or drink_choose or total or new_total ) begin // 決定下一個state
	
	case (state) 
		
		S0: begin 
				if ( last_coin == -1 ) last_coin = coin ;
				
				if ( last_state == S1 && !cancel ) begin 
					new_total = total + last_coin ; // 回來加錢
					print_coin = last_coin ;
					//$display("last_state: %d, IF! ", last_state ) ;
				end
				else if ( inputCoin && done == 0 ) begin// 有投錢 但尚未加coin
					//total = new_total ;
					new_total = total + coin ;
					done = 1 ;	// coin加完了
					print_coin = coin ;
					//$display("last_state: %d, else IF! ", last_state ) ;
				end
				else if ( done == 1 ) ;// 加完coin了
				else begin // 最開始沒投$的狀態
					new_total = total ;
					//$display("ELSE! ") ;
				end
				
				//$display( "%d  (4) new_total %d, total : %d, inputCoin: %d, done: %d\n",$time/10, new_total, total, inputCoin, done );
				
				last_state = S0 ;
				if ( cancel == 1 ) next_state = S3 ; // 如果取消 
				else if ( new_total >= tea ) next_state = S1 ; // 如果目前金額達飲料最低金額
				else next_state = S0 ; // 繼續投錢
				//$display( "%d  (5)  state: %d, next_state: %d\n", $time/10, state, next_state );
				if ( !cancel && inputCoin ) begin
					$display( "coin: %d, total: %d dollars\n", print_coin, new_total );
					//$display( "%d	coin: %d, total: %d dollars\n", $time/10, print_coin, new_total );
				end
			end
		S1: begin 
				total = new_total ;
				last_state = S1 ;
				if ( hasChosen ) next_state = S2 ;
				else next_state = S0 ;
				//$display( "%d  (5)  state: %d, next_state: %d\n", $time/10, state, next_state );
			end
		S2: begin
				last_state = S2;
				next_state = S3 ;
				//$display( "%d  (5)  state: %d, next_state: %d\n", $time/10, state, next_state );
			end
		S3: begin
				last_state = S3;
				next_state = S0 ;
				//$display( "%d  (5)  state: %d, next_state: %d\n", $time/10, state, next_state );
			end
	endcase
	
end
*/

always@(posedge inputCoin ) begin
	last_coin = coin ;


end
endmodule