/* 
 * Control Unit for simple 8-bit CPU.
*/

module control (input clk, reset, interrupt,
                input [7:0] datamem_data, datamem_address, regfile_out1, regfile_out2, alu_out,
		        output reg [3:0] alu_opcode,
                output reg [7:0] regfile_data, output [7:0] usermem_data,
                output reg [1:0] regfile_read1, regfile_read2, regfile_writereg,
                output reg [7:0] usermem_address, pc_jmpaddr,
                output reg rw, regfile_regwrite, pc_jump);
        /* Flags */
	reg [1:0] state;
    reg [1:0] nextState;
    reg [7:0] instruction_c;
	reg [7:0] instruction;
	reg [7:0] prevaddr;
    reg [7:0] umd;
    reg is_onecyc, is_rts, is_nop;
    
    /* states */ 
    parameter state0 = 2'b00;
    parameter state1 = 2'b10;
    parameter state2 = 2'b10;
    parameter stateISR = 2'b11; //state 3 

    assign usermem_data=rw?umd:8'bz;

    always @(state or is_onecyc or is_rts or pc_jump or is_nop or reset) 
    begin : controlFSM
    next_state <= state0; 
      begin
      case(state)
     State0: if (state == state0) begin
        instruction_c<=datamem_data;
        is_onecyc <= (datamem_data[7:4] <= 4'h7);
        is_rts <= (datamem_data == 4'hb);
      end
    //end
        always @(posedge clk)
        /* Check for reset*/
        if(reset == 1)
        begin
                {instruction, alu_opcode, regfile_data, umd, usermem_address} <= 8'b0;
                {regfile_read1, regfile_read2, regfile_writereg} <= 3'b0;
                {rw, regfile_regwrite, pc_jump} <= 1'b0;
		stage <= state0;
        end
	else if(interrupt == 1)
	   begin
		state <= stateISR; 
        prevaddr <= datamem_address;
		pc_jump <= 1;
        pc_jmpaddr <= 8'hfe;
	   end
    end    
        /* Stage 1: Fetch instruction, execute it in case it does not require an operand: */
        //  $display("Stage 1!");

      State 1:(state == state1)
    begin
	pc_jump <= 0;
    rw <=0 ;
	instruction <= datamem_data;
          if (is_onecyc)
	begin
		rw <= 0;
        regfile_regwrite <= 1;
        regfile_read1 <= instruction_c[3:2];
        regfile_read2 <= instruction_c[1:0];
        alu_opcode <= instruction_c[7:4];
		regfile_writereg <= instruction_c[1:0];
		regfile_data <= alu_out;
		state <= state0;
    end
        
        else if (is_onecyc == 0)
                if (is_rts) /* RTS */
                begin
                    pc_jump <= 1;
                    regfile_regwrite <= 0;
                    pc_jmpaddr <= prevaddr + 1;
                    stage <= state2;
                end
                else if (is_rts == 0)
                    if (is_nop) /* NOP */
                        stage <= state0;
                    else /* Execute dual-cycle instruction */
                        stage <= state1;
        end
	/* Stage 2: Fetch the operand and execute the relevant instruction: */
	State0: if (state == state1)
	begin
  //    $display("Stage 2!");

      case (instruction_c[7:4])
                        4'h8 /* LD */:
                        begin
                                rw <= 0;
                                regfile_writereg <= instruction[1:0];
                                regfile_regwrite <= 1;
                                regfile_data <= datamem_data;
                        end
                        4'h9 /* JMP */:
                        begin
                                rw <= 0;
                                pc_jump <= 1;
                                pc_jmpaddr <= datamem_data;
                        end
			4'ha /* CALL */:
			begin
                                rw <= 0;
				prevaddr <= datamem_address + 1;
                                pc_jump <= 1;
                                pc_jmpaddr <= datamem_data;
			end
                        4'hc /* BEQ */:
                        begin
                                rw <= 0;
                                regfile_regwrite <= 0;
                                regfile_read1 <= instruction[3:2];
                                regfile_read2 <= instruction[1:0];
                                if(regfile_out1 == regfile_out2)
                                begin
					prevaddr <= datamem_address + 1;
				        pc_jump <= 1;
                                        pc_jmpaddr <= datamem_data;
                                end
                        end
			4'hd /* BNE */:
			begin
                                rw <= 0;
                                regfile_regwrite <= 0;
                                regfile_read1 <= instruction[3:2];
                                regfile_read2 <= instruction[1:0];
                                if(regfile_out1 != regfile_out2)
                                begin
					prevaddr <= datamem_address + 1;
				        pc_jump <= 1;
                                        pc_jmpaddr <= datamem_data;
                                end
			end
			4'he /* ST */:
			begin
				rw <= 1;
				usermem_address <= datamem_data;
                                regfile_read1 <= instruction[3:2];
				umd <= regfile_out1;
			end
			4'hf /* LDUMEM */:
			begin
                                rw <= 0;
				usermem_address <= datamem_data;
                                regfile_writereg <= instruction[1:0];
                                regfile_regwrite <= 1;
                                regfile_data <= usermem_data;
			end
		endcase
		stage <= 2'h0;
	end
endmodule //control


module pc(input clk, reset, jump,
          input [7:0] jmpaddr,
          output reg[7:0] data);
	 
	always @(posedge clk) begin
	if (reset == 1)
		data <= 8'b0;
	else if (reset == 0)
	begin
		if (jump == 1)
			data <= jmpaddr;
		else if (jump == 0)
			data <= data + 1;
	end
	end
endmodule //pc
