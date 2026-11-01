OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x00000000;
  .text.start /*ORIGIN(RAM)*/ : {
      LONG(_space_for_stack);
      LONG(_start)
  }
  . = 0x00000200;
  .text.init : { *(.text.init) }
  . = ALIGN(0x10);
  .tohost : { *(.tohost) }
  . = ALIGN(0x10);
  .text : { *(.text) }
  . = ALIGN(0x10);
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
  . = ALIGN(0x10);
  _space_for_stack = . + 0x100;
}

