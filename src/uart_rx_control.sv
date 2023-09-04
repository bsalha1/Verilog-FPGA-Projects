`timescale 1ns / 1ps

module uart_rx_control
    #(
        parameter int unsigned BAUD_DIVISOR = 1024,
        parameter byte unsigned OVERSAMPLING = 8,
        parameter byte unsigned FRAME_SIZE = 8
    )
    (
        input wire clk,
        input wire rx,
        output wire [FRAME_SIZE - 1:0] rx_data,
        output wire rx_complete
    );

    /*
     * Generate the clock that ticks the UART RX interface. This will
     * run at freq = 2 * oversampling * baud rate.
     */
    logic rx_clk;
    clock_divider #(.DIVISOR(BAUD_DIVISOR / OVERSAMPLING / 2))
        rx_clock_divider
    (
        .clk_in(clk), .clk_out(rx_clk)
    );

    /*
     * State machine state.
     */
    typedef enum {IDLE, START_BIT, DATA, STOP_BIT, COMPLETE} uart_state;
    uart_state state = IDLE;

    /*
     * State machine variables.
     */
    logic [FRAME_SIZE-1:0] data = 0;
    logic [FRAME_SIZE-1:0] data_working = 0;
    byte unsigned oversampler_count = 0;
    byte unsigned bit_index = 0;
    bit complete = 0;

    /*
     * Latch internal registers to output.
     */
    assign rx_data = data;
    assign rx_complete = complete;

    /*
     * UART RX state machine.
     */
    always @(posedge rx_clk) begin
        case (state)

            IDLE: begin

                /*
                 * Reset all the stateful variables except "data" so that other
                 * peripherals can use the previous "data".
                 */
                data_working <= 0;
                oversampler_count <= 0;
                bit_index <= 0;
                complete <= 0;

                /*
                 * Once RX line goes low, this is the start bit.
                 */
                if (rx == 0) begin
                    state <= START_BIT;
                end
            end

            START_BIT: begin

                /*
                 * If RX line is still low (we are still in start bit), then
                 * oversample until we are in the middle of the start bit. This
                 * will allow us to sample the middle of every bit.
                 */
                if (rx == 0) begin
                    if (oversampler_count == (OVERSAMPLING - 1) / 2) begin
                        oversampler_count <= 0;
                        state <= DATA;
                    end
                    else begin
                        oversampler_count <= oversampler_count + 1;
                    end
                end
                else begin
                    state <= IDLE;
                end
            end

            DATA: begin

                /*
                 * If we oversampled the current bit enough, then either move
                 * to the next bit if there is another bit, or wait for stop bit.
                 */
                if (oversampler_count == OVERSAMPLING - 1) begin
                    oversampler_count <= 0;
                    data_working[bit_index] <= rx;

                    /*
                     * If we have received the whole frame, wait for the stop
                     * bit.
                     */
                    if (bit_index == FRAME_SIZE - 1) begin
                        state <= STOP_BIT;
                    end
                    /*
                     * Otherwise, increment to the next bit to be received.
                     */
                    else begin
                        bit_index <= bit_index + 1;
                    end
                end
                else begin
                    oversampler_count <= oversampler_count + 1;
                end
            end

            STOP_BIT: begin

                /*
                 * Sample middle of stop bit.
                 */
                if (oversampler_count == OVERSAMPLING - 1) begin

                    /*
                     * If the line is high, then this is a valid stop bit, so mark the transaction as complete
                     * and transition back to IDLE.
                     */
                    if (rx == 1) begin
                        complete <= 1;
                        data <= data_working;
                        state <= IDLE;
                    end
                    /*
                     * Otherwise, this is an invalid stop bit, so transition to IDLE.
                     */
                    else begin
                        state <= IDLE;
                    end
                end
                else begin
                    oversampler_count <= oversampler_count + 1;
                end
            end

        endcase
    end
endmodule
