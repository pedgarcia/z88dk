; $Id: bit_open_di.asm,v 1.2 2013-10-21 14:23:45 stefano Exp $
;
; Enterprise 64/128 1 bit sound functions
;
; (Open sound port) and disable interrupts for exact timing
;
; Stefano Bodrato - 2011
;


    XLIB     bit_open_di
    XREF     snd_tick
    XREF     bit_irqstatus

    INCLUDE  "games/games.inc"
    
.bit_open_di
        
        ld a,i		; get the current status of the irq line
        di
        push af
        
        ex (sp),hl
        ld (bit_irqstatus),hl
        pop hl
        
		ld      a,@00001000	; Set D/A mode on left channel
		out     ($A7),a
        ld  a,(snd_tick)
        ret
