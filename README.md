# QFP32 Arithmetic Core
implements a full customizable arithmetic core using the QFP32 format. Available arithmetic operations are easily configured by an generic flags.
The QFP32 (stands for QuadFixedPoint32) format mixture between the classical full blown FPU and the simple fixed point arithmetic.
Benefits are much less area requirements lesser pipeline depth and higher speed compared to an FPU at the cost that the number range is limited from +- 2^(-24) to 2^29.
The design is fully tested.

## Operations:
* add (2 cycles)
* sub (2 cycles)
* mul (2-3 cycles depending on multicycle constraint for higher speed)
* reciprocal (31 cycles but less LEs than divider)
* divider (31 cycles)
* fromInt/toInt (1 cycle)
* to be extended... :)

For high performance addition and comparison are implemented using carry lookahead adder. Full CLA library is included! 
