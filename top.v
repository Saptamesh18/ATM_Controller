module ATM_Controller (
    input clk,
    input reset,
    input card_inserted,
    input pin_entered,
    input pin_correct,
    input [1:0] transaction_choice, // 2'b00: Idle, 2'b01: Balance, 2'b10: Withdrawal
    input [15:0] amount,
    output reg cash_dispensed,
    output reg [15:0] balance,
    output  [2:0] state_indicator,
    output reg warning_message,
    output reg card_blocked,
    output reg exceed_balance
);

// State Encoding
localparam IDLE        = 3'd0,
           CARD_INSERTED = 3'd1,
           CHECK_PIN     = 3'd2,
           TRANSACTION   = 3'd3,
           BALANCE_INQ   = 3'd4,
           CASH_WITHDRAW = 3'd5,
           DISPENSE_CASH = 3'd6,
           EJECT_CARD    = 3'd7;

reg [2:0] state, next_state;
reg [1:0] pin_attempts;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        pin_attempts <= 0;
        card_retained <= 0;
        cash_dispensed <= 0;
        warning_message <= 0;
        card_blocked <= 0;
    end else begin
        state <= next_state;
    end
end

// Next State Logic
always @(*) begin
    next_state = state;
    card_retained = 0;
    cash_dispensed = 0;
    warning_message = 0;
    card_blocked = 0;

    case (state)
        IDLE:
            if (card_inserted)
                next_state = CARD_INSERTED;

        CARD_INSERTED:
            if (pin_entered)
                next_state = CHECK_PIN;
            else
                next_state = EJECT_CARD;

        CHECK_PIN: begin
            if (pin_correct)
                next_state = TRANSACTION;
            else if (pin_attempts >= 2)
                next_state = EJECT_CARD;
            else
                next_state = CARD_INSERTED;
        end

        TRANSACTION:
            case (transaction_choice)
                2'b01: next_state = BALANCE_INQ;
                2'b10: next_state = CASH_WITHDRAW;
                default: next_state = EJECT_CARD;
            endcase

        BALANCE_INQ:
            next_state = EJECT_CARD;

        CASH_WITHDRAW:
            if (amount <= balance)
                next_state = DISPENSE_CASH;
            else
                begin
                exceed_balance <= 1;
                next_state =TRANSACTION;
                end

        DISPENSE_CASH:
            next_state = EJECT_CARD;

        EJECT_CARD:
            next_state = IDLE;

        default:
            next_state = IDLE;
    endcase
end

// Output and State-Dependent Logic
always @(posedge clk) begin
    if (reset) begin
        balance <= 1000;
        card_retained <= 0;
        cash_dispensed <= 0;
        pin_attempts <= 0;
        warning_message <= 0;
        card_blocked <= 0;
    end else begin
        case (state)
            CHECK_PIN: begin
                if (pin_correct)
                    pin_attempts <= 0;
                else begin
                    pin_attempts <= pin_attempts + 1;
                    warning_message <= 1;
                    if (pin_attempts >= 2)
                        card_blocked <= 1;
                end
            end

            DISPENSE_CASH: begin
                balance <= balance - amount;
                cash_dispensed <= 1;
            end

            EJECT_CARD: begin
                cash_dispensed <= 0;
                pin_attempts <= 0; // reset attempts after card eject
                card_retained <= 0;
                warning_message <= 0;
                card_blocked <= 0;
            end
        endcase
    end
end

assign state_indicator = state;

endmodule
