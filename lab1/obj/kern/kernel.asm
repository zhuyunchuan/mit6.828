
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
f0100054:	c7 04 24 e0 1a 10 f0 	movl   $0xf0101ae0,(%esp)
f010005b:	e8 5b 09 00 00       	call   f01009bb <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 16 09 00 00       	call   f0100988 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 cb 1d 10 f0 	movl   $0xf0101dcb,(%esp)
f0100079:	e8 3d 09 00 00       	call   f01009bb <cprintf>
	va_end(ap);
}
f010007e:	c9                   	leave  
f010007f:	c3                   	ret    

f0100080 <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void _panic(const char *file, int line, const char *fmt,...)
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
f01000a5:	c7 04 24 fa 1a 10 f0 	movl   $0xf0101afa,(%esp)
f01000ac:	e8 0a 09 00 00       	call   f01009bb <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 c5 08 00 00       	call   f0100988 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 cb 1d 10 f0 	movl   $0xf0101dcb,(%esp)
f01000ca:	e8 ec 08 00 00       	call   f01009bb <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 41 07 00 00       	call   f010081c <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <test_backtrace>:
#include <kern/monitor.h>
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void test_backtrace(int x)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	53                   	push   %ebx
f01000e1:	83 ec 14             	sub    $0x14,%esp
f01000e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f01000e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000eb:	c7 04 24 12 1b 10 f0 	movl   $0xf0101b12,(%esp)
f01000f2:	e8 c4 08 00 00       	call   f01009bb <cprintf>
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
f0100121:	e8 82 05 00 00       	call   f01006a8 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100126:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010012a:	c7 04 24 2e 1b 10 f0 	movl   $0xf0101b2e,(%esp)
f0100131:	e8 85 08 00 00       	call   f01009bb <cprintf>
}
f0100136:	83 c4 14             	add    $0x14,%esp
f0100139:	5b                   	pop    %ebx
f010013a:	5d                   	pop    %ebp
f010013b:	c3                   	ret    

f010013c <i386_init>:

void i386_init(void)
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
f010015f:	e8 55 14 00 00       	call   f01015b9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100164:	e8 45 03 00 00       	call   f01004ae <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100169:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100170:	00 
f0100171:	c7 04 24 49 1b 10 f0 	movl   $0xf0101b49,(%esp)
f0100178:	e8 3e 08 00 00       	call   f01009bb <cprintf>




	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010017d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100184:	e8 54 ff ff ff       	call   f01000dd <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100190:	e8 87 06 00 00       	call   f010081c <monitor>
f0100195:	eb f2                	jmp    f0100189 <i386_init+0x4d>
	...

f01001a0 <delay>:
static void cons_intr(int (*proc)(void));
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void delay(void)
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
#define COM_LSR_TSRE	0x40	//   Transmitter off

static bool serial_exists;

static int serial_proc_data(void)
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
		return -1;
	return inb(COM1+COM_RX);
}

void serial_intr(void)
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
{
	cons_putc(c);
}

int getchar(void)
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
	return 0;
}

// output a character to the console
static void cons_putc(int c)
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
static void serial_putc(int c)
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
static void serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002c8:	a8 20                	test   $0x20,%al
f01002ca:	75 0b                	jne    f01002d7 <cons_putc+0x36>
	     i++)
f01002cc:	83 c3 01             	add    $0x1,%ebx
static void serial_putc(int c)
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
			 "memory", "cc");
}

static __inline void outb(int port, uint8_t data)
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
			 "memory", "cc");
}

static __inline void outb(int port, uint8_t data)
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


static void cga_putc(int c)
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
f010043e:	e8 dd 11 00 00       	call   f0101620 <memmove>
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
static void cons_putc(int c)
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

void cputchar(int c)
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
			 "memory", "cc");
}

static __inline void outb(int port, uint8_t data)
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
			 "memory", "cc");
}

static __inline void outb(int port, uint8_t data)
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
f010058d:	c7 04 24 64 1b 10 f0 	movl   $0xf0101b64,(%esp)
f0100594:	e8 22 04 00 00       	call   f01009bb <cprintf>
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
f01005ed:	0f b6 80 a0 1b 10 f0 	movzbl -0xfefe460(%eax),%eax
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
f0100624:	0f b6 81 a0 1b 10 f0 	movzbl -0xfefe460(%ecx),%eax
f010062b:	0b 05 40 03 11 f0    	or     0xf0110340,%eax
f0100631:	0f b6 91 a0 1c 10 f0 	movzbl -0xfefe360(%ecx),%edx
f0100638:	31 c2                	xor    %eax,%edx
f010063a:	89 15 40 03 11 f0    	mov    %edx,0xf0110340

	c = charcode[shift & (CTL | SHIFT)][data];
f0100640:	89 d0                	mov    %edx,%eax
f0100642:	83 e0 03             	and    $0x3,%eax
f0100645:	8b 04 85 a0 1d 10 f0 	mov    -0xfefe260(,%eax,4),%eax
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
f010067d:	c7 04 24 81 1b 10 f0 	movl   $0xf0101b81,(%esp)
f0100684:	e8 32 03 00 00       	call   f01009bb <cprintf>
			 "memory", "cc");
}

static __inline void outb(int port, uint8_t data)
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

f01006a0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006a0:	55                   	push   %ebp
f01006a1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006a3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006a6:	5d                   	pop    %ebp
f01006a7:	c3                   	ret    

f01006a8 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006a8:	55                   	push   %ebp
f01006a9:	89 e5                	mov    %esp,%ebp
f01006ab:	57                   	push   %edi
f01006ac:	56                   	push   %esi
f01006ad:	53                   	push   %ebx
f01006ae:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01006b1:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t ebp_addr = read_ebp();	
	uint32_t eip_addr = *((uint32_t*)(ebp_addr + 1));
f01006b3:	8b 43 01             	mov    0x1(%ebx),%eax
f01006b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
	uint32_t arg1 = *((uint32_t*)(ebp_addr + 2));
f01006b9:	8b 43 02             	mov    0x2(%ebx),%eax
f01006bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32_t arg2 = *((uint32_t*)(ebp_addr + 3));
f01006bf:	8b 7b 03             	mov    0x3(%ebx),%edi
	uint32_t arg3 = *((uint32_t*)(ebp_addr + 4));
f01006c2:	8b 73 04             	mov    0x4(%ebx),%esi

	do
	{
		cprintf("ebp %x eip %x arg %x %x %x \n", ebp_addr, eip_addr, arg1, arg2, arg3);
f01006c5:	89 74 24 14          	mov    %esi,0x14(%esp)
f01006c9:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01006cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01006d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01006d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01006d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01006df:	c7 04 24 b0 1d 10 f0 	movl   $0xf0101db0,(%esp)
f01006e6:	e8 d0 02 00 00       	call   f01009bb <cprintf>
		ebp_addr = *((uint32_t*)(ebp_addr));
f01006eb:	8b 1b                	mov    (%ebx),%ebx
			uint32_t eip_addr = *((uint32_t*)(ebp_addr + 1));
			uint32_t arg1 = *((uint32_t*)(ebp_addr + 2));
			uint32_t arg2 = *((uint32_t*)(ebp_addr + 3));
			uint32_t arg3 = *((uint32_t*)(ebp_addr + 4));
		}
	}while(ebp_addr != 0);
f01006ed:	85 db                	test   %ebx,%ebx
f01006ef:	75 d4                	jne    f01006c5 <mon_backtrace+0x1d>

	return 0;
}
f01006f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f6:	83 c4 2c             	add    $0x2c,%esp
f01006f9:	5b                   	pop    %ebx
f01006fa:	5e                   	pop    %esi
f01006fb:	5f                   	pop    %edi
f01006fc:	5d                   	pop    %ebp
f01006fd:	c3                   	ret    

f01006fe <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006fe:	55                   	push   %ebp
f01006ff:	89 e5                	mov    %esp,%ebp
f0100701:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100704:	c7 04 24 cd 1d 10 f0 	movl   $0xf0101dcd,(%esp)
f010070b:	e8 ab 02 00 00       	call   f01009bb <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100710:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100717:	00 
f0100718:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010071f:	f0 
f0100720:	c7 04 24 64 1e 10 f0 	movl   $0xf0101e64,(%esp)
f0100727:	e8 8f 02 00 00       	call   f01009bb <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010072c:	c7 44 24 08 c5 1a 10 	movl   $0x101ac5,0x8(%esp)
f0100733:	00 
f0100734:	c7 44 24 04 c5 1a 10 	movl   $0xf0101ac5,0x4(%esp)
f010073b:	f0 
f010073c:	c7 04 24 88 1e 10 f0 	movl   $0xf0101e88,(%esp)
f0100743:	e8 73 02 00 00       	call   f01009bb <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100748:	c7 44 24 08 20 03 11 	movl   $0x110320,0x8(%esp)
f010074f:	00 
f0100750:	c7 44 24 04 20 03 11 	movl   $0xf0110320,0x4(%esp)
f0100757:	f0 
f0100758:	c7 04 24 ac 1e 10 f0 	movl   $0xf0101eac,(%esp)
f010075f:	e8 57 02 00 00       	call   f01009bb <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100764:	c7 44 24 08 80 09 11 	movl   $0x110980,0x8(%esp)
f010076b:	00 
f010076c:	c7 44 24 04 80 09 11 	movl   $0xf0110980,0x4(%esp)
f0100773:	f0 
f0100774:	c7 04 24 d0 1e 10 f0 	movl   $0xf0101ed0,(%esp)
f010077b:	e8 3b 02 00 00       	call   f01009bb <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100780:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0100785:	81 ea 0c 00 10 f0    	sub    $0xf010000c,%edx
f010078b:	81 c2 80 09 11 f0    	add    $0xf0110980,%edx
f0100791:	89 d0                	mov    %edx,%eax
f0100793:	c1 f8 1f             	sar    $0x1f,%eax
f0100796:	c1 e8 16             	shr    $0x16,%eax
f0100799:	01 d0                	add    %edx,%eax
f010079b:	c1 f8 0a             	sar    $0xa,%eax
f010079e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007a2:	c7 04 24 f4 1e 10 f0 	movl   $0xf0101ef4,(%esp)
f01007a9:	e8 0d 02 00 00       	call   f01009bb <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f01007ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b3:	c9                   	leave  
f01007b4:	c3                   	ret    

f01007b5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007b5:	55                   	push   %ebp
f01007b6:	89 e5                	mov    %esp,%ebp
f01007b8:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007bb:	a1 c4 1f 10 f0       	mov    0xf0101fc4,%eax
f01007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007c4:	a1 c0 1f 10 f0       	mov    0xf0101fc0,%eax
f01007c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007cd:	c7 04 24 e6 1d 10 f0 	movl   $0xf0101de6,(%esp)
f01007d4:	e8 e2 01 00 00       	call   f01009bb <cprintf>
f01007d9:	a1 d0 1f 10 f0       	mov    0xf0101fd0,%eax
f01007de:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007e2:	a1 cc 1f 10 f0       	mov    0xf0101fcc,%eax
f01007e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007eb:	c7 04 24 e6 1d 10 f0 	movl   $0xf0101de6,(%esp)
f01007f2:	e8 c4 01 00 00       	call   f01009bb <cprintf>
f01007f7:	a1 dc 1f 10 f0       	mov    0xf0101fdc,%eax
f01007fc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100800:	a1 d8 1f 10 f0       	mov    0xf0101fd8,%eax
f0100805:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100809:	c7 04 24 e6 1d 10 f0 	movl   $0xf0101de6,(%esp)
f0100810:	e8 a6 01 00 00       	call   f01009bb <cprintf>
	return 0;
}
f0100815:	b8 00 00 00 00       	mov    $0x0,%eax
f010081a:	c9                   	leave  
f010081b:	c3                   	ret    

f010081c <monitor>:
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void monitor(struct Trapframe *tf)
{
f010081c:	55                   	push   %ebp
f010081d:	89 e5                	mov    %esp,%ebp
f010081f:	57                   	push   %edi
f0100820:	56                   	push   %esi
f0100821:	53                   	push   %ebx
f0100822:	83 ec 4c             	sub    $0x4c,%esp
f0100825:	8b 7d 08             	mov    0x8(%ebp),%edi
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100828:	c7 04 24 20 1f 10 f0 	movl   $0xf0101f20,(%esp)
f010082f:	e8 87 01 00 00       	call   f01009bb <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100834:	c7 04 24 44 1f 10 f0 	movl   $0xf0101f44,(%esp)
f010083b:	e8 7b 01 00 00       	call   f01009bb <cprintf>


	while (1) {
		buf = readline("K> ");
f0100840:	c7 04 24 ef 1d 10 f0 	movl   $0xf0101def,(%esp)
f0100847:	e8 a4 0a 00 00       	call   f01012f0 <readline>
f010084c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010084e:	85 c0                	test   %eax,%eax
f0100850:	74 ee                	je     f0100840 <monitor+0x24>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100852:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
f0100859:	be 00 00 00 00       	mov    $0x0,%esi
f010085e:	eb 06                	jmp    f0100866 <monitor+0x4a>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100860:	c6 03 00             	movb   $0x0,(%ebx)
f0100863:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100866:	0f b6 03             	movzbl (%ebx),%eax
f0100869:	84 c0                	test   %al,%al
f010086b:	74 70                	je     f01008dd <monitor+0xc1>
f010086d:	0f be c0             	movsbl %al,%eax
f0100870:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100874:	c7 04 24 f3 1d 10 f0 	movl   $0xf0101df3,(%esp)
f010087b:	e8 cf 0c 00 00       	call   f010154f <strchr>
f0100880:	85 c0                	test   %eax,%eax
f0100882:	75 dc                	jne    f0100860 <monitor+0x44>
			*buf++ = 0;
		if (*buf == 0)
f0100884:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100887:	74 54                	je     f01008dd <monitor+0xc1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100889:	83 fe 0f             	cmp    $0xf,%esi
f010088c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100890:	75 16                	jne    f01008a8 <monitor+0x8c>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100892:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100899:	00 
f010089a:	c7 04 24 f8 1d 10 f0 	movl   $0xf0101df8,(%esp)
f01008a1:	e8 15 01 00 00       	call   f01009bb <cprintf>
f01008a6:	eb 98                	jmp    f0100840 <monitor+0x24>
			return 0;
		}
		argv[argc++] = buf;
f01008a8:	89 5c b5 b4          	mov    %ebx,-0x4c(%ebp,%esi,4)
f01008ac:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008af:	0f b6 03             	movzbl (%ebx),%eax
f01008b2:	84 c0                	test   %al,%al
f01008b4:	75 0e                	jne    f01008c4 <monitor+0xa8>
f01008b6:	66 90                	xchg   %ax,%ax
f01008b8:	eb ac                	jmp    f0100866 <monitor+0x4a>
			buf++;
f01008ba:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008bd:	0f b6 03             	movzbl (%ebx),%eax
f01008c0:	84 c0                	test   %al,%al
f01008c2:	74 a2                	je     f0100866 <monitor+0x4a>
f01008c4:	0f be c0             	movsbl %al,%eax
f01008c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008cb:	c7 04 24 f3 1d 10 f0 	movl   $0xf0101df3,(%esp)
f01008d2:	e8 78 0c 00 00       	call   f010154f <strchr>
f01008d7:	85 c0                	test   %eax,%eax
f01008d9:	74 df                	je     f01008ba <monitor+0x9e>
f01008db:	eb 89                	jmp    f0100866 <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f01008dd:	c7 44 b5 b4 00 00 00 	movl   $0x0,-0x4c(%ebp,%esi,4)
f01008e4:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008e5:	85 f6                	test   %esi,%esi
f01008e7:	90                   	nop    
f01008e8:	0f 84 52 ff ff ff    	je     f0100840 <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ee:	ba c0 1f 10 f0       	mov    $0xf0101fc0,%edx
f01008f3:	8b 02                	mov    (%edx),%eax
f01008f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f01008fc:	89 04 24             	mov    %eax,(%esp)
f01008ff:	e8 d4 0b 00 00       	call   f01014d8 <strcmp>
f0100904:	ba 00 00 00 00       	mov    $0x0,%edx
f0100909:	85 c0                	test   %eax,%eax
f010090b:	74 3a                	je     f0100947 <monitor+0x12b>
f010090d:	a1 cc 1f 10 f0       	mov    0xf0101fcc,%eax
f0100912:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100916:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100919:	89 04 24             	mov    %eax,(%esp)
f010091c:	e8 b7 0b 00 00       	call   f01014d8 <strcmp>
f0100921:	ba 01 00 00 00       	mov    $0x1,%edx
f0100926:	85 c0                	test   %eax,%eax
f0100928:	74 1d                	je     f0100947 <monitor+0x12b>
f010092a:	a1 d8 1f 10 f0       	mov    0xf0101fd8,%eax
f010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100933:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100936:	89 04 24             	mov    %eax,(%esp)
f0100939:	e8 9a 0b 00 00       	call   f01014d8 <strcmp>
f010093e:	85 c0                	test   %eax,%eax
f0100940:	75 26                	jne    f0100968 <monitor+0x14c>
f0100942:	ba 02 00 00 00       	mov    $0x2,%edx
			return commands[i].func(argc, argv, tf);
f0100947:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010094a:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010094e:	8d 55 b4             	lea    -0x4c(%ebp),%edx
f0100951:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100955:	89 34 24             	mov    %esi,(%esp)
f0100958:	ff 14 85 c8 1f 10 f0 	call   *-0xfefe038(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010095f:	85 c0                	test   %eax,%eax
f0100961:	78 1d                	js     f0100980 <monitor+0x164>
f0100963:	e9 d8 fe ff ff       	jmp    f0100840 <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100968:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f010096b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010096f:	c7 04 24 15 1e 10 f0 	movl   $0xf0101e15,(%esp)
f0100976:	e8 40 00 00 00       	call   f01009bb <cprintf>
f010097b:	e9 c0 fe ff ff       	jmp    f0100840 <monitor+0x24>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100980:	83 c4 4c             	add    $0x4c,%esp
f0100983:	5b                   	pop    %ebx
f0100984:	5e                   	pop    %esi
f0100985:	5f                   	pop    %edi
f0100986:	5d                   	pop    %ebp
f0100987:	c3                   	ret    

f0100988 <vcprintf>:
	cputchar(ch);
	*cnt++;
}

int vcprintf(const char *fmt, va_list ap)
{
f0100988:	55                   	push   %ebp
f0100989:	89 e5                	mov    %esp,%ebp
f010098b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010098e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100995:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100998:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010099c:	8b 45 08             	mov    0x8(%ebp),%eax
f010099f:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
f01009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009aa:	c7 04 24 d5 09 10 f0 	movl   $0xf01009d5,(%esp)
f01009b1:	e8 ba 04 00 00       	call   f0100e70 <vprintfmt>
f01009b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
	return cnt;
}
f01009b9:	c9                   	leave  
f01009ba:	c3                   	ret    

f01009bb <cprintf>:

int cprintf(const char *fmt, ...)
{
f01009bb:	55                   	push   %ebp
f01009bc:	89 e5                	mov    %esp,%ebp
f01009be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f01009c1:	8d 45 0c             	lea    0xc(%ebp),%eax
f01009c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01009cb:	89 04 24             	mov    %eax,(%esp)
f01009ce:	e8 b5 ff ff ff       	call   f0100988 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009d3:	c9                   	leave  
f01009d4:	c3                   	ret    

f01009d5 <putch>:
#include <inc/stdio.h>
#include <inc/stdarg.h>


static void putch(int ch, int *cnt)
{
f01009d5:	55                   	push   %ebp
f01009d6:	89 e5                	mov    %esp,%ebp
f01009d8:	83 ec 08             	sub    $0x8,%esp
	cputchar(ch);
f01009db:	8b 45 08             	mov    0x8(%ebp),%eax
f01009de:	89 04 24             	mov    %eax,(%esp)
f01009e1:	e8 b8 fa ff ff       	call   f010049e <cputchar>
	*cnt++;
}
f01009e6:	c9                   	leave  
f01009e7:	c3                   	ret    
	...

f01009f0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009f0:	55                   	push   %ebp
f01009f1:	89 e5                	mov    %esp,%ebp
f01009f3:	57                   	push   %edi
f01009f4:	56                   	push   %esi
f01009f5:	53                   	push   %ebx
f01009f6:	83 ec 14             	sub    $0x14,%esp
f01009f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01009fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a02:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a05:	8b 1a                	mov    (%edx),%ebx
f0100a07:	8b 01                	mov    (%ecx),%eax
f0100a09:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0100a0c:	39 c3                	cmp    %eax,%ebx
f0100a0e:	0f 8f aa 00 00 00    	jg     f0100abe <stab_binsearch+0xce>
f0100a14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100a1b:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100a1e:	01 da                	add    %ebx,%edx
f0100a20:	89 d0                	mov    %edx,%eax
f0100a22:	c1 e8 1f             	shr    $0x1f,%eax
f0100a25:	01 d0                	add    %edx,%eax
f0100a27:	89 c6                	mov    %eax,%esi
f0100a29:	d1 fe                	sar    %esi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a2b:	39 de                	cmp    %ebx,%esi
f0100a2d:	7c 2b                	jl     f0100a5a <stab_binsearch+0x6a>
f0100a2f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a32:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a35:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100a3a:	39 f8                	cmp    %edi,%eax
f0100a3c:	74 24                	je     f0100a62 <stab_binsearch+0x72>
f0100a3e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a41:	8d 54 82 f8          	lea    -0x8(%edx,%eax,4),%edx
f0100a45:	89 f1                	mov    %esi,%ecx
			m--;
f0100a47:	83 e9 01             	sub    $0x1,%ecx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a4a:	39 d9                	cmp    %ebx,%ecx
f0100a4c:	7c 0c                	jl     f0100a5a <stab_binsearch+0x6a>
f0100a4e:	0f b6 02             	movzbl (%edx),%eax
f0100a51:	83 ea 0c             	sub    $0xc,%edx
f0100a54:	39 f8                	cmp    %edi,%eax
f0100a56:	75 ef                	jne    f0100a47 <stab_binsearch+0x57>
f0100a58:	eb 0a                	jmp    f0100a64 <stab_binsearch+0x74>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a5a:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100a5d:	8d 76 00             	lea    0x0(%esi),%esi
f0100a60:	eb 4d                	jmp    f0100aaf <stab_binsearch+0xbf>
			continue;
f0100a62:	89 f1                	mov    %esi,%ecx
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a64:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100a67:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a6a:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
f0100a6e:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0100a71:	73 11                	jae    f0100a84 <stab_binsearch+0x94>
			*region_left = m;
f0100a73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a76:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
f0100a78:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100a7b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0100a82:	eb 2b                	jmp    f0100aaf <stab_binsearch+0xbf>
		} else if (stabs[m].n_value > addr) {
f0100a84:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0100a87:	76 14                	jbe    f0100a9d <stab_binsearch+0xad>
			*region_right = m - 1;
f0100a89:	83 e9 01             	sub    $0x1,%ecx
f0100a8c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0100a8f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100a92:	89 0a                	mov    %ecx,(%edx)
f0100a94:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0100a9b:	eb 12                	jmp    f0100aaf <stab_binsearch+0xbf>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a9d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100aa0:	89 0e                	mov    %ecx,(%esi)
			l = m;
			addr++;
f0100aa2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100aa6:	89 cb                	mov    %ecx,%ebx
f0100aa8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0100aaf:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100ab2:	0f 8d 63 ff ff ff    	jge    f0100a1b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100ab8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0100abc:	75 0f                	jne    f0100acd <stab_binsearch+0xdd>
		*region_right = *region_left - 1;
f0100abe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ac1:	8b 02                	mov    (%edx),%eax
f0100ac3:	83 e8 01             	sub    $0x1,%eax
f0100ac6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ac9:	89 01                	mov    %eax,(%ecx)
f0100acb:	eb 3a                	jmp    f0100b07 <stab_binsearch+0x117>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100acd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100ad0:	8b 0e                	mov    (%esi),%ecx
		     l > *region_left && stabs[l].n_type != type;
f0100ad2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ad5:	8b 18                	mov    (%eax),%ebx
f0100ad7:	39 d9                	cmp    %ebx,%ecx
f0100ad9:	7e 27                	jle    f0100b02 <stab_binsearch+0x112>
f0100adb:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100ade:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100ae1:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100ae6:	39 f8                	cmp    %edi,%eax
f0100ae8:	74 18                	je     f0100b02 <stab_binsearch+0x112>
f0100aea:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100aed:	8d 54 82 f8          	lea    -0x8(%edx,%eax,4),%edx
		     l--)
f0100af1:	83 e9 01             	sub    $0x1,%ecx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100af4:	39 d9                	cmp    %ebx,%ecx
f0100af6:	7e 0a                	jle    f0100b02 <stab_binsearch+0x112>
f0100af8:	0f b6 02             	movzbl (%edx),%eax
f0100afb:	83 ea 0c             	sub    $0xc,%edx
f0100afe:	39 f8                	cmp    %edi,%eax
f0100b00:	75 ef                	jne    f0100af1 <stab_binsearch+0x101>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b02:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b05:	89 0e                	mov    %ecx,(%esi)
	}
}
f0100b07:	83 c4 14             	add    $0x14,%esp
f0100b0a:	5b                   	pop    %ebx
f0100b0b:	5e                   	pop    %esi
f0100b0c:	5f                   	pop    %edi
f0100b0d:	5d                   	pop    %ebp
f0100b0e:	c3                   	ret    

f0100b0f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b0f:	55                   	push   %ebp
f0100b10:	89 e5                	mov    %esp,%ebp
f0100b12:	83 ec 28             	sub    $0x28,%esp
f0100b15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100b18:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100b1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100b1e:	8b 75 08             	mov    0x8(%ebp),%esi
f0100b21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b24:	c7 03 e4 1f 10 f0    	movl   $0xf0101fe4,(%ebx)
	info->eip_line = 0;
f0100b2a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100b31:	c7 43 08 e4 1f 10 f0 	movl   $0xf0101fe4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100b38:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b3f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b42:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b49:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b4f:	76 12                	jbe    f0100b63 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b51:	b8 f5 71 10 f0       	mov    $0xf01071f5,%eax
f0100b56:	3d 89 58 10 f0       	cmp    $0xf0105889,%eax
f0100b5b:	0f 86 81 01 00 00    	jbe    f0100ce2 <debuginfo_eip+0x1d3>
f0100b61:	eb 1c                	jmp    f0100b7f <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b63:	c7 44 24 08 ee 1f 10 	movl   $0xf0101fee,0x8(%esp)
f0100b6a:	f0 
f0100b6b:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100b72:	00 
f0100b73:	c7 04 24 fb 1f 10 f0 	movl   $0xf0101ffb,(%esp)
f0100b7a:	e8 01 f5 ff ff       	call   f0100080 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b7f:	80 3d f4 71 10 f0 00 	cmpb   $0x0,0xf01071f4
f0100b86:	0f 85 56 01 00 00    	jne    f0100ce2 <debuginfo_eip+0x1d3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b8c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b93:	b8 88 58 10 f0       	mov    $0xf0105888,%eax
f0100b98:	2d 1c 22 10 f0       	sub    $0xf010221c,%eax
f0100b9d:	c1 f8 02             	sar    $0x2,%eax
f0100ba0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100ba6:	83 e8 01             	sub    $0x1,%eax
f0100ba9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100bac:	8d 4d ec             	lea    -0x14(%ebp),%ecx
f0100baf:	8d 55 f0             	lea    -0x10(%ebp),%edx
f0100bb2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bb6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100bbd:	b8 1c 22 10 f0       	mov    $0xf010221c,%eax
f0100bc2:	e8 29 fe ff ff       	call   f01009f0 <stab_binsearch>
	if (lfile == 0)
f0100bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100bca:	85 c0                	test   %eax,%eax
f0100bcc:	0f 84 10 01 00 00    	je     f0100ce2 <debuginfo_eip+0x1d3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100bd2:	89 45 e8             	mov    %eax,-0x18(%ebp)
	rfun = rfile;
f0100bd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100bd8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100bdb:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0100bde:	8d 55 e8             	lea    -0x18(%ebp),%edx
f0100be1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100be5:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100bec:	b8 1c 22 10 f0       	mov    $0xf010221c,%eax
f0100bf1:	e8 fa fd ff ff       	call   f01009f0 <stab_binsearch>

	if (lfun <= rfun) {
f0100bf6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100bf9:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0100bfc:	7f 35                	jg     f0100c33 <debuginfo_eip+0x124>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100bfe:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100c01:	8b 14 85 1c 22 10 f0 	mov    -0xfefdde4(,%eax,4),%edx
f0100c08:	b8 f5 71 10 f0       	mov    $0xf01071f5,%eax
f0100c0d:	2d 89 58 10 f0       	sub    $0xf0105889,%eax
f0100c12:	39 c2                	cmp    %eax,%edx
f0100c14:	73 09                	jae    f0100c1f <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c16:	8d 82 89 58 10 f0    	lea    -0xfefa777(%edx),%eax
f0100c1c:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100c22:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c25:	8b 14 95 24 22 10 f0 	mov    -0xfefdddc(,%edx,4),%edx
f0100c2c:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
		// Search within the function definition for the line number.
		lline = lfun;
f0100c2f:	89 c6                	mov    %eax,%esi
f0100c31:	eb 06                	jmp    f0100c39 <debuginfo_eip+0x12a>
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c33:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c36:	8b 75 f0             	mov    -0x10(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c39:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100c40:	00 
f0100c41:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c44:	89 04 24             	mov    %eax,(%esp)
f0100c47:	e8 35 09 00 00       	call   f0101581 <strfind>
f0100c4c:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c4f:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c52:	8b 7d f0             	mov    -0x10(%ebp),%edi
f0100c55:	39 fe                	cmp    %edi,%esi
f0100c57:	7c 49                	jl     f0100ca2 <debuginfo_eip+0x193>
f0100c59:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c5c:	8d 0c 85 1c 22 10 f0 	lea    -0xfefdde4(,%eax,4),%ecx
f0100c63:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
f0100c67:	8d 04 85 10 22 10 f0 	lea    -0xfefddf0(,%eax,4),%eax
f0100c6e:	80 fa 84             	cmp    $0x84,%dl
f0100c71:	75 1a                	jne    f0100c8d <debuginfo_eip+0x17e>
f0100c73:	e9 84 00 00 00       	jmp    f0100cfc <debuginfo_eip+0x1ed>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100c78:	83 ee 01             	sub    $0x1,%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c7b:	39 f7                	cmp    %esi,%edi
f0100c7d:	7f 23                	jg     f0100ca2 <debuginfo_eip+0x193>
f0100c7f:	89 c1                	mov    %eax,%ecx
f0100c81:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100c85:	83 e8 0c             	sub    $0xc,%eax
f0100c88:	80 fa 84             	cmp    $0x84,%dl
f0100c8b:	74 6f                	je     f0100cfc <debuginfo_eip+0x1ed>
f0100c8d:	80 fa 64             	cmp    $0x64,%dl
f0100c90:	75 e6                	jne    f0100c78 <debuginfo_eip+0x169>
f0100c92:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0100c96:	74 e0                	je     f0100c78 <debuginfo_eip+0x169>
f0100c98:	eb 62                	jmp    f0100cfc <debuginfo_eip+0x1ed>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c9a:	8d 82 89 58 10 f0    	lea    -0xfefa777(%edx),%eax
f0100ca0:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ca2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100ca5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ca8:	39 c2                	cmp    %eax,%edx
f0100caa:	7d 3e                	jge    f0100cea <debuginfo_eip+0x1db>
		for (lline = lfun + 1;
f0100cac:	8d 4a 01             	lea    0x1(%edx),%ecx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100caf:	39 c8                	cmp    %ecx,%eax
f0100cb1:	7e 37                	jle    f0100cea <debuginfo_eip+0x1db>
f0100cb3:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100cb6:	80 3c 85 20 22 10 f0 	cmpb   $0xa0,-0xfefdde0(,%eax,4)
f0100cbd:	a0 
f0100cbe:	75 2a                	jne    f0100cea <debuginfo_eip+0x1db>
f0100cc0:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100cc3:	8d 14 85 38 22 10 f0 	lea    -0xfefddc8(,%eax,4),%edx
		     lline++)
			info->eip_fn_narg++;
f0100cca:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100cce:	83 c1 01             	add    $0x1,%ecx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100cd1:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0100cd4:	7e 14                	jle    f0100cea <debuginfo_eip+0x1db>
f0100cd6:	0f b6 02             	movzbl (%edx),%eax
f0100cd9:	83 c2 0c             	add    $0xc,%edx
f0100cdc:	3c a0                	cmp    $0xa0,%al
f0100cde:	74 ea                	je     f0100cca <debuginfo_eip+0x1bb>
f0100ce0:	eb 08                	jmp    f0100cea <debuginfo_eip+0x1db>
f0100ce2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ce7:	90                   	nop    
f0100ce8:	eb 05                	jmp    f0100cef <debuginfo_eip+0x1e0>
f0100cea:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0100cef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100cf2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100cf5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100cf8:	89 ec                	mov    %ebp,%esp
f0100cfa:	5d                   	pop    %ebp
f0100cfb:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100cfc:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100cff:	8b 14 85 1c 22 10 f0 	mov    -0xfefdde4(,%eax,4),%edx
f0100d06:	b8 f5 71 10 f0       	mov    $0xf01071f5,%eax
f0100d0b:	2d 89 58 10 f0       	sub    $0xf0105889,%eax
f0100d10:	39 c2                	cmp    %eax,%edx
f0100d12:	72 86                	jb     f0100c9a <debuginfo_eip+0x18b>
f0100d14:	eb 8c                	jmp    f0100ca2 <debuginfo_eip+0x193>
	...

f0100d20 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d20:	55                   	push   %ebp
f0100d21:	89 e5                	mov    %esp,%ebp
f0100d23:	57                   	push   %edi
f0100d24:	56                   	push   %esi
f0100d25:	53                   	push   %ebx
f0100d26:	83 ec 3c             	sub    $0x3c,%esp
f0100d29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d2c:	89 d7                	mov    %edx,%edi
f0100d2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d31:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d34:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d37:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100d3a:	8b 55 10             	mov    0x10(%ebp),%edx
f0100d3d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d40:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100d43:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0100d4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d4d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
f0100d50:	72 16                	jb     f0100d68 <printnum+0x48>
f0100d52:	77 08                	ja     f0100d5c <printnum+0x3c>
f0100d54:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d57:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0100d5a:	76 0c                	jbe    f0100d68 <printnum+0x48>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d5c:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100d5f:	83 eb 01             	sub    $0x1,%ebx
f0100d62:	85 db                	test   %ebx,%ebx
f0100d64:	7f 57                	jg     f0100dbd <printnum+0x9d>
f0100d66:	eb 6a                	jmp    f0100dd2 <printnum+0xb2>
static void printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d68:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100d6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d6f:	83 e8 01             	sub    $0x1,%eax
f0100d72:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d76:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d7a:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100d7e:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100d82:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100d85:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100d88:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d90:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d93:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d96:	89 04 24             	mov    %eax,(%esp)
f0100d99:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d9d:	e8 ae 0a 00 00       	call   f0101850 <__udivdi3>
f0100da2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100da6:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100daa:	89 04 24             	mov    %eax,(%esp)
f0100dad:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100db1:	89 fa                	mov    %edi,%edx
f0100db3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100db6:	e8 65 ff ff ff       	call   f0100d20 <printnum>
f0100dbb:	eb 15                	jmp    f0100dd2 <printnum+0xb2>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100dbd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100dc1:	89 34 24             	mov    %esi,(%esp)
f0100dc4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100dc7:	83 eb 01             	sub    $0x1,%ebx
f0100dca:	85 db                	test   %ebx,%ebx
f0100dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100dd0:	7f eb                	jg     f0100dbd <printnum+0x9d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100dd2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100dd6:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100dda:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100ddd:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100de0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100de4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100de8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100deb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dee:	89 04 24             	mov    %eax,(%esp)
f0100df1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100df5:	e8 86 0b 00 00       	call   f0101980 <__umoddi3>
f0100dfa:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100dfe:	0f be 80 09 20 10 f0 	movsbl -0xfefdff7(%eax),%eax
f0100e05:	89 04 24             	mov    %eax,(%esp)
f0100e08:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100e0b:	83 c4 3c             	add    $0x3c,%esp
f0100e0e:	5b                   	pop    %ebx
f0100e0f:	5e                   	pop    %esi
f0100e10:	5f                   	pop    %edi
f0100e11:	5d                   	pop    %ebp
f0100e12:	c3                   	ret    

f0100e13 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag)
{
f0100e13:	55                   	push   %ebp
f0100e14:	89 e5                	mov    %esp,%ebp
f0100e16:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
f0100e18:	83 fa 01             	cmp    $0x1,%edx
f0100e1b:	7e 0f                	jle    f0100e2c <getuint+0x19>
		return va_arg(*ap, unsigned long long);
f0100e1d:	8b 00                	mov    (%eax),%eax
f0100e1f:	83 c0 08             	add    $0x8,%eax
f0100e22:	89 01                	mov    %eax,(%ecx)
f0100e24:	8b 50 fc             	mov    -0x4(%eax),%edx
f0100e27:	8b 40 f8             	mov    -0x8(%eax),%eax
f0100e2a:	eb 24                	jmp    f0100e50 <getuint+0x3d>
	else if (lflag)
f0100e2c:	85 d2                	test   %edx,%edx
f0100e2e:	74 11                	je     f0100e41 <getuint+0x2e>
		return va_arg(*ap, unsigned long);
f0100e30:	8b 00                	mov    (%eax),%eax
f0100e32:	83 c0 04             	add    $0x4,%eax
f0100e35:	89 01                	mov    %eax,(%ecx)
f0100e37:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100e3a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e3f:	eb 0f                	jmp    f0100e50 <getuint+0x3d>
	else
		return va_arg(*ap, unsigned int);
f0100e41:	8b 00                	mov    (%eax),%eax
f0100e43:	83 c0 04             	add    $0x4,%eax
f0100e46:	89 01                	mov    %eax,(%ecx)
f0100e48:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100e4b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100e50:	5d                   	pop    %ebp
f0100e51:	c3                   	ret    

f0100e52 <sprintputch>:
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b)
{
f0100e52:	55                   	push   %ebp
f0100e53:	89 e5                	mov    %esp,%ebp
f0100e55:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
f0100e58:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
f0100e5c:	8b 02                	mov    (%edx),%eax
f0100e5e:	3b 42 04             	cmp    0x4(%edx),%eax
f0100e61:	73 0b                	jae    f0100e6e <sprintputch+0x1c>
		*b->buf++ = ch;
f0100e63:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
f0100e67:	88 08                	mov    %cl,(%eax)
f0100e69:	83 c0 01             	add    $0x1,%eax
f0100e6c:	89 02                	mov    %eax,(%edx)
}
f0100e6e:	5d                   	pop    %ebp
f0100e6f:	c3                   	ret    

f0100e70 <vprintfmt>:

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e70:	55                   	push   %ebp
f0100e71:	89 e5                	mov    %esp,%ebp
f0100e73:	57                   	push   %edi
f0100e74:	56                   	push   %esi
f0100e75:	53                   	push   %ebx
f0100e76:	83 ec 2c             	sub    $0x2c,%esp
f0100e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0100e7c:	eb 15                	jmp    f0100e93 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e7e:	85 c0                	test   %eax,%eax
f0100e80:	0f 84 b9 03 00 00    	je     f010123f <vprintfmt+0x3cf>
				return;
			putch(ch, putdat);//when vprintfmt was called, *putdat = &(0)
f0100e86:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e89:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100e8d:	89 04 24             	mov    %eax,(%esp)
f0100e90:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e93:	0f b6 03             	movzbl (%ebx),%eax
f0100e96:	83 c3 01             	add    $0x1,%ebx
f0100e99:	83 f8 25             	cmp    $0x25,%eax
f0100e9c:	75 e0                	jne    f0100e7e <vprintfmt+0xe>
f0100e9e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ea3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100eaa:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100eaf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0100eb6:	c6 45 ef 20          	movb   $0x20,-0x11(%ebp)
f0100eba:	eb 07                	jmp    f0100ec3 <vprintfmt+0x53>
f0100ebc:	c6 45 ef 2d          	movb   $0x2d,-0x11(%ebp)
f0100ec0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ec3:	0f b6 03             	movzbl (%ebx),%eax
f0100ec6:	0f b6 c8             	movzbl %al,%ecx
f0100ec9:	8d 73 01             	lea    0x1(%ebx),%esi
f0100ecc:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0100ecf:	83 e8 23             	sub    $0x23,%eax
f0100ed2:	3c 55                	cmp    $0x55,%al
f0100ed4:	0f 87 44 03 00 00    	ja     f010121e <vprintfmt+0x3ae>
f0100eda:	0f b6 c0             	movzbl %al,%eax
f0100edd:	ff 24 85 98 20 10 f0 	jmp    *-0xfefdf68(,%eax,4)
f0100ee4:	c6 45 ef 30          	movb   $0x30,-0x11(%ebp)
f0100ee8:	eb d6                	jmp    f0100ec0 <vprintfmt+0x50>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100eea:	8d 79 d0             	lea    -0x30(%ecx),%edi
				ch = *fmt;
f0100eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ef0:	0f be 08             	movsbl (%eax),%ecx
				if (ch < '0' || ch > '9')
f0100ef3:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0100ef6:	83 f8 09             	cmp    $0x9,%eax
f0100ef9:	77 3f                	ja     f0100f3a <vprintfmt+0xca>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100efb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
				precision = precision * 10 + ch - '0';
f0100eff:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0100f02:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
f0100f06:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0100f09:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f0100f0c:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0100f0f:	83 f8 09             	cmp    $0x9,%eax
f0100f12:	76 e7                	jbe    f0100efb <vprintfmt+0x8b>
f0100f14:	eb 24                	jmp    f0100f3a <vprintfmt+0xca>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100f16:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f19:	83 c0 04             	add    $0x4,%eax
f0100f1c:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f1f:	8b 78 fc             	mov    -0x4(%eax),%edi
f0100f22:	eb 16                	jmp    f0100f3a <vprintfmt+0xca>
			goto process_precision;

		case '.':
			if (width < 0)
f0100f24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f27:	c1 f8 1f             	sar    $0x1f,%eax
f0100f2a:	f7 d0                	not    %eax
f0100f2c:	21 45 e4             	and    %eax,-0x1c(%ebp)
f0100f2f:	eb 8f                	jmp    f0100ec0 <vprintfmt+0x50>
f0100f31:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100f38:	eb 86                	jmp    f0100ec0 <vprintfmt+0x50>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100f3a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100f3e:	79 80                	jns    f0100ec0 <vprintfmt+0x50>
f0100f40:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100f43:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100f48:	e9 73 ff ff ff       	jmp    f0100ec0 <vprintfmt+0x50>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f4d:	83 c2 01             	add    $0x1,%edx
f0100f50:	e9 6b ff ff ff       	jmp    f0100ec0 <vprintfmt+0x50>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f55:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f58:	83 c0 04             	add    $0x4,%eax
f0100f5b:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f5e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f61:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f65:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100f68:	89 04 24             	mov    %eax,(%esp)
f0100f6b:	ff 55 08             	call   *0x8(%ebp)
f0100f6e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100f71:	e9 1d ff ff ff       	jmp    f0100e93 <vprintfmt+0x23>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f76:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f79:	83 c0 04             	add    $0x4,%eax
f0100f7c:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f7f:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100f82:	89 c2                	mov    %eax,%edx
f0100f84:	c1 fa 1f             	sar    $0x1f,%edx
f0100f87:	31 d0                	xor    %edx,%eax
f0100f89:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100f8b:	83 f8 06             	cmp    $0x6,%eax
f0100f8e:	7f 0b                	jg     f0100f9b <vprintfmt+0x12b>
f0100f90:	8b 14 85 f0 21 10 f0 	mov    -0xfefde10(,%eax,4),%edx
f0100f97:	85 d2                	test   %edx,%edx
f0100f99:	75 26                	jne    f0100fc1 <vprintfmt+0x151>
				printfmt(putch, putdat, "error %d", err);
f0100f9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f9f:	c7 44 24 08 1a 20 10 	movl   $0xf010201a,0x8(%esp)
f0100fa6:	f0 
f0100fa7:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100faa:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fae:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fb1:	89 04 24             	mov    %eax,(%esp)
f0100fb4:	e8 0e 03 00 00       	call   f01012c7 <printfmt>
f0100fb9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100fbc:	e9 d2 fe ff ff       	jmp    f0100e93 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0100fc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100fc5:	c7 44 24 08 23 20 10 	movl   $0xf0102023,0x8(%esp)
f0100fcc:	f0 
f0100fcd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100fd0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100fd4:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fd7:	89 34 24             	mov    %esi,(%esp)
f0100fda:	e8 e8 02 00 00       	call   f01012c7 <printfmt>
f0100fdf:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100fe2:	e9 ac fe ff ff       	jmp    f0100e93 <vprintfmt+0x23>
f0100fe7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100fea:	89 fa                	mov    %edi,%edx
f0100fec:	8b 5d f0             	mov    -0x10(%ebp),%ebx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100fef:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff2:	83 c0 04             	add    $0x4,%eax
f0100ff5:	89 45 14             	mov    %eax,0x14(%ebp)
f0100ff8:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100ffb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ffe:	85 c0                	test   %eax,%eax
f0101000:	75 07                	jne    f0101009 <vprintfmt+0x199>
f0101002:	c7 45 e0 26 20 10 f0 	movl   $0xf0102026,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0101009:	85 f6                	test   %esi,%esi
f010100b:	7e 06                	jle    f0101013 <vprintfmt+0x1a3>
f010100d:	80 7d ef 2d          	cmpb   $0x2d,-0x11(%ebp)
f0101011:	75 1a                	jne    f010102d <vprintfmt+0x1bd>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101013:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101016:	0f be 10             	movsbl (%eax),%edx
f0101019:	85 d2                	test   %edx,%edx
f010101b:	0f 85 9c 00 00 00    	jne    f01010bd <vprintfmt+0x24d>
f0101021:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101028:	e9 7d 00 00 00       	jmp    f01010aa <vprintfmt+0x23a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010102d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101031:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101034:	89 14 24             	mov    %edx,(%esp)
f0101037:	e8 cf 03 00 00       	call   f010140b <strnlen>
f010103c:	29 c6                	sub    %eax,%esi
f010103e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0101041:	85 f6                	test   %esi,%esi
f0101043:	7e ce                	jle    f0101013 <vprintfmt+0x1a3>
					putch(padc, putdat);
f0101045:	0f be 75 ef          	movsbl -0x11(%ebp),%esi
f0101049:	8b 45 0c             	mov    0xc(%ebp),%eax
f010104c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101050:	89 34 24             	mov    %esi,(%esp)
f0101053:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101056:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010105a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010105e:	7f e9                	jg     f0101049 <vprintfmt+0x1d9>
f0101060:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101067:	eb aa                	jmp    f0101013 <vprintfmt+0x1a3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101069:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010106d:	8d 76 00             	lea    0x0(%esi),%esi
f0101070:	74 1b                	je     f010108d <vprintfmt+0x21d>
f0101072:	8d 42 e0             	lea    -0x20(%edx),%eax
f0101075:	83 f8 5e             	cmp    $0x5e,%eax
f0101078:	76 13                	jbe    f010108d <vprintfmt+0x21d>
					putch('?', putdat);
f010107a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010107d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101081:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101088:	ff 55 08             	call   *0x8(%ebp)
f010108b:	eb 0d                	jmp    f010109a <vprintfmt+0x22a>
				else
					putch(ch, putdat);
f010108d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101090:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101094:	89 14 24             	mov    %edx,(%esp)
f0101097:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010109a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010109e:	0f be 16             	movsbl (%esi),%edx
f01010a1:	85 d2                	test   %edx,%edx
f01010a3:	74 05                	je     f01010aa <vprintfmt+0x23a>
f01010a5:	83 c6 01             	add    $0x1,%esi
f01010a8:	eb 19                	jmp    f01010c3 <vprintfmt+0x253>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01010aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01010ae:	7f 22                	jg     f01010d2 <vprintfmt+0x262>
f01010b0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01010b3:	90                   	nop    
f01010b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01010b8:	e9 d6 fd ff ff       	jmp    f0100e93 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01010bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01010c0:	83 c6 01             	add    $0x1,%esi
f01010c3:	85 ff                	test   %edi,%edi
f01010c5:	78 a2                	js     f0101069 <vprintfmt+0x1f9>
f01010c7:	83 ef 01             	sub    $0x1,%edi
f01010ca:	79 9d                	jns    f0101069 <vprintfmt+0x1f9>
f01010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01010d0:	eb d8                	jmp    f01010aa <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01010d2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01010d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010d9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01010e0:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01010e3:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01010e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01010eb:	7f e5                	jg     f01010d2 <vprintfmt+0x262>
f01010ed:	e9 a1 fd ff ff       	jmp    f0100e93 <vprintfmt+0x23>

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010f2:	83 fa 01             	cmp    $0x1,%edx
f01010f5:	8d 76 00             	lea    0x0(%esi),%esi
f01010f8:	7e 11                	jle    f010110b <vprintfmt+0x29b>
		return va_arg(*ap, long long);
f01010fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01010fd:	83 c0 08             	add    $0x8,%eax
f0101100:	89 45 14             	mov    %eax,0x14(%ebp)
f0101103:	8b 70 f8             	mov    -0x8(%eax),%esi
f0101106:	8b 78 fc             	mov    -0x4(%eax),%edi
f0101109:	eb 2c                	jmp    f0101137 <vprintfmt+0x2c7>
	else if (lflag)
f010110b:	85 d2                	test   %edx,%edx
f010110d:	74 15                	je     f0101124 <vprintfmt+0x2b4>
		return va_arg(*ap, long);
f010110f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101112:	83 c0 04             	add    $0x4,%eax
f0101115:	89 45 14             	mov    %eax,0x14(%ebp)
f0101118:	8b 40 fc             	mov    -0x4(%eax),%eax
f010111b:	89 c6                	mov    %eax,%esi
f010111d:	89 c7                	mov    %eax,%edi
f010111f:	c1 ff 1f             	sar    $0x1f,%edi
f0101122:	eb 13                	jmp    f0101137 <vprintfmt+0x2c7>
	else
		return va_arg(*ap, int);
f0101124:	8b 45 14             	mov    0x14(%ebp),%eax
f0101127:	83 c0 04             	add    $0x4,%eax
f010112a:	89 45 14             	mov    %eax,0x14(%ebp)
f010112d:	8b 40 fc             	mov    -0x4(%eax),%eax
f0101130:	89 c6                	mov    %eax,%esi
f0101132:	89 c7                	mov    %eax,%edi
f0101134:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101137:	89 f2                	mov    %esi,%edx
f0101139:	89 f9                	mov    %edi,%ecx
f010113b:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
f0101140:	85 ff                	test   %edi,%edi
f0101142:	0f 89 94 00 00 00    	jns    f01011dc <vprintfmt+0x36c>
				putch('-', putdat);
f0101148:	8b 45 0c             	mov    0xc(%ebp),%eax
f010114b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010114f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101156:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101159:	89 f2                	mov    %esi,%edx
f010115b:	89 f9                	mov    %edi,%ecx
f010115d:	f7 da                	neg    %edx
f010115f:	83 d1 00             	adc    $0x0,%ecx
f0101162:	f7 d9                	neg    %ecx
f0101164:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101169:	eb 71                	jmp    f01011dc <vprintfmt+0x36c>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010116b:	8d 45 14             	lea    0x14(%ebp),%eax
f010116e:	e8 a0 fc ff ff       	call   f0100e13 <getuint>
f0101173:	89 d1                	mov    %edx,%ecx
f0101175:	89 c2                	mov    %eax,%edx
f0101177:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010117c:	eb 5e                	jmp    f01011dc <vprintfmt+0x36c>
			putch('x', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
			*/
			num = getuint(&ap, lflag);
f010117e:	8d 45 14             	lea    0x14(%ebp),%eax
f0101181:	e8 8d fc ff ff       	call   f0100e13 <getuint>
f0101186:	89 d1                	mov    %edx,%ecx
f0101188:	89 c2                	mov    %eax,%edx
f010118a:	bb 08 00 00 00       	mov    $0x8,%ebx
f010118f:	eb 4b                	jmp    f01011dc <vprintfmt+0x36c>
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f0101191:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101194:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101198:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010119f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01011a2:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011a5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011a9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01011b0:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01011b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01011b6:	83 c0 04             	add    $0x4,%eax
f01011b9:	89 45 14             	mov    %eax,0x14(%ebp)
f01011bc:	8b 50 fc             	mov    -0x4(%eax),%edx
f01011bf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011c4:	bb 10 00 00 00       	mov    $0x10,%ebx
f01011c9:	eb 11                	jmp    f01011dc <vprintfmt+0x36c>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01011cb:	8d 45 14             	lea    0x14(%ebp),%eax
f01011ce:	e8 40 fc ff ff       	call   f0100e13 <getuint>
f01011d3:	89 d1                	mov    %edx,%ecx
f01011d5:	89 c2                	mov    %eax,%edx
f01011d7:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f01011dc:	0f be 45 ef          	movsbl -0x11(%ebp),%eax
f01011e0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01011e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01011ef:	89 14 24             	mov    %edx,(%esp)
f01011f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01011f6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01011f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01011fc:	e8 1f fb ff ff       	call   f0100d20 <printnum>
f0101201:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0101204:	e9 8a fc ff ff       	jmp    f0100e93 <vprintfmt+0x23>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101209:	8b 55 0c             	mov    0xc(%ebp),%edx
f010120c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101210:	89 0c 24             	mov    %ecx,(%esp)
f0101213:	ff 55 08             	call   *0x8(%ebp)
f0101216:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0101219:	e9 75 fc ff ff       	jmp    f0100e93 <vprintfmt+0x23>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010121e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101221:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101225:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010122c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010122f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101232:	80 38 25             	cmpb   $0x25,(%eax)
f0101235:	0f 84 58 fc ff ff    	je     f0100e93 <vprintfmt+0x23>
f010123b:	89 c3                	mov    %eax,%ebx
f010123d:	eb f0                	jmp    f010122f <vprintfmt+0x3bf>
				/* do nothing */;
			break;
		}
	}
}
f010123f:	83 c4 2c             	add    $0x2c,%esp
f0101242:	5b                   	pop    %ebx
f0101243:	5e                   	pop    %esi
f0101244:	5f                   	pop    %edi
f0101245:	5d                   	pop    %ebp
f0101246:	c3                   	ret    

f0101247 <vsnprintf>:
	if (b->buf < b->ebuf)
		*b->buf++ = ch;
}

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101247:	55                   	push   %ebp
f0101248:	89 e5                	mov    %esp,%ebp
f010124a:	83 ec 28             	sub    $0x28,%esp
f010124d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101250:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0101253:	85 c0                	test   %eax,%eax
f0101255:	74 04                	je     f010125b <vsnprintf+0x14>
f0101257:	85 d2                	test   %edx,%edx
f0101259:	7f 07                	jg     f0101262 <vsnprintf+0x1b>
f010125b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101260:	eb 3b                	jmp    f010129d <vsnprintf+0x56>
		*b->buf++ = ch;
}

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101262:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101265:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0101269:	89 45 f8             	mov    %eax,-0x8(%ebp)
f010126c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101273:	8b 45 14             	mov    0x14(%ebp),%eax
f0101276:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010127a:	8b 45 10             	mov    0x10(%ebp),%eax
f010127d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101281:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101284:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101288:	c7 04 24 52 0e 10 f0 	movl   $0xf0100e52,(%esp)
f010128f:	e8 dc fb ff ff       	call   f0100e70 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101294:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101297:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010129a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f010129d:	c9                   	leave  
f010129e:	c3                   	ret    

f010129f <snprintf>:

//print number n characters
int snprintf(char *buf, int n, const char *fmt, ...)
{
f010129f:	55                   	push   %ebp
f01012a0:	89 e5                	mov    %esp,%ebp
f01012a2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01012a5:	8d 45 14             	lea    0x14(%ebp),%eax
f01012a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012ac:	8b 45 10             	mov    0x10(%ebp),%eax
f01012af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01012bd:	89 04 24             	mov    %eax,(%esp)
f01012c0:	e8 82 ff ff ff       	call   f0101247 <vsnprintf>
	va_end(ap);

	return rc;
}
f01012c5:	c9                   	leave  
f01012c6:	c3                   	ret    

f01012c7 <printfmt>:
		}
	}
}

void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01012c7:	55                   	push   %ebp
f01012c8:	89 e5                	mov    %esp,%ebp
f01012ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01012cd:	8d 45 14             	lea    0x14(%ebp),%eax
f01012d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012d4:	8b 45 10             	mov    0x10(%ebp),%eax
f01012d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01012e5:	89 04 24             	mov    %eax,(%esp)
f01012e8:	e8 83 fb ff ff       	call   f0100e70 <vprintfmt>
	va_end(ap);
}
f01012ed:	c9                   	leave  
f01012ee:	c3                   	ret    
	...

f01012f0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01012f0:	55                   	push   %ebp
f01012f1:	89 e5                	mov    %esp,%ebp
f01012f3:	57                   	push   %edi
f01012f4:	56                   	push   %esi
f01012f5:	53                   	push   %ebx
f01012f6:	83 ec 0c             	sub    $0xc,%esp
f01012f9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01012fc:	85 c0                	test   %eax,%eax
f01012fe:	74 10                	je     f0101310 <readline+0x20>
		cprintf("%s", prompt);
f0101300:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101304:	c7 04 24 23 20 10 f0 	movl   $0xf0102023,(%esp)
f010130b:	e8 ab f6 ff ff       	call   f01009bb <cprintf>

	i = 0;
	echoing = iscons(0);
f0101310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101317:	e8 7b ef ff ff       	call   f0100297 <iscons>
f010131c:	89 c7                	mov    %eax,%edi
f010131e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101323:	e8 5e ef ff ff       	call   f0100286 <getchar>
f0101328:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010132a:	85 c0                	test   %eax,%eax
f010132c:	79 1a                	jns    f0101348 <readline+0x58>
			cprintf("read error: %e\n", c);
f010132e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101332:	c7 04 24 0c 22 10 f0 	movl   $0xf010220c,(%esp)
f0101339:	e8 7d f6 ff ff       	call   f01009bb <cprintf>
f010133e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101343:	e9 99 00 00 00       	jmp    f01013e1 <readline+0xf1>
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101348:	83 f8 08             	cmp    $0x8,%eax
f010134b:	74 05                	je     f0101352 <readline+0x62>
f010134d:	83 f8 7f             	cmp    $0x7f,%eax
f0101350:	75 28                	jne    f010137a <readline+0x8a>
f0101352:	85 f6                	test   %esi,%esi
f0101354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101358:	7e 20                	jle    f010137a <readline+0x8a>
			if (echoing)
f010135a:	85 ff                	test   %edi,%edi
f010135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101360:	74 13                	je     f0101375 <readline+0x85>
				cputchar('\b');
f0101362:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101370:	e8 29 f1 ff ff       	call   f010049e <cputchar>
			i--;
f0101375:	83 ee 01             	sub    $0x1,%esi
f0101378:	eb a9                	jmp    f0101323 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010137a:	83 fb 1f             	cmp    $0x1f,%ebx
f010137d:	8d 76 00             	lea    0x0(%esi),%esi
f0101380:	7e 29                	jle    f01013ab <readline+0xbb>
f0101382:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101388:	7f 21                	jg     f01013ab <readline+0xbb>
			if (echoing)
f010138a:	85 ff                	test   %edi,%edi
f010138c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101390:	74 0b                	je     f010139d <readline+0xad>
				cputchar(c);
f0101392:	89 1c 24             	mov    %ebx,(%esp)
f0101395:	8d 76 00             	lea    0x0(%esi),%esi
f0101398:	e8 01 f1 ff ff       	call   f010049e <cputchar>
			buf[i++] = c;
f010139d:	88 9e 80 05 11 f0    	mov    %bl,-0xfeefa80(%esi)
f01013a3:	83 c6 01             	add    $0x1,%esi
f01013a6:	e9 78 ff ff ff       	jmp    f0101323 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01013ab:	83 fb 0a             	cmp    $0xa,%ebx
f01013ae:	74 09                	je     f01013b9 <readline+0xc9>
f01013b0:	83 fb 0d             	cmp    $0xd,%ebx
f01013b3:	0f 85 6a ff ff ff    	jne    f0101323 <readline+0x33>
			if (echoing)
f01013b9:	85 ff                	test   %edi,%edi
f01013bb:	90                   	nop    
f01013bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01013c0:	74 13                	je     f01013d5 <readline+0xe5>
				cputchar('\n');
f01013c2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01013c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01013d0:	e8 c9 f0 ff ff       	call   f010049e <cputchar>
			buf[i] = 0;
f01013d5:	c6 86 80 05 11 f0 00 	movb   $0x0,-0xfeefa80(%esi)
f01013dc:	b8 80 05 11 f0       	mov    $0xf0110580,%eax
			return buf;
		}
	}
}
f01013e1:	83 c4 0c             	add    $0xc,%esp
f01013e4:	5b                   	pop    %ebx
f01013e5:	5e                   	pop    %esi
f01013e6:	5f                   	pop    %edi
f01013e7:	5d                   	pop    %ebp
f01013e8:	c3                   	ret    
f01013e9:	00 00                	add    %al,(%eax)
f01013eb:	00 00                	add    %al,(%eax)
f01013ed:	00 00                	add    %al,(%eax)
	...

f01013f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01013f0:	55                   	push   %ebp
f01013f1:	89 e5                	mov    %esp,%ebp
f01013f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01013f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01013fb:	80 3a 00             	cmpb   $0x0,(%edx)
f01013fe:	74 09                	je     f0101409 <strlen+0x19>
		n++;
f0101400:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101403:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101407:	75 f7                	jne    f0101400 <strlen+0x10>
		n++;
	return n;
}
f0101409:	5d                   	pop    %ebp
f010140a:	c3                   	ret    

f010140b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010140b:	55                   	push   %ebp
f010140c:	89 e5                	mov    %esp,%ebp
f010140e:	53                   	push   %ebx
f010140f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101412:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101415:	85 c9                	test   %ecx,%ecx
f0101417:	74 19                	je     f0101432 <strnlen+0x27>
f0101419:	80 3b 00             	cmpb   $0x0,(%ebx)
f010141c:	74 14                	je     f0101432 <strnlen+0x27>
f010141e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101423:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101426:	39 c8                	cmp    %ecx,%eax
f0101428:	74 0d                	je     f0101437 <strnlen+0x2c>
f010142a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010142e:	75 f3                	jne    f0101423 <strnlen+0x18>
f0101430:	eb 05                	jmp    f0101437 <strnlen+0x2c>
f0101432:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101437:	5b                   	pop    %ebx
f0101438:	5d                   	pop    %ebp
f0101439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101440:	c3                   	ret    

f0101441 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101441:	55                   	push   %ebp
f0101442:	89 e5                	mov    %esp,%ebp
f0101444:	53                   	push   %ebx
f0101445:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101448:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010144b:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101450:	0f b6 04 11          	movzbl (%ecx,%edx,1),%eax
f0101454:	88 04 13             	mov    %al,(%ebx,%edx,1)
f0101457:	83 c2 01             	add    $0x1,%edx
f010145a:	84 c0                	test   %al,%al
f010145c:	75 f2                	jne    f0101450 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010145e:	89 d8                	mov    %ebx,%eax
f0101460:	5b                   	pop    %ebx
f0101461:	5d                   	pop    %ebp
f0101462:	c3                   	ret    

f0101463 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101463:	55                   	push   %ebp
f0101464:	89 e5                	mov    %esp,%ebp
f0101466:	56                   	push   %esi
f0101467:	53                   	push   %ebx
f0101468:	8b 75 08             	mov    0x8(%ebp),%esi
f010146b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010146e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101471:	85 db                	test   %ebx,%ebx
f0101473:	74 18                	je     f010148d <strncpy+0x2a>
f0101475:	ba 00 00 00 00       	mov    $0x0,%edx
		*dst++ = *src;
f010147a:	0f b6 01             	movzbl (%ecx),%eax
f010147d:	88 04 16             	mov    %al,(%esi,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101480:	80 39 01             	cmpb   $0x1,(%ecx)
f0101483:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101486:	83 c2 01             	add    $0x1,%edx
f0101489:	39 d3                	cmp    %edx,%ebx
f010148b:	77 ed                	ja     f010147a <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010148d:	89 f0                	mov    %esi,%eax
f010148f:	5b                   	pop    %ebx
f0101490:	5e                   	pop    %esi
f0101491:	5d                   	pop    %ebp
f0101492:	c3                   	ret    

f0101493 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101493:	55                   	push   %ebp
f0101494:	89 e5                	mov    %esp,%ebp
f0101496:	56                   	push   %esi
f0101497:	53                   	push   %ebx
f0101498:	8b 75 08             	mov    0x8(%ebp),%esi
f010149b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010149e:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01014a1:	89 f0                	mov    %esi,%eax
f01014a3:	85 d2                	test   %edx,%edx
f01014a5:	74 2b                	je     f01014d2 <strlcpy+0x3f>
		while (--size > 0 && *src != '\0')
f01014a7:	89 d1                	mov    %edx,%ecx
f01014a9:	83 e9 01             	sub    $0x1,%ecx
f01014ac:	74 1f                	je     f01014cd <strlcpy+0x3a>
f01014ae:	0f b6 13             	movzbl (%ebx),%edx
f01014b1:	84 d2                	test   %dl,%dl
f01014b3:	74 18                	je     f01014cd <strlcpy+0x3a>
f01014b5:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f01014b7:	88 10                	mov    %dl,(%eax)
f01014b9:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01014bc:	83 e9 01             	sub    $0x1,%ecx
f01014bf:	74 0e                	je     f01014cf <strlcpy+0x3c>
			*dst++ = *src++;
f01014c1:	83 c3 01             	add    $0x1,%ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01014c4:	0f b6 13             	movzbl (%ebx),%edx
f01014c7:	84 d2                	test   %dl,%dl
f01014c9:	75 ec                	jne    f01014b7 <strlcpy+0x24>
f01014cb:	eb 02                	jmp    f01014cf <strlcpy+0x3c>
f01014cd:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01014cf:	c6 00 00             	movb   $0x0,(%eax)
f01014d2:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01014d4:	5b                   	pop    %ebx
f01014d5:	5e                   	pop    %esi
f01014d6:	5d                   	pop    %ebp
f01014d7:	c3                   	ret    

f01014d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01014d8:	55                   	push   %ebp
f01014d9:	89 e5                	mov    %esp,%ebp
f01014db:	8b 55 08             	mov    0x8(%ebp),%edx
f01014de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
f01014e1:	0f b6 02             	movzbl (%edx),%eax
f01014e4:	84 c0                	test   %al,%al
f01014e6:	74 15                	je     f01014fd <strcmp+0x25>
f01014e8:	3a 01                	cmp    (%ecx),%al
f01014ea:	75 11                	jne    f01014fd <strcmp+0x25>
		p++, q++;
f01014ec:	83 c2 01             	add    $0x1,%edx
f01014ef:	83 c1 01             	add    $0x1,%ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01014f2:	0f b6 02             	movzbl (%edx),%eax
f01014f5:	84 c0                	test   %al,%al
f01014f7:	74 04                	je     f01014fd <strcmp+0x25>
f01014f9:	3a 01                	cmp    (%ecx),%al
f01014fb:	74 ef                	je     f01014ec <strcmp+0x14>
f01014fd:	0f b6 c0             	movzbl %al,%eax
f0101500:	0f b6 11             	movzbl (%ecx),%edx
f0101503:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101505:	5d                   	pop    %ebp
f0101506:	c3                   	ret    

f0101507 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101507:	55                   	push   %ebp
f0101508:	89 e5                	mov    %esp,%ebp
f010150a:	53                   	push   %ebx
f010150b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010150e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101511:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0101514:	85 d2                	test   %edx,%edx
f0101516:	74 2f                	je     f0101547 <strncmp+0x40>
f0101518:	0f b6 01             	movzbl (%ecx),%eax
f010151b:	84 c0                	test   %al,%al
f010151d:	74 1c                	je     f010153b <strncmp+0x34>
f010151f:	3a 03                	cmp    (%ebx),%al
f0101521:	75 18                	jne    f010153b <strncmp+0x34>
f0101523:	83 ea 01             	sub    $0x1,%edx
f0101526:	66 90                	xchg   %ax,%ax
f0101528:	74 1d                	je     f0101547 <strncmp+0x40>
		n--, p++, q++;
f010152a:	83 c1 01             	add    $0x1,%ecx
f010152d:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101530:	0f b6 01             	movzbl (%ecx),%eax
f0101533:	84 c0                	test   %al,%al
f0101535:	74 04                	je     f010153b <strncmp+0x34>
f0101537:	3a 03                	cmp    (%ebx),%al
f0101539:	74 e8                	je     f0101523 <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010153b:	0f b6 11             	movzbl (%ecx),%edx
f010153e:	0f b6 03             	movzbl (%ebx),%eax
f0101541:	29 c2                	sub    %eax,%edx
f0101543:	89 d0                	mov    %edx,%eax
f0101545:	eb 05                	jmp    f010154c <strncmp+0x45>
f0101547:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010154c:	5b                   	pop    %ebx
f010154d:	5d                   	pop    %ebp
f010154e:	c3                   	ret    

f010154f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010154f:	55                   	push   %ebp
f0101550:	89 e5                	mov    %esp,%ebp
f0101552:	8b 45 08             	mov    0x8(%ebp),%eax
f0101555:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101559:	0f b6 10             	movzbl (%eax),%edx
f010155c:	84 d2                	test   %dl,%dl
f010155e:	74 1a                	je     f010157a <strchr+0x2b>
		if (*s == c)
f0101560:	38 ca                	cmp    %cl,%dl
f0101562:	75 06                	jne    f010156a <strchr+0x1b>
f0101564:	eb 19                	jmp    f010157f <strchr+0x30>
f0101566:	38 ca                	cmp    %cl,%dl
f0101568:	74 15                	je     f010157f <strchr+0x30>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010156a:	83 c0 01             	add    $0x1,%eax
f010156d:	0f b6 10             	movzbl (%eax),%edx
f0101570:	84 d2                	test   %dl,%dl
f0101572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101578:	75 ec                	jne    f0101566 <strchr+0x17>
f010157a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f010157f:	5d                   	pop    %ebp
f0101580:	c3                   	ret    

f0101581 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101581:	55                   	push   %ebp
f0101582:	89 e5                	mov    %esp,%ebp
f0101584:	8b 45 08             	mov    0x8(%ebp),%eax
f0101587:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010158b:	0f b6 10             	movzbl (%eax),%edx
f010158e:	84 d2                	test   %dl,%dl
f0101590:	74 20                	je     f01015b2 <strfind+0x31>
		if (*s == c)
f0101592:	38 ca                	cmp    %cl,%dl
f0101594:	75 0c                	jne    f01015a2 <strfind+0x21>
f0101596:	eb 1a                	jmp    f01015b2 <strfind+0x31>
f0101598:	38 ca                	cmp    %cl,%dl
f010159a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01015a0:	74 10                	je     f01015b2 <strfind+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01015a2:	83 c0 01             	add    $0x1,%eax
f01015a5:	0f b6 10             	movzbl (%eax),%edx
f01015a8:	84 d2                	test   %dl,%dl
f01015aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01015b0:	75 e6                	jne    f0101598 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01015b2:	5d                   	pop    %ebp
f01015b3:	90                   	nop    
f01015b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01015b8:	c3                   	ret    

f01015b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01015b9:	55                   	push   %ebp
f01015ba:	89 e5                	mov    %esp,%ebp
f01015bc:	83 ec 0c             	sub    $0xc,%esp
f01015bf:	89 1c 24             	mov    %ebx,(%esp)
f01015c2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01015c6:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01015ca:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015cd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *p;

	if (n == 0)
f01015d0:	85 f6                	test   %esi,%esi
f01015d2:	74 3b                	je     f010160f <memset+0x56>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01015d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01015da:	75 2b                	jne    f0101607 <memset+0x4e>
f01015dc:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01015e2:	75 23                	jne    f0101607 <memset+0x4e>
		c &= 0xFF;
f01015e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01015e8:	89 d3                	mov    %edx,%ebx
f01015ea:	c1 e3 08             	shl    $0x8,%ebx
f01015ed:	89 d0                	mov    %edx,%eax
f01015ef:	c1 e0 18             	shl    $0x18,%eax
f01015f2:	89 d1                	mov    %edx,%ecx
f01015f4:	c1 e1 10             	shl    $0x10,%ecx
f01015f7:	09 c8                	or     %ecx,%eax
f01015f9:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f01015fb:	09 d8                	or     %ebx,%eax
f01015fd:	89 f1                	mov    %esi,%ecx
f01015ff:	c1 e9 02             	shr    $0x2,%ecx
f0101602:	fc                   	cld    
f0101603:	f3 ab                	rep stos %eax,%es:(%edi)
f0101605:	eb 08                	jmp    f010160f <memset+0x56>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101607:	8b 45 0c             	mov    0xc(%ebp),%eax
f010160a:	89 f1                	mov    %esi,%ecx
f010160c:	fc                   	cld    
f010160d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010160f:	89 f8                	mov    %edi,%eax
f0101611:	8b 1c 24             	mov    (%esp),%ebx
f0101614:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101618:	8b 7c 24 08          	mov    0x8(%esp),%edi
f010161c:	89 ec                	mov    %ebp,%esp
f010161e:	5d                   	pop    %ebp
f010161f:	c3                   	ret    

f0101620 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101620:	55                   	push   %ebp
f0101621:	89 e5                	mov    %esp,%ebp
f0101623:	83 ec 0c             	sub    $0xc,%esp
f0101626:	89 1c 24             	mov    %ebx,(%esp)
f0101629:	89 74 24 04          	mov    %esi,0x4(%esp)
f010162d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101631:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101634:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0101637:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010163a:	89 df                	mov    %ebx,%edi
	if (s < d && s + n > d) {
f010163c:	39 de                	cmp    %ebx,%esi
f010163e:	73 31                	jae    f0101671 <memmove+0x51>
f0101640:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101643:	39 d3                	cmp    %edx,%ebx
f0101645:	73 2a                	jae    f0101671 <memmove+0x51>
		s += n;
		d += n;
f0101647:	8d 34 0b             	lea    (%ebx,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010164a:	89 f0                	mov    %esi,%eax
f010164c:	09 d0                	or     %edx,%eax
f010164e:	a8 03                	test   $0x3,%al
f0101650:	75 13                	jne    f0101665 <memmove+0x45>
f0101652:	f6 c1 03             	test   $0x3,%cl
f0101655:	75 0e                	jne    f0101665 <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0101657:	8d 7e fc             	lea    -0x4(%esi),%edi
f010165a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010165d:	c1 e9 02             	shr    $0x2,%ecx
f0101660:	fd                   	std    
f0101661:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101663:	eb 09                	jmp    f010166e <memmove+0x4e>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101665:	8d 7e ff             	lea    -0x1(%esi),%edi
f0101668:	8d 72 ff             	lea    -0x1(%edx),%esi
f010166b:	fd                   	std    
f010166c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010166e:	fc                   	cld    
f010166f:	eb 18                	jmp    f0101689 <memmove+0x69>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101671:	89 f0                	mov    %esi,%eax
f0101673:	09 f8                	or     %edi,%eax
f0101675:	a8 03                	test   $0x3,%al
f0101677:	75 0d                	jne    f0101686 <memmove+0x66>
f0101679:	f6 c1 03             	test   $0x3,%cl
f010167c:	75 08                	jne    f0101686 <memmove+0x66>
			asm volatile("cld; rep movsl\n"
f010167e:	c1 e9 02             	shr    $0x2,%ecx
f0101681:	fc                   	cld    
f0101682:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101684:	eb 03                	jmp    f0101689 <memmove+0x69>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101686:	fc                   	cld    
f0101687:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101689:	89 d8                	mov    %ebx,%eax
f010168b:	8b 1c 24             	mov    (%esp),%ebx
f010168e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101692:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101696:	89 ec                	mov    %ebp,%esp
f0101698:	5d                   	pop    %ebp
f0101699:	c3                   	ret    

f010169a <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f010169a:	55                   	push   %ebp
f010169b:	89 e5                	mov    %esp,%ebp
f010169d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01016a0:	8b 45 10             	mov    0x10(%ebp),%eax
f01016a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01016b1:	89 04 24             	mov    %eax,(%esp)
f01016b4:	e8 67 ff ff ff       	call   f0101620 <memmove>
}
f01016b9:	c9                   	leave  
f01016ba:	c3                   	ret    

f01016bb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01016bb:	55                   	push   %ebp
f01016bc:	89 e5                	mov    %esp,%ebp
f01016be:	57                   	push   %edi
f01016bf:	56                   	push   %esi
f01016c0:	53                   	push   %ebx
f01016c1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01016c4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016c7:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016ca:	85 c0                	test   %eax,%eax
f01016cc:	74 38                	je     f0101706 <memcmp+0x4b>
		if (*s1 != *s2)
f01016ce:	0f b6 17             	movzbl (%edi),%edx
f01016d1:	0f b6 1e             	movzbl (%esi),%ebx
f01016d4:	38 da                	cmp    %bl,%dl
f01016d6:	74 22                	je     f01016fa <memcmp+0x3f>
f01016d8:	eb 14                	jmp    f01016ee <memcmp+0x33>
f01016da:	0f b6 54 0f 01       	movzbl 0x1(%edi,%ecx,1),%edx
f01016df:	0f b6 5c 0e 01       	movzbl 0x1(%esi,%ecx,1),%ebx
f01016e4:	83 c1 01             	add    $0x1,%ecx
f01016e7:	83 e8 01             	sub    $0x1,%eax
f01016ea:	38 da                	cmp    %bl,%dl
f01016ec:	74 14                	je     f0101702 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f01016ee:	0f b6 d2             	movzbl %dl,%edx
f01016f1:	0f b6 c3             	movzbl %bl,%eax
f01016f4:	29 c2                	sub    %eax,%edx
f01016f6:	89 d0                	mov    %edx,%eax
f01016f8:	eb 11                	jmp    f010170b <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016fa:	83 e8 01             	sub    $0x1,%eax
f01016fd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101702:	85 c0                	test   %eax,%eax
f0101704:	75 d4                	jne    f01016da <memcmp+0x1f>
f0101706:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f010170b:	5b                   	pop    %ebx
f010170c:	5e                   	pop    %esi
f010170d:	5f                   	pop    %edi
f010170e:	5d                   	pop    %ebp
f010170f:	c3                   	ret    

f0101710 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101710:	55                   	push   %ebp
f0101711:	89 e5                	mov    %esp,%ebp
f0101713:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101716:	89 c1                	mov    %eax,%ecx
f0101718:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
f010171b:	39 c8                	cmp    %ecx,%eax
f010171d:	73 1b                	jae    f010173a <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
f010171f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
f0101723:	38 10                	cmp    %dl,(%eax)
f0101725:	75 0b                	jne    f0101732 <memfind+0x22>
f0101727:	eb 11                	jmp    f010173a <memfind+0x2a>
f0101729:	38 10                	cmp    %dl,(%eax)
f010172b:	90                   	nop    
f010172c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101730:	74 08                	je     f010173a <memfind+0x2a>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101732:	83 c0 01             	add    $0x1,%eax
f0101735:	39 c1                	cmp    %eax,%ecx
f0101737:	90                   	nop    
f0101738:	77 ef                	ja     f0101729 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010173a:	5d                   	pop    %ebp
f010173b:	90                   	nop    
f010173c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101740:	c3                   	ret    

f0101741 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101741:	55                   	push   %ebp
f0101742:	89 e5                	mov    %esp,%ebp
f0101744:	57                   	push   %edi
f0101745:	56                   	push   %esi
f0101746:	53                   	push   %ebx
f0101747:	83 ec 04             	sub    $0x4,%esp
f010174a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010174d:	8b 7d 10             	mov    0x10(%ebp),%edi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101750:	0f b6 01             	movzbl (%ecx),%eax
f0101753:	3c 20                	cmp    $0x20,%al
f0101755:	74 04                	je     f010175b <strtol+0x1a>
f0101757:	3c 09                	cmp    $0x9,%al
f0101759:	75 0e                	jne    f0101769 <strtol+0x28>
		s++;
f010175b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010175e:	0f b6 01             	movzbl (%ecx),%eax
f0101761:	3c 20                	cmp    $0x20,%al
f0101763:	74 f6                	je     f010175b <strtol+0x1a>
f0101765:	3c 09                	cmp    $0x9,%al
f0101767:	74 f2                	je     f010175b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101769:	3c 2b                	cmp    $0x2b,%al
f010176b:	75 0d                	jne    f010177a <strtol+0x39>
		s++;
f010176d:	83 c1 01             	add    $0x1,%ecx
f0101770:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101777:	90                   	nop    
f0101778:	eb 15                	jmp    f010178f <strtol+0x4e>
	else if (*s == '-')
f010177a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101781:	3c 2d                	cmp    $0x2d,%al
f0101783:	75 0a                	jne    f010178f <strtol+0x4e>
		s++, neg = 1;
f0101785:	83 c1 01             	add    $0x1,%ecx
f0101788:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010178f:	85 ff                	test   %edi,%edi
f0101791:	0f 94 c0             	sete   %al
f0101794:	74 05                	je     f010179b <strtol+0x5a>
f0101796:	83 ff 10             	cmp    $0x10,%edi
f0101799:	75 1f                	jne    f01017ba <strtol+0x79>
f010179b:	80 39 30             	cmpb   $0x30,(%ecx)
f010179e:	75 1a                	jne    f01017ba <strtol+0x79>
f01017a0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01017a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017a8:	75 10                	jne    f01017ba <strtol+0x79>
		s += 2, base = 16;
f01017aa:	83 c1 02             	add    $0x2,%ecx
f01017ad:	bf 10 00 00 00       	mov    $0x10,%edi
f01017b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017b8:	eb 2d                	jmp    f01017e7 <strtol+0xa6>
	else if (base == 0 && s[0] == '0')
f01017ba:	85 ff                	test   %edi,%edi
f01017bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017c0:	75 18                	jne    f01017da <strtol+0x99>
f01017c2:	80 39 30             	cmpb   $0x30,(%ecx)
f01017c5:	8d 76 00             	lea    0x0(%esi),%esi
f01017c8:	75 18                	jne    f01017e2 <strtol+0xa1>
		s++, base = 8;
f01017ca:	83 c1 01             	add    $0x1,%ecx
f01017cd:	66 bf 08 00          	mov    $0x8,%di
f01017d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017d8:	eb 0d                	jmp    f01017e7 <strtol+0xa6>
	else if (base == 0)
f01017da:	84 c0                	test   %al,%al
f01017dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017e0:	74 05                	je     f01017e7 <strtol+0xa6>
f01017e2:	bf 0a 00 00 00       	mov    $0xa,%edi
f01017e7:	be 00 00 00 00       	mov    $0x0,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01017ec:	0f b6 11             	movzbl (%ecx),%edx
f01017ef:	89 d3                	mov    %edx,%ebx
f01017f1:	8d 42 d0             	lea    -0x30(%edx),%eax
f01017f4:	3c 09                	cmp    $0x9,%al
f01017f6:	77 08                	ja     f0101800 <strtol+0xbf>
			dig = *s - '0';
f01017f8:	0f be c2             	movsbl %dl,%eax
f01017fb:	8d 50 d0             	lea    -0x30(%eax),%edx
f01017fe:	eb 1c                	jmp    f010181c <strtol+0xdb>
		else if (*s >= 'a' && *s <= 'z')
f0101800:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0101803:	3c 19                	cmp    $0x19,%al
f0101805:	77 08                	ja     f010180f <strtol+0xce>
			dig = *s - 'a' + 10;
f0101807:	0f be c2             	movsbl %dl,%eax
f010180a:	8d 50 a9             	lea    -0x57(%eax),%edx
f010180d:	eb 0d                	jmp    f010181c <strtol+0xdb>
		else if (*s >= 'A' && *s <= 'Z')
f010180f:	8d 43 bf             	lea    -0x41(%ebx),%eax
f0101812:	3c 19                	cmp    $0x19,%al
f0101814:	77 17                	ja     f010182d <strtol+0xec>
			dig = *s - 'A' + 10;
f0101816:	0f be c2             	movsbl %dl,%eax
f0101819:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
f010181c:	39 fa                	cmp    %edi,%edx
f010181e:	7d 0d                	jge    f010182d <strtol+0xec>
			break;
		s++, val = (val * base) + dig;
f0101820:	83 c1 01             	add    $0x1,%ecx
f0101823:	89 f0                	mov    %esi,%eax
f0101825:	0f af c7             	imul   %edi,%eax
f0101828:	8d 34 02             	lea    (%edx,%eax,1),%esi
f010182b:	eb bf                	jmp    f01017ec <strtol+0xab>
		// we don't properly detect overflow!
	}
f010182d:	89 f0                	mov    %esi,%eax

	if (endptr)
f010182f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101833:	74 05                	je     f010183a <strtol+0xf9>
		*endptr = (char *) s;
f0101835:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101838:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
f010183a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010183e:	74 04                	je     f0101844 <strtol+0x103>
f0101840:	89 c6                	mov    %eax,%esi
f0101842:	f7 de                	neg    %esi
}
f0101844:	89 f0                	mov    %esi,%eax
f0101846:	83 c4 04             	add    $0x4,%esp
f0101849:	5b                   	pop    %ebx
f010184a:	5e                   	pop    %esi
f010184b:	5f                   	pop    %edi
f010184c:	5d                   	pop    %ebp
f010184d:	c3                   	ret    
	...

f0101850 <__udivdi3>:
f0101850:	55                   	push   %ebp
f0101851:	89 e5                	mov    %esp,%ebp
f0101853:	57                   	push   %edi
f0101854:	56                   	push   %esi
f0101855:	83 ec 1c             	sub    $0x1c,%esp
f0101858:	8b 45 10             	mov    0x10(%ebp),%eax
f010185b:	8b 55 08             	mov    0x8(%ebp),%edx
f010185e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101861:	89 c6                	mov    %eax,%esi
f0101863:	8b 45 14             	mov    0x14(%ebp),%eax
f0101866:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101869:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010186c:	85 c0                	test   %eax,%eax
f010186e:	75 38                	jne    f01018a8 <__udivdi3+0x58>
f0101870:	39 ce                	cmp    %ecx,%esi
f0101872:	77 4c                	ja     f01018c0 <__udivdi3+0x70>
f0101874:	85 f6                	test   %esi,%esi
f0101876:	75 0d                	jne    f0101885 <__udivdi3+0x35>
f0101878:	b9 01 00 00 00       	mov    $0x1,%ecx
f010187d:	31 d2                	xor    %edx,%edx
f010187f:	89 c8                	mov    %ecx,%eax
f0101881:	f7 f6                	div    %esi
f0101883:	89 c6                	mov    %eax,%esi
f0101885:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101888:	31 d2                	xor    %edx,%edx
f010188a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010188d:	89 f8                	mov    %edi,%eax
f010188f:	f7 f6                	div    %esi
f0101891:	89 c7                	mov    %eax,%edi
f0101893:	89 c8                	mov    %ecx,%eax
f0101895:	f7 f6                	div    %esi
f0101897:	89 fe                	mov    %edi,%esi
f0101899:	89 c1                	mov    %eax,%ecx
f010189b:	89 c8                	mov    %ecx,%eax
f010189d:	89 f2                	mov    %esi,%edx
f010189f:	83 c4 1c             	add    $0x1c,%esp
f01018a2:	5e                   	pop    %esi
f01018a3:	5f                   	pop    %edi
f01018a4:	5d                   	pop    %ebp
f01018a5:	c3                   	ret    
f01018a6:	66 90                	xchg   %ax,%ax
f01018a8:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f01018ab:	76 2b                	jbe    f01018d8 <__udivdi3+0x88>
f01018ad:	31 c9                	xor    %ecx,%ecx
f01018af:	31 f6                	xor    %esi,%esi
f01018b1:	89 c8                	mov    %ecx,%eax
f01018b3:	89 f2                	mov    %esi,%edx
f01018b5:	83 c4 1c             	add    $0x1c,%esp
f01018b8:	5e                   	pop    %esi
f01018b9:	5f                   	pop    %edi
f01018ba:	5d                   	pop    %ebp
f01018bb:	c3                   	ret    
f01018bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018c0:	89 d1                	mov    %edx,%ecx
f01018c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01018c5:	89 c8                	mov    %ecx,%eax
f01018c7:	f7 f6                	div    %esi
f01018c9:	31 f6                	xor    %esi,%esi
f01018cb:	89 c1                	mov    %eax,%ecx
f01018cd:	89 c8                	mov    %ecx,%eax
f01018cf:	89 f2                	mov    %esi,%edx
f01018d1:	83 c4 1c             	add    $0x1c,%esp
f01018d4:	5e                   	pop    %esi
f01018d5:	5f                   	pop    %edi
f01018d6:	5d                   	pop    %ebp
f01018d7:	c3                   	ret    
f01018d8:	0f bd f8             	bsr    %eax,%edi
f01018db:	83 f7 1f             	xor    $0x1f,%edi
f01018de:	75 20                	jne    f0101900 <__udivdi3+0xb0>
f01018e0:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f01018e3:	72 05                	jb     f01018ea <__udivdi3+0x9a>
f01018e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f01018e8:	77 c3                	ja     f01018ad <__udivdi3+0x5d>
f01018ea:	b9 01 00 00 00       	mov    $0x1,%ecx
f01018ef:	31 f6                	xor    %esi,%esi
f01018f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018f8:	eb b7                	jmp    f01018b1 <__udivdi3+0x61>
f01018fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101900:	89 f9                	mov    %edi,%ecx
f0101902:	89 f2                	mov    %esi,%edx
f0101904:	d3 e0                	shl    %cl,%eax
f0101906:	b9 20 00 00 00       	mov    $0x20,%ecx
f010190b:	29 f9                	sub    %edi,%ecx
f010190d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101910:	d3 ea                	shr    %cl,%edx
f0101912:	89 f9                	mov    %edi,%ecx
f0101914:	d3 e6                	shl    %cl,%esi
f0101916:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f010191a:	09 d0                	or     %edx,%eax
f010191c:	89 75 f4             	mov    %esi,-0xc(%ebp)
f010191f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101922:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101925:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101928:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010192b:	d3 ee                	shr    %cl,%esi
f010192d:	89 f9                	mov    %edi,%ecx
f010192f:	d3 e2                	shl    %cl,%edx
f0101931:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101935:	d3 e8                	shr    %cl,%eax
f0101937:	09 d0                	or     %edx,%eax
f0101939:	89 f2                	mov    %esi,%edx
f010193b:	f7 75 f0             	divl   -0x10(%ebp)
f010193e:	89 d6                	mov    %edx,%esi
f0101940:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101943:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101946:	f7 65 e0             	mull   -0x20(%ebp)
f0101949:	39 d6                	cmp    %edx,%esi
f010194b:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010194e:	72 20                	jb     f0101970 <__udivdi3+0x120>
f0101950:	74 0e                	je     f0101960 <__udivdi3+0x110>
f0101952:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101955:	31 f6                	xor    %esi,%esi
f0101957:	e9 55 ff ff ff       	jmp    f01018b1 <__udivdi3+0x61>
f010195c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101960:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101963:	89 f9                	mov    %edi,%ecx
f0101965:	d3 e0                	shl    %cl,%eax
f0101967:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f010196a:	73 e6                	jae    f0101952 <__udivdi3+0x102>
f010196c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101970:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101973:	31 f6                	xor    %esi,%esi
f0101975:	83 e9 01             	sub    $0x1,%ecx
f0101978:	e9 34 ff ff ff       	jmp    f01018b1 <__udivdi3+0x61>
f010197d:	00 00                	add    %al,(%eax)
	...

f0101980 <__umoddi3>:
f0101980:	55                   	push   %ebp
f0101981:	89 e5                	mov    %esp,%ebp
f0101983:	57                   	push   %edi
f0101984:	56                   	push   %esi
f0101985:	83 ec 20             	sub    $0x20,%esp
f0101988:	8b 45 10             	mov    0x10(%ebp),%eax
f010198b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010198e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101991:	89 c7                	mov    %eax,%edi
f0101993:	8b 45 14             	mov    0x14(%ebp),%eax
f0101996:	89 4d e8             	mov    %ecx,-0x18(%ebp)
f0101999:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f010199c:	85 c0                	test   %eax,%eax
f010199e:	75 18                	jne    f01019b8 <__umoddi3+0x38>
f01019a0:	39 f7                	cmp    %esi,%edi
f01019a2:	76 24                	jbe    f01019c8 <__umoddi3+0x48>
f01019a4:	89 c8                	mov    %ecx,%eax
f01019a6:	89 f2                	mov    %esi,%edx
f01019a8:	f7 f7                	div    %edi
f01019aa:	89 d0                	mov    %edx,%eax
f01019ac:	31 d2                	xor    %edx,%edx
f01019ae:	83 c4 20             	add    $0x20,%esp
f01019b1:	5e                   	pop    %esi
f01019b2:	5f                   	pop    %edi
f01019b3:	5d                   	pop    %ebp
f01019b4:	c3                   	ret    
f01019b5:	8d 76 00             	lea    0x0(%esi),%esi
f01019b8:	39 f0                	cmp    %esi,%eax
f01019ba:	76 2c                	jbe    f01019e8 <__umoddi3+0x68>
f01019bc:	89 c8                	mov    %ecx,%eax
f01019be:	89 f2                	mov    %esi,%edx
f01019c0:	83 c4 20             	add    $0x20,%esp
f01019c3:	5e                   	pop    %esi
f01019c4:	5f                   	pop    %edi
f01019c5:	5d                   	pop    %ebp
f01019c6:	c3                   	ret    
f01019c7:	90                   	nop    
f01019c8:	85 ff                	test   %edi,%edi
f01019ca:	75 0b                	jne    f01019d7 <__umoddi3+0x57>
f01019cc:	b8 01 00 00 00       	mov    $0x1,%eax
f01019d1:	31 d2                	xor    %edx,%edx
f01019d3:	f7 f7                	div    %edi
f01019d5:	89 c7                	mov    %eax,%edi
f01019d7:	89 f0                	mov    %esi,%eax
f01019d9:	31 d2                	xor    %edx,%edx
f01019db:	f7 f7                	div    %edi
f01019dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01019e0:	f7 f7                	div    %edi
f01019e2:	eb c6                	jmp    f01019aa <__umoddi3+0x2a>
f01019e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019e8:	0f bd d0             	bsr    %eax,%edx
f01019eb:	83 f2 1f             	xor    $0x1f,%edx
f01019ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01019f1:	75 1d                	jne    f0101a10 <__umoddi3+0x90>
f01019f3:	39 f0                	cmp    %esi,%eax
f01019f5:	0f 83 b5 00 00 00    	jae    f0101ab0 <__umoddi3+0x130>
f01019fb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01019fe:	29 f9                	sub    %edi,%ecx
f0101a00:	19 c6                	sbb    %eax,%esi
f0101a02:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0101a05:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101a08:	89 f2                	mov    %esi,%edx
f0101a0a:	eb b4                	jmp    f01019c0 <__umoddi3+0x40>
f0101a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a10:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101a14:	89 c2                	mov    %eax,%edx
f0101a16:	b8 20 00 00 00       	mov    $0x20,%eax
f0101a1b:	2b 45 e4             	sub    -0x1c(%ebp),%eax
f0101a1e:	d3 e2                	shl    %cl,%edx
f0101a20:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101a23:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101a27:	89 f8                	mov    %edi,%eax
f0101a29:	d3 e8                	shr    %cl,%eax
f0101a2b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101a2f:	09 d0                	or     %edx,%eax
f0101a31:	89 f2                	mov    %esi,%edx
f0101a33:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101a36:	89 f0                	mov    %esi,%eax
f0101a38:	d3 e7                	shl    %cl,%edi
f0101a3a:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101a3e:	89 7d f4             	mov    %edi,-0xc(%ebp)
f0101a41:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0101a44:	d3 e8                	shr    %cl,%eax
f0101a46:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101a4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101a4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101a50:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101a53:	d3 e2                	shl    %cl,%edx
f0101a55:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101a59:	d3 e8                	shr    %cl,%eax
f0101a5b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101a5f:	09 d0                	or     %edx,%eax
f0101a61:	89 f2                	mov    %esi,%edx
f0101a63:	f7 75 f0             	divl   -0x10(%ebp)
f0101a66:	89 d6                	mov    %edx,%esi
f0101a68:	d3 e7                	shl    %cl,%edi
f0101a6a:	f7 65 f4             	mull   -0xc(%ebp)
f0101a6d:	39 d6                	cmp    %edx,%esi
f0101a6f:	73 2f                	jae    f0101aa0 <__umoddi3+0x120>
f0101a71:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0101a74:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0101a77:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101a7b:	29 c7                	sub    %eax,%edi
f0101a7d:	19 d6                	sbb    %edx,%esi
f0101a7f:	89 fa                	mov    %edi,%edx
f0101a81:	89 f0                	mov    %esi,%eax
f0101a83:	d3 ea                	shr    %cl,%edx
f0101a85:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101a89:	d3 e0                	shl    %cl,%eax
f0101a8b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101a8f:	09 d0                	or     %edx,%eax
f0101a91:	89 f2                	mov    %esi,%edx
f0101a93:	d3 ea                	shr    %cl,%edx
f0101a95:	e9 26 ff ff ff       	jmp    f01019c0 <__umoddi3+0x40>
f0101a9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101aa0:	75 d5                	jne    f0101a77 <__umoddi3+0xf7>
f0101aa2:	39 c7                	cmp    %eax,%edi
f0101aa4:	73 d1                	jae    f0101a77 <__umoddi3+0xf7>
f0101aa6:	66 90                	xchg   %ax,%ax
f0101aa8:	eb c7                	jmp    f0101a71 <__umoddi3+0xf1>
f0101aaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101ab0:	3b 7d ec             	cmp    -0x14(%ebp),%edi
f0101ab3:	90                   	nop    
f0101ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ab8:	0f 87 47 ff ff ff    	ja     f0101a05 <__umoddi3+0x85>
f0101abe:	66 90                	xchg   %ax,%ax
f0101ac0:	e9 36 ff ff ff       	jmp    f01019fb <__umoddi3+0x7b>
