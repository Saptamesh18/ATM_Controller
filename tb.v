`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2025 00:53:44
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps
module ATM_Controller_tb;

    // Inputs
    reg clk;
    reg reset;
    reg card_inserted;
    reg pin_entered;
    reg pin_correct;
    reg [1:0] transaction_choice;
    reg [15:0] amount;

    // Outputs
    wire card_retained;
    wire cash_dispensed;
    wire [15:0] balance;
    wire [2:0] state_indicator;
    wire warning_message;
    wire card_blocked;
    wire exceed_balance;

    // Instantiate the Unit Under Test (UUT)
    ATM_Controller uut (
        .clk(clk),
        .reset(reset),
        .card_inserted(card_inserted),
        .pin_entered(pin_entered),
        .pin_correct(pin_correct),
        .transaction_choice(transaction_choice),
        .amount(amount),
        .card_retained(card_retained),
        .cash_dispensed(cash_dispensed),
        .balance(balance),
        .state_indicator(state_indicator),
        .warning_message(warning_message),
        .card_blocked(card_blocked),
        .exceed_balance(exceed_balance)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequences
    initial begin
        $dumpfile("atm_controller_tb.vcd");
        $dumpvars(0, ATM_Controller_tb);

        // Initialize inputs
        clk = 0;
        reset = 1;
        card_inserted = 0;
        pin_entered = 0;
        pin_correct = 0;
        transaction_choice = 2'b00;
        amount = 0;

        // Reset
        #10 reset = 0;

        // Test 1: Correct PIN entry and Balance Inquiry
        card_inserted = 1;
        #10 pin_entered = 1;
        pin_correct = 1;
        transaction_choice = 2'b01;
        #20;

        // Test 2: Incorrect PIN entry attempt 3 times
        reset = 1; #10 reset = 0;
        card_inserted = 1;
        pin_entered = 1;
        pin_correct = 0;
        transaction_choice = 2'b00;

        // 1st attempt
        #20;

        // 2nd attempt
        pin_entered = 1;
        #20;

        // 3rd attempt -> Should block the card
        pin_entered = 1;
        #20;

        // Test 3: Cash Withdrawal
        reset = 1; #10 reset = 0;
        card_inserted = 1;
        pin_entered = 1;
        pin_correct = 1;
        transaction_choice = 2'b10;
        amount = 100;
        #40;

        $finish;
    end
endmodule

