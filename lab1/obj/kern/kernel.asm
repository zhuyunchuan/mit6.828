
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <_start>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 00 11 00 	lgdtl  0x110018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100033:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100038:	e8 ff 00 00 00       	call   f010013c <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f0100046:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100049:	89 44 24 08          	mov    %eax,0x8(%esp)
f010004d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100050:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100054:	c7 04 24 80 1a 10 f0 	movl   $0xf0101a80,(%esp)
f010005b:	e8 db 08 00 00       	call   f010093b <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 96 08 00 00       	call   f0100908 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 2b 1b 10 f0 	movl   $0xf0101b2b,(%esp)
f0100079:	e8 bd 08 00 00       	call   f010093b <cprintf>
	va_end(ap);
}
f010007e:	c9                   	leave  
f010007f:	c3                   	ret    

f0100080 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100080:	55                   	push   %ebp
f0100081:	89 e5                	mov    %esp,%ebp
f0100083:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f0100086:	83 3d 20 03 11 f0 00 	cmpl   $0x0,0xf0110320
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 20 03 11 f0       	mov    %eax,0xf0110320

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 9a 1a 10 f0 	movl   $0xf0101a9a,(%esp)
f01000ac:	e8 8a 08 00 00       	call   f010093b <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 45 08 00 00       	call   f0100908 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 2b 1b 10 f0 	movl   $0xf0101b2b,(%esp)
f01000ca:	e8 6c 08 00 00       	call   f010093b <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 d7 06 00 00       	call   f01007b2 <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	53                   	push   %ebx
f01000e1:	83 ec 14             	sub    $0x14,%esp
f01000e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f01000e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000eb:	c7 04 24 b2 1a 10 f0 	movl   $0xf0101ab2,(%esp)
f01000f2:	e8 44 08 00 00       	call   f010093b <cprintf>
	if (x > 0)
f01000f7:	85 db                	test   %ebx,%ebx
f01000f9:	7e 0f                	jle    f010010a <test_backtrace+0x2d>
		test_backtrace(x-1);
f01000fb:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01000fe:	89 04 24             	mov    %eax,(%esp)
f0100101:	e8 d7 ff ff ff       	call   f01000dd <test_backtrace>
f0100106:	66 90                	xchg   %ax,%ax
f0100108:	eb 1c                	jmp    f0100126 <test_backtrace+0x49>
	else
		mon_backtrace(0, 0, 0);
f010010a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100111:	00 
f0100112:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100119:	00 
f010011a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100121:	e8 7a 05 00 00       	call   f01006a0 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100126:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010012a:	c7 04 24 ce 1a 10 f0 	movl   $0xf0101ace,(%esp)
f0100131:	e8 05 08 00 00       	call   f010093b <cprintf>
}
f0100136:	83 c4 14             	add    $0x14,%esp
f0100139:	5b                   	pop    %ebx
f010013a:	5d                   	pop    %ebp
f010013b:	c3                   	ret    

f010013c <i386_init>:

void
i386_init(void)
{
f010013c:	55                   	push   %ebp
f010013d:	89 e5                	mov    %esp,%ebp
f010013f:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100142:	b8 80 09 11 f0       	mov    $0xf0110980,%eax
f0100147:	2d 20 03 11 f0       	sub    $0xf0110320,%eax
f010014c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100150:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100157:	00 
f0100158:	c7 04 24 20 03 11 f0 	movl   $0xf0110320,(%esp)
f010015f:	e8 05 14 00 00       	call   f0101569 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100164:	e8 45 03 00 00       	call   f01004ae <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100169:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100170:	00 
f0100171:	c7 04 24 e9 1a 10 f0 	movl   $0xf0101ae9,(%esp)
f0100178:	e8 be 07 00 00       	call   f010093b <cprintf>




	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010017d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100184:	e8 54 ff ff ff       	call   f01000dd <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100190:	e8 1d 06 00 00       	call   f01007b2 <monitor>
f0100195:	eb f2                	jmp    f0100189 <i386_init+0x4d>
	...

f01001a0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	ec                   	in     (%dx),%al
f01001aa:	ec                   	in     (%dx),%al
f01001ab:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001ac:	5d                   	pop    %ebp
f01001ad:	c3                   	ret    

f01001ae <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001ae:	55                   	push   %ebp
f01001af:	89 e5                	mov    %esp,%ebp
f01001b1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001b7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01001bc:	a8 01                	test   $0x1,%al
f01001be:	74 09                	je     f01001c9 <serial_proc_data+0x1b>
f01001c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001c5:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001c6:	0f b6 d0             	movzbl %al,%edx
}
f01001c9:	89 d0                	mov    %edx,%eax
f01001cb:	5d                   	pop    %ebp
f01001cc:	c3                   	ret    

f01001cd <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001cd:	55                   	push   %ebp
f01001ce:	89 e5                	mov    %esp,%ebp
f01001d0:	57                   	push   %edi
f01001d1:	56                   	push   %esi
f01001d2:	53                   	push   %ebx
f01001d3:	83 ec 0c             	sub    $0xc,%esp
f01001d6:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001d8:	be 64 05 11 f0       	mov    $0xf0110564,%esi
f01001dd:	bf 60 03 11 f0       	mov    $0xf0110360,%edi
f01001e2:	eb 1f                	jmp    f0100203 <cons_intr+0x36>
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
f01001e4:	85 c0                	test   %eax,%eax
f01001e6:	74 1b                	je     f0100203 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001e8:	8b 16                	mov    (%esi),%edx
f01001ea:	88 04 17             	mov    %al,(%edi,%edx,1)
f01001ed:	83 c2 01             	add    $0x1,%edx
		if (cons.wpos == CONSBUFSIZE)
f01001f0:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001f6:	0f 94 c0             	sete   %al
f01001f9:	0f b6 c0             	movzbl %al,%eax
f01001fc:	83 e8 01             	sub    $0x1,%eax
f01001ff:	21 c2                	and    %eax,%edx
f0100201:	89 16                	mov    %edx,(%esi)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100203:	ff d3                	call   *%ebx
f0100205:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100208:	75 da                	jne    f01001e4 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010020a:	83 c4 0c             	add    $0xc,%esp
f010020d:	5b                   	pop    %ebx
f010020e:	5e                   	pop    %esi
f010020f:	5f                   	pop    %edi
f0100210:	5d                   	pop    %ebp
f0100211:	c3                   	ret    

f0100212 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100212:	55                   	push   %ebp
f0100213:	89 e5                	mov    %esp,%ebp
f0100215:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100218:	b8 a1 05 10 f0       	mov    $0xf01005a1,%eax
f010021d:	e8 ab ff ff ff       	call   f01001cd <cons_intr>
}
f0100222:	c9                   	leave  
f0100223:	c3                   	ret    

f0100224 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100224:	55                   	push   %ebp
f0100225:	89 e5                	mov    %esp,%ebp
f0100227:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010022a:	83 3d 44 03 11 f0 00 	cmpl   $0x0,0xf0110344
f0100231:	74 0a                	je     f010023d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100233:	b8 ae 01 10 f0       	mov    $0xf01001ae,%eax
f0100238:	e8 90 ff ff ff       	call   f01001cd <cons_intr>
}
f010023d:	c9                   	leave  
f010023e:	c3                   	ret    

f010023f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010023f:	55                   	push   %ebp
f0100240:	89 e5                	mov    %esp,%ebp
f0100242:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100245:	e8 da ff ff ff       	call   f0100224 <serial_intr>
	kbd_intr();
f010024a:	e8 c3 ff ff ff       	call   f0100212 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010024f:	a1 60 05 11 f0       	mov    0xf0110560,%eax
f0100254:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100259:	3b 05 64 05 11 f0    	cmp    0xf0110564,%eax
f010025f:	74 21                	je     f0100282 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100261:	0f b6 88 60 03 11 f0 	movzbl -0xfeefca0(%eax),%ecx
f0100268:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.rpos == CONSBUFSIZE)
f010026b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100271:	0f 94 c0             	sete   %al
f0100274:	0f b6 c0             	movzbl %al,%eax
f0100277:	83 e8 01             	sub    $0x1,%eax
f010027a:	21 c2                	and    %eax,%edx
f010027c:	89 15 60 05 11 f0    	mov    %edx,0xf0110560
		return c;
	}
	return 0;
}
f0100282:	89 c8                	mov    %ecx,%eax
f0100284:	c9                   	leave  
f0100285:	c3                   	ret    

f0100286 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100286:	55                   	push   %ebp
f0100287:	89 e5                	mov    %esp,%ebp
f0100289:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010028c:	e8 ae ff ff ff       	call   f010023f <cons_getc>
f0100291:	85 c0                	test   %eax,%eax
f0100293:	74 f7                	je     f010028c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100295:	c9                   	leave  
f0100296:	c3                   	ret    

f0100297 <iscons>:

int
iscons(int fdnum)
{
f0100297:	55                   	push   %ebp
f0100298:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010029a:	b8 01 00 00 00       	mov    $0x1,%eax
f010029f:	5d                   	pop    %ebp
f01002a0:	c3                   	ret    

f01002a1 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002a1:	55                   	push   %ebp
f01002a2:	89 e5                	mov    %esp,%ebp
f01002a4:	57                   	push   %edi
f01002a5:	56                   	push   %esi
f01002a6:	53                   	push   %ebx
f01002a7:	83 ec 1c             	sub    $0x1c,%esp
f01002aa:	89 c7                	mov    %eax,%edi
f01002ac:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002b1:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002b2:	a8 20                	test   $0x20,%al
f01002b4:	75 21                	jne    f01002d7 <cons_putc+0x36>
f01002b6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002bb:	be fd 03 00 00       	mov    $0x3fd,%esi
	     i++)
		delay();
f01002c0:	e8 db fe ff ff       	call   f01001a0 <delay>
f01002c5:	89 f2                	mov    %esi,%edx
f01002c7:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002c8:	a8 20                	test   $0x20,%al
f01002ca:	75 0b                	jne    f01002d7 <cons_putc+0x36>
	     i++)
f01002cc:	83 c3 01             	add    $0x1,%ebx
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002cf:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002d5:	75 e9                	jne    f01002c0 <cons_putc+0x1f>
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01002d7:	89 fa                	mov    %edi,%edx
f01002d9:	88 55 f3             	mov    %dl,-0xd(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002dc:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002e1:	89 f8                	mov    %edi,%eax
f01002e3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e4:	b2 79                	mov    $0x79,%dl
f01002e6:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002e7:	84 c0                	test   %al,%al
f01002e9:	78 21                	js     f010030c <cons_putc+0x6b>
f01002eb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002f0:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01002f5:	e8 a6 fe ff ff       	call   f01001a0 <delay>
f01002fa:	89 f2                	mov    %esi,%edx
f01002fc:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002fd:	84 c0                	test   %al,%al
f01002ff:	78 0b                	js     f010030c <cons_putc+0x6b>
f0100301:	83 c3 01             	add    $0x1,%ebx
f0100304:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010030a:	75 e9                	jne    f01002f5 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010030c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100311:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100315:	ee                   	out    %al,(%dx)
f0100316:	b2 7a                	mov    $0x7a,%dl
f0100318:	b8 0d 00 00 00       	mov    $0xd,%eax
f010031d:	ee                   	out    %al,(%dx)
f010031e:	b8 08 00 00 00       	mov    $0x8,%eax
f0100323:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100324:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010032a:	75 06                	jne    f0100332 <cons_putc+0x91>
		c |= 0x0700;
f010032c:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100332:	89 f8                	mov    %edi,%eax
f0100334:	25 ff 00 00 00       	and    $0xff,%eax
f0100339:	83 f8 09             	cmp    $0x9,%eax
f010033c:	0f 84 85 00 00 00    	je     f01003c7 <cons_putc+0x126>
f0100342:	83 f8 09             	cmp    $0x9,%eax
f0100345:	7f 0b                	jg     f0100352 <cons_putc+0xb1>
f0100347:	83 f8 08             	cmp    $0x8,%eax
f010034a:	0f 85 ab 00 00 00    	jne    f01003fb <cons_putc+0x15a>
f0100350:	eb 18                	jmp    f010036a <cons_putc+0xc9>
f0100352:	83 f8 0a             	cmp    $0xa,%eax
f0100355:	8d 76 00             	lea    0x0(%esi),%esi
f0100358:	74 43                	je     f010039d <cons_putc+0xfc>
f010035a:	83 f8 0d             	cmp    $0xd,%eax
f010035d:	8d 76 00             	lea    0x0(%esi),%esi
f0100360:	0f 85 95 00 00 00    	jne    f01003fb <cons_putc+0x15a>
f0100366:	66 90                	xchg   %ax,%ax
f0100368:	eb 3b                	jmp    f01003a5 <cons_putc+0x104>
	case '\b':
		if (crt_pos > 0) {
f010036a:	0f b7 05 50 03 11 f0 	movzwl 0xf0110350,%eax
f0100371:	66 85 c0             	test   %ax,%ax
f0100374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100378:	0f 84 e8 00 00 00    	je     f0100466 <cons_putc+0x1c5>
			crt_pos--;
f010037e:	83 e8 01             	sub    $0x1,%eax
f0100381:	66 a3 50 03 11 f0    	mov    %ax,0xf0110350
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100387:	0f b7 c0             	movzwl %ax,%eax
f010038a:	89 fa                	mov    %edi,%edx
f010038c:	b2 00                	mov    $0x0,%dl
f010038e:	83 ca 20             	or     $0x20,%edx
f0100391:	8b 0d 4c 03 11 f0    	mov    0xf011034c,%ecx
f0100397:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010039b:	eb 7b                	jmp    f0100418 <cons_putc+0x177>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010039d:	66 83 05 50 03 11 f0 	addw   $0x50,0xf0110350
f01003a4:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003a5:	0f b7 05 50 03 11 f0 	movzwl 0xf0110350,%eax
f01003ac:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003b2:	c1 e8 10             	shr    $0x10,%eax
f01003b5:	66 c1 e8 06          	shr    $0x6,%ax
f01003b9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003bc:	c1 e0 04             	shl    $0x4,%eax
f01003bf:	66 a3 50 03 11 f0    	mov    %ax,0xf0110350
f01003c5:	eb 51                	jmp    f0100418 <cons_putc+0x177>
		break;
	case '\t':
		cons_putc(' ');
f01003c7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cc:	e8 d0 fe ff ff       	call   f01002a1 <cons_putc>
		cons_putc(' ');
f01003d1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d6:	e8 c6 fe ff ff       	call   f01002a1 <cons_putc>
		cons_putc(' ');
f01003db:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e0:	e8 bc fe ff ff       	call   f01002a1 <cons_putc>
		cons_putc(' ');
f01003e5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ea:	e8 b2 fe ff ff       	call   f01002a1 <cons_putc>
		cons_putc(' ');
f01003ef:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f4:	e8 a8 fe ff ff       	call   f01002a1 <cons_putc>
f01003f9:	eb 1d                	jmp    f0100418 <cons_putc+0x177>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003fb:	0f b7 05 50 03 11 f0 	movzwl 0xf0110350,%eax
f0100402:	0f b7 c8             	movzwl %ax,%ecx
f0100405:	8b 15 4c 03 11 f0    	mov    0xf011034c,%edx
f010040b:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010040f:	83 c0 01             	add    $0x1,%eax
f0100412:	66 a3 50 03 11 f0    	mov    %ax,0xf0110350
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100418:	66 81 3d 50 03 11 f0 	cmpw   $0x7cf,0xf0110350
f010041f:	cf 07 
f0100421:	76 43                	jbe    f0100466 <cons_putc+0x1c5>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100423:	8b 15 4c 03 11 f0    	mov    0xf011034c,%edx
f0100429:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100430:	00 
f0100431:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f0100437:	89 44 24 04          	mov    %eax,0x4(%esp)
f010043b:	89 14 24             	mov    %edx,(%esp)
f010043e:	e8 8d 11 00 00       	call   f01015d0 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100443:	8b 15 4c 03 11 f0    	mov    0xf011034c,%edx
f0100449:	b8 80 07 00 00       	mov    $0x780,%eax
f010044e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100454:	83 c0 01             	add    $0x1,%eax
f0100457:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010045c:	75 f0                	jne    f010044e <cons_putc+0x1ad>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010045e:	66 83 2d 50 03 11 f0 	subw   $0x50,0xf0110350
f0100465:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100466:	8b 35 48 03 11 f0    	mov    0xf0110348,%esi
f010046c:	89 f3                	mov    %esi,%ebx
f010046e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100476:	0f b7 0d 50 03 11 f0 	movzwl 0xf0110350,%ecx
f010047d:	83 c6 01             	add    $0x1,%esi
f0100480:	89 c8                	mov    %ecx,%eax
f0100482:	66 c1 e8 08          	shr    $0x8,%ax
f0100486:	89 f2                	mov    %esi,%edx
f0100488:	ee                   	out    %al,(%dx)
f0100489:	b8 0f 00 00 00       	mov    $0xf,%eax
f010048e:	89 da                	mov    %ebx,%edx
f0100490:	ee                   	out    %al,(%dx)
f0100491:	89 c8                	mov    %ecx,%eax
f0100493:	89 f2                	mov    %esi,%edx
f0100495:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100496:	83 c4 1c             	add    $0x1c,%esp
f0100499:	5b                   	pop    %ebx
f010049a:	5e                   	pop    %esi
f010049b:	5f                   	pop    %edi
f010049c:	5d                   	pop    %ebp
f010049d:	c3                   	ret    

f010049e <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010049e:	55                   	push   %ebp
f010049f:	89 e5                	mov    %esp,%ebp
f01004a1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01004a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01004a7:	e8 f5 fd ff ff       	call   f01002a1 <cons_putc>
}
f01004ac:	c9                   	leave  
f01004ad:	c3                   	ret    

f01004ae <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ae:	55                   	push   %ebp
f01004af:	89 e5                	mov    %esp,%ebp
f01004b1:	57                   	push   %edi
f01004b2:	56                   	push   %esi
f01004b3:	53                   	push   %ebx
f01004b4:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004b7:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01004bc:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01004bf:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01004c4:	0f b7 00             	movzwl (%eax),%eax
f01004c7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004cb:	74 11                	je     f01004de <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01004cd:	c7 05 48 03 11 f0 b4 	movl   $0x3b4,0xf0110348
f01004d4:	03 00 00 
f01004d7:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01004dc:	eb 16                	jmp    f01004f4 <cons_init+0x46>
	} else {
		*cp = was;
f01004de:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01004e5:	c7 05 48 03 11 f0 d4 	movl   $0x3d4,0xf0110348
f01004ec:	03 00 00 
f01004ef:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01004f4:	8b 1d 48 03 11 f0    	mov    0xf0110348,%ebx
f01004fa:	89 d9                	mov    %ebx,%ecx
f01004fc:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100501:	89 da                	mov    %ebx,%edx
f0100503:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100504:	83 c3 01             	add    $0x1,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100507:	89 da                	mov    %ebx,%edx
f0100509:	ec                   	in     (%dx),%al
f010050a:	0f b6 c0             	movzbl %al,%eax
f010050d:	89 c7                	mov    %eax,%edi
f010050f:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100512:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100517:	89 ca                	mov    %ecx,%edx
f0100519:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010051a:	89 da                	mov    %ebx,%edx
f010051c:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010051d:	89 35 4c 03 11 f0    	mov    %esi,0xf011034c
	crt_pos = pos;
f0100523:	0f b6 d0             	movzbl %al,%edx
f0100526:	89 f8                	mov    %edi,%eax
f0100528:	09 d0                	or     %edx,%eax
f010052a:	66 a3 50 03 11 f0    	mov    %ax,0xf0110350
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100530:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100535:	b8 00 00 00 00       	mov    $0x0,%eax
f010053a:	89 da                	mov    %ebx,%edx
f010053c:	ee                   	out    %al,(%dx)
f010053d:	b2 fb                	mov    $0xfb,%dl
f010053f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100544:	ee                   	out    %al,(%dx)
f0100545:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010054a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010054f:	89 ca                	mov    %ecx,%edx
f0100551:	ee                   	out    %al,(%dx)
f0100552:	b2 f9                	mov    $0xf9,%dl
f0100554:	b8 00 00 00 00       	mov    $0x0,%eax
f0100559:	ee                   	out    %al,(%dx)
f010055a:	b2 fb                	mov    $0xfb,%dl
f010055c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100561:	ee                   	out    %al,(%dx)
f0100562:	b2 fc                	mov    $0xfc,%dl
f0100564:	b8 00 00 00 00       	mov    $0x0,%eax
f0100569:	ee                   	out    %al,(%dx)
f010056a:	b2 f9                	mov    $0xf9,%dl
f010056c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100571:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100572:	b2 fd                	mov    $0xfd,%dl
f0100574:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100575:	3c ff                	cmp    $0xff,%al
f0100577:	0f 95 c0             	setne  %al
f010057a:	0f b6 f0             	movzbl %al,%esi
f010057d:	89 35 44 03 11 f0    	mov    %esi,0xf0110344
f0100583:	89 da                	mov    %ebx,%edx
f0100585:	ec                   	in     (%dx),%al
f0100586:	89 ca                	mov    %ecx,%edx
f0100588:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100589:	85 f6                	test   %esi,%esi
f010058b:	75 0c                	jne    f0100599 <cons_init+0xeb>
		cprintf("Serial port does not exist!\n");
f010058d:	c7 04 24 04 1b 10 f0 	movl   $0xf0101b04,(%esp)
f0100594:	e8 a2 03 00 00       	call   f010093b <cprintf>
}
f0100599:	83 c4 0c             	add    $0xc,%esp
f010059c:	5b                   	pop    %ebx
f010059d:	5e                   	pop    %esi
f010059e:	5f                   	pop    %edi
f010059f:	5d                   	pop    %ebp
f01005a0:	c3                   	ret    

f01005a1 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01005a1:	55                   	push   %ebp
f01005a2:	89 e5                	mov    %esp,%ebp
f01005a4:	53                   	push   %ebx
f01005a5:	83 ec 04             	sub    $0x4,%esp
f01005a8:	ba 64 00 00 00       	mov    $0x64,%edx
f01005ad:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01005ae:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005b3:	a8 01                	test   $0x1,%al
f01005b5:	0f 84 d9 00 00 00    	je     f0100694 <kbd_proc_data+0xf3>
f01005bb:	ba 60 00 00 00       	mov    $0x60,%edx
f01005c0:	ec                   	in     (%dx),%al
f01005c1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01005c3:	3c e0                	cmp    $0xe0,%al
f01005c5:	75 11                	jne    f01005d8 <kbd_proc_data+0x37>
		// E0 escape character
		shift |= E0ESC;
f01005c7:	83 0d 40 03 11 f0 40 	orl    $0x40,0xf0110340
f01005ce:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005d3:	e9 bc 00 00 00       	jmp    f0100694 <kbd_proc_data+0xf3>
		return 0;
	} else if (data & 0x80) {
f01005d8:	84 c0                	test   %al,%al
f01005da:	79 31                	jns    f010060d <kbd_proc_data+0x6c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01005dc:	8b 0d 40 03 11 f0    	mov    0xf0110340,%ecx
f01005e2:	f6 c1 40             	test   $0x40,%cl
f01005e5:	75 03                	jne    f01005ea <kbd_proc_data+0x49>
f01005e7:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01005ea:	0f b6 c2             	movzbl %dl,%eax
f01005ed:	0f b6 80 40 1b 10 f0 	movzbl -0xfefe4c0(%eax),%eax
f01005f4:	83 c8 40             	or     $0x40,%eax
f01005f7:	0f b6 c0             	movzbl %al,%eax
f01005fa:	f7 d0                	not    %eax
f01005fc:	21 c8                	and    %ecx,%eax
f01005fe:	a3 40 03 11 f0       	mov    %eax,0xf0110340
f0100603:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100608:	e9 87 00 00 00       	jmp    f0100694 <kbd_proc_data+0xf3>
		return 0;
	} else if (shift & E0ESC) {
f010060d:	a1 40 03 11 f0       	mov    0xf0110340,%eax
f0100612:	a8 40                	test   $0x40,%al
f0100614:	74 0b                	je     f0100621 <kbd_proc_data+0x80>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100616:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100619:	83 e0 bf             	and    $0xffffffbf,%eax
f010061c:	a3 40 03 11 f0       	mov    %eax,0xf0110340
	}

	shift |= shiftcode[data];
f0100621:	0f b6 ca             	movzbl %dl,%ecx
	shift ^= togglecode[data];
f0100624:	0f b6 81 40 1b 10 f0 	movzbl -0xfefe4c0(%ecx),%eax
f010062b:	0b 05 40 03 11 f0    	or     0xf0110340,%eax
f0100631:	0f b6 91 40 1c 10 f0 	movzbl -0xfefe3c0(%ecx),%edx
f0100638:	31 c2                	xor    %eax,%edx
f010063a:	89 15 40 03 11 f0    	mov    %edx,0xf0110340

	c = charcode[shift & (CTL | SHIFT)][data];
f0100640:	89 d0                	mov    %edx,%eax
f0100642:	83 e0 03             	and    $0x3,%eax
f0100645:	8b 04 85 40 1d 10 f0 	mov    -0xfefe2c0(,%eax,4),%eax
f010064c:	0f b6 1c 08          	movzbl (%eax,%ecx,1),%ebx
	if (shift & CAPSLOCK) {
f0100650:	f6 c2 08             	test   $0x8,%dl
f0100653:	74 18                	je     f010066d <kbd_proc_data+0xcc>
		if ('a' <= c && c <= 'z')
f0100655:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100658:	83 f8 19             	cmp    $0x19,%eax
f010065b:	77 05                	ja     f0100662 <kbd_proc_data+0xc1>
			c += 'A' - 'a';
f010065d:	83 eb 20             	sub    $0x20,%ebx
f0100660:	eb 0b                	jmp    f010066d <kbd_proc_data+0xcc>
		else if ('A' <= c && c <= 'Z')
f0100662:	8d 43 bf             	lea    -0x41(%ebx),%eax
f0100665:	83 f8 19             	cmp    $0x19,%eax
f0100668:	77 03                	ja     f010066d <kbd_proc_data+0xcc>
			c += 'a' - 'A';
f010066a:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010066d:	89 d0                	mov    %edx,%eax
f010066f:	f7 d0                	not    %eax
f0100671:	a8 06                	test   $0x6,%al
f0100673:	75 1f                	jne    f0100694 <kbd_proc_data+0xf3>
f0100675:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010067b:	75 17                	jne    f0100694 <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f010067d:	c7 04 24 21 1b 10 f0 	movl   $0xf0101b21,(%esp)
f0100684:	e8 b2 02 00 00       	call   f010093b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100689:	ba 92 00 00 00       	mov    $0x92,%edx
f010068e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100693:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100694:	89 d8                	mov    %ebx,%eax
f0100696:	83 c4 04             	add    $0x4,%esp
f0100699:	5b                   	pop    %ebx
f010069a:	5d                   	pop    %ebp
f010069b:	c3                   	ret    
f010069c:	00 00                	add    %al,(%eax)
	...

f01006a0 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006a0:	55                   	push   %ebp
f01006a1:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01006a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006a8:	5d                   	pop    %ebp
f01006a9:	c3                   	ret    

f01006aa <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006aa:	55                   	push   %ebp
f01006ab:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006ad:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006b0:	5d                   	pop    %ebp
f01006b1:	c3                   	ret    

f01006b2 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006b2:	55                   	push   %ebp
f01006b3:	89 e5                	mov    %esp,%ebp
f01006b5:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006b8:	c7 04 24 50 1d 10 f0 	movl   $0xf0101d50,(%esp)
f01006bf:	e8 77 02 00 00       	call   f010093b <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f01006c4:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006cb:	00 
f01006cc:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006d3:	f0 
f01006d4:	c7 04 24 dc 1d 10 f0 	movl   $0xf0101ddc,(%esp)
f01006db:	e8 5b 02 00 00       	call   f010093b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006e0:	c7 44 24 08 75 1a 10 	movl   $0x101a75,0x8(%esp)
f01006e7:	00 
f01006e8:	c7 44 24 04 75 1a 10 	movl   $0xf0101a75,0x4(%esp)
f01006ef:	f0 
f01006f0:	c7 04 24 00 1e 10 f0 	movl   $0xf0101e00,(%esp)
f01006f7:	e8 3f 02 00 00       	call   f010093b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006fc:	c7 44 24 08 20 03 11 	movl   $0x110320,0x8(%esp)
f0100703:	00 
f0100704:	c7 44 24 04 20 03 11 	movl   $0xf0110320,0x4(%esp)
f010070b:	f0 
f010070c:	c7 04 24 24 1e 10 f0 	movl   $0xf0101e24,(%esp)
f0100713:	e8 23 02 00 00       	call   f010093b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100718:	c7 44 24 08 80 09 11 	movl   $0x110980,0x8(%esp)
f010071f:	00 
f0100720:	c7 44 24 04 80 09 11 	movl   $0xf0110980,0x4(%esp)
f0100727:	f0 
f0100728:	c7 04 24 48 1e 10 f0 	movl   $0xf0101e48,(%esp)
f010072f:	e8 07 02 00 00       	call   f010093b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100734:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0100739:	81 ea 0c 00 10 f0    	sub    $0xf010000c,%edx
f010073f:	81 c2 80 09 11 f0    	add    $0xf0110980,%edx
f0100745:	89 d0                	mov    %edx,%eax
f0100747:	c1 f8 1f             	sar    $0x1f,%eax
f010074a:	c1 e8 16             	shr    $0x16,%eax
f010074d:	01 d0                	add    %edx,%eax
f010074f:	c1 f8 0a             	sar    $0xa,%eax
f0100752:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100756:	c7 04 24 6c 1e 10 f0 	movl   $0xf0101e6c,(%esp)
f010075d:	e8 d9 01 00 00       	call   f010093b <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f0100762:	b8 00 00 00 00       	mov    $0x0,%eax
f0100767:	c9                   	leave  
f0100768:	c3                   	ret    

f0100769 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100769:	55                   	push   %ebp
f010076a:	89 e5                	mov    %esp,%ebp
f010076c:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010076f:	a1 10 1f 10 f0       	mov    0xf0101f10,%eax
f0100774:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100778:	a1 0c 1f 10 f0       	mov    0xf0101f0c,%eax
f010077d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100781:	c7 04 24 69 1d 10 f0 	movl   $0xf0101d69,(%esp)
f0100788:	e8 ae 01 00 00       	call   f010093b <cprintf>
f010078d:	a1 1c 1f 10 f0       	mov    0xf0101f1c,%eax
f0100792:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100796:	a1 18 1f 10 f0       	mov    0xf0101f18,%eax
f010079b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010079f:	c7 04 24 69 1d 10 f0 	movl   $0xf0101d69,(%esp)
f01007a6:	e8 90 01 00 00       	call   f010093b <cprintf>
	return 0;
}
f01007ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b0:	c9                   	leave  
f01007b1:	c3                   	ret    

f01007b2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	57                   	push   %edi
f01007b6:	56                   	push   %esi
f01007b7:	53                   	push   %ebx
f01007b8:	83 ec 4c             	sub    $0x4c,%esp
f01007bb:	8b 7d 08             	mov    0x8(%ebp),%edi
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007be:	c7 04 24 98 1e 10 f0 	movl   $0xf0101e98,(%esp)
f01007c5:	e8 71 01 00 00       	call   f010093b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007ca:	c7 04 24 bc 1e 10 f0 	movl   $0xf0101ebc,(%esp)
f01007d1:	e8 65 01 00 00       	call   f010093b <cprintf>


	while (1) {
		buf = readline("K> ");
f01007d6:	c7 04 24 72 1d 10 f0 	movl   $0xf0101d72,(%esp)
f01007dd:	e8 be 0a 00 00       	call   f01012a0 <readline>
f01007e2:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007e4:	85 c0                	test   %eax,%eax
f01007e6:	74 ee                	je     f01007d6 <monitor+0x24>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007e8:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
f01007ef:	be 00 00 00 00       	mov    $0x0,%esi
f01007f4:	eb 06                	jmp    f01007fc <monitor+0x4a>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007f6:	c6 03 00             	movb   $0x0,(%ebx)
f01007f9:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007fc:	0f b6 03             	movzbl (%ebx),%eax
f01007ff:	84 c0                	test   %al,%al
f0100801:	74 72                	je     f0100875 <monitor+0xc3>
f0100803:	0f be c0             	movsbl %al,%eax
f0100806:	89 44 24 04          	mov    %eax,0x4(%esp)
f010080a:	c7 04 24 76 1d 10 f0 	movl   $0xf0101d76,(%esp)
f0100811:	e8 e9 0c 00 00       	call   f01014ff <strchr>
f0100816:	85 c0                	test   %eax,%eax
f0100818:	75 dc                	jne    f01007f6 <monitor+0x44>
			*buf++ = 0;
		if (*buf == 0)
f010081a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010081d:	74 56                	je     f0100875 <monitor+0xc3>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010081f:	83 fe 0f             	cmp    $0xf,%esi
f0100822:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0100828:	75 16                	jne    f0100840 <monitor+0x8e>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010082a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100831:	00 
f0100832:	c7 04 24 7b 1d 10 f0 	movl   $0xf0101d7b,(%esp)
f0100839:	e8 fd 00 00 00       	call   f010093b <cprintf>
f010083e:	eb 96                	jmp    f01007d6 <monitor+0x24>
			return 0;
		}
		argv[argc++] = buf;
f0100840:	89 5c b5 b4          	mov    %ebx,-0x4c(%ebp,%esi,4)
f0100844:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100847:	0f b6 03             	movzbl (%ebx),%eax
f010084a:	84 c0                	test   %al,%al
f010084c:	75 0e                	jne    f010085c <monitor+0xaa>
f010084e:	66 90                	xchg   %ax,%ax
f0100850:	eb aa                	jmp    f01007fc <monitor+0x4a>
			buf++;
f0100852:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100855:	0f b6 03             	movzbl (%ebx),%eax
f0100858:	84 c0                	test   %al,%al
f010085a:	74 a0                	je     f01007fc <monitor+0x4a>
f010085c:	0f be c0             	movsbl %al,%eax
f010085f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100863:	c7 04 24 76 1d 10 f0 	movl   $0xf0101d76,(%esp)
f010086a:	e8 90 0c 00 00       	call   f01014ff <strchr>
f010086f:	85 c0                	test   %eax,%eax
f0100871:	74 df                	je     f0100852 <monitor+0xa0>
f0100873:	eb 87                	jmp    f01007fc <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f0100875:	c7 44 b5 b4 00 00 00 	movl   $0x0,-0x4c(%ebp,%esi,4)
f010087c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010087d:	85 f6                	test   %esi,%esi
f010087f:	90                   	nop    
f0100880:	0f 84 50 ff ff ff    	je     f01007d6 <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100886:	ba 0c 1f 10 f0       	mov    $0xf0101f0c,%edx
f010088b:	8b 02                	mov    (%edx),%eax
f010088d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100891:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100894:	89 04 24             	mov    %eax,(%esp)
f0100897:	e8 ec 0b 00 00       	call   f0101488 <strcmp>
f010089c:	ba 00 00 00 00       	mov    $0x0,%edx
f01008a1:	85 c0                	test   %eax,%eax
f01008a3:	74 1d                	je     f01008c2 <monitor+0x110>
f01008a5:	a1 18 1f 10 f0       	mov    0xf0101f18,%eax
f01008aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ae:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f01008b1:	89 04 24             	mov    %eax,(%esp)
f01008b4:	e8 cf 0b 00 00       	call   f0101488 <strcmp>
f01008b9:	85 c0                	test   %eax,%eax
f01008bb:	75 28                	jne    f01008e5 <monitor+0x133>
f01008bd:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01008c2:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01008c5:	01 d0                	add    %edx,%eax
f01008c7:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01008cb:	8d 55 b4             	lea    -0x4c(%ebp),%edx
f01008ce:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008d2:	89 34 24             	mov    %esi,(%esp)
f01008d5:	ff 14 85 14 1f 10 f0 	call   *-0xfefe0ec(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008dc:	85 c0                	test   %eax,%eax
f01008de:	78 1d                	js     f01008fd <monitor+0x14b>
f01008e0:	e9 f1 fe ff ff       	jmp    f01007d6 <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008e5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f01008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ec:	c7 04 24 98 1d 10 f0 	movl   $0xf0101d98,(%esp)
f01008f3:	e8 43 00 00 00       	call   f010093b <cprintf>
f01008f8:	e9 d9 fe ff ff       	jmp    f01007d6 <monitor+0x24>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008fd:	83 c4 4c             	add    $0x4c,%esp
f0100900:	5b                   	pop    %ebx
f0100901:	5e                   	pop    %esi
f0100902:	5f                   	pop    %edi
f0100903:	5d                   	pop    %ebp
f0100904:	c3                   	ret    
f0100905:	00 00                	add    %al,(%eax)
	...

f0100908 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100908:	55                   	push   %ebp
f0100909:	89 e5                	mov    %esp,%ebp
f010090b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010090e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100915:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100918:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010091c:	8b 45 08             	mov    0x8(%ebp),%eax
f010091f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100923:	8d 45 fc             	lea    -0x4(%ebp),%eax
f0100926:	89 44 24 04          	mov    %eax,0x4(%esp)
f010092a:	c7 04 24 55 09 10 f0 	movl   $0xf0100955,(%esp)
f0100931:	e8 ba 04 00 00       	call   f0100df0 <vprintfmt>
f0100936:	8b 45 fc             	mov    -0x4(%ebp),%eax
	return cnt;
}
f0100939:	c9                   	leave  
f010093a:	c3                   	ret    

f010093b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010093b:	55                   	push   %ebp
f010093c:	89 e5                	mov    %esp,%ebp
f010093e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100941:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100944:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100948:	8b 45 08             	mov    0x8(%ebp),%eax
f010094b:	89 04 24             	mov    %eax,(%esp)
f010094e:	e8 b5 ff ff ff       	call   f0100908 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100953:	c9                   	leave  
f0100954:	c3                   	ret    

f0100955 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100955:	55                   	push   %ebp
f0100956:	89 e5                	mov    %esp,%ebp
f0100958:	83 ec 08             	sub    $0x8,%esp
	cputchar(ch);
f010095b:	8b 45 08             	mov    0x8(%ebp),%eax
f010095e:	89 04 24             	mov    %eax,(%esp)
f0100961:	e8 38 fb ff ff       	call   f010049e <cputchar>
	*cnt++;
}
f0100966:	c9                   	leave  
f0100967:	c3                   	ret    
	...

f0100970 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100970:	55                   	push   %ebp
f0100971:	89 e5                	mov    %esp,%ebp
f0100973:	57                   	push   %edi
f0100974:	56                   	push   %esi
f0100975:	53                   	push   %ebx
f0100976:	83 ec 14             	sub    $0x14,%esp
f0100979:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010097c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010097f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100982:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100985:	8b 1a                	mov    (%edx),%ebx
f0100987:	8b 01                	mov    (%ecx),%eax
f0100989:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010098c:	39 c3                	cmp    %eax,%ebx
f010098e:	0f 8f aa 00 00 00    	jg     f0100a3e <stab_binsearch+0xce>
f0100994:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f010099b:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010099e:	01 da                	add    %ebx,%edx
f01009a0:	89 d0                	mov    %edx,%eax
f01009a2:	c1 e8 1f             	shr    $0x1f,%eax
f01009a5:	01 d0                	add    %edx,%eax
f01009a7:	89 c6                	mov    %eax,%esi
f01009a9:	d1 fe                	sar    %esi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009ab:	39 de                	cmp    %ebx,%esi
f01009ad:	7c 2b                	jl     f01009da <stab_binsearch+0x6a>
f01009af:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009b2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01009b5:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01009ba:	39 f8                	cmp    %edi,%eax
f01009bc:	74 24                	je     f01009e2 <stab_binsearch+0x72>
f01009be:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009c1:	8d 54 82 f8          	lea    -0x8(%edx,%eax,4),%edx
f01009c5:	89 f1                	mov    %esi,%ecx
			m--;
f01009c7:	83 e9 01             	sub    $0x1,%ecx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009ca:	39 d9                	cmp    %ebx,%ecx
f01009cc:	7c 0c                	jl     f01009da <stab_binsearch+0x6a>
f01009ce:	0f b6 02             	movzbl (%edx),%eax
f01009d1:	83 ea 0c             	sub    $0xc,%edx
f01009d4:	39 f8                	cmp    %edi,%eax
f01009d6:	75 ef                	jne    f01009c7 <stab_binsearch+0x57>
f01009d8:	eb 0a                	jmp    f01009e4 <stab_binsearch+0x74>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009da:	8d 5e 01             	lea    0x1(%esi),%ebx
f01009dd:	8d 76 00             	lea    0x0(%esi),%esi
f01009e0:	eb 4d                	jmp    f0100a2f <stab_binsearch+0xbf>
			continue;
f01009e2:	89 f1                	mov    %esi,%ecx
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009e4:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01009e7:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01009ea:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
f01009ee:	3b 45 0c             	cmp    0xc(%ebp),%eax
f01009f1:	73 11                	jae    f0100a04 <stab_binsearch+0x94>
			*region_left = m;
f01009f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009f6:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
f01009f8:	8d 5e 01             	lea    0x1(%esi),%ebx
f01009fb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0100a02:	eb 2b                	jmp    f0100a2f <stab_binsearch+0xbf>
		} else if (stabs[m].n_value > addr) {
f0100a04:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0100a07:	76 14                	jbe    f0100a1d <stab_binsearch+0xad>
			*region_right = m - 1;
f0100a09:	83 e9 01             	sub    $0x1,%ecx
f0100a0c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0100a0f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100a12:	89 0a                	mov    %ecx,(%edx)
f0100a14:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0100a1b:	eb 12                	jmp    f0100a2f <stab_binsearch+0xbf>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a1d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a20:	89 0e                	mov    %ecx,(%esi)
			l = m;
			addr++;
f0100a22:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a26:	89 cb                	mov    %ecx,%ebx
f0100a28:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0100a2f:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100a32:	0f 8d 63 ff ff ff    	jge    f010099b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0100a3c:	75 0f                	jne    f0100a4d <stab_binsearch+0xdd>
		*region_right = *region_left - 1;
f0100a3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100a41:	8b 02                	mov    (%edx),%eax
f0100a43:	83 e8 01             	sub    $0x1,%eax
f0100a46:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100a49:	89 01                	mov    %eax,(%ecx)
f0100a4b:	eb 3a                	jmp    f0100a87 <stab_binsearch+0x117>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a4d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a50:	8b 0e                	mov    (%esi),%ecx
		     l > *region_left && stabs[l].n_type != type;
f0100a52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a55:	8b 18                	mov    (%eax),%ebx
f0100a57:	39 d9                	cmp    %ebx,%ecx
f0100a59:	7e 27                	jle    f0100a82 <stab_binsearch+0x112>
f0100a5b:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100a5e:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a61:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100a66:	39 f8                	cmp    %edi,%eax
f0100a68:	74 18                	je     f0100a82 <stab_binsearch+0x112>
f0100a6a:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100a6d:	8d 54 82 f8          	lea    -0x8(%edx,%eax,4),%edx
		     l--)
f0100a71:	83 e9 01             	sub    $0x1,%ecx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100a74:	39 d9                	cmp    %ebx,%ecx
f0100a76:	7e 0a                	jle    f0100a82 <stab_binsearch+0x112>
f0100a78:	0f b6 02             	movzbl (%edx),%eax
f0100a7b:	83 ea 0c             	sub    $0xc,%edx
f0100a7e:	39 f8                	cmp    %edi,%eax
f0100a80:	75 ef                	jne    f0100a71 <stab_binsearch+0x101>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a82:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a85:	89 0e                	mov    %ecx,(%esi)
	}
}
f0100a87:	83 c4 14             	add    $0x14,%esp
f0100a8a:	5b                   	pop    %ebx
f0100a8b:	5e                   	pop    %esi
f0100a8c:	5f                   	pop    %edi
f0100a8d:	5d                   	pop    %ebp
f0100a8e:	c3                   	ret    

f0100a8f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a8f:	55                   	push   %ebp
f0100a90:	89 e5                	mov    %esp,%ebp
f0100a92:	83 ec 28             	sub    $0x28,%esp
f0100a95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100a98:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100a9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100a9e:	8b 75 08             	mov    0x8(%ebp),%esi
f0100aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100aa4:	c7 03 24 1f 10 f0    	movl   $0xf0101f24,(%ebx)
	info->eip_line = 0;
f0100aaa:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100ab1:	c7 43 08 24 1f 10 f0 	movl   $0xf0101f24,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100ab8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100abf:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ac2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100ac9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100acf:	76 12                	jbe    f0100ae3 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ad1:	b8 03 70 10 f0       	mov    $0xf0107003,%eax
f0100ad6:	3d d9 56 10 f0       	cmp    $0xf01056d9,%eax
f0100adb:	0f 86 81 01 00 00    	jbe    f0100c62 <debuginfo_eip+0x1d3>
f0100ae1:	eb 1c                	jmp    f0100aff <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ae3:	c7 44 24 08 2e 1f 10 	movl   $0xf0101f2e,0x8(%esp)
f0100aea:	f0 
f0100aeb:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100af2:	00 
f0100af3:	c7 04 24 3b 1f 10 f0 	movl   $0xf0101f3b,(%esp)
f0100afa:	e8 81 f5 ff ff       	call   f0100080 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100aff:	80 3d 02 70 10 f0 00 	cmpb   $0x0,0xf0107002
f0100b06:	0f 85 56 01 00 00    	jne    f0100c62 <debuginfo_eip+0x1d3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b0c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b13:	b8 d8 56 10 f0       	mov    $0xf01056d8,%eax
f0100b18:	2d 5c 21 10 f0       	sub    $0xf010215c,%eax
f0100b1d:	c1 f8 02             	sar    $0x2,%eax
f0100b20:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b26:	83 e8 01             	sub    $0x1,%eax
f0100b29:	89 45 ec             	mov    %eax,-0x14(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b2c:	8d 4d ec             	lea    -0x14(%ebp),%ecx
f0100b2f:	8d 55 f0             	lea    -0x10(%ebp),%edx
f0100b32:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b36:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100b3d:	b8 5c 21 10 f0       	mov    $0xf010215c,%eax
f0100b42:	e8 29 fe ff ff       	call   f0100970 <stab_binsearch>
	if (lfile == 0)
f0100b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b4a:	85 c0                	test   %eax,%eax
f0100b4c:	0f 84 10 01 00 00    	je     f0100c62 <debuginfo_eip+0x1d3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b52:	89 45 e8             	mov    %eax,-0x18(%ebp)
	rfun = rfile;
f0100b55:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100b58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b5b:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0100b5e:	8d 55 e8             	lea    -0x18(%ebp),%edx
f0100b61:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b65:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100b6c:	b8 5c 21 10 f0       	mov    $0xf010215c,%eax
f0100b71:	e8 fa fd ff ff       	call   f0100970 <stab_binsearch>

	if (lfun <= rfun) {
f0100b76:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100b79:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0100b7c:	7f 35                	jg     f0100bb3 <debuginfo_eip+0x124>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b7e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b81:	8b 14 85 5c 21 10 f0 	mov    -0xfefdea4(,%eax,4),%edx
f0100b88:	b8 03 70 10 f0       	mov    $0xf0107003,%eax
f0100b8d:	2d d9 56 10 f0       	sub    $0xf01056d9,%eax
f0100b92:	39 c2                	cmp    %eax,%edx
f0100b94:	73 09                	jae    f0100b9f <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b96:	8d 82 d9 56 10 f0    	lea    -0xfefa927(%edx),%eax
f0100b9c:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100ba2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ba5:	8b 14 95 64 21 10 f0 	mov    -0xfefde9c(,%edx,4),%edx
f0100bac:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
		// Search within the function definition for the line number.
		lline = lfun;
f0100baf:	89 c6                	mov    %eax,%esi
f0100bb1:	eb 06                	jmp    f0100bb9 <debuginfo_eip+0x12a>
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bb3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bb6:	8b 75 f0             	mov    -0x10(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bb9:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100bc0:	00 
f0100bc1:	8b 43 08             	mov    0x8(%ebx),%eax
f0100bc4:	89 04 24             	mov    %eax,(%esp)
f0100bc7:	e8 65 09 00 00       	call   f0101531 <strfind>
f0100bcc:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bcf:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bd2:	8b 7d f0             	mov    -0x10(%ebp),%edi
f0100bd5:	39 fe                	cmp    %edi,%esi
f0100bd7:	7c 49                	jl     f0100c22 <debuginfo_eip+0x193>
f0100bd9:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100bdc:	8d 0c 85 5c 21 10 f0 	lea    -0xfefdea4(,%eax,4),%ecx
f0100be3:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
f0100be7:	8d 04 85 50 21 10 f0 	lea    -0xfefdeb0(,%eax,4),%eax
f0100bee:	80 fa 84             	cmp    $0x84,%dl
f0100bf1:	75 1a                	jne    f0100c0d <debuginfo_eip+0x17e>
f0100bf3:	e9 84 00 00 00       	jmp    f0100c7c <debuginfo_eip+0x1ed>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100bf8:	83 ee 01             	sub    $0x1,%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bfb:	39 f7                	cmp    %esi,%edi
f0100bfd:	7f 23                	jg     f0100c22 <debuginfo_eip+0x193>
f0100bff:	89 c1                	mov    %eax,%ecx
f0100c01:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100c05:	83 e8 0c             	sub    $0xc,%eax
f0100c08:	80 fa 84             	cmp    $0x84,%dl
f0100c0b:	74 6f                	je     f0100c7c <debuginfo_eip+0x1ed>
f0100c0d:	80 fa 64             	cmp    $0x64,%dl
f0100c10:	75 e6                	jne    f0100bf8 <debuginfo_eip+0x169>
f0100c12:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0100c16:	74 e0                	je     f0100bf8 <debuginfo_eip+0x169>
f0100c18:	eb 62                	jmp    f0100c7c <debuginfo_eip+0x1ed>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c1a:	8d 82 d9 56 10 f0    	lea    -0xfefa927(%edx),%eax
f0100c20:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c22:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c28:	39 c2                	cmp    %eax,%edx
f0100c2a:	7d 3e                	jge    f0100c6a <debuginfo_eip+0x1db>
		for (lline = lfun + 1;
f0100c2c:	8d 4a 01             	lea    0x1(%edx),%ecx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c2f:	39 c8                	cmp    %ecx,%eax
f0100c31:	7e 37                	jle    f0100c6a <debuginfo_eip+0x1db>
f0100c33:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100c36:	80 3c 85 60 21 10 f0 	cmpb   $0xa0,-0xfefdea0(,%eax,4)
f0100c3d:	a0 
f0100c3e:	75 2a                	jne    f0100c6a <debuginfo_eip+0x1db>
f0100c40:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c43:	8d 14 85 78 21 10 f0 	lea    -0xfefde88(,%eax,4),%edx
		     lline++)
			info->eip_fn_narg++;
f0100c4a:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100c4e:	83 c1 01             	add    $0x1,%ecx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c51:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0100c54:	7e 14                	jle    f0100c6a <debuginfo_eip+0x1db>
f0100c56:	0f b6 02             	movzbl (%edx),%eax
f0100c59:	83 c2 0c             	add    $0xc,%edx
f0100c5c:	3c a0                	cmp    $0xa0,%al
f0100c5e:	74 ea                	je     f0100c4a <debuginfo_eip+0x1bb>
f0100c60:	eb 08                	jmp    f0100c6a <debuginfo_eip+0x1db>
f0100c62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c67:	90                   	nop    
f0100c68:	eb 05                	jmp    f0100c6f <debuginfo_eip+0x1e0>
f0100c6a:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0100c6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100c72:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100c75:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100c78:	89 ec                	mov    %ebp,%esp
f0100c7a:	5d                   	pop    %ebp
f0100c7b:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c7c:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c7f:	8b 14 85 5c 21 10 f0 	mov    -0xfefdea4(,%eax,4),%edx
f0100c86:	b8 03 70 10 f0       	mov    $0xf0107003,%eax
f0100c8b:	2d d9 56 10 f0       	sub    $0xf01056d9,%eax
f0100c90:	39 c2                	cmp    %eax,%edx
f0100c92:	72 86                	jb     f0100c1a <debuginfo_eip+0x18b>
f0100c94:	eb 8c                	jmp    f0100c22 <debuginfo_eip+0x193>
	...

f0100ca0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ca0:	55                   	push   %ebp
f0100ca1:	89 e5                	mov    %esp,%ebp
f0100ca3:	57                   	push   %edi
f0100ca4:	56                   	push   %esi
f0100ca5:	53                   	push   %ebx
f0100ca6:	83 ec 3c             	sub    $0x3c,%esp
f0100ca9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100cac:	89 d7                	mov    %edx,%edi
f0100cae:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cb7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100cba:	8b 55 10             	mov    0x10(%ebp),%edx
f0100cbd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cc0:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100cc3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0100cca:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ccd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
f0100cd0:	72 16                	jb     f0100ce8 <printnum+0x48>
f0100cd2:	77 08                	ja     f0100cdc <printnum+0x3c>
f0100cd4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cd7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0100cda:	76 0c                	jbe    f0100ce8 <printnum+0x48>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100cdc:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100cdf:	83 eb 01             	sub    $0x1,%ebx
f0100ce2:	85 db                	test   %ebx,%ebx
f0100ce4:	7f 57                	jg     f0100d3d <printnum+0x9d>
f0100ce6:	eb 6a                	jmp    f0100d52 <printnum+0xb2>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ce8:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100cec:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cef:	83 e8 01             	sub    $0x1,%eax
f0100cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cf6:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100cfa:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100cfe:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100d02:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100d05:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100d08:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d0c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d10:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d13:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d16:	89 04 24             	mov    %eax,(%esp)
f0100d19:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d1d:	e8 de 0a 00 00       	call   f0101800 <__udivdi3>
f0100d22:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100d26:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100d2a:	89 04 24             	mov    %eax,(%esp)
f0100d2d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d31:	89 fa                	mov    %edi,%edx
f0100d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d36:	e8 65 ff ff ff       	call   f0100ca0 <printnum>
f0100d3b:	eb 15                	jmp    f0100d52 <printnum+0xb2>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d3d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d41:	89 34 24             	mov    %esi,(%esp)
f0100d44:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d47:	83 eb 01             	sub    $0x1,%ebx
f0100d4a:	85 db                	test   %ebx,%ebx
f0100d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100d50:	7f eb                	jg     f0100d3d <printnum+0x9d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d52:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d56:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100d5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100d5d:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100d60:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d64:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d68:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d6e:	89 04 24             	mov    %eax,(%esp)
f0100d71:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d75:	e8 b6 0b 00 00       	call   f0101930 <__umoddi3>
f0100d7a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d7e:	0f be 80 49 1f 10 f0 	movsbl -0xfefe0b7(%eax),%eax
f0100d85:	89 04 24             	mov    %eax,(%esp)
f0100d88:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100d8b:	83 c4 3c             	add    $0x3c,%esp
f0100d8e:	5b                   	pop    %ebx
f0100d8f:	5e                   	pop    %esi
f0100d90:	5f                   	pop    %edi
f0100d91:	5d                   	pop    %ebp
f0100d92:	c3                   	ret    

f0100d93 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d93:	55                   	push   %ebp
f0100d94:	89 e5                	mov    %esp,%ebp
f0100d96:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
f0100d98:	83 fa 01             	cmp    $0x1,%edx
f0100d9b:	7e 0f                	jle    f0100dac <getuint+0x19>
		return va_arg(*ap, unsigned long long);
f0100d9d:	8b 00                	mov    (%eax),%eax
f0100d9f:	83 c0 08             	add    $0x8,%eax
f0100da2:	89 01                	mov    %eax,(%ecx)
f0100da4:	8b 50 fc             	mov    -0x4(%eax),%edx
f0100da7:	8b 40 f8             	mov    -0x8(%eax),%eax
f0100daa:	eb 24                	jmp    f0100dd0 <getuint+0x3d>
	else if (lflag)
f0100dac:	85 d2                	test   %edx,%edx
f0100dae:	74 11                	je     f0100dc1 <getuint+0x2e>
		return va_arg(*ap, unsigned long);
f0100db0:	8b 00                	mov    (%eax),%eax
f0100db2:	83 c0 04             	add    $0x4,%eax
f0100db5:	89 01                	mov    %eax,(%ecx)
f0100db7:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100dba:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dbf:	eb 0f                	jmp    f0100dd0 <getuint+0x3d>
	else
		return va_arg(*ap, unsigned int);
f0100dc1:	8b 00                	mov    (%eax),%eax
f0100dc3:	83 c0 04             	add    $0x4,%eax
f0100dc6:	89 01                	mov    %eax,(%ecx)
f0100dc8:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100dcb:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100dd0:	5d                   	pop    %ebp
f0100dd1:	c3                   	ret    

f0100dd2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100dd2:	55                   	push   %ebp
f0100dd3:	89 e5                	mov    %esp,%ebp
f0100dd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
f0100dd8:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
f0100ddc:	8b 02                	mov    (%edx),%eax
f0100dde:	3b 42 04             	cmp    0x4(%edx),%eax
f0100de1:	73 0b                	jae    f0100dee <sprintputch+0x1c>
		*b->buf++ = ch;
f0100de3:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
f0100de7:	88 08                	mov    %cl,(%eax)
f0100de9:	83 c0 01             	add    $0x1,%eax
f0100dec:	89 02                	mov    %eax,(%edx)
}
f0100dee:	5d                   	pop    %ebp
f0100def:	c3                   	ret    

f0100df0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100df0:	55                   	push   %ebp
f0100df1:	89 e5                	mov    %esp,%ebp
f0100df3:	57                   	push   %edi
f0100df4:	56                   	push   %esi
f0100df5:	53                   	push   %ebx
f0100df6:	83 ec 2c             	sub    $0x2c,%esp
f0100df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0100dfc:	eb 15                	jmp    f0100e13 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100dfe:	85 c0                	test   %eax,%eax
f0100e00:	0f 84 e4 03 00 00    	je     f01011ea <vprintfmt+0x3fa>
				return;
			putch(ch, putdat);
f0100e06:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e09:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100e0d:	89 04 24             	mov    %eax,(%esp)
f0100e10:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e13:	0f b6 03             	movzbl (%ebx),%eax
f0100e16:	83 c3 01             	add    $0x1,%ebx
f0100e19:	83 f8 25             	cmp    $0x25,%eax
f0100e1c:	75 e0                	jne    f0100dfe <vprintfmt+0xe>
f0100e1e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e23:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100e2a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100e2f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0100e36:	c6 45 ef 20          	movb   $0x20,-0x11(%ebp)
f0100e3a:	eb 07                	jmp    f0100e43 <vprintfmt+0x53>
f0100e3c:	c6 45 ef 2d          	movb   $0x2d,-0x11(%ebp)
f0100e40:	8b 5d f0             	mov    -0x10(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e43:	0f b6 03             	movzbl (%ebx),%eax
f0100e46:	0f b6 c8             	movzbl %al,%ecx
f0100e49:	8d 73 01             	lea    0x1(%ebx),%esi
f0100e4c:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0100e4f:	83 e8 23             	sub    $0x23,%eax
f0100e52:	3c 55                	cmp    $0x55,%al
f0100e54:	0f 87 6f 03 00 00    	ja     f01011c9 <vprintfmt+0x3d9>
f0100e5a:	0f b6 c0             	movzbl %al,%eax
f0100e5d:	ff 24 85 d8 1f 10 f0 	jmp    *-0xfefe028(,%eax,4)
f0100e64:	c6 45 ef 30          	movb   $0x30,-0x11(%ebp)
f0100e68:	eb d6                	jmp    f0100e40 <vprintfmt+0x50>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e6a:	8d 79 d0             	lea    -0x30(%ecx),%edi
				ch = *fmt;
f0100e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e70:	0f be 08             	movsbl (%eax),%ecx
				if (ch < '0' || ch > '9')
f0100e73:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0100e76:	83 f8 09             	cmp    $0x9,%eax
f0100e79:	77 3f                	ja     f0100eba <vprintfmt+0xca>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e7b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
				precision = precision * 10 + ch - '0';
f0100e7f:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0100e82:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
f0100e86:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0100e89:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f0100e8c:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0100e8f:	83 f8 09             	cmp    $0x9,%eax
f0100e92:	76 e7                	jbe    f0100e7b <vprintfmt+0x8b>
f0100e94:	eb 24                	jmp    f0100eba <vprintfmt+0xca>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e96:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e99:	83 c0 04             	add    $0x4,%eax
f0100e9c:	89 45 14             	mov    %eax,0x14(%ebp)
f0100e9f:	8b 78 fc             	mov    -0x4(%eax),%edi
f0100ea2:	eb 16                	jmp    f0100eba <vprintfmt+0xca>
			goto process_precision;

		case '.':
			if (width < 0)
f0100ea4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ea7:	c1 f8 1f             	sar    $0x1f,%eax
f0100eaa:	f7 d0                	not    %eax
f0100eac:	21 45 e4             	and    %eax,-0x1c(%ebp)
f0100eaf:	eb 8f                	jmp    f0100e40 <vprintfmt+0x50>
f0100eb1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100eb8:	eb 86                	jmp    f0100e40 <vprintfmt+0x50>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100eba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100ebe:	79 80                	jns    f0100e40 <vprintfmt+0x50>
f0100ec0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100ec3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100ec8:	e9 73 ff ff ff       	jmp    f0100e40 <vprintfmt+0x50>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ecd:	83 c2 01             	add    $0x1,%edx
f0100ed0:	e9 6b ff ff ff       	jmp    f0100e40 <vprintfmt+0x50>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ed5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ed8:	83 c0 04             	add    $0x4,%eax
f0100edb:	89 45 14             	mov    %eax,0x14(%ebp)
f0100ede:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ee1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ee5:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100ee8:	89 04 24             	mov    %eax,(%esp)
f0100eeb:	ff 55 08             	call   *0x8(%ebp)
f0100eee:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100ef1:	e9 1d ff ff ff       	jmp    f0100e13 <vprintfmt+0x23>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ef6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef9:	83 c0 04             	add    $0x4,%eax
f0100efc:	89 45 14             	mov    %eax,0x14(%ebp)
f0100eff:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100f02:	89 c2                	mov    %eax,%edx
f0100f04:	c1 fa 1f             	sar    $0x1f,%edx
f0100f07:	31 d0                	xor    %edx,%eax
f0100f09:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100f0b:	83 f8 06             	cmp    $0x6,%eax
f0100f0e:	7f 0b                	jg     f0100f1b <vprintfmt+0x12b>
f0100f10:	8b 14 85 30 21 10 f0 	mov    -0xfefded0(,%eax,4),%edx
f0100f17:	85 d2                	test   %edx,%edx
f0100f19:	75 26                	jne    f0100f41 <vprintfmt+0x151>
				printfmt(putch, putdat, "error %d", err);
f0100f1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f1f:	c7 44 24 08 5a 1f 10 	movl   $0xf0101f5a,0x8(%esp)
f0100f26:	f0 
f0100f27:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100f2a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f31:	89 04 24             	mov    %eax,(%esp)
f0100f34:	e8 39 03 00 00       	call   f0101272 <printfmt>
f0100f39:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100f3c:	e9 d2 fe ff ff       	jmp    f0100e13 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0100f41:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f45:	c7 44 24 08 63 1f 10 	movl   $0xf0101f63,0x8(%esp)
f0100f4c:	f0 
f0100f4d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f50:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f54:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f57:	89 34 24             	mov    %esi,(%esp)
f0100f5a:	e8 13 03 00 00       	call   f0101272 <printfmt>
f0100f5f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100f62:	e9 ac fe ff ff       	jmp    f0100e13 <vprintfmt+0x23>
f0100f67:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f6a:	89 fa                	mov    %edi,%edx
f0100f6c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f6f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f72:	83 c0 04             	add    $0x4,%eax
f0100f75:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f78:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100f7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f7e:	85 c0                	test   %eax,%eax
f0100f80:	75 07                	jne    f0100f89 <vprintfmt+0x199>
f0100f82:	c7 45 e0 66 1f 10 f0 	movl   $0xf0101f66,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0100f89:	85 f6                	test   %esi,%esi
f0100f8b:	7e 06                	jle    f0100f93 <vprintfmt+0x1a3>
f0100f8d:	80 7d ef 2d          	cmpb   $0x2d,-0x11(%ebp)
f0100f91:	75 1a                	jne    f0100fad <vprintfmt+0x1bd>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f93:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f96:	0f be 10             	movsbl (%eax),%edx
f0100f99:	85 d2                	test   %edx,%edx
f0100f9b:	0f 85 9c 00 00 00    	jne    f010103d <vprintfmt+0x24d>
f0100fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0100fa8:	e9 7d 00 00 00       	jmp    f010102a <vprintfmt+0x23a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fad:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100fb1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100fb4:	89 14 24             	mov    %edx,(%esp)
f0100fb7:	e8 ff 03 00 00       	call   f01013bb <strnlen>
f0100fbc:	29 c6                	sub    %eax,%esi
f0100fbe:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0100fc1:	85 f6                	test   %esi,%esi
f0100fc3:	7e ce                	jle    f0100f93 <vprintfmt+0x1a3>
					putch(padc, putdat);
f0100fc5:	0f be 75 ef          	movsbl -0x11(%ebp),%esi
f0100fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fd0:	89 34 24             	mov    %esi,(%esp)
f0100fd3:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fd6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100fda:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100fde:	7f e9                	jg     f0100fc9 <vprintfmt+0x1d9>
f0100fe0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100fe7:	eb aa                	jmp    f0100f93 <vprintfmt+0x1a3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100fe9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100fed:	8d 76 00             	lea    0x0(%esi),%esi
f0100ff0:	74 1b                	je     f010100d <vprintfmt+0x21d>
f0100ff2:	8d 42 e0             	lea    -0x20(%edx),%eax
f0100ff5:	83 f8 5e             	cmp    $0x5e,%eax
f0100ff8:	76 13                	jbe    f010100d <vprintfmt+0x21d>
					putch('?', putdat);
f0100ffa:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ffd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101001:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101008:	ff 55 08             	call   *0x8(%ebp)
f010100b:	eb 0d                	jmp    f010101a <vprintfmt+0x22a>
				else
					putch(ch, putdat);
f010100d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101010:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101014:	89 14 24             	mov    %edx,(%esp)
f0101017:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010101a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010101e:	0f be 16             	movsbl (%esi),%edx
f0101021:	85 d2                	test   %edx,%edx
f0101023:	74 05                	je     f010102a <vprintfmt+0x23a>
f0101025:	83 c6 01             	add    $0x1,%esi
f0101028:	eb 19                	jmp    f0101043 <vprintfmt+0x253>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010102a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010102e:	7f 22                	jg     f0101052 <vprintfmt+0x262>
f0101030:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0101033:	90                   	nop    
f0101034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101038:	e9 d6 fd ff ff       	jmp    f0100e13 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010103d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101040:	83 c6 01             	add    $0x1,%esi
f0101043:	85 ff                	test   %edi,%edi
f0101045:	78 a2                	js     f0100fe9 <vprintfmt+0x1f9>
f0101047:	83 ef 01             	sub    $0x1,%edi
f010104a:	79 9d                	jns    f0100fe9 <vprintfmt+0x1f9>
f010104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101050:	eb d8                	jmp    f010102a <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101052:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101055:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101059:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101060:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101063:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0101067:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010106b:	7f e5                	jg     f0101052 <vprintfmt+0x262>
f010106d:	e9 a1 fd ff ff       	jmp    f0100e13 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101072:	83 fa 01             	cmp    $0x1,%edx
f0101075:	8d 76 00             	lea    0x0(%esi),%esi
f0101078:	7e 11                	jle    f010108b <vprintfmt+0x29b>
		return va_arg(*ap, long long);
f010107a:	8b 45 14             	mov    0x14(%ebp),%eax
f010107d:	83 c0 08             	add    $0x8,%eax
f0101080:	89 45 14             	mov    %eax,0x14(%ebp)
f0101083:	8b 70 f8             	mov    -0x8(%eax),%esi
f0101086:	8b 78 fc             	mov    -0x4(%eax),%edi
f0101089:	eb 2c                	jmp    f01010b7 <vprintfmt+0x2c7>
	else if (lflag)
f010108b:	85 d2                	test   %edx,%edx
f010108d:	74 15                	je     f01010a4 <vprintfmt+0x2b4>
		return va_arg(*ap, long);
f010108f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101092:	83 c0 04             	add    $0x4,%eax
f0101095:	89 45 14             	mov    %eax,0x14(%ebp)
f0101098:	8b 40 fc             	mov    -0x4(%eax),%eax
f010109b:	89 c6                	mov    %eax,%esi
f010109d:	89 c7                	mov    %eax,%edi
f010109f:	c1 ff 1f             	sar    $0x1f,%edi
f01010a2:	eb 13                	jmp    f01010b7 <vprintfmt+0x2c7>
	else
		return va_arg(*ap, int);
f01010a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a7:	83 c0 04             	add    $0x4,%eax
f01010aa:	89 45 14             	mov    %eax,0x14(%ebp)
f01010ad:	8b 40 fc             	mov    -0x4(%eax),%eax
f01010b0:	89 c6                	mov    %eax,%esi
f01010b2:	89 c7                	mov    %eax,%edi
f01010b4:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01010b7:	89 f2                	mov    %esi,%edx
f01010b9:	89 f9                	mov    %edi,%ecx
f01010bb:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
f01010c0:	85 ff                	test   %edi,%edi
f01010c2:	0f 89 bf 00 00 00    	jns    f0101187 <vprintfmt+0x397>
				putch('-', putdat);
f01010c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010cf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01010d6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01010d9:	89 f2                	mov    %esi,%edx
f01010db:	89 f9                	mov    %edi,%ecx
f01010dd:	f7 da                	neg    %edx
f01010df:	83 d1 00             	adc    $0x0,%ecx
f01010e2:	f7 d9                	neg    %ecx
f01010e4:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01010e9:	e9 99 00 00 00       	jmp    f0101187 <vprintfmt+0x397>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01010ee:	8d 45 14             	lea    0x14(%ebp),%eax
f01010f1:	e8 9d fc ff ff       	call   f0100d93 <getuint>
f01010f6:	89 d1                	mov    %edx,%ecx
f01010f8:	89 c2                	mov    %eax,%edx
f01010fa:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01010ff:	e9 83 00 00 00       	jmp    f0101187 <vprintfmt+0x397>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101104:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101107:	89 54 24 04          	mov    %edx,0x4(%esp)
f010110b:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101112:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0101115:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101118:	89 74 24 04          	mov    %esi,0x4(%esp)
f010111c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101123:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0101126:	89 74 24 04          	mov    %esi,0x4(%esp)
f010112a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101131:	ff 55 08             	call   *0x8(%ebp)
f0101134:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0101137:	e9 d7 fc ff ff       	jmp    f0100e13 <vprintfmt+0x23>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010113c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010113f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101143:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010114a:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010114d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101150:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101154:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010115b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f010115e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101161:	83 c0 04             	add    $0x4,%eax
f0101164:	89 45 14             	mov    %eax,0x14(%ebp)
f0101167:	8b 50 fc             	mov    -0x4(%eax),%edx
f010116a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010116f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101174:	eb 11                	jmp    f0101187 <vprintfmt+0x397>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101176:	8d 45 14             	lea    0x14(%ebp),%eax
f0101179:	e8 15 fc ff ff       	call   f0100d93 <getuint>
f010117e:	89 d1                	mov    %edx,%ecx
f0101180:	89 c2                	mov    %eax,%edx
f0101182:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101187:	0f be 45 ef          	movsbl -0x11(%ebp),%eax
f010118b:	89 44 24 10          	mov    %eax,0x10(%esp)
f010118f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101192:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101196:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010119a:	89 14 24             	mov    %edx,(%esp)
f010119d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01011a1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01011a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01011a7:	e8 f4 fa ff ff       	call   f0100ca0 <printnum>
f01011ac:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01011af:	e9 5f fc ff ff       	jmp    f0100e13 <vprintfmt+0x23>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011bb:	89 0c 24             	mov    %ecx,(%esp)
f01011be:	ff 55 08             	call   *0x8(%ebp)
f01011c1:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01011c4:	e9 4a fc ff ff       	jmp    f0100e13 <vprintfmt+0x23>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01011c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01011cc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01011d0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01011d7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011da:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01011dd:	80 38 25             	cmpb   $0x25,(%eax)
f01011e0:	0f 84 2d fc ff ff    	je     f0100e13 <vprintfmt+0x23>
f01011e6:	89 c3                	mov    %eax,%ebx
f01011e8:	eb f0                	jmp    f01011da <vprintfmt+0x3ea>
				/* do nothing */;
			break;
		}
	}
}
f01011ea:	83 c4 2c             	add    $0x2c,%esp
f01011ed:	5b                   	pop    %ebx
f01011ee:	5e                   	pop    %esi
f01011ef:	5f                   	pop    %edi
f01011f0:	5d                   	pop    %ebp
f01011f1:	c3                   	ret    

f01011f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011f2:	55                   	push   %ebp
f01011f3:	89 e5                	mov    %esp,%ebp
f01011f5:	83 ec 28             	sub    $0x28,%esp
f01011f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01011fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f01011fe:	85 c0                	test   %eax,%eax
f0101200:	74 04                	je     f0101206 <vsnprintf+0x14>
f0101202:	85 d2                	test   %edx,%edx
f0101204:	7f 07                	jg     f010120d <vsnprintf+0x1b>
f0101206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010120b:	eb 3b                	jmp    f0101248 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f010120d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101210:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0101214:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0101217:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010121e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101221:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101225:	8b 45 10             	mov    0x10(%ebp),%eax
f0101228:	89 44 24 08          	mov    %eax,0x8(%esp)
f010122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010122f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101233:	c7 04 24 d2 0d 10 f0 	movl   $0xf0100dd2,(%esp)
f010123a:	e8 b1 fb ff ff       	call   f0100df0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101242:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101245:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0101248:	c9                   	leave  
f0101249:	c3                   	ret    

f010124a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010124a:	55                   	push   %ebp
f010124b:	89 e5                	mov    %esp,%ebp
f010124d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0101250:	8d 45 14             	lea    0x14(%ebp),%eax
f0101253:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101257:	8b 45 10             	mov    0x10(%ebp),%eax
f010125a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010125e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101261:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101265:	8b 45 08             	mov    0x8(%ebp),%eax
f0101268:	89 04 24             	mov    %eax,(%esp)
f010126b:	e8 82 ff ff ff       	call   f01011f2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101270:	c9                   	leave  
f0101271:	c3                   	ret    

f0101272 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101272:	55                   	push   %ebp
f0101273:	89 e5                	mov    %esp,%ebp
f0101275:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0101278:	8d 45 14             	lea    0x14(%ebp),%eax
f010127b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010127f:	8b 45 10             	mov    0x10(%ebp),%eax
f0101282:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101286:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101289:	89 44 24 04          	mov    %eax,0x4(%esp)
f010128d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101290:	89 04 24             	mov    %eax,(%esp)
f0101293:	e8 58 fb ff ff       	call   f0100df0 <vprintfmt>
	va_end(ap);
}
f0101298:	c9                   	leave  
f0101299:	c3                   	ret    
f010129a:	00 00                	add    %al,(%eax)
f010129c:	00 00                	add    %al,(%eax)
	...

f01012a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01012a0:	55                   	push   %ebp
f01012a1:	89 e5                	mov    %esp,%ebp
f01012a3:	57                   	push   %edi
f01012a4:	56                   	push   %esi
f01012a5:	53                   	push   %ebx
f01012a6:	83 ec 0c             	sub    $0xc,%esp
f01012a9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01012ac:	85 c0                	test   %eax,%eax
f01012ae:	74 10                	je     f01012c0 <readline+0x20>
		cprintf("%s", prompt);
f01012b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012b4:	c7 04 24 63 1f 10 f0 	movl   $0xf0101f63,(%esp)
f01012bb:	e8 7b f6 ff ff       	call   f010093b <cprintf>

	i = 0;
	echoing = iscons(0);
f01012c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012c7:	e8 cb ef ff ff       	call   f0100297 <iscons>
f01012cc:	89 c7                	mov    %eax,%edi
f01012ce:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f01012d3:	e8 ae ef ff ff       	call   f0100286 <getchar>
f01012d8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01012da:	85 c0                	test   %eax,%eax
f01012dc:	79 1a                	jns    f01012f8 <readline+0x58>
			cprintf("read error: %e\n", c);
f01012de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012e2:	c7 04 24 4c 21 10 f0 	movl   $0xf010214c,(%esp)
f01012e9:	e8 4d f6 ff ff       	call   f010093b <cprintf>
f01012ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01012f3:	e9 99 00 00 00       	jmp    f0101391 <readline+0xf1>
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012f8:	83 f8 08             	cmp    $0x8,%eax
f01012fb:	74 05                	je     f0101302 <readline+0x62>
f01012fd:	83 f8 7f             	cmp    $0x7f,%eax
f0101300:	75 28                	jne    f010132a <readline+0x8a>
f0101302:	85 f6                	test   %esi,%esi
f0101304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101308:	7e 20                	jle    f010132a <readline+0x8a>
			if (echoing)
f010130a:	85 ff                	test   %edi,%edi
f010130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101310:	74 13                	je     f0101325 <readline+0x85>
				cputchar('\b');
f0101312:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101320:	e8 79 f1 ff ff       	call   f010049e <cputchar>
			i--;
f0101325:	83 ee 01             	sub    $0x1,%esi
f0101328:	eb a9                	jmp    f01012d3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010132a:	83 fb 1f             	cmp    $0x1f,%ebx
f010132d:	8d 76 00             	lea    0x0(%esi),%esi
f0101330:	7e 29                	jle    f010135b <readline+0xbb>
f0101332:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101338:	7f 21                	jg     f010135b <readline+0xbb>
			if (echoing)
f010133a:	85 ff                	test   %edi,%edi
f010133c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101340:	74 0b                	je     f010134d <readline+0xad>
				cputchar(c);
f0101342:	89 1c 24             	mov    %ebx,(%esp)
f0101345:	8d 76 00             	lea    0x0(%esi),%esi
f0101348:	e8 51 f1 ff ff       	call   f010049e <cputchar>
			buf[i++] = c;
f010134d:	88 9e 80 05 11 f0    	mov    %bl,-0xfeefa80(%esi)
f0101353:	83 c6 01             	add    $0x1,%esi
f0101356:	e9 78 ff ff ff       	jmp    f01012d3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010135b:	83 fb 0a             	cmp    $0xa,%ebx
f010135e:	74 09                	je     f0101369 <readline+0xc9>
f0101360:	83 fb 0d             	cmp    $0xd,%ebx
f0101363:	0f 85 6a ff ff ff    	jne    f01012d3 <readline+0x33>
			if (echoing)
f0101369:	85 ff                	test   %edi,%edi
f010136b:	90                   	nop    
f010136c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101370:	74 13                	je     f0101385 <readline+0xe5>
				cputchar('\n');
f0101372:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101380:	e8 19 f1 ff ff       	call   f010049e <cputchar>
			buf[i] = 0;
f0101385:	c6 86 80 05 11 f0 00 	movb   $0x0,-0xfeefa80(%esi)
f010138c:	b8 80 05 11 f0       	mov    $0xf0110580,%eax
			return buf;
		}
	}
}
f0101391:	83 c4 0c             	add    $0xc,%esp
f0101394:	5b                   	pop    %ebx
f0101395:	5e                   	pop    %esi
f0101396:	5f                   	pop    %edi
f0101397:	5d                   	pop    %ebp
f0101398:	c3                   	ret    
f0101399:	00 00                	add    %al,(%eax)
f010139b:	00 00                	add    %al,(%eax)
f010139d:	00 00                	add    %al,(%eax)
	...

f01013a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01013a0:	55                   	push   %ebp
f01013a1:	89 e5                	mov    %esp,%ebp
f01013a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01013a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ab:	80 3a 00             	cmpb   $0x0,(%edx)
f01013ae:	74 09                	je     f01013b9 <strlen+0x19>
		n++;
f01013b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01013b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01013b7:	75 f7                	jne    f01013b0 <strlen+0x10>
		n++;
	return n;
}
f01013b9:	5d                   	pop    %ebp
f01013ba:	c3                   	ret    

f01013bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01013bb:	55                   	push   %ebp
f01013bc:	89 e5                	mov    %esp,%ebp
f01013be:	53                   	push   %ebx
f01013bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01013c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013c5:	85 c9                	test   %ecx,%ecx
f01013c7:	74 19                	je     f01013e2 <strnlen+0x27>
f01013c9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01013cc:	74 14                	je     f01013e2 <strnlen+0x27>
f01013ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01013d3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013d6:	39 c8                	cmp    %ecx,%eax
f01013d8:	74 0d                	je     f01013e7 <strnlen+0x2c>
f01013da:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01013de:	75 f3                	jne    f01013d3 <strnlen+0x18>
f01013e0:	eb 05                	jmp    f01013e7 <strnlen+0x2c>
f01013e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01013e7:	5b                   	pop    %ebx
f01013e8:	5d                   	pop    %ebp
f01013e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01013f0:	c3                   	ret    

f01013f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01013f1:	55                   	push   %ebp
f01013f2:	89 e5                	mov    %esp,%ebp
f01013f4:	53                   	push   %ebx
f01013f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01013f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013fb:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101400:	0f b6 04 11          	movzbl (%ecx,%edx,1),%eax
f0101404:	88 04 13             	mov    %al,(%ebx,%edx,1)
f0101407:	83 c2 01             	add    $0x1,%edx
f010140a:	84 c0                	test   %al,%al
f010140c:	75 f2                	jne    f0101400 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010140e:	89 d8                	mov    %ebx,%eax
f0101410:	5b                   	pop    %ebx
f0101411:	5d                   	pop    %ebp
f0101412:	c3                   	ret    

f0101413 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101413:	55                   	push   %ebp
f0101414:	89 e5                	mov    %esp,%ebp
f0101416:	56                   	push   %esi
f0101417:	53                   	push   %ebx
f0101418:	8b 75 08             	mov    0x8(%ebp),%esi
f010141b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010141e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101421:	85 db                	test   %ebx,%ebx
f0101423:	74 18                	je     f010143d <strncpy+0x2a>
f0101425:	ba 00 00 00 00       	mov    $0x0,%edx
		*dst++ = *src;
f010142a:	0f b6 01             	movzbl (%ecx),%eax
f010142d:	88 04 16             	mov    %al,(%esi,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101430:	80 39 01             	cmpb   $0x1,(%ecx)
f0101433:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101436:	83 c2 01             	add    $0x1,%edx
f0101439:	39 d3                	cmp    %edx,%ebx
f010143b:	77 ed                	ja     f010142a <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010143d:	89 f0                	mov    %esi,%eax
f010143f:	5b                   	pop    %ebx
f0101440:	5e                   	pop    %esi
f0101441:	5d                   	pop    %ebp
f0101442:	c3                   	ret    

f0101443 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101443:	55                   	push   %ebp
f0101444:	89 e5                	mov    %esp,%ebp
f0101446:	56                   	push   %esi
f0101447:	53                   	push   %ebx
f0101448:	8b 75 08             	mov    0x8(%ebp),%esi
f010144b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010144e:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101451:	89 f0                	mov    %esi,%eax
f0101453:	85 d2                	test   %edx,%edx
f0101455:	74 2b                	je     f0101482 <strlcpy+0x3f>
		while (--size > 0 && *src != '\0')
f0101457:	89 d1                	mov    %edx,%ecx
f0101459:	83 e9 01             	sub    $0x1,%ecx
f010145c:	74 1f                	je     f010147d <strlcpy+0x3a>
f010145e:	0f b6 13             	movzbl (%ebx),%edx
f0101461:	84 d2                	test   %dl,%dl
f0101463:	74 18                	je     f010147d <strlcpy+0x3a>
f0101465:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f0101467:	88 10                	mov    %dl,(%eax)
f0101469:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010146c:	83 e9 01             	sub    $0x1,%ecx
f010146f:	74 0e                	je     f010147f <strlcpy+0x3c>
			*dst++ = *src++;
f0101471:	83 c3 01             	add    $0x1,%ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101474:	0f b6 13             	movzbl (%ebx),%edx
f0101477:	84 d2                	test   %dl,%dl
f0101479:	75 ec                	jne    f0101467 <strlcpy+0x24>
f010147b:	eb 02                	jmp    f010147f <strlcpy+0x3c>
f010147d:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010147f:	c6 00 00             	movb   $0x0,(%eax)
f0101482:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101484:	5b                   	pop    %ebx
f0101485:	5e                   	pop    %esi
f0101486:	5d                   	pop    %ebp
f0101487:	c3                   	ret    

f0101488 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101488:	55                   	push   %ebp
f0101489:	89 e5                	mov    %esp,%ebp
f010148b:	8b 55 08             	mov    0x8(%ebp),%edx
f010148e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
f0101491:	0f b6 02             	movzbl (%edx),%eax
f0101494:	84 c0                	test   %al,%al
f0101496:	74 15                	je     f01014ad <strcmp+0x25>
f0101498:	3a 01                	cmp    (%ecx),%al
f010149a:	75 11                	jne    f01014ad <strcmp+0x25>
		p++, q++;
f010149c:	83 c2 01             	add    $0x1,%edx
f010149f:	83 c1 01             	add    $0x1,%ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01014a2:	0f b6 02             	movzbl (%edx),%eax
f01014a5:	84 c0                	test   %al,%al
f01014a7:	74 04                	je     f01014ad <strcmp+0x25>
f01014a9:	3a 01                	cmp    (%ecx),%al
f01014ab:	74 ef                	je     f010149c <strcmp+0x14>
f01014ad:	0f b6 c0             	movzbl %al,%eax
f01014b0:	0f b6 11             	movzbl (%ecx),%edx
f01014b3:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01014b5:	5d                   	pop    %ebp
f01014b6:	c3                   	ret    

f01014b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01014b7:	55                   	push   %ebp
f01014b8:	89 e5                	mov    %esp,%ebp
f01014ba:	53                   	push   %ebx
f01014bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01014be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01014c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01014c4:	85 d2                	test   %edx,%edx
f01014c6:	74 2f                	je     f01014f7 <strncmp+0x40>
f01014c8:	0f b6 01             	movzbl (%ecx),%eax
f01014cb:	84 c0                	test   %al,%al
f01014cd:	74 1c                	je     f01014eb <strncmp+0x34>
f01014cf:	3a 03                	cmp    (%ebx),%al
f01014d1:	75 18                	jne    f01014eb <strncmp+0x34>
f01014d3:	83 ea 01             	sub    $0x1,%edx
f01014d6:	66 90                	xchg   %ax,%ax
f01014d8:	74 1d                	je     f01014f7 <strncmp+0x40>
		n--, p++, q++;
f01014da:	83 c1 01             	add    $0x1,%ecx
f01014dd:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01014e0:	0f b6 01             	movzbl (%ecx),%eax
f01014e3:	84 c0                	test   %al,%al
f01014e5:	74 04                	je     f01014eb <strncmp+0x34>
f01014e7:	3a 03                	cmp    (%ebx),%al
f01014e9:	74 e8                	je     f01014d3 <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01014eb:	0f b6 11             	movzbl (%ecx),%edx
f01014ee:	0f b6 03             	movzbl (%ebx),%eax
f01014f1:	29 c2                	sub    %eax,%edx
f01014f3:	89 d0                	mov    %edx,%eax
f01014f5:	eb 05                	jmp    f01014fc <strncmp+0x45>
f01014f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014fc:	5b                   	pop    %ebx
f01014fd:	5d                   	pop    %ebp
f01014fe:	c3                   	ret    

f01014ff <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01014ff:	55                   	push   %ebp
f0101500:	89 e5                	mov    %esp,%ebp
f0101502:	8b 45 08             	mov    0x8(%ebp),%eax
f0101505:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101509:	0f b6 10             	movzbl (%eax),%edx
f010150c:	84 d2                	test   %dl,%dl
f010150e:	74 1a                	je     f010152a <strchr+0x2b>
		if (*s == c)
f0101510:	38 ca                	cmp    %cl,%dl
f0101512:	75 06                	jne    f010151a <strchr+0x1b>
f0101514:	eb 19                	jmp    f010152f <strchr+0x30>
f0101516:	38 ca                	cmp    %cl,%dl
f0101518:	74 15                	je     f010152f <strchr+0x30>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010151a:	83 c0 01             	add    $0x1,%eax
f010151d:	0f b6 10             	movzbl (%eax),%edx
f0101520:	84 d2                	test   %dl,%dl
f0101522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101528:	75 ec                	jne    f0101516 <strchr+0x17>
f010152a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f010152f:	5d                   	pop    %ebp
f0101530:	c3                   	ret    

f0101531 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101531:	55                   	push   %ebp
f0101532:	89 e5                	mov    %esp,%ebp
f0101534:	8b 45 08             	mov    0x8(%ebp),%eax
f0101537:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010153b:	0f b6 10             	movzbl (%eax),%edx
f010153e:	84 d2                	test   %dl,%dl
f0101540:	74 20                	je     f0101562 <strfind+0x31>
		if (*s == c)
f0101542:	38 ca                	cmp    %cl,%dl
f0101544:	75 0c                	jne    f0101552 <strfind+0x21>
f0101546:	eb 1a                	jmp    f0101562 <strfind+0x31>
f0101548:	38 ca                	cmp    %cl,%dl
f010154a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101550:	74 10                	je     f0101562 <strfind+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101552:	83 c0 01             	add    $0x1,%eax
f0101555:	0f b6 10             	movzbl (%eax),%edx
f0101558:	84 d2                	test   %dl,%dl
f010155a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101560:	75 e6                	jne    f0101548 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101562:	5d                   	pop    %ebp
f0101563:	90                   	nop    
f0101564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101568:	c3                   	ret    

f0101569 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101569:	55                   	push   %ebp
f010156a:	89 e5                	mov    %esp,%ebp
f010156c:	83 ec 0c             	sub    $0xc,%esp
f010156f:	89 1c 24             	mov    %ebx,(%esp)
f0101572:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101576:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010157a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010157d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *p;

	if (n == 0)
f0101580:	85 f6                	test   %esi,%esi
f0101582:	74 3b                	je     f01015bf <memset+0x56>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101584:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010158a:	75 2b                	jne    f01015b7 <memset+0x4e>
f010158c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101592:	75 23                	jne    f01015b7 <memset+0x4e>
		c &= 0xFF;
f0101594:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101598:	89 d3                	mov    %edx,%ebx
f010159a:	c1 e3 08             	shl    $0x8,%ebx
f010159d:	89 d0                	mov    %edx,%eax
f010159f:	c1 e0 18             	shl    $0x18,%eax
f01015a2:	89 d1                	mov    %edx,%ecx
f01015a4:	c1 e1 10             	shl    $0x10,%ecx
f01015a7:	09 c8                	or     %ecx,%eax
f01015a9:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f01015ab:	09 d8                	or     %ebx,%eax
f01015ad:	89 f1                	mov    %esi,%ecx
f01015af:	c1 e9 02             	shr    $0x2,%ecx
f01015b2:	fc                   	cld    
f01015b3:	f3 ab                	rep stos %eax,%es:(%edi)
f01015b5:	eb 08                	jmp    f01015bf <memset+0x56>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01015b7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ba:	89 f1                	mov    %esi,%ecx
f01015bc:	fc                   	cld    
f01015bd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01015bf:	89 f8                	mov    %edi,%eax
f01015c1:	8b 1c 24             	mov    (%esp),%ebx
f01015c4:	8b 74 24 04          	mov    0x4(%esp),%esi
f01015c8:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01015cc:	89 ec                	mov    %ebp,%esp
f01015ce:	5d                   	pop    %ebp
f01015cf:	c3                   	ret    

f01015d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01015d0:	55                   	push   %ebp
f01015d1:	89 e5                	mov    %esp,%ebp
f01015d3:	83 ec 0c             	sub    $0xc,%esp
f01015d6:	89 1c 24             	mov    %ebx,(%esp)
f01015d9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01015dd:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01015e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01015e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f01015e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f01015ea:	89 df                	mov    %ebx,%edi
	if (s < d && s + n > d) {
f01015ec:	39 de                	cmp    %ebx,%esi
f01015ee:	73 31                	jae    f0101621 <memmove+0x51>
f01015f0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01015f3:	39 d3                	cmp    %edx,%ebx
f01015f5:	73 2a                	jae    f0101621 <memmove+0x51>
		s += n;
		d += n;
f01015f7:	8d 34 0b             	lea    (%ebx,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015fa:	89 f0                	mov    %esi,%eax
f01015fc:	09 d0                	or     %edx,%eax
f01015fe:	a8 03                	test   $0x3,%al
f0101600:	75 13                	jne    f0101615 <memmove+0x45>
f0101602:	f6 c1 03             	test   $0x3,%cl
f0101605:	75 0e                	jne    f0101615 <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0101607:	8d 7e fc             	lea    -0x4(%esi),%edi
f010160a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010160d:	c1 e9 02             	shr    $0x2,%ecx
f0101610:	fd                   	std    
f0101611:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101613:	eb 09                	jmp    f010161e <memmove+0x4e>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101615:	8d 7e ff             	lea    -0x1(%esi),%edi
f0101618:	8d 72 ff             	lea    -0x1(%edx),%esi
f010161b:	fd                   	std    
f010161c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010161e:	fc                   	cld    
f010161f:	eb 18                	jmp    f0101639 <memmove+0x69>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101621:	89 f0                	mov    %esi,%eax
f0101623:	09 f8                	or     %edi,%eax
f0101625:	a8 03                	test   $0x3,%al
f0101627:	75 0d                	jne    f0101636 <memmove+0x66>
f0101629:	f6 c1 03             	test   $0x3,%cl
f010162c:	75 08                	jne    f0101636 <memmove+0x66>
			asm volatile("cld; rep movsl\n"
f010162e:	c1 e9 02             	shr    $0x2,%ecx
f0101631:	fc                   	cld    
f0101632:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101634:	eb 03                	jmp    f0101639 <memmove+0x69>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101636:	fc                   	cld    
f0101637:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101639:	89 d8                	mov    %ebx,%eax
f010163b:	8b 1c 24             	mov    (%esp),%ebx
f010163e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101642:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101646:	89 ec                	mov    %ebp,%esp
f0101648:	5d                   	pop    %ebp
f0101649:	c3                   	ret    

f010164a <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f010164a:	55                   	push   %ebp
f010164b:	89 e5                	mov    %esp,%ebp
f010164d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101650:	8b 45 10             	mov    0x10(%ebp),%eax
f0101653:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101657:	8b 45 0c             	mov    0xc(%ebp),%eax
f010165a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010165e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101661:	89 04 24             	mov    %eax,(%esp)
f0101664:	e8 67 ff ff ff       	call   f01015d0 <memmove>
}
f0101669:	c9                   	leave  
f010166a:	c3                   	ret    

f010166b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010166b:	55                   	push   %ebp
f010166c:	89 e5                	mov    %esp,%ebp
f010166e:	57                   	push   %edi
f010166f:	56                   	push   %esi
f0101670:	53                   	push   %ebx
f0101671:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101674:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101677:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010167a:	85 c0                	test   %eax,%eax
f010167c:	74 38                	je     f01016b6 <memcmp+0x4b>
		if (*s1 != *s2)
f010167e:	0f b6 17             	movzbl (%edi),%edx
f0101681:	0f b6 1e             	movzbl (%esi),%ebx
f0101684:	38 da                	cmp    %bl,%dl
f0101686:	74 22                	je     f01016aa <memcmp+0x3f>
f0101688:	eb 14                	jmp    f010169e <memcmp+0x33>
f010168a:	0f b6 54 0f 01       	movzbl 0x1(%edi,%ecx,1),%edx
f010168f:	0f b6 5c 0e 01       	movzbl 0x1(%esi,%ecx,1),%ebx
f0101694:	83 c1 01             	add    $0x1,%ecx
f0101697:	83 e8 01             	sub    $0x1,%eax
f010169a:	38 da                	cmp    %bl,%dl
f010169c:	74 14                	je     f01016b2 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f010169e:	0f b6 d2             	movzbl %dl,%edx
f01016a1:	0f b6 c3             	movzbl %bl,%eax
f01016a4:	29 c2                	sub    %eax,%edx
f01016a6:	89 d0                	mov    %edx,%eax
f01016a8:	eb 11                	jmp    f01016bb <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016aa:	83 e8 01             	sub    $0x1,%eax
f01016ad:	b9 00 00 00 00       	mov    $0x0,%ecx
f01016b2:	85 c0                	test   %eax,%eax
f01016b4:	75 d4                	jne    f010168a <memcmp+0x1f>
f01016b6:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f01016bb:	5b                   	pop    %ebx
f01016bc:	5e                   	pop    %esi
f01016bd:	5f                   	pop    %edi
f01016be:	5d                   	pop    %ebp
f01016bf:	c3                   	ret    

f01016c0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01016c0:	55                   	push   %ebp
f01016c1:	89 e5                	mov    %esp,%ebp
f01016c3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01016c6:	89 c1                	mov    %eax,%ecx
f01016c8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
f01016cb:	39 c8                	cmp    %ecx,%eax
f01016cd:	73 1b                	jae    f01016ea <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
f01016cf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
f01016d3:	38 10                	cmp    %dl,(%eax)
f01016d5:	75 0b                	jne    f01016e2 <memfind+0x22>
f01016d7:	eb 11                	jmp    f01016ea <memfind+0x2a>
f01016d9:	38 10                	cmp    %dl,(%eax)
f01016db:	90                   	nop    
f01016dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01016e0:	74 08                	je     f01016ea <memfind+0x2a>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01016e2:	83 c0 01             	add    $0x1,%eax
f01016e5:	39 c1                	cmp    %eax,%ecx
f01016e7:	90                   	nop    
f01016e8:	77 ef                	ja     f01016d9 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01016ea:	5d                   	pop    %ebp
f01016eb:	90                   	nop    
f01016ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01016f0:	c3                   	ret    

f01016f1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01016f1:	55                   	push   %ebp
f01016f2:	89 e5                	mov    %esp,%ebp
f01016f4:	57                   	push   %edi
f01016f5:	56                   	push   %esi
f01016f6:	53                   	push   %ebx
f01016f7:	83 ec 04             	sub    $0x4,%esp
f01016fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016fd:	8b 7d 10             	mov    0x10(%ebp),%edi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101700:	0f b6 01             	movzbl (%ecx),%eax
f0101703:	3c 20                	cmp    $0x20,%al
f0101705:	74 04                	je     f010170b <strtol+0x1a>
f0101707:	3c 09                	cmp    $0x9,%al
f0101709:	75 0e                	jne    f0101719 <strtol+0x28>
		s++;
f010170b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010170e:	0f b6 01             	movzbl (%ecx),%eax
f0101711:	3c 20                	cmp    $0x20,%al
f0101713:	74 f6                	je     f010170b <strtol+0x1a>
f0101715:	3c 09                	cmp    $0x9,%al
f0101717:	74 f2                	je     f010170b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101719:	3c 2b                	cmp    $0x2b,%al
f010171b:	75 0d                	jne    f010172a <strtol+0x39>
		s++;
f010171d:	83 c1 01             	add    $0x1,%ecx
f0101720:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101727:	90                   	nop    
f0101728:	eb 15                	jmp    f010173f <strtol+0x4e>
	else if (*s == '-')
f010172a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101731:	3c 2d                	cmp    $0x2d,%al
f0101733:	75 0a                	jne    f010173f <strtol+0x4e>
		s++, neg = 1;
f0101735:	83 c1 01             	add    $0x1,%ecx
f0101738:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010173f:	85 ff                	test   %edi,%edi
f0101741:	0f 94 c0             	sete   %al
f0101744:	74 05                	je     f010174b <strtol+0x5a>
f0101746:	83 ff 10             	cmp    $0x10,%edi
f0101749:	75 1f                	jne    f010176a <strtol+0x79>
f010174b:	80 39 30             	cmpb   $0x30,(%ecx)
f010174e:	75 1a                	jne    f010176a <strtol+0x79>
f0101750:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101758:	75 10                	jne    f010176a <strtol+0x79>
		s += 2, base = 16;
f010175a:	83 c1 02             	add    $0x2,%ecx
f010175d:	bf 10 00 00 00       	mov    $0x10,%edi
f0101762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101768:	eb 2d                	jmp    f0101797 <strtol+0xa6>
	else if (base == 0 && s[0] == '0')
f010176a:	85 ff                	test   %edi,%edi
f010176c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101770:	75 18                	jne    f010178a <strtol+0x99>
f0101772:	80 39 30             	cmpb   $0x30,(%ecx)
f0101775:	8d 76 00             	lea    0x0(%esi),%esi
f0101778:	75 18                	jne    f0101792 <strtol+0xa1>
		s++, base = 8;
f010177a:	83 c1 01             	add    $0x1,%ecx
f010177d:	66 bf 08 00          	mov    $0x8,%di
f0101781:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101788:	eb 0d                	jmp    f0101797 <strtol+0xa6>
	else if (base == 0)
f010178a:	84 c0                	test   %al,%al
f010178c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101790:	74 05                	je     f0101797 <strtol+0xa6>
f0101792:	bf 0a 00 00 00       	mov    $0xa,%edi
f0101797:	be 00 00 00 00       	mov    $0x0,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010179c:	0f b6 11             	movzbl (%ecx),%edx
f010179f:	89 d3                	mov    %edx,%ebx
f01017a1:	8d 42 d0             	lea    -0x30(%edx),%eax
f01017a4:	3c 09                	cmp    $0x9,%al
f01017a6:	77 08                	ja     f01017b0 <strtol+0xbf>
			dig = *s - '0';
f01017a8:	0f be c2             	movsbl %dl,%eax
f01017ab:	8d 50 d0             	lea    -0x30(%eax),%edx
f01017ae:	eb 1c                	jmp    f01017cc <strtol+0xdb>
		else if (*s >= 'a' && *s <= 'z')
f01017b0:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01017b3:	3c 19                	cmp    $0x19,%al
f01017b5:	77 08                	ja     f01017bf <strtol+0xce>
			dig = *s - 'a' + 10;
f01017b7:	0f be c2             	movsbl %dl,%eax
f01017ba:	8d 50 a9             	lea    -0x57(%eax),%edx
f01017bd:	eb 0d                	jmp    f01017cc <strtol+0xdb>
		else if (*s >= 'A' && *s <= 'Z')
f01017bf:	8d 43 bf             	lea    -0x41(%ebx),%eax
f01017c2:	3c 19                	cmp    $0x19,%al
f01017c4:	77 17                	ja     f01017dd <strtol+0xec>
			dig = *s - 'A' + 10;
f01017c6:	0f be c2             	movsbl %dl,%eax
f01017c9:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
f01017cc:	39 fa                	cmp    %edi,%edx
f01017ce:	7d 0d                	jge    f01017dd <strtol+0xec>
			break;
		s++, val = (val * base) + dig;
f01017d0:	83 c1 01             	add    $0x1,%ecx
f01017d3:	89 f0                	mov    %esi,%eax
f01017d5:	0f af c7             	imul   %edi,%eax
f01017d8:	8d 34 02             	lea    (%edx,%eax,1),%esi
f01017db:	eb bf                	jmp    f010179c <strtol+0xab>
		// we don't properly detect overflow!
	}
f01017dd:	89 f0                	mov    %esi,%eax

	if (endptr)
f01017df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01017e3:	74 05                	je     f01017ea <strtol+0xf9>
		*endptr = (char *) s;
f01017e5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017e8:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
f01017ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01017ee:	74 04                	je     f01017f4 <strtol+0x103>
f01017f0:	89 c6                	mov    %eax,%esi
f01017f2:	f7 de                	neg    %esi
}
f01017f4:	89 f0                	mov    %esi,%eax
f01017f6:	83 c4 04             	add    $0x4,%esp
f01017f9:	5b                   	pop    %ebx
f01017fa:	5e                   	pop    %esi
f01017fb:	5f                   	pop    %edi
f01017fc:	5d                   	pop    %ebp
f01017fd:	c3                   	ret    
	...

f0101800 <__udivdi3>:
f0101800:	55                   	push   %ebp
f0101801:	89 e5                	mov    %esp,%ebp
f0101803:	57                   	push   %edi
f0101804:	56                   	push   %esi
f0101805:	83 ec 1c             	sub    $0x1c,%esp
f0101808:	8b 45 10             	mov    0x10(%ebp),%eax
f010180b:	8b 55 08             	mov    0x8(%ebp),%edx
f010180e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101811:	89 c6                	mov    %eax,%esi
f0101813:	8b 45 14             	mov    0x14(%ebp),%eax
f0101816:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101819:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010181c:	85 c0                	test   %eax,%eax
f010181e:	75 38                	jne    f0101858 <__udivdi3+0x58>
f0101820:	39 ce                	cmp    %ecx,%esi
f0101822:	77 4c                	ja     f0101870 <__udivdi3+0x70>
f0101824:	85 f6                	test   %esi,%esi
f0101826:	75 0d                	jne    f0101835 <__udivdi3+0x35>
f0101828:	b9 01 00 00 00       	mov    $0x1,%ecx
f010182d:	31 d2                	xor    %edx,%edx
f010182f:	89 c8                	mov    %ecx,%eax
f0101831:	f7 f6                	div    %esi
f0101833:	89 c6                	mov    %eax,%esi
f0101835:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101838:	31 d2                	xor    %edx,%edx
f010183a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010183d:	89 f8                	mov    %edi,%eax
f010183f:	f7 f6                	div    %esi
f0101841:	89 c7                	mov    %eax,%edi
f0101843:	89 c8                	mov    %ecx,%eax
f0101845:	f7 f6                	div    %esi
f0101847:	89 fe                	mov    %edi,%esi
f0101849:	89 c1                	mov    %eax,%ecx
f010184b:	89 c8                	mov    %ecx,%eax
f010184d:	89 f2                	mov    %esi,%edx
f010184f:	83 c4 1c             	add    $0x1c,%esp
f0101852:	5e                   	pop    %esi
f0101853:	5f                   	pop    %edi
f0101854:	5d                   	pop    %ebp
f0101855:	c3                   	ret    
f0101856:	66 90                	xchg   %ax,%ax
f0101858:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f010185b:	76 2b                	jbe    f0101888 <__udivdi3+0x88>
f010185d:	31 c9                	xor    %ecx,%ecx
f010185f:	31 f6                	xor    %esi,%esi
f0101861:	89 c8                	mov    %ecx,%eax
f0101863:	89 f2                	mov    %esi,%edx
f0101865:	83 c4 1c             	add    $0x1c,%esp
f0101868:	5e                   	pop    %esi
f0101869:	5f                   	pop    %edi
f010186a:	5d                   	pop    %ebp
f010186b:	c3                   	ret    
f010186c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101870:	89 d1                	mov    %edx,%ecx
f0101872:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101875:	89 c8                	mov    %ecx,%eax
f0101877:	f7 f6                	div    %esi
f0101879:	31 f6                	xor    %esi,%esi
f010187b:	89 c1                	mov    %eax,%ecx
f010187d:	89 c8                	mov    %ecx,%eax
f010187f:	89 f2                	mov    %esi,%edx
f0101881:	83 c4 1c             	add    $0x1c,%esp
f0101884:	5e                   	pop    %esi
f0101885:	5f                   	pop    %edi
f0101886:	5d                   	pop    %ebp
f0101887:	c3                   	ret    
f0101888:	0f bd f8             	bsr    %eax,%edi
f010188b:	83 f7 1f             	xor    $0x1f,%edi
f010188e:	75 20                	jne    f01018b0 <__udivdi3+0xb0>
f0101890:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0101893:	72 05                	jb     f010189a <__udivdi3+0x9a>
f0101895:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101898:	77 c3                	ja     f010185d <__udivdi3+0x5d>
f010189a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010189f:	31 f6                	xor    %esi,%esi
f01018a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018a8:	eb b7                	jmp    f0101861 <__udivdi3+0x61>
f01018aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018b0:	89 f9                	mov    %edi,%ecx
f01018b2:	89 f2                	mov    %esi,%edx
f01018b4:	d3 e0                	shl    %cl,%eax
f01018b6:	b9 20 00 00 00       	mov    $0x20,%ecx
f01018bb:	29 f9                	sub    %edi,%ecx
f01018bd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01018c0:	d3 ea                	shr    %cl,%edx
f01018c2:	89 f9                	mov    %edi,%ecx
f01018c4:	d3 e6                	shl    %cl,%esi
f01018c6:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f01018ca:	09 d0                	or     %edx,%eax
f01018cc:	89 75 f4             	mov    %esi,-0xc(%ebp)
f01018cf:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01018d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01018d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01018d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01018db:	d3 ee                	shr    %cl,%esi
f01018dd:	89 f9                	mov    %edi,%ecx
f01018df:	d3 e2                	shl    %cl,%edx
f01018e1:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f01018e5:	d3 e8                	shr    %cl,%eax
f01018e7:	09 d0                	or     %edx,%eax
f01018e9:	89 f2                	mov    %esi,%edx
f01018eb:	f7 75 f0             	divl   -0x10(%ebp)
f01018ee:	89 d6                	mov    %edx,%esi
f01018f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01018f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01018f6:	f7 65 e0             	mull   -0x20(%ebp)
f01018f9:	39 d6                	cmp    %edx,%esi
f01018fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01018fe:	72 20                	jb     f0101920 <__udivdi3+0x120>
f0101900:	74 0e                	je     f0101910 <__udivdi3+0x110>
f0101902:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101905:	31 f6                	xor    %esi,%esi
f0101907:	e9 55 ff ff ff       	jmp    f0101861 <__udivdi3+0x61>
f010190c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101910:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101913:	89 f9                	mov    %edi,%ecx
f0101915:	d3 e0                	shl    %cl,%eax
f0101917:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f010191a:	73 e6                	jae    f0101902 <__udivdi3+0x102>
f010191c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101920:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101923:	31 f6                	xor    %esi,%esi
f0101925:	83 e9 01             	sub    $0x1,%ecx
f0101928:	e9 34 ff ff ff       	jmp    f0101861 <__udivdi3+0x61>
f010192d:	00 00                	add    %al,(%eax)
	...

f0101930 <__umoddi3>:
f0101930:	55                   	push   %ebp
f0101931:	89 e5                	mov    %esp,%ebp
f0101933:	57                   	push   %edi
f0101934:	56                   	push   %esi
f0101935:	83 ec 20             	sub    $0x20,%esp
f0101938:	8b 45 10             	mov    0x10(%ebp),%eax
f010193b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010193e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101941:	89 c7                	mov    %eax,%edi
f0101943:	8b 45 14             	mov    0x14(%ebp),%eax
f0101946:	89 4d e8             	mov    %ecx,-0x18(%ebp)
f0101949:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f010194c:	85 c0                	test   %eax,%eax
f010194e:	75 18                	jne    f0101968 <__umoddi3+0x38>
f0101950:	39 f7                	cmp    %esi,%edi
f0101952:	76 24                	jbe    f0101978 <__umoddi3+0x48>
f0101954:	89 c8                	mov    %ecx,%eax
f0101956:	89 f2                	mov    %esi,%edx
f0101958:	f7 f7                	div    %edi
f010195a:	89 d0                	mov    %edx,%eax
f010195c:	31 d2                	xor    %edx,%edx
f010195e:	83 c4 20             	add    $0x20,%esp
f0101961:	5e                   	pop    %esi
f0101962:	5f                   	pop    %edi
f0101963:	5d                   	pop    %ebp
f0101964:	c3                   	ret    
f0101965:	8d 76 00             	lea    0x0(%esi),%esi
f0101968:	39 f0                	cmp    %esi,%eax
f010196a:	76 2c                	jbe    f0101998 <__umoddi3+0x68>
f010196c:	89 c8                	mov    %ecx,%eax
f010196e:	89 f2                	mov    %esi,%edx
f0101970:	83 c4 20             	add    $0x20,%esp
f0101973:	5e                   	pop    %esi
f0101974:	5f                   	pop    %edi
f0101975:	5d                   	pop    %ebp
f0101976:	c3                   	ret    
f0101977:	90                   	nop    
f0101978:	85 ff                	test   %edi,%edi
f010197a:	75 0b                	jne    f0101987 <__umoddi3+0x57>
f010197c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101981:	31 d2                	xor    %edx,%edx
f0101983:	f7 f7                	div    %edi
f0101985:	89 c7                	mov    %eax,%edi
f0101987:	89 f0                	mov    %esi,%eax
f0101989:	31 d2                	xor    %edx,%edx
f010198b:	f7 f7                	div    %edi
f010198d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101990:	f7 f7                	div    %edi
f0101992:	eb c6                	jmp    f010195a <__umoddi3+0x2a>
f0101994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101998:	0f bd d0             	bsr    %eax,%edx
f010199b:	83 f2 1f             	xor    $0x1f,%edx
f010199e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01019a1:	75 1d                	jne    f01019c0 <__umoddi3+0x90>
f01019a3:	39 f0                	cmp    %esi,%eax
f01019a5:	0f 83 b5 00 00 00    	jae    f0101a60 <__umoddi3+0x130>
f01019ab:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01019ae:	29 f9                	sub    %edi,%ecx
f01019b0:	19 c6                	sbb    %eax,%esi
f01019b2:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f01019b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01019b8:	89 f2                	mov    %esi,%edx
f01019ba:	eb b4                	jmp    f0101970 <__umoddi3+0x40>
f01019bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019c0:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f01019c4:	89 c2                	mov    %eax,%edx
f01019c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01019cb:	2b 45 e4             	sub    -0x1c(%ebp),%eax
f01019ce:	d3 e2                	shl    %cl,%edx
f01019d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01019d3:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f01019d7:	89 f8                	mov    %edi,%eax
f01019d9:	d3 e8                	shr    %cl,%eax
f01019db:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f01019df:	09 d0                	or     %edx,%eax
f01019e1:	89 f2                	mov    %esi,%edx
f01019e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01019e6:	89 f0                	mov    %esi,%eax
f01019e8:	d3 e7                	shl    %cl,%edi
f01019ea:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f01019ee:	89 7d f4             	mov    %edi,-0xc(%ebp)
f01019f1:	8b 7d e8             	mov    -0x18(%ebp),%edi
f01019f4:	d3 e8                	shr    %cl,%eax
f01019f6:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f01019fa:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01019fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101a00:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101a03:	d3 e2                	shl    %cl,%edx
f0101a05:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101a09:	d3 e8                	shr    %cl,%eax
f0101a0b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101a0f:	09 d0                	or     %edx,%eax
f0101a11:	89 f2                	mov    %esi,%edx
f0101a13:	f7 75 f0             	divl   -0x10(%ebp)
f0101a16:	89 d6                	mov    %edx,%esi
f0101a18:	d3 e7                	shl    %cl,%edi
f0101a1a:	f7 65 f4             	mull   -0xc(%ebp)
f0101a1d:	39 d6                	cmp    %edx,%esi
f0101a1f:	73 2f                	jae    f0101a50 <__umoddi3+0x120>
f0101a21:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0101a24:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0101a27:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101a2b:	29 c7                	sub    %eax,%edi
f0101a2d:	19 d6                	sbb    %edx,%esi
f0101a2f:	89 fa                	mov    %edi,%edx
f0101a31:	89 f0                	mov    %esi,%eax
f0101a33:	d3 ea                	shr    %cl,%edx
f0101a35:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101a39:	d3 e0                	shl    %cl,%eax
f0101a3b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101a3f:	09 d0                	or     %edx,%eax
f0101a41:	89 f2                	mov    %esi,%edx
f0101a43:	d3 ea                	shr    %cl,%edx
f0101a45:	e9 26 ff ff ff       	jmp    f0101970 <__umoddi3+0x40>
f0101a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a50:	75 d5                	jne    f0101a27 <__umoddi3+0xf7>
f0101a52:	39 c7                	cmp    %eax,%edi
f0101a54:	73 d1                	jae    f0101a27 <__umoddi3+0xf7>
f0101a56:	66 90                	xchg   %ax,%ax
f0101a58:	eb c7                	jmp    f0101a21 <__umoddi3+0xf1>
f0101a5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a60:	3b 7d ec             	cmp    -0x14(%ebp),%edi
f0101a63:	90                   	nop    
f0101a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a68:	0f 87 47 ff ff ff    	ja     f01019b5 <__umoddi3+0x85>
f0101a6e:	66 90                	xchg   %ax,%ax
f0101a70:	e9 36 ff ff ff       	jmp    f01019ab <__umoddi3+0x7b>
