# CPU Designs Library

This repository contains all relevant info about (most) processor architectures I designed. That includes schematics, assemblers, code examples, and detailed instruction set documentations.

### Contents

- MAPLU 1: [Puny Processing Unit](ppu)
- MAPLU 2: [Smolproc](smolproc)
- MAPLU 3: [PHINIX](phinix)
- MAPLU 4: PHINIX+ (Planned)
- MAPLU 5: Pipedream (Planned)

## A few words for each architecture

### Puny Processing Unit

    The PPU was concieved from the task I had laid out to create a Harvard memory layout architecture that
    would minimise the bits an instruction word would use. In the end that was 10 bits though with many
    compromises in the maximum sizes of the memory. (64 program locations, 16 data locations)
    
    It of course had some other quirks like an unheard-of 2-operand + accumulator system in which
    an ADD would be done like this: [Dst = Acc + Src] where as contemporary 2-operand architectures
    like x86 would do it like this: [Dst = Dst + Src]. There is no real reason for this decision other
    than I was naive and had no meaningful designing experience at that time.

### Smolproc

    The Smolproc was the first processor that I designed to feature a pipeline. It was a proof-of-concept
    that eventually even ended up on an FPGA. The architecture itself was based off of a predescessor of
    PHINIX which got scaled down from 16 to 8 bits. Due to the pipeline layout the system could be set up
    with a Harvard or a Von Neumann layout if a 2-port memory was available.
    
    The instructions use the contemporary 2-operand system and are able to address 256 words (bytes)
    of memory and are variable in size. That is because it is the simplest way to get a full 8 bits
    immediate using word-based instructions. So in effect every instruction that needed an immediate
    would be 2 words in size. This would cause a NOP to be generated in the pipeline during that
    instruction's execution. Due to a happy accident, all memory operations are 2 words, which totally
    eliminated the possibility of a memory dependency requiring a stall. As a result, Smolproc never stalls
    and its forwarding system is complete. The branch delay slots were left in, however.

### PHINIX

    The Pipelined INteger Instruction eXecutor is the processor that ended up emerging after the
    development of the architecture that Smolproc was based off of continued. It features an even
    deeper 6 stage pipeline with a dual write register file and a word size of 16 bits.

### PHINIX+

    PHINIX+ is a successor to PHINIX for which are planned various tweaks to improve performace.
    Namely a Predicate instruction is planned to be included to reduce the slowdowns of full sized branches
    and also the dual-write register file is planned to be scaled back down to single-write due to the
    complexity of forwarding.

### Pipedream

    Pipedream is the culmination of my current aspirations for a semi-modern processor featuring
    a modern modified Harvard memory layout, virtual memory, privalege levels, interrupts and many more.
    It rightfully deserves that name due to its purely hypotherical status.
