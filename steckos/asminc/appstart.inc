.macro appstart __S
__LOADADDR__ = __S
.export __LOADADDR__
.segment "LOADADDR"
.word __LOADADDR__
.code
.endmacro