
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
f0100054:	c7 04 24 c0 1c 10 f0 	movl   $0xf0101cc0,(%esp)
f010005b:	e8 37 0b 00 00       	call   f0100b97 <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 f2 0a 00 00       	call   f0100b64 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 ab 1f 10 f0 	movl   $0xf0101fab,(%esp)
f0100079:	e8 19 0b 00 00       	call   f0100b97 <cprintf>
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
f0100086:	83 3d 60 03 11 f0 00 	cmpl   $0x0,0xf0110360
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 60 03 11 f0       	mov    %eax,0xf0110360

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 da 1c 10 f0 	movl   $0xf0101cda,(%esp)
f01000ac:	e8 e6 0a 00 00       	call   f0100b97 <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 a1 0a 00 00       	call   f0100b64 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 ab 1f 10 f0 	movl   $0xf0101fab,(%esp)
f01000ca:	e8 c8 0a 00 00       	call   f0100b97 <cprintf>
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
f01000eb:	c7 04 24 f2 1c 10 f0 	movl   $0xf0101cf2,(%esp)
f01000f2:	e8 a0 0a 00 00       	call   f0100b97 <cprintf>
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
f010012a:	c7 04 24 0e 1d 10 f0 	movl   $0xf0101d0e,(%esp)
f0100131:	e8 61 0a 00 00       	call   f0100b97 <cprintf>
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
f0100142:	b8 d0 09 11 f0       	mov    $0xf01109d0,%eax
f0100147:	2d 58 03 11 f0       	sub    $0xf0110358,%eax
f010014c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100150:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100157:	00 
f0100158:	c7 04 24 58 03 11 f0 	movl   $0xf0110358,(%esp)
f010015f:	e8 35 16 00 00       	call   f0101799 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100164:	e8 45 03 00 00       	call   f01004ae <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100169:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100170:	00 
f0100171:	c7 04 24 29 1d 10 f0 	movl   $0xf0101d29,(%esp)
f0100178:	e8 1a 0a 00 00       	call   f0100b97 <cprintf>




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
f01001d8:	be a4 05 11 f0       	mov    $0xf01105a4,%esi
f01001dd:	bf a0 03 11 f0       	mov    $0xf01103a0,%edi
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
f010022a:	83 3d 84 03 11 f0 00 	cmpl   $0x0,0xf0110384
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
f010024f:	a1 a0 05 11 f0       	mov    0xf01105a0,%eax
f0100254:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100259:	3b 05 a4 05 11 f0    	cmp    0xf01105a4,%eax
f010025f:	74 21                	je     f0100282 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100261:	0f b6 88 a0 03 11 f0 	movzbl -0xfeefc60(%eax),%ecx
f0100268:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.rpos == CONSBUFSIZE)
f010026b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100271:	0f 94 c0             	sete   %al
f0100274:	0f b6 c0             	movzbl %al,%eax
f0100277:	83 e8 01             	sub    $0x1,%eax
f010027a:	21 c2                	and    %eax,%edx
f010027c:	89 15 a0 05 11 f0    	mov    %edx,0xf01105a0
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
f010036a:	0f b7 05 90 03 11 f0 	movzwl 0xf0110390,%eax
f0100371:	66 85 c0             	test   %ax,%ax
f0100374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100378:	0f 84 e8 00 00 00    	je     f0100466 <cons_putc+0x1c5>
			crt_pos--;
f010037e:	83 e8 01             	sub    $0x1,%eax
f0100381:	66 a3 90 03 11 f0    	mov    %ax,0xf0110390
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100387:	0f b7 c0             	movzwl %ax,%eax
f010038a:	89 fa                	mov    %edi,%edx
f010038c:	b2 00                	mov    $0x0,%dl
f010038e:	83 ca 20             	or     $0x20,%edx
f0100391:	8b 0d 8c 03 11 f0    	mov    0xf011038c,%ecx
f0100397:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010039b:	eb 7b                	jmp    f0100418 <cons_putc+0x177>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010039d:	66 83 05 90 03 11 f0 	addw   $0x50,0xf0110390
f01003a4:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003a5:	0f b7 05 90 03 11 f0 	movzwl 0xf0110390,%eax
f01003ac:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003b2:	c1 e8 10             	shr    $0x10,%eax
f01003b5:	66 c1 e8 06          	shr    $0x6,%ax
f01003b9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003bc:	c1 e0 04             	shl    $0x4,%eax
f01003bf:	66 a3 90 03 11 f0    	mov    %ax,0xf0110390
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
f01003fb:	0f b7 05 90 03 11 f0 	movzwl 0xf0110390,%eax
f0100402:	0f b7 c8             	movzwl %ax,%ecx
f0100405:	8b 15 8c 03 11 f0    	mov    0xf011038c,%edx
f010040b:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010040f:	83 c0 01             	add    $0x1,%eax
f0100412:	66 a3 90 03 11 f0    	mov    %ax,0xf0110390
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100418:	66 81 3d 90 03 11 f0 	cmpw   $0x7cf,0xf0110390
f010041f:	cf 07 
f0100421:	76 43                	jbe    f0100466 <cons_putc+0x1c5>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100423:	8b 15 8c 03 11 f0    	mov    0xf011038c,%edx
f0100429:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100430:	00 
f0100431:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f0100437:	89 44 24 04          	mov    %eax,0x4(%esp)
f010043b:	89 14 24             	mov    %edx,(%esp)
f010043e:	e8 bd 13 00 00       	call   f0101800 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100443:	8b 15 8c 03 11 f0    	mov    0xf011038c,%edx
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
f010045e:	66 83 2d 90 03 11 f0 	subw   $0x50,0xf0110390
f0100465:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100466:	8b 35 88 03 11 f0    	mov    0xf0110388,%esi
f010046c:	89 f3                	mov    %esi,%ebx
f010046e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100476:	0f b7 0d 90 03 11 f0 	movzwl 0xf0110390,%ecx
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
f01004cd:	c7 05 88 03 11 f0 b4 	movl   $0x3b4,0xf0110388
f01004d4:	03 00 00 
f01004d7:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01004dc:	eb 16                	jmp    f01004f4 <cons_init+0x46>
	} else {
		*cp = was;
f01004de:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01004e5:	c7 05 88 03 11 f0 d4 	movl   $0x3d4,0xf0110388
f01004ec:	03 00 00 
f01004ef:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01004f4:	8b 1d 88 03 11 f0    	mov    0xf0110388,%ebx
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
f010051d:	89 35 8c 03 11 f0    	mov    %esi,0xf011038c
	crt_pos = pos;
f0100523:	0f b6 d0             	movzbl %al,%edx
f0100526:	89 f8                	mov    %edi,%eax
f0100528:	09 d0                	or     %edx,%eax
f010052a:	66 a3 90 03 11 f0    	mov    %ax,0xf0110390
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
f010057d:	89 35 84 03 11 f0    	mov    %esi,0xf0110384
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
f010058d:	c7 04 24 44 1d 10 f0 	movl   $0xf0101d44,(%esp)
f0100594:	e8 fe 05 00 00       	call   f0100b97 <cprintf>
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
f01005c7:	83 0d 80 03 11 f0 40 	orl    $0x40,0xf0110380
f01005ce:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005d3:	e9 bc 00 00 00       	jmp    f0100694 <kbd_proc_data+0xf3>
		return 0;
	} else if (data & 0x80) {
f01005d8:	84 c0                	test   %al,%al
f01005da:	79 31                	jns    f010060d <kbd_proc_data+0x6c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01005dc:	8b 0d 80 03 11 f0    	mov    0xf0110380,%ecx
f01005e2:	f6 c1 40             	test   $0x40,%cl
f01005e5:	75 03                	jne    f01005ea <kbd_proc_data+0x49>
f01005e7:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01005ea:	0f b6 c2             	movzbl %dl,%eax
f01005ed:	0f b6 80 80 1d 10 f0 	movzbl -0xfefe280(%eax),%eax
f01005f4:	83 c8 40             	or     $0x40,%eax
f01005f7:	0f b6 c0             	movzbl %al,%eax
f01005fa:	f7 d0                	not    %eax
f01005fc:	21 c8                	and    %ecx,%eax
f01005fe:	a3 80 03 11 f0       	mov    %eax,0xf0110380
f0100603:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100608:	e9 87 00 00 00       	jmp    f0100694 <kbd_proc_data+0xf3>
		return 0;
	} else if (shift & E0ESC) {
f010060d:	a1 80 03 11 f0       	mov    0xf0110380,%eax
f0100612:	a8 40                	test   $0x40,%al
f0100614:	74 0b                	je     f0100621 <kbd_proc_data+0x80>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100616:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100619:	83 e0 bf             	and    $0xffffffbf,%eax
f010061c:	a3 80 03 11 f0       	mov    %eax,0xf0110380
	}

	shift |= shiftcode[data];
f0100621:	0f b6 ca             	movzbl %dl,%ecx
	shift ^= togglecode[data];
f0100624:	0f b6 81 80 1d 10 f0 	movzbl -0xfefe280(%ecx),%eax
f010062b:	0b 05 80 03 11 f0    	or     0xf0110380,%eax
f0100631:	0f b6 91 80 1e 10 f0 	movzbl -0xfefe180(%ecx),%edx
f0100638:	31 c2                	xor    %eax,%edx
f010063a:	89 15 80 03 11 f0    	mov    %edx,0xf0110380

	c = charcode[shift & (CTL | SHIFT)][data];
f0100640:	89 d0                	mov    %edx,%eax
f0100642:	83 e0 03             	and    $0x3,%eax
f0100645:	8b 04 85 80 1f 10 f0 	mov    -0xfefe080(,%eax,4),%eax
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
f010067d:	c7 04 24 61 1d 10 f0 	movl   $0xf0101d61,(%esp)
f0100684:	e8 0e 05 00 00       	call   f0100b97 <cprintf>
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
f01006df:	c7 04 24 90 1f 10 f0 	movl   $0xf0101f90,(%esp)
f01006e6:	e8 ac 04 00 00       	call   f0100b97 <cprintf>
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
f0100704:	c7 04 24 ad 1f 10 f0 	movl   $0xf0101fad,(%esp)
f010070b:	e8 87 04 00 00       	call   f0100b97 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100710:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100717:	00 
f0100718:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010071f:	f0 
f0100720:	c7 04 24 44 20 10 f0 	movl   $0xf0102044,(%esp)
f0100727:	e8 6b 04 00 00       	call   f0100b97 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010072c:	c7 44 24 08 a5 1c 10 	movl   $0x101ca5,0x8(%esp)
f0100733:	00 
f0100734:	c7 44 24 04 a5 1c 10 	movl   $0xf0101ca5,0x4(%esp)
f010073b:	f0 
f010073c:	c7 04 24 68 20 10 f0 	movl   $0xf0102068,(%esp)
f0100743:	e8 4f 04 00 00       	call   f0100b97 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100748:	c7 44 24 08 58 03 11 	movl   $0x110358,0x8(%esp)
f010074f:	00 
f0100750:	c7 44 24 04 58 03 11 	movl   $0xf0110358,0x4(%esp)
f0100757:	f0 
f0100758:	c7 04 24 8c 20 10 f0 	movl   $0xf010208c,(%esp)
f010075f:	e8 33 04 00 00       	call   f0100b97 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100764:	c7 44 24 08 d0 09 11 	movl   $0x1109d0,0x8(%esp)
f010076b:	00 
f010076c:	c7 44 24 04 d0 09 11 	movl   $0xf01109d0,0x4(%esp)
f0100773:	f0 
f0100774:	c7 04 24 b0 20 10 f0 	movl   $0xf01020b0,(%esp)
f010077b:	e8 17 04 00 00       	call   f0100b97 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100780:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0100785:	81 ea 0c 00 10 f0    	sub    $0xf010000c,%edx
f010078b:	81 c2 d0 09 11 f0    	add    $0xf01109d0,%edx
f0100791:	89 d0                	mov    %edx,%eax
f0100793:	c1 f8 1f             	sar    $0x1f,%eax
f0100796:	c1 e8 16             	shr    $0x16,%eax
f0100799:	01 d0                	add    %edx,%eax
f010079b:	c1 f8 0a             	sar    $0xa,%eax
f010079e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007a2:	c7 04 24 d4 20 10 f0 	movl   $0xf01020d4,(%esp)
f01007a9:	e8 e9 03 00 00       	call   f0100b97 <cprintf>
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
f01007bb:	a1 a4 21 10 f0       	mov    0xf01021a4,%eax
f01007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007c4:	a1 a0 21 10 f0       	mov    0xf01021a0,%eax
f01007c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007cd:	c7 04 24 c6 1f 10 f0 	movl   $0xf0101fc6,(%esp)
f01007d4:	e8 be 03 00 00       	call   f0100b97 <cprintf>
f01007d9:	a1 b0 21 10 f0       	mov    0xf01021b0,%eax
f01007de:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007e2:	a1 ac 21 10 f0       	mov    0xf01021ac,%eax
f01007e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007eb:	c7 04 24 c6 1f 10 f0 	movl   $0xf0101fc6,(%esp)
f01007f2:	e8 a0 03 00 00       	call   f0100b97 <cprintf>
f01007f7:	a1 bc 21 10 f0       	mov    0xf01021bc,%eax
f01007fc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100800:	a1 b8 21 10 f0       	mov    0xf01021b8,%eax
f0100805:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100809:	c7 04 24 c6 1f 10 f0 	movl   $0xf0101fc6,(%esp)
f0100810:	e8 82 03 00 00       	call   f0100b97 <cprintf>
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
f0100828:	c7 04 24 00 21 10 f0 	movl   $0xf0102100,(%esp)
f010082f:	e8 63 03 00 00       	call   f0100b97 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100834:	c7 04 24 24 21 10 f0 	movl   $0xf0102124,(%esp)
f010083b:	e8 57 03 00 00       	call   f0100b97 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100840:	c7 04 24 cf 1f 10 f0 	movl   $0xf0101fcf,(%esp)
f0100847:	e8 84 0c 00 00       	call   f01014d0 <readline>
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
f0100874:	c7 04 24 d3 1f 10 f0 	movl   $0xf0101fd3,(%esp)
f010087b:	e8 af 0e 00 00       	call   f010172f <strchr>
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
f010089a:	c7 04 24 d8 1f 10 f0 	movl   $0xf0101fd8,(%esp)
f01008a1:	e8 f1 02 00 00       	call   f0100b97 <cprintf>
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
f01008cb:	c7 04 24 d3 1f 10 f0 	movl   $0xf0101fd3,(%esp)
f01008d2:	e8 58 0e 00 00       	call   f010172f <strchr>
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
f01008ee:	ba a0 21 10 f0       	mov    $0xf01021a0,%edx
f01008f3:	8b 02                	mov    (%edx),%eax
f01008f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f01008fc:	89 04 24             	mov    %eax,(%esp)
f01008ff:	e8 b4 0d 00 00       	call   f01016b8 <strcmp>
f0100904:	ba 00 00 00 00       	mov    $0x0,%edx
f0100909:	85 c0                	test   %eax,%eax
f010090b:	74 3a                	je     f0100947 <monitor+0x12b>
f010090d:	a1 ac 21 10 f0       	mov    0xf01021ac,%eax
f0100912:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100916:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100919:	89 04 24             	mov    %eax,(%esp)
f010091c:	e8 97 0d 00 00       	call   f01016b8 <strcmp>
f0100921:	ba 01 00 00 00       	mov    $0x1,%edx
f0100926:	85 c0                	test   %eax,%eax
f0100928:	74 1d                	je     f0100947 <monitor+0x12b>
f010092a:	a1 b8 21 10 f0       	mov    0xf01021b8,%eax
f010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100933:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100936:	89 04 24             	mov    %eax,(%esp)
f0100939:	e8 7a 0d 00 00       	call   f01016b8 <strcmp>
f010093e:	85 c0                	test   %eax,%eax
f0100940:	75 26                	jne    f0100968 <monitor+0x14c>
f0100942:	ba 02 00 00 00       	mov    $0x2,%edx
			return commands[i].func(argc, argv, tf);
f0100947:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010094a:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010094e:	8d 55 b4             	lea    -0x4c(%ebp),%edx
f0100951:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100955:	89 34 24             	mov    %esi,(%esp)
f0100958:	ff 14 85 a8 21 10 f0 	call   *-0xfefde58(,%eax,4)


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
f010096f:	c7 04 24 f5 1f 10 f0 	movl   $0xf0101ff5,(%esp)
f0100976:	e8 1c 02 00 00       	call   f0100b97 <cprintf>
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

f0100988 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100988:	55                   	push   %ebp
f0100989:	89 e5                	mov    %esp,%ebp
f010098b:	53                   	push   %ebx
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
f010098c:	c7 05 b4 05 11 f0 00 	movl   $0x0,0xf01105b4
f0100993:	00 00 00 
	for (i = 0; i < npage; i++) {
f0100996:	83 3d c0 09 11 f0 00 	cmpl   $0x0,0xf01109c0
f010099d:	74 63                	je     f0100a02 <page_init+0x7a>
f010099f:	bb 00 00 00 00       	mov    $0x0,%ebx
f01009a4:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f01009a9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01009ac:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f01009b3:	a1 cc 09 11 f0       	mov    0xf01109cc,%eax
f01009b8:	66 c7 44 08 08 00 00 	movw   $0x0,0x8(%eax,%ecx,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f01009bf:	8b 15 b4 05 11 f0    	mov    0xf01105b4,%edx
f01009c5:	a1 cc 09 11 f0       	mov    0xf01109cc,%eax
f01009ca:	89 14 08             	mov    %edx,(%eax,%ecx,1)
f01009cd:	85 d2                	test   %edx,%edx
f01009cf:	74 10                	je     f01009e1 <page_init+0x59>
f01009d1:	89 ca                	mov    %ecx,%edx
f01009d3:	03 15 cc 09 11 f0    	add    0xf01109cc,%edx
f01009d9:	a1 b4 05 11 f0       	mov    0xf01105b4,%eax
f01009de:	89 50 04             	mov    %edx,0x4(%eax)
f01009e1:	89 c8                	mov    %ecx,%eax
f01009e3:	03 05 cc 09 11 f0    	add    0xf01109cc,%eax
f01009e9:	a3 b4 05 11 f0       	mov    %eax,0xf01105b4
f01009ee:	c7 40 04 b4 05 11 f0 	movl   $0xf01105b4,0x4(%eax)
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f01009f5:	83 c3 01             	add    $0x1,%ebx
f01009f8:	89 d8                	mov    %ebx,%eax
f01009fa:	39 1d c0 09 11 f0    	cmp    %ebx,0xf01109c0
f0100a00:	77 a7                	ja     f01009a9 <page_init+0x21>
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
}
f0100a02:	5b                   	pop    %ebx
f0100a03:	5d                   	pop    %ebp
f0100a04:	c3                   	ret    

f0100a05 <page_alloc>:
//   -E_NO_MEM -- otherwise 
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
int
page_alloc(struct Page **pp_store)
{
f0100a05:	55                   	push   %ebp
f0100a06:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return -E_NO_MEM;
}
f0100a08:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100a0d:	5d                   	pop    %ebp
f0100a0e:	c3                   	ret    

f0100a0f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100a0f:	55                   	push   %ebp
f0100a10:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100a12:	5d                   	pop    %ebp
f0100a13:	c3                   	ret    

f0100a14 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100a14:	55                   	push   %ebp
f0100a15:	89 e5                	mov    %esp,%ebp
f0100a17:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100a1a:	66 83 68 08 01       	subw   $0x1,0x8(%eax)
		page_free(pp);
}
f0100a1f:	5d                   	pop    %ebp
f0100a20:	c3                   	ret    

f0100a21 <pgdir_walk>:
// Hint 2: the x86 MMU checks permission bits in both the page directory
// and the page table, so it's safe to leave permissions in the page
// more permissive than strictly necessary.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100a21:	55                   	push   %ebp
f0100a22:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100a24:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a29:	5d                   	pop    %ebp
f0100a2a:	c3                   	ret    

f0100a2b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f0100a2b:	55                   	push   %ebp
f0100a2c:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100a2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a33:	5d                   	pop    %ebp
f0100a34:	c3                   	ret    

f0100a35 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100a35:	55                   	push   %ebp
f0100a36:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100a38:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a3d:	5d                   	pop    %ebp
f0100a3e:	c3                   	ret    

f0100a3f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100a3f:	55                   	push   %ebp
f0100a40:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100a42:	5d                   	pop    %ebp
f0100a43:	c3                   	ret    

f0100a44 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100a44:	55                   	push   %ebp
f0100a45:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100a47:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a4a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100a4d:	5d                   	pop    %ebp
f0100a4e:	c3                   	ret    

f0100a4f <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f0100a4f:	55                   	push   %ebp
f0100a50:	89 e5                	mov    %esp,%ebp
f0100a52:	83 ec 18             	sub    $0x18,%esp
	pde_t* pgdir;
	uint32_t cr0;
	size_t n;

	// Delete this line:
	panic("i386_vm_init: This function is not finished\n");
f0100a55:	c7 44 24 08 c4 21 10 	movl   $0xf01021c4,0x8(%esp)
f0100a5c:	f0 
f0100a5d:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
f0100a64:	00 
f0100a65:	c7 04 24 18 22 10 f0 	movl   $0xf0102218,(%esp)
f0100a6c:	e8 0f f6 ff ff       	call   f0100080 <_panic>

f0100a71 <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0100a71:	55                   	push   %ebp
f0100a72:	89 e5                	mov    %esp,%ebp
f0100a74:	83 ec 18             	sub    $0x18,%esp
f0100a77:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100a7a:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100a7d:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a7f:	89 04 24             	mov    %eax,(%esp)
f0100a82:	e8 b5 00 00 00       	call   f0100b3c <mc146818_read>
f0100a87:	89 c3                	mov    %eax,%ebx
f0100a89:	8d 46 01             	lea    0x1(%esi),%eax
f0100a8c:	89 04 24             	mov    %eax,(%esp)
f0100a8f:	e8 a8 00 00 00       	call   f0100b3c <mc146818_read>
f0100a94:	c1 e0 08             	shl    $0x8,%eax
f0100a97:	09 d8                	or     %ebx,%eax
}
f0100a99:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100a9c:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100a9f:	89 ec                	mov    %ebp,%esp
f0100aa1:	5d                   	pop    %ebp
f0100aa2:	c3                   	ret    

f0100aa3 <i386_detect_memory>:

void
i386_detect_memory(void)
{
f0100aa3:	55                   	push   %ebp
f0100aa4:	89 e5                	mov    %esp,%ebp
f0100aa6:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f0100aa9:	b8 15 00 00 00       	mov    $0x15,%eax
f0100aae:	e8 be ff ff ff       	call   f0100a71 <nvram_read>
f0100ab3:	c1 e0 0a             	shl    $0xa,%eax
f0100ab6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100abb:	a3 ac 05 11 f0       	mov    %eax,0xf01105ac
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0100ac0:	b8 17 00 00 00       	mov    $0x17,%eax
f0100ac5:	e8 a7 ff ff ff       	call   f0100a71 <nvram_read>
f0100aca:	c1 e0 0a             	shl    $0xa,%eax
f0100acd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ad2:	a3 b0 05 11 f0       	mov    %eax,0xf01105b0

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0100ad7:	85 c0                	test   %eax,%eax
f0100ad9:	74 0c                	je     f0100ae7 <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0100adb:	05 00 00 10 00       	add    $0x100000,%eax
f0100ae0:	a3 a8 05 11 f0       	mov    %eax,0xf01105a8
f0100ae5:	eb 0a                	jmp    f0100af1 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0100ae7:	a1 ac 05 11 f0       	mov    0xf01105ac,%eax
f0100aec:	a3 a8 05 11 f0       	mov    %eax,0xf01105a8

	npage = maxpa / PGSIZE;
f0100af1:	a1 a8 05 11 f0       	mov    0xf01105a8,%eax
f0100af6:	89 c2                	mov    %eax,%edx
f0100af8:	c1 ea 0c             	shr    $0xc,%edx
f0100afb:	89 15 c0 09 11 f0    	mov    %edx,0xf01109c0

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100b01:	c1 e8 0a             	shr    $0xa,%eax
f0100b04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b08:	c7 04 24 f4 21 10 f0 	movl   $0xf01021f4,(%esp)
f0100b0f:	e8 83 00 00 00       	call   f0100b97 <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100b14:	a1 b0 05 11 f0       	mov    0xf01105b0,%eax
f0100b19:	c1 e8 0a             	shr    $0xa,%eax
f0100b1c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b20:	a1 ac 05 11 f0       	mov    0xf01105ac,%eax
f0100b25:	c1 e8 0a             	shr    $0xa,%eax
f0100b28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b2c:	c7 04 24 24 22 10 f0 	movl   $0xf0102224,(%esp)
f0100b33:	e8 5f 00 00 00       	call   f0100b97 <cprintf>
}
f0100b38:	c9                   	leave  
f0100b39:	c3                   	ret    
	...

f0100b3c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100b3c:	55                   	push   %ebp
f0100b3d:	89 e5                	mov    %esp,%ebp
			 "memory", "cc");
}

static __inline void outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100b3f:	ba 70 00 00 00       	mov    $0x70,%edx
f0100b44:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b47:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100b48:	b2 71                	mov    $0x71,%dl
f0100b4a:	ec                   	in     (%dx),%al
f0100b4b:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0100b4e:	5d                   	pop    %ebp
f0100b4f:	c3                   	ret    

f0100b50 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100b50:	55                   	push   %ebp
f0100b51:	89 e5                	mov    %esp,%ebp
			 "memory", "cc");
}

static __inline void outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100b53:	ba 70 00 00 00       	mov    $0x70,%edx
f0100b58:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b5b:	ee                   	out    %al,(%dx)
f0100b5c:	b2 71                	mov    $0x71,%dl
f0100b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b61:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100b62:	5d                   	pop    %ebp
f0100b63:	c3                   	ret    

f0100b64 <vcprintf>:
	cputchar(ch);
	*cnt++;
}

int vcprintf(const char *fmt, va_list ap)
{
f0100b64:	55                   	push   %ebp
f0100b65:	89 e5                	mov    %esp,%ebp
f0100b67:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100b6a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b71:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b74:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b78:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b7b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b7f:	8d 45 fc             	lea    -0x4(%ebp),%eax
f0100b82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b86:	c7 04 24 b1 0b 10 f0 	movl   $0xf0100bb1,(%esp)
f0100b8d:	e8 be 04 00 00       	call   f0101050 <vprintfmt>
f0100b92:	8b 45 fc             	mov    -0x4(%ebp),%eax
	return cnt;
}
f0100b95:	c9                   	leave  
f0100b96:	c3                   	ret    

f0100b97 <cprintf>:

int cprintf(const char *fmt, ...)
{
f0100b97:	55                   	push   %ebp
f0100b98:	89 e5                	mov    %esp,%ebp
f0100b9a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100b9d:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ba4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ba7:	89 04 24             	mov    %eax,(%esp)
f0100baa:	e8 b5 ff ff ff       	call   f0100b64 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100baf:	c9                   	leave  
f0100bb0:	c3                   	ret    

f0100bb1 <putch>:
#include <inc/stdio.h>
#include <inc/stdarg.h>


static void putch(int ch, int *cnt)
{
f0100bb1:	55                   	push   %ebp
f0100bb2:	89 e5                	mov    %esp,%ebp
f0100bb4:	83 ec 08             	sub    $0x8,%esp
	cputchar(ch);
f0100bb7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bba:	89 04 24             	mov    %eax,(%esp)
f0100bbd:	e8 dc f8 ff ff       	call   f010049e <cputchar>
	*cnt++;
}
f0100bc2:	c9                   	leave  
f0100bc3:	c3                   	ret    
	...

f0100bd0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100bd0:	55                   	push   %ebp
f0100bd1:	89 e5                	mov    %esp,%ebp
f0100bd3:	57                   	push   %edi
f0100bd4:	56                   	push   %esi
f0100bd5:	53                   	push   %ebx
f0100bd6:	83 ec 14             	sub    $0x14,%esp
f0100bd9:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0100bdc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100bdf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100be2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100be5:	8b 1a                	mov    (%edx),%ebx
f0100be7:	8b 01                	mov    (%ecx),%eax
f0100be9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0100bec:	39 c3                	cmp    %eax,%ebx
f0100bee:	0f 8f aa 00 00 00    	jg     f0100c9e <stab_binsearch+0xce>
f0100bf4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100bfb:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100bfe:	01 da                	add    %ebx,%edx
f0100c00:	89 d0                	mov    %edx,%eax
f0100c02:	c1 e8 1f             	shr    $0x1f,%eax
f0100c05:	01 d0                	add    %edx,%eax
f0100c07:	89 c6                	mov    %eax,%esi
f0100c09:	d1 fe                	sar    %esi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100c0b:	39 de                	cmp    %ebx,%esi
f0100c0d:	7c 2b                	jl     f0100c3a <stab_binsearch+0x6a>
f0100c0f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c12:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100c15:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100c1a:	39 f8                	cmp    %edi,%eax
f0100c1c:	74 24                	je     f0100c42 <stab_binsearch+0x72>
f0100c1e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c21:	8d 54 82 f8          	lea    -0x8(%edx,%eax,4),%edx
f0100c25:	89 f1                	mov    %esi,%ecx
			m--;
f0100c27:	83 e9 01             	sub    $0x1,%ecx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100c2a:	39 d9                	cmp    %ebx,%ecx
f0100c2c:	7c 0c                	jl     f0100c3a <stab_binsearch+0x6a>
f0100c2e:	0f b6 02             	movzbl (%edx),%eax
f0100c31:	83 ea 0c             	sub    $0xc,%edx
f0100c34:	39 f8                	cmp    %edi,%eax
f0100c36:	75 ef                	jne    f0100c27 <stab_binsearch+0x57>
f0100c38:	eb 0a                	jmp    f0100c44 <stab_binsearch+0x74>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100c3a:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100c3d:	8d 76 00             	lea    0x0(%esi),%esi
f0100c40:	eb 4d                	jmp    f0100c8f <stab_binsearch+0xbf>
			continue;
f0100c42:	89 f1                	mov    %esi,%ecx
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100c44:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100c47:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100c4a:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
f0100c4e:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0100c51:	73 11                	jae    f0100c64 <stab_binsearch+0x94>
			*region_left = m;
f0100c53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c56:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
f0100c58:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100c5b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0100c62:	eb 2b                	jmp    f0100c8f <stab_binsearch+0xbf>
		} else if (stabs[m].n_value > addr) {
f0100c64:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0100c67:	76 14                	jbe    f0100c7d <stab_binsearch+0xad>
			*region_right = m - 1;
f0100c69:	83 e9 01             	sub    $0x1,%ecx
f0100c6c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0100c6f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100c72:	89 0a                	mov    %ecx,(%edx)
f0100c74:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0100c7b:	eb 12                	jmp    f0100c8f <stab_binsearch+0xbf>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100c7d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c80:	89 0e                	mov    %ecx,(%esi)
			l = m;
			addr++;
f0100c82:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100c86:	89 cb                	mov    %ecx,%ebx
f0100c88:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0100c8f:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100c92:	0f 8d 63 ff ff ff    	jge    f0100bfb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100c98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0100c9c:	75 0f                	jne    f0100cad <stab_binsearch+0xdd>
		*region_right = *region_left - 1;
f0100c9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ca1:	8b 02                	mov    (%edx),%eax
f0100ca3:	83 e8 01             	sub    $0x1,%eax
f0100ca6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ca9:	89 01                	mov    %eax,(%ecx)
f0100cab:	eb 3a                	jmp    f0100ce7 <stab_binsearch+0x117>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100cad:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100cb0:	8b 0e                	mov    (%esi),%ecx
		     l > *region_left && stabs[l].n_type != type;
f0100cb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cb5:	8b 18                	mov    (%eax),%ebx
f0100cb7:	39 d9                	cmp    %ebx,%ecx
f0100cb9:	7e 27                	jle    f0100ce2 <stab_binsearch+0x112>
f0100cbb:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100cbe:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100cc1:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100cc6:	39 f8                	cmp    %edi,%eax
f0100cc8:	74 18                	je     f0100ce2 <stab_binsearch+0x112>
f0100cca:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100ccd:	8d 54 82 f8          	lea    -0x8(%edx,%eax,4),%edx
		     l--)
f0100cd1:	83 e9 01             	sub    $0x1,%ecx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100cd4:	39 d9                	cmp    %ebx,%ecx
f0100cd6:	7e 0a                	jle    f0100ce2 <stab_binsearch+0x112>
f0100cd8:	0f b6 02             	movzbl (%edx),%eax
f0100cdb:	83 ea 0c             	sub    $0xc,%edx
f0100cde:	39 f8                	cmp    %edi,%eax
f0100ce0:	75 ef                	jne    f0100cd1 <stab_binsearch+0x101>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100ce2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ce5:	89 0e                	mov    %ecx,(%esi)
	}
}
f0100ce7:	83 c4 14             	add    $0x14,%esp
f0100cea:	5b                   	pop    %ebx
f0100ceb:	5e                   	pop    %esi
f0100cec:	5f                   	pop    %edi
f0100ced:	5d                   	pop    %ebp
f0100cee:	c3                   	ret    

f0100cef <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100cef:	55                   	push   %ebp
f0100cf0:	89 e5                	mov    %esp,%ebp
f0100cf2:	83 ec 28             	sub    $0x28,%esp
f0100cf5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100cf8:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100cfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100cfe:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100d04:	c7 03 40 22 10 f0    	movl   $0xf0102240,(%ebx)
	info->eip_line = 0;
f0100d0a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100d11:	c7 43 08 40 22 10 f0 	movl   $0xf0102240,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100d18:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100d1f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100d22:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100d29:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100d2f:	76 12                	jbe    f0100d43 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d31:	b8 81 7e 10 f0       	mov    $0xf0107e81,%eax
f0100d36:	3d 35 62 10 f0       	cmp    $0xf0106235,%eax
f0100d3b:	0f 86 81 01 00 00    	jbe    f0100ec2 <debuginfo_eip+0x1d3>
f0100d41:	eb 1c                	jmp    f0100d5f <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100d43:	c7 44 24 08 4a 22 10 	movl   $0xf010224a,0x8(%esp)
f0100d4a:	f0 
f0100d4b:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100d52:	00 
f0100d53:	c7 04 24 57 22 10 f0 	movl   $0xf0102257,(%esp)
f0100d5a:	e8 21 f3 ff ff       	call   f0100080 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d5f:	80 3d 80 7e 10 f0 00 	cmpb   $0x0,0xf0107e80
f0100d66:	0f 85 56 01 00 00    	jne    f0100ec2 <debuginfo_eip+0x1d3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100d6c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100d73:	b8 34 62 10 f0       	mov    $0xf0106234,%eax
f0100d78:	2d 78 24 10 f0       	sub    $0xf0102478,%eax
f0100d7d:	c1 f8 02             	sar    $0x2,%eax
f0100d80:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100d86:	83 e8 01             	sub    $0x1,%eax
f0100d89:	89 45 ec             	mov    %eax,-0x14(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100d8c:	8d 4d ec             	lea    -0x14(%ebp),%ecx
f0100d8f:	8d 55 f0             	lea    -0x10(%ebp),%edx
f0100d92:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d96:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100d9d:	b8 78 24 10 f0       	mov    $0xf0102478,%eax
f0100da2:	e8 29 fe ff ff       	call   f0100bd0 <stab_binsearch>
	if (lfile == 0)
f0100da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100daa:	85 c0                	test   %eax,%eax
f0100dac:	0f 84 10 01 00 00    	je     f0100ec2 <debuginfo_eip+0x1d3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100db2:	89 45 e8             	mov    %eax,-0x18(%ebp)
	rfun = rfile;
f0100db5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100db8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100dbb:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0100dbe:	8d 55 e8             	lea    -0x18(%ebp),%edx
f0100dc1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100dc5:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100dcc:	b8 78 24 10 f0       	mov    $0xf0102478,%eax
f0100dd1:	e8 fa fd ff ff       	call   f0100bd0 <stab_binsearch>

	if (lfun <= rfun) {
f0100dd6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100dd9:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0100ddc:	7f 35                	jg     f0100e13 <debuginfo_eip+0x124>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100dde:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100de1:	8b 14 85 78 24 10 f0 	mov    -0xfefdb88(,%eax,4),%edx
f0100de8:	b8 81 7e 10 f0       	mov    $0xf0107e81,%eax
f0100ded:	2d 35 62 10 f0       	sub    $0xf0106235,%eax
f0100df2:	39 c2                	cmp    %eax,%edx
f0100df4:	73 09                	jae    f0100dff <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100df6:	8d 82 35 62 10 f0    	lea    -0xfef9dcb(%edx),%eax
f0100dfc:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100dff:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100e02:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e05:	8b 14 95 80 24 10 f0 	mov    -0xfefdb80(,%edx,4),%edx
f0100e0c:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
		// Search within the function definition for the line number.
		lline = lfun;
f0100e0f:	89 c6                	mov    %eax,%esi
f0100e11:	eb 06                	jmp    f0100e19 <debuginfo_eip+0x12a>
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100e13:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100e16:	8b 75 f0             	mov    -0x10(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100e19:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100e20:	00 
f0100e21:	8b 43 08             	mov    0x8(%ebx),%eax
f0100e24:	89 04 24             	mov    %eax,(%esp)
f0100e27:	e8 35 09 00 00       	call   f0101761 <strfind>
f0100e2c:	2b 43 08             	sub    0x8(%ebx),%eax
f0100e2f:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e32:	8b 7d f0             	mov    -0x10(%ebp),%edi
f0100e35:	39 fe                	cmp    %edi,%esi
f0100e37:	7c 49                	jl     f0100e82 <debuginfo_eip+0x193>
f0100e39:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100e3c:	8d 0c 85 78 24 10 f0 	lea    -0xfefdb88(,%eax,4),%ecx
f0100e43:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
f0100e47:	8d 04 85 6c 24 10 f0 	lea    -0xfefdb94(,%eax,4),%eax
f0100e4e:	80 fa 84             	cmp    $0x84,%dl
f0100e51:	75 1a                	jne    f0100e6d <debuginfo_eip+0x17e>
f0100e53:	e9 84 00 00 00       	jmp    f0100edc <debuginfo_eip+0x1ed>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100e58:	83 ee 01             	sub    $0x1,%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e5b:	39 f7                	cmp    %esi,%edi
f0100e5d:	7f 23                	jg     f0100e82 <debuginfo_eip+0x193>
f0100e5f:	89 c1                	mov    %eax,%ecx
f0100e61:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100e65:	83 e8 0c             	sub    $0xc,%eax
f0100e68:	80 fa 84             	cmp    $0x84,%dl
f0100e6b:	74 6f                	je     f0100edc <debuginfo_eip+0x1ed>
f0100e6d:	80 fa 64             	cmp    $0x64,%dl
f0100e70:	75 e6                	jne    f0100e58 <debuginfo_eip+0x169>
f0100e72:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0100e76:	74 e0                	je     f0100e58 <debuginfo_eip+0x169>
f0100e78:	eb 62                	jmp    f0100edc <debuginfo_eip+0x1ed>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e7a:	8d 82 35 62 10 f0    	lea    -0xfef9dcb(%edx),%eax
f0100e80:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e82:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100e85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e88:	39 c2                	cmp    %eax,%edx
f0100e8a:	7d 3e                	jge    f0100eca <debuginfo_eip+0x1db>
		for (lline = lfun + 1;
f0100e8c:	8d 4a 01             	lea    0x1(%edx),%ecx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e8f:	39 c8                	cmp    %ecx,%eax
f0100e91:	7e 37                	jle    f0100eca <debuginfo_eip+0x1db>
f0100e93:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100e96:	80 3c 85 7c 24 10 f0 	cmpb   $0xa0,-0xfefdb84(,%eax,4)
f0100e9d:	a0 
f0100e9e:	75 2a                	jne    f0100eca <debuginfo_eip+0x1db>
f0100ea0:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100ea3:	8d 14 85 94 24 10 f0 	lea    -0xfefdb6c(,%eax,4),%edx
		     lline++)
			info->eip_fn_narg++;
f0100eaa:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100eae:	83 c1 01             	add    $0x1,%ecx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100eb1:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0100eb4:	7e 14                	jle    f0100eca <debuginfo_eip+0x1db>
f0100eb6:	0f b6 02             	movzbl (%edx),%eax
f0100eb9:	83 c2 0c             	add    $0xc,%edx
f0100ebc:	3c a0                	cmp    $0xa0,%al
f0100ebe:	74 ea                	je     f0100eaa <debuginfo_eip+0x1bb>
f0100ec0:	eb 08                	jmp    f0100eca <debuginfo_eip+0x1db>
f0100ec2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ec7:	90                   	nop    
f0100ec8:	eb 05                	jmp    f0100ecf <debuginfo_eip+0x1e0>
f0100eca:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0100ecf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100ed2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100ed8:	89 ec                	mov    %ebp,%esp
f0100eda:	5d                   	pop    %ebp
f0100edb:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100edc:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100edf:	8b 14 85 78 24 10 f0 	mov    -0xfefdb88(,%eax,4),%edx
f0100ee6:	b8 81 7e 10 f0       	mov    $0xf0107e81,%eax
f0100eeb:	2d 35 62 10 f0       	sub    $0xf0106235,%eax
f0100ef0:	39 c2                	cmp    %eax,%edx
f0100ef2:	72 86                	jb     f0100e7a <debuginfo_eip+0x18b>
f0100ef4:	eb 8c                	jmp    f0100e82 <debuginfo_eip+0x193>
	...

f0100f00 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f00:	55                   	push   %ebp
f0100f01:	89 e5                	mov    %esp,%ebp
f0100f03:	57                   	push   %edi
f0100f04:	56                   	push   %esi
f0100f05:	53                   	push   %ebx
f0100f06:	83 ec 3c             	sub    $0x3c,%esp
f0100f09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f0c:	89 d7                	mov    %edx,%edi
f0100f0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f11:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f14:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f17:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100f1a:	8b 55 10             	mov    0x10(%ebp),%edx
f0100f1d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f20:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100f23:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0100f2a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f2d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
f0100f30:	72 16                	jb     f0100f48 <printnum+0x48>
f0100f32:	77 08                	ja     f0100f3c <printnum+0x3c>
f0100f34:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f37:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0100f3a:	76 0c                	jbe    f0100f48 <printnum+0x48>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100f3c:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f3f:	83 eb 01             	sub    $0x1,%ebx
f0100f42:	85 db                	test   %ebx,%ebx
f0100f44:	7f 57                	jg     f0100f9d <printnum+0x9d>
f0100f46:	eb 6a                	jmp    f0100fb2 <printnum+0xb2>
static void printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f48:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100f4c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f4f:	83 e8 01             	sub    $0x1,%eax
f0100f52:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f56:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100f5a:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100f5e:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100f62:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100f65:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100f68:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f70:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f73:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f76:	89 04 24             	mov    %eax,(%esp)
f0100f79:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f7d:	e8 ae 0a 00 00       	call   f0101a30 <__udivdi3>
f0100f82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100f86:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100f8a:	89 04 24             	mov    %eax,(%esp)
f0100f8d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f91:	89 fa                	mov    %edi,%edx
f0100f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f96:	e8 65 ff ff ff       	call   f0100f00 <printnum>
f0100f9b:	eb 15                	jmp    f0100fb2 <printnum+0xb2>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f9d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fa1:	89 34 24             	mov    %esi,(%esp)
f0100fa4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100fa7:	83 eb 01             	sub    $0x1,%ebx
f0100faa:	85 db                	test   %ebx,%ebx
f0100fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100fb0:	7f eb                	jg     f0100f9d <printnum+0x9d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100fb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fb6:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100fba:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100fbd:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100fc0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fc4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100fc8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100fcb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fce:	89 04 24             	mov    %eax,(%esp)
f0100fd1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100fd5:	e8 86 0b 00 00       	call   f0101b60 <__umoddi3>
f0100fda:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fde:	0f be 80 65 22 10 f0 	movsbl -0xfefdd9b(%eax),%eax
f0100fe5:	89 04 24             	mov    %eax,(%esp)
f0100fe8:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100feb:	83 c4 3c             	add    $0x3c,%esp
f0100fee:	5b                   	pop    %ebx
f0100fef:	5e                   	pop    %esi
f0100ff0:	5f                   	pop    %edi
f0100ff1:	5d                   	pop    %ebp
f0100ff2:	c3                   	ret    

f0100ff3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long getuint(va_list *ap, int lflag)
{
f0100ff3:	55                   	push   %ebp
f0100ff4:	89 e5                	mov    %esp,%ebp
f0100ff6:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
f0100ff8:	83 fa 01             	cmp    $0x1,%edx
f0100ffb:	7e 0f                	jle    f010100c <getuint+0x19>
		return va_arg(*ap, unsigned long long);
f0100ffd:	8b 00                	mov    (%eax),%eax
f0100fff:	83 c0 08             	add    $0x8,%eax
f0101002:	89 01                	mov    %eax,(%ecx)
f0101004:	8b 50 fc             	mov    -0x4(%eax),%edx
f0101007:	8b 40 f8             	mov    -0x8(%eax),%eax
f010100a:	eb 24                	jmp    f0101030 <getuint+0x3d>
	else if (lflag)
f010100c:	85 d2                	test   %edx,%edx
f010100e:	74 11                	je     f0101021 <getuint+0x2e>
		return va_arg(*ap, unsigned long);
f0101010:	8b 00                	mov    (%eax),%eax
f0101012:	83 c0 04             	add    $0x4,%eax
f0101015:	89 01                	mov    %eax,(%ecx)
f0101017:	8b 40 fc             	mov    -0x4(%eax),%eax
f010101a:	ba 00 00 00 00       	mov    $0x0,%edx
f010101f:	eb 0f                	jmp    f0101030 <getuint+0x3d>
	else
		return va_arg(*ap, unsigned int);
f0101021:	8b 00                	mov    (%eax),%eax
f0101023:	83 c0 04             	add    $0x4,%eax
f0101026:	89 01                	mov    %eax,(%ecx)
f0101028:	8b 40 fc             	mov    -0x4(%eax),%eax
f010102b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101030:	5d                   	pop    %ebp
f0101031:	c3                   	ret    

f0101032 <sprintputch>:
	char *ebuf;
	int cnt;
};

static void sprintputch(int ch, struct sprintbuf *b)
{
f0101032:	55                   	push   %ebp
f0101033:	89 e5                	mov    %esp,%ebp
f0101035:	8b 55 0c             	mov    0xc(%ebp),%edx
	b->cnt++;
f0101038:	83 42 08 01          	addl   $0x1,0x8(%edx)
	if (b->buf < b->ebuf)
f010103c:	8b 02                	mov    (%edx),%eax
f010103e:	3b 42 04             	cmp    0x4(%edx),%eax
f0101041:	73 0b                	jae    f010104e <sprintputch+0x1c>
		*b->buf++ = ch;
f0101043:	0f b6 4d 08          	movzbl 0x8(%ebp),%ecx
f0101047:	88 08                	mov    %cl,(%eax)
f0101049:	83 c0 01             	add    $0x1,%eax
f010104c:	89 02                	mov    %eax,(%edx)
}
f010104e:	5d                   	pop    %ebp
f010104f:	c3                   	ret    

f0101050 <vprintfmt>:

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101050:	55                   	push   %ebp
f0101051:	89 e5                	mov    %esp,%ebp
f0101053:	57                   	push   %edi
f0101054:	56                   	push   %esi
f0101055:	53                   	push   %ebx
f0101056:	83 ec 2c             	sub    $0x2c,%esp
f0101059:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010105c:	eb 15                	jmp    f0101073 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010105e:	85 c0                	test   %eax,%eax
f0101060:	0f 84 b9 03 00 00    	je     f010141f <vprintfmt+0x3cf>
				return;
			putch(ch, putdat);//when vprintfmt was called, *putdat = &(0)
f0101066:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101069:	89 54 24 04          	mov    %edx,0x4(%esp)
f010106d:	89 04 24             	mov    %eax,(%esp)
f0101070:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101073:	0f b6 03             	movzbl (%ebx),%eax
f0101076:	83 c3 01             	add    $0x1,%ebx
f0101079:	83 f8 25             	cmp    $0x25,%eax
f010107c:	75 e0                	jne    f010105e <vprintfmt+0xe>
f010107e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101083:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010108a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f010108f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0101096:	c6 45 ef 20          	movb   $0x20,-0x11(%ebp)
f010109a:	eb 07                	jmp    f01010a3 <vprintfmt+0x53>
f010109c:	c6 45 ef 2d          	movb   $0x2d,-0x11(%ebp)
f01010a0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010a3:	0f b6 03             	movzbl (%ebx),%eax
f01010a6:	0f b6 c8             	movzbl %al,%ecx
f01010a9:	8d 73 01             	lea    0x1(%ebx),%esi
f01010ac:	89 75 f0             	mov    %esi,-0x10(%ebp)
f01010af:	83 e8 23             	sub    $0x23,%eax
f01010b2:	3c 55                	cmp    $0x55,%al
f01010b4:	0f 87 44 03 00 00    	ja     f01013fe <vprintfmt+0x3ae>
f01010ba:	0f b6 c0             	movzbl %al,%eax
f01010bd:	ff 24 85 f4 22 10 f0 	jmp    *-0xfefdd0c(,%eax,4)
f01010c4:	c6 45 ef 30          	movb   $0x30,-0x11(%ebp)
f01010c8:	eb d6                	jmp    f01010a0 <vprintfmt+0x50>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01010ca:	8d 79 d0             	lea    -0x30(%ecx),%edi
				ch = *fmt;
f01010cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01010d0:	0f be 08             	movsbl (%eax),%ecx
				if (ch < '0' || ch > '9')
f01010d3:	8d 41 d0             	lea    -0x30(%ecx),%eax
f01010d6:	83 f8 09             	cmp    $0x9,%eax
f01010d9:	77 3f                	ja     f010111a <vprintfmt+0xca>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01010db:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
				precision = precision * 10 + ch - '0';
f01010df:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f01010e2:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
f01010e6:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01010e9:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f01010ec:	8d 41 d0             	lea    -0x30(%ecx),%eax
f01010ef:	83 f8 09             	cmp    $0x9,%eax
f01010f2:	76 e7                	jbe    f01010db <vprintfmt+0x8b>
f01010f4:	eb 24                	jmp    f010111a <vprintfmt+0xca>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01010f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f9:	83 c0 04             	add    $0x4,%eax
f01010fc:	89 45 14             	mov    %eax,0x14(%ebp)
f01010ff:	8b 78 fc             	mov    -0x4(%eax),%edi
f0101102:	eb 16                	jmp    f010111a <vprintfmt+0xca>
			goto process_precision;

		case '.':
			if (width < 0)
f0101104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101107:	c1 f8 1f             	sar    $0x1f,%eax
f010110a:	f7 d0                	not    %eax
f010110c:	21 45 e4             	and    %eax,-0x1c(%ebp)
f010110f:	eb 8f                	jmp    f01010a0 <vprintfmt+0x50>
f0101111:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0101118:	eb 86                	jmp    f01010a0 <vprintfmt+0x50>
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010111a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010111e:	79 80                	jns    f01010a0 <vprintfmt+0x50>
f0101120:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0101123:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0101128:	e9 73 ff ff ff       	jmp    f01010a0 <vprintfmt+0x50>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010112d:	83 c2 01             	add    $0x1,%edx
f0101130:	e9 6b ff ff ff       	jmp    f01010a0 <vprintfmt+0x50>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101135:	8b 45 14             	mov    0x14(%ebp),%eax
f0101138:	83 c0 04             	add    $0x4,%eax
f010113b:	89 45 14             	mov    %eax,0x14(%ebp)
f010113e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101141:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101145:	8b 40 fc             	mov    -0x4(%eax),%eax
f0101148:	89 04 24             	mov    %eax,(%esp)
f010114b:	ff 55 08             	call   *0x8(%ebp)
f010114e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0101151:	e9 1d ff ff ff       	jmp    f0101073 <vprintfmt+0x23>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101156:	8b 45 14             	mov    0x14(%ebp),%eax
f0101159:	83 c0 04             	add    $0x4,%eax
f010115c:	89 45 14             	mov    %eax,0x14(%ebp)
f010115f:	8b 40 fc             	mov    -0x4(%eax),%eax
f0101162:	89 c2                	mov    %eax,%edx
f0101164:	c1 fa 1f             	sar    $0x1f,%edx
f0101167:	31 d0                	xor    %edx,%eax
f0101169:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f010116b:	83 f8 06             	cmp    $0x6,%eax
f010116e:	7f 0b                	jg     f010117b <vprintfmt+0x12b>
f0101170:	8b 14 85 4c 24 10 f0 	mov    -0xfefdbb4(,%eax,4),%edx
f0101177:	85 d2                	test   %edx,%edx
f0101179:	75 26                	jne    f01011a1 <vprintfmt+0x151>
				printfmt(putch, putdat, "error %d", err);
f010117b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010117f:	c7 44 24 08 76 22 10 	movl   $0xf0102276,0x8(%esp)
f0101186:	f0 
f0101187:	8b 75 0c             	mov    0xc(%ebp),%esi
f010118a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010118e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101191:	89 04 24             	mov    %eax,(%esp)
f0101194:	e8 0e 03 00 00       	call   f01014a7 <printfmt>
f0101199:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f010119c:	e9 d2 fe ff ff       	jmp    f0101073 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01011a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01011a5:	c7 44 24 08 7f 22 10 	movl   $0xf010227f,0x8(%esp)
f01011ac:	f0 
f01011ad:	8b 55 0c             	mov    0xc(%ebp),%edx
f01011b0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01011b4:	8b 75 08             	mov    0x8(%ebp),%esi
f01011b7:	89 34 24             	mov    %esi,(%esp)
f01011ba:	e8 e8 02 00 00       	call   f01014a7 <printfmt>
f01011bf:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01011c2:	e9 ac fe ff ff       	jmp    f0101073 <vprintfmt+0x23>
f01011c7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01011ca:	89 fa                	mov    %edi,%edx
f01011cc:	8b 5d f0             	mov    -0x10(%ebp),%ebx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01011cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01011d2:	83 c0 04             	add    $0x4,%eax
f01011d5:	89 45 14             	mov    %eax,0x14(%ebp)
f01011d8:	8b 40 fc             	mov    -0x4(%eax),%eax
f01011db:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011de:	85 c0                	test   %eax,%eax
f01011e0:	75 07                	jne    f01011e9 <vprintfmt+0x199>
f01011e2:	c7 45 e0 82 22 10 f0 	movl   $0xf0102282,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f01011e9:	85 f6                	test   %esi,%esi
f01011eb:	7e 06                	jle    f01011f3 <vprintfmt+0x1a3>
f01011ed:	80 7d ef 2d          	cmpb   $0x2d,-0x11(%ebp)
f01011f1:	75 1a                	jne    f010120d <vprintfmt+0x1bd>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011f6:	0f be 10             	movsbl (%eax),%edx
f01011f9:	85 d2                	test   %edx,%edx
f01011fb:	0f 85 9c 00 00 00    	jne    f010129d <vprintfmt+0x24d>
f0101201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101208:	e9 7d 00 00 00       	jmp    f010128a <vprintfmt+0x23a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010120d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101211:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101214:	89 14 24             	mov    %edx,(%esp)
f0101217:	e8 cf 03 00 00       	call   f01015eb <strnlen>
f010121c:	29 c6                	sub    %eax,%esi
f010121e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0101221:	85 f6                	test   %esi,%esi
f0101223:	7e ce                	jle    f01011f3 <vprintfmt+0x1a3>
					putch(padc, putdat);
f0101225:	0f be 75 ef          	movsbl -0x11(%ebp),%esi
f0101229:	8b 45 0c             	mov    0xc(%ebp),%eax
f010122c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101230:	89 34 24             	mov    %esi,(%esp)
f0101233:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101236:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010123a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010123e:	7f e9                	jg     f0101229 <vprintfmt+0x1d9>
f0101240:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101247:	eb aa                	jmp    f01011f3 <vprintfmt+0x1a3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101249:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010124d:	8d 76 00             	lea    0x0(%esi),%esi
f0101250:	74 1b                	je     f010126d <vprintfmt+0x21d>
f0101252:	8d 42 e0             	lea    -0x20(%edx),%eax
f0101255:	83 f8 5e             	cmp    $0x5e,%eax
f0101258:	76 13                	jbe    f010126d <vprintfmt+0x21d>
					putch('?', putdat);
f010125a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010125d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101261:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101268:	ff 55 08             	call   *0x8(%ebp)
f010126b:	eb 0d                	jmp    f010127a <vprintfmt+0x22a>
				else
					putch(ch, putdat);
f010126d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101270:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101274:	89 14 24             	mov    %edx,(%esp)
f0101277:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010127a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010127e:	0f be 16             	movsbl (%esi),%edx
f0101281:	85 d2                	test   %edx,%edx
f0101283:	74 05                	je     f010128a <vprintfmt+0x23a>
f0101285:	83 c6 01             	add    $0x1,%esi
f0101288:	eb 19                	jmp    f01012a3 <vprintfmt+0x253>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010128a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010128e:	7f 22                	jg     f01012b2 <vprintfmt+0x262>
f0101290:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0101293:	90                   	nop    
f0101294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101298:	e9 d6 fd ff ff       	jmp    f0101073 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010129d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01012a0:	83 c6 01             	add    $0x1,%esi
f01012a3:	85 ff                	test   %edi,%edi
f01012a5:	78 a2                	js     f0101249 <vprintfmt+0x1f9>
f01012a7:	83 ef 01             	sub    $0x1,%edi
f01012aa:	79 9d                	jns    f0101249 <vprintfmt+0x1f9>
f01012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01012b0:	eb d8                	jmp    f010128a <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01012b2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012b5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012b9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01012c0:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01012c3:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01012c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01012cb:	7f e5                	jg     f01012b2 <vprintfmt+0x262>
f01012cd:	e9 a1 fd ff ff       	jmp    f0101073 <vprintfmt+0x23>

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01012d2:	83 fa 01             	cmp    $0x1,%edx
f01012d5:	8d 76 00             	lea    0x0(%esi),%esi
f01012d8:	7e 11                	jle    f01012eb <vprintfmt+0x29b>
		return va_arg(*ap, long long);
f01012da:	8b 45 14             	mov    0x14(%ebp),%eax
f01012dd:	83 c0 08             	add    $0x8,%eax
f01012e0:	89 45 14             	mov    %eax,0x14(%ebp)
f01012e3:	8b 70 f8             	mov    -0x8(%eax),%esi
f01012e6:	8b 78 fc             	mov    -0x4(%eax),%edi
f01012e9:	eb 2c                	jmp    f0101317 <vprintfmt+0x2c7>
	else if (lflag)
f01012eb:	85 d2                	test   %edx,%edx
f01012ed:	74 15                	je     f0101304 <vprintfmt+0x2b4>
		return va_arg(*ap, long);
f01012ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f2:	83 c0 04             	add    $0x4,%eax
f01012f5:	89 45 14             	mov    %eax,0x14(%ebp)
f01012f8:	8b 40 fc             	mov    -0x4(%eax),%eax
f01012fb:	89 c6                	mov    %eax,%esi
f01012fd:	89 c7                	mov    %eax,%edi
f01012ff:	c1 ff 1f             	sar    $0x1f,%edi
f0101302:	eb 13                	jmp    f0101317 <vprintfmt+0x2c7>
	else
		return va_arg(*ap, int);
f0101304:	8b 45 14             	mov    0x14(%ebp),%eax
f0101307:	83 c0 04             	add    $0x4,%eax
f010130a:	89 45 14             	mov    %eax,0x14(%ebp)
f010130d:	8b 40 fc             	mov    -0x4(%eax),%eax
f0101310:	89 c6                	mov    %eax,%esi
f0101312:	89 c7                	mov    %eax,%edi
f0101314:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101317:	89 f2                	mov    %esi,%edx
f0101319:	89 f9                	mov    %edi,%ecx
f010131b:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
f0101320:	85 ff                	test   %edi,%edi
f0101322:	0f 89 94 00 00 00    	jns    f01013bc <vprintfmt+0x36c>
				putch('-', putdat);
f0101328:	8b 45 0c             	mov    0xc(%ebp),%eax
f010132b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010132f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101336:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101339:	89 f2                	mov    %esi,%edx
f010133b:	89 f9                	mov    %edi,%ecx
f010133d:	f7 da                	neg    %edx
f010133f:	83 d1 00             	adc    $0x0,%ecx
f0101342:	f7 d9                	neg    %ecx
f0101344:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101349:	eb 71                	jmp    f01013bc <vprintfmt+0x36c>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010134b:	8d 45 14             	lea    0x14(%ebp),%eax
f010134e:	e8 a0 fc ff ff       	call   f0100ff3 <getuint>
f0101353:	89 d1                	mov    %edx,%ecx
f0101355:	89 c2                	mov    %eax,%edx
f0101357:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010135c:	eb 5e                	jmp    f01013bc <vprintfmt+0x36c>
			putch('x', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
			*/
			num = getuint(&ap, lflag);
f010135e:	8d 45 14             	lea    0x14(%ebp),%eax
f0101361:	e8 8d fc ff ff       	call   f0100ff3 <getuint>
f0101366:	89 d1                	mov    %edx,%ecx
f0101368:	89 c2                	mov    %eax,%edx
f010136a:	bb 08 00 00 00       	mov    $0x8,%ebx
f010136f:	eb 4b                	jmp    f01013bc <vprintfmt+0x36c>
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f0101371:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101374:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101378:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010137f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101382:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101385:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101389:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101390:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0101393:	8b 45 14             	mov    0x14(%ebp),%eax
f0101396:	83 c0 04             	add    $0x4,%eax
f0101399:	89 45 14             	mov    %eax,0x14(%ebp)
f010139c:	8b 50 fc             	mov    -0x4(%eax),%edx
f010139f:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013a4:	bb 10 00 00 00       	mov    $0x10,%ebx
f01013a9:	eb 11                	jmp    f01013bc <vprintfmt+0x36c>
			base = 16;
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01013ab:	8d 45 14             	lea    0x14(%ebp),%eax
f01013ae:	e8 40 fc ff ff       	call   f0100ff3 <getuint>
f01013b3:	89 d1                	mov    %edx,%ecx
f01013b5:	89 c2                	mov    %eax,%edx
f01013b7:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f01013bc:	0f be 45 ef          	movsbl -0x11(%ebp),%eax
f01013c0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01013c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01013c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013cb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01013cf:	89 14 24             	mov    %edx,(%esp)
f01013d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01013d6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01013dc:	e8 1f fb ff ff       	call   f0100f00 <printnum>
f01013e1:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01013e4:	e9 8a fc ff ff       	jmp    f0101073 <vprintfmt+0x23>
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01013e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013ec:	89 54 24 04          	mov    %edx,0x4(%esp)
f01013f0:	89 0c 24             	mov    %ecx,(%esp)
f01013f3:	ff 55 08             	call   *0x8(%ebp)
f01013f6:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01013f9:	e9 75 fc ff ff       	jmp    f0101073 <vprintfmt+0x23>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01013fe:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101401:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101405:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010140c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010140f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101412:	80 38 25             	cmpb   $0x25,(%eax)
f0101415:	0f 84 58 fc ff ff    	je     f0101073 <vprintfmt+0x23>
f010141b:	89 c3                	mov    %eax,%ebx
f010141d:	eb f0                	jmp    f010140f <vprintfmt+0x3bf>
				/* do nothing */;
			break;
		}
	}
}
f010141f:	83 c4 2c             	add    $0x2c,%esp
f0101422:	5b                   	pop    %ebx
f0101423:	5e                   	pop    %esi
f0101424:	5f                   	pop    %edi
f0101425:	5d                   	pop    %ebp
f0101426:	c3                   	ret    

f0101427 <vsnprintf>:
	if (b->buf < b->ebuf)
		*b->buf++ = ch;
}

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101427:	55                   	push   %ebp
f0101428:	89 e5                	mov    %esp,%ebp
f010142a:	83 ec 28             	sub    $0x28,%esp
f010142d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101430:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0101433:	85 c0                	test   %eax,%eax
f0101435:	74 04                	je     f010143b <vsnprintf+0x14>
f0101437:	85 d2                	test   %edx,%edx
f0101439:	7f 07                	jg     f0101442 <vsnprintf+0x1b>
f010143b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101440:	eb 3b                	jmp    f010147d <vsnprintf+0x56>
		*b->buf++ = ch;
}

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101442:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101445:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0101449:	89 45 f8             	mov    %eax,-0x8(%ebp)
f010144c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101453:	8b 45 14             	mov    0x14(%ebp),%eax
f0101456:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010145a:	8b 45 10             	mov    0x10(%ebp),%eax
f010145d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101461:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101464:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101468:	c7 04 24 32 10 10 f0 	movl   $0xf0101032,(%esp)
f010146f:	e8 dc fb ff ff       	call   f0101050 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101474:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101477:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010147a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f010147d:	c9                   	leave  
f010147e:	c3                   	ret    

f010147f <snprintf>:

//print number n characters
int snprintf(char *buf, int n, const char *fmt, ...)
{
f010147f:	55                   	push   %ebp
f0101480:	89 e5                	mov    %esp,%ebp
f0101482:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0101485:	8d 45 14             	lea    0x14(%ebp),%eax
f0101488:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010148c:	8b 45 10             	mov    0x10(%ebp),%eax
f010148f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101493:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101496:	89 44 24 04          	mov    %eax,0x4(%esp)
f010149a:	8b 45 08             	mov    0x8(%ebp),%eax
f010149d:	89 04 24             	mov    %eax,(%esp)
f01014a0:	e8 82 ff ff ff       	call   f0101427 <vsnprintf>
	va_end(ap);

	return rc;
}
f01014a5:	c9                   	leave  
f01014a6:	c3                   	ret    

f01014a7 <printfmt>:
		}
	}
}

void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01014a7:	55                   	push   %ebp
f01014a8:	89 e5                	mov    %esp,%ebp
f01014aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01014ad:	8d 45 14             	lea    0x14(%ebp),%eax
f01014b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014b4:	8b 45 10             	mov    0x10(%ebp),%eax
f01014b7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01014c5:	89 04 24             	mov    %eax,(%esp)
f01014c8:	e8 83 fb ff ff       	call   f0101050 <vprintfmt>
	va_end(ap);
}
f01014cd:	c9                   	leave  
f01014ce:	c3                   	ret    
	...

f01014d0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014d0:	55                   	push   %ebp
f01014d1:	89 e5                	mov    %esp,%ebp
f01014d3:	57                   	push   %edi
f01014d4:	56                   	push   %esi
f01014d5:	53                   	push   %ebx
f01014d6:	83 ec 0c             	sub    $0xc,%esp
f01014d9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014dc:	85 c0                	test   %eax,%eax
f01014de:	74 10                	je     f01014f0 <readline+0x20>
		cprintf("%s", prompt);
f01014e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014e4:	c7 04 24 7f 22 10 f0 	movl   $0xf010227f,(%esp)
f01014eb:	e8 a7 f6 ff ff       	call   f0100b97 <cprintf>

	i = 0;
	echoing = iscons(0);
f01014f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014f7:	e8 9b ed ff ff       	call   f0100297 <iscons>
f01014fc:	89 c7                	mov    %eax,%edi
f01014fe:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101503:	e8 7e ed ff ff       	call   f0100286 <getchar>
f0101508:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010150a:	85 c0                	test   %eax,%eax
f010150c:	79 1a                	jns    f0101528 <readline+0x58>
			cprintf("read error: %e\n", c);
f010150e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101512:	c7 04 24 68 24 10 f0 	movl   $0xf0102468,(%esp)
f0101519:	e8 79 f6 ff ff       	call   f0100b97 <cprintf>
f010151e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101523:	e9 99 00 00 00       	jmp    f01015c1 <readline+0xf1>
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101528:	83 f8 08             	cmp    $0x8,%eax
f010152b:	74 05                	je     f0101532 <readline+0x62>
f010152d:	83 f8 7f             	cmp    $0x7f,%eax
f0101530:	75 28                	jne    f010155a <readline+0x8a>
f0101532:	85 f6                	test   %esi,%esi
f0101534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101538:	7e 20                	jle    f010155a <readline+0x8a>
			if (echoing)
f010153a:	85 ff                	test   %edi,%edi
f010153c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101540:	74 13                	je     f0101555 <readline+0x85>
				cputchar('\b');
f0101542:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101550:	e8 49 ef ff ff       	call   f010049e <cputchar>
			i--;
f0101555:	83 ee 01             	sub    $0x1,%esi
f0101558:	eb a9                	jmp    f0101503 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010155a:	83 fb 1f             	cmp    $0x1f,%ebx
f010155d:	8d 76 00             	lea    0x0(%esi),%esi
f0101560:	7e 29                	jle    f010158b <readline+0xbb>
f0101562:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101568:	7f 21                	jg     f010158b <readline+0xbb>
			if (echoing)
f010156a:	85 ff                	test   %edi,%edi
f010156c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101570:	74 0b                	je     f010157d <readline+0xad>
				cputchar(c);
f0101572:	89 1c 24             	mov    %ebx,(%esp)
f0101575:	8d 76 00             	lea    0x0(%esi),%esi
f0101578:	e8 21 ef ff ff       	call   f010049e <cputchar>
			buf[i++] = c;
f010157d:	88 9e c0 05 11 f0    	mov    %bl,-0xfeefa40(%esi)
f0101583:	83 c6 01             	add    $0x1,%esi
f0101586:	e9 78 ff ff ff       	jmp    f0101503 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010158b:	83 fb 0a             	cmp    $0xa,%ebx
f010158e:	74 09                	je     f0101599 <readline+0xc9>
f0101590:	83 fb 0d             	cmp    $0xd,%ebx
f0101593:	0f 85 6a ff ff ff    	jne    f0101503 <readline+0x33>
			if (echoing)
f0101599:	85 ff                	test   %edi,%edi
f010159b:	90                   	nop    
f010159c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01015a0:	74 13                	je     f01015b5 <readline+0xe5>
				cputchar('\n');
f01015a2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01015a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01015b0:	e8 e9 ee ff ff       	call   f010049e <cputchar>
			buf[i] = 0;
f01015b5:	c6 86 c0 05 11 f0 00 	movb   $0x0,-0xfeefa40(%esi)
f01015bc:	b8 c0 05 11 f0       	mov    $0xf01105c0,%eax
			return buf;
		}
	}
}
f01015c1:	83 c4 0c             	add    $0xc,%esp
f01015c4:	5b                   	pop    %ebx
f01015c5:	5e                   	pop    %esi
f01015c6:	5f                   	pop    %edi
f01015c7:	5d                   	pop    %ebp
f01015c8:	c3                   	ret    
f01015c9:	00 00                	add    %al,(%eax)
f01015cb:	00 00                	add    %al,(%eax)
f01015cd:	00 00                	add    %al,(%eax)
	...

f01015d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015d0:	55                   	push   %ebp
f01015d1:	89 e5                	mov    %esp,%ebp
f01015d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01015db:	80 3a 00             	cmpb   $0x0,(%edx)
f01015de:	74 09                	je     f01015e9 <strlen+0x19>
		n++;
f01015e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01015e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015e7:	75 f7                	jne    f01015e0 <strlen+0x10>
		n++;
	return n;
}
f01015e9:	5d                   	pop    %ebp
f01015ea:	c3                   	ret    

f01015eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015eb:	55                   	push   %ebp
f01015ec:	89 e5                	mov    %esp,%ebp
f01015ee:	53                   	push   %ebx
f01015ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01015f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015f5:	85 c9                	test   %ecx,%ecx
f01015f7:	74 19                	je     f0101612 <strnlen+0x27>
f01015f9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01015fc:	74 14                	je     f0101612 <strnlen+0x27>
f01015fe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101603:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101606:	39 c8                	cmp    %ecx,%eax
f0101608:	74 0d                	je     f0101617 <strnlen+0x2c>
f010160a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010160e:	75 f3                	jne    f0101603 <strnlen+0x18>
f0101610:	eb 05                	jmp    f0101617 <strnlen+0x2c>
f0101612:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101617:	5b                   	pop    %ebx
f0101618:	5d                   	pop    %ebp
f0101619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101620:	c3                   	ret    

f0101621 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101621:	55                   	push   %ebp
f0101622:	89 e5                	mov    %esp,%ebp
f0101624:	53                   	push   %ebx
f0101625:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101628:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010162b:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101630:	0f b6 04 11          	movzbl (%ecx,%edx,1),%eax
f0101634:	88 04 13             	mov    %al,(%ebx,%edx,1)
f0101637:	83 c2 01             	add    $0x1,%edx
f010163a:	84 c0                	test   %al,%al
f010163c:	75 f2                	jne    f0101630 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010163e:	89 d8                	mov    %ebx,%eax
f0101640:	5b                   	pop    %ebx
f0101641:	5d                   	pop    %ebp
f0101642:	c3                   	ret    

f0101643 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101643:	55                   	push   %ebp
f0101644:	89 e5                	mov    %esp,%ebp
f0101646:	56                   	push   %esi
f0101647:	53                   	push   %ebx
f0101648:	8b 75 08             	mov    0x8(%ebp),%esi
f010164b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010164e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101651:	85 db                	test   %ebx,%ebx
f0101653:	74 18                	je     f010166d <strncpy+0x2a>
f0101655:	ba 00 00 00 00       	mov    $0x0,%edx
		*dst++ = *src;
f010165a:	0f b6 01             	movzbl (%ecx),%eax
f010165d:	88 04 16             	mov    %al,(%esi,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101660:	80 39 01             	cmpb   $0x1,(%ecx)
f0101663:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101666:	83 c2 01             	add    $0x1,%edx
f0101669:	39 d3                	cmp    %edx,%ebx
f010166b:	77 ed                	ja     f010165a <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010166d:	89 f0                	mov    %esi,%eax
f010166f:	5b                   	pop    %ebx
f0101670:	5e                   	pop    %esi
f0101671:	5d                   	pop    %ebp
f0101672:	c3                   	ret    

f0101673 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101673:	55                   	push   %ebp
f0101674:	89 e5                	mov    %esp,%ebp
f0101676:	56                   	push   %esi
f0101677:	53                   	push   %ebx
f0101678:	8b 75 08             	mov    0x8(%ebp),%esi
f010167b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010167e:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101681:	89 f0                	mov    %esi,%eax
f0101683:	85 d2                	test   %edx,%edx
f0101685:	74 2b                	je     f01016b2 <strlcpy+0x3f>
		while (--size > 0 && *src != '\0')
f0101687:	89 d1                	mov    %edx,%ecx
f0101689:	83 e9 01             	sub    $0x1,%ecx
f010168c:	74 1f                	je     f01016ad <strlcpy+0x3a>
f010168e:	0f b6 13             	movzbl (%ebx),%edx
f0101691:	84 d2                	test   %dl,%dl
f0101693:	74 18                	je     f01016ad <strlcpy+0x3a>
f0101695:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f0101697:	88 10                	mov    %dl,(%eax)
f0101699:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010169c:	83 e9 01             	sub    $0x1,%ecx
f010169f:	74 0e                	je     f01016af <strlcpy+0x3c>
			*dst++ = *src++;
f01016a1:	83 c3 01             	add    $0x1,%ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01016a4:	0f b6 13             	movzbl (%ebx),%edx
f01016a7:	84 d2                	test   %dl,%dl
f01016a9:	75 ec                	jne    f0101697 <strlcpy+0x24>
f01016ab:	eb 02                	jmp    f01016af <strlcpy+0x3c>
f01016ad:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01016af:	c6 00 00             	movb   $0x0,(%eax)
f01016b2:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01016b4:	5b                   	pop    %ebx
f01016b5:	5e                   	pop    %esi
f01016b6:	5d                   	pop    %ebp
f01016b7:	c3                   	ret    

f01016b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01016b8:	55                   	push   %ebp
f01016b9:	89 e5                	mov    %esp,%ebp
f01016bb:	8b 55 08             	mov    0x8(%ebp),%edx
f01016be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	while (*p && *p == *q)
f01016c1:	0f b6 02             	movzbl (%edx),%eax
f01016c4:	84 c0                	test   %al,%al
f01016c6:	74 15                	je     f01016dd <strcmp+0x25>
f01016c8:	3a 01                	cmp    (%ecx),%al
f01016ca:	75 11                	jne    f01016dd <strcmp+0x25>
		p++, q++;
f01016cc:	83 c2 01             	add    $0x1,%edx
f01016cf:	83 c1 01             	add    $0x1,%ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01016d2:	0f b6 02             	movzbl (%edx),%eax
f01016d5:	84 c0                	test   %al,%al
f01016d7:	74 04                	je     f01016dd <strcmp+0x25>
f01016d9:	3a 01                	cmp    (%ecx),%al
f01016db:	74 ef                	je     f01016cc <strcmp+0x14>
f01016dd:	0f b6 c0             	movzbl %al,%eax
f01016e0:	0f b6 11             	movzbl (%ecx),%edx
f01016e3:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01016e5:	5d                   	pop    %ebp
f01016e6:	c3                   	ret    

f01016e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016e7:	55                   	push   %ebp
f01016e8:	89 e5                	mov    %esp,%ebp
f01016ea:	53                   	push   %ebx
f01016eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016f1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01016f4:	85 d2                	test   %edx,%edx
f01016f6:	74 2f                	je     f0101727 <strncmp+0x40>
f01016f8:	0f b6 01             	movzbl (%ecx),%eax
f01016fb:	84 c0                	test   %al,%al
f01016fd:	74 1c                	je     f010171b <strncmp+0x34>
f01016ff:	3a 03                	cmp    (%ebx),%al
f0101701:	75 18                	jne    f010171b <strncmp+0x34>
f0101703:	83 ea 01             	sub    $0x1,%edx
f0101706:	66 90                	xchg   %ax,%ax
f0101708:	74 1d                	je     f0101727 <strncmp+0x40>
		n--, p++, q++;
f010170a:	83 c1 01             	add    $0x1,%ecx
f010170d:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101710:	0f b6 01             	movzbl (%ecx),%eax
f0101713:	84 c0                	test   %al,%al
f0101715:	74 04                	je     f010171b <strncmp+0x34>
f0101717:	3a 03                	cmp    (%ebx),%al
f0101719:	74 e8                	je     f0101703 <strncmp+0x1c>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010171b:	0f b6 11             	movzbl (%ecx),%edx
f010171e:	0f b6 03             	movzbl (%ebx),%eax
f0101721:	29 c2                	sub    %eax,%edx
f0101723:	89 d0                	mov    %edx,%eax
f0101725:	eb 05                	jmp    f010172c <strncmp+0x45>
f0101727:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010172c:	5b                   	pop    %ebx
f010172d:	5d                   	pop    %ebp
f010172e:	c3                   	ret    

f010172f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010172f:	55                   	push   %ebp
f0101730:	89 e5                	mov    %esp,%ebp
f0101732:	8b 45 08             	mov    0x8(%ebp),%eax
f0101735:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101739:	0f b6 10             	movzbl (%eax),%edx
f010173c:	84 d2                	test   %dl,%dl
f010173e:	74 1a                	je     f010175a <strchr+0x2b>
		if (*s == c)
f0101740:	38 ca                	cmp    %cl,%dl
f0101742:	75 06                	jne    f010174a <strchr+0x1b>
f0101744:	eb 19                	jmp    f010175f <strchr+0x30>
f0101746:	38 ca                	cmp    %cl,%dl
f0101748:	74 15                	je     f010175f <strchr+0x30>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010174a:	83 c0 01             	add    $0x1,%eax
f010174d:	0f b6 10             	movzbl (%eax),%edx
f0101750:	84 d2                	test   %dl,%dl
f0101752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101758:	75 ec                	jne    f0101746 <strchr+0x17>
f010175a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f010175f:	5d                   	pop    %ebp
f0101760:	c3                   	ret    

f0101761 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101761:	55                   	push   %ebp
f0101762:	89 e5                	mov    %esp,%ebp
f0101764:	8b 45 08             	mov    0x8(%ebp),%eax
f0101767:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010176b:	0f b6 10             	movzbl (%eax),%edx
f010176e:	84 d2                	test   %dl,%dl
f0101770:	74 20                	je     f0101792 <strfind+0x31>
		if (*s == c)
f0101772:	38 ca                	cmp    %cl,%dl
f0101774:	75 0c                	jne    f0101782 <strfind+0x21>
f0101776:	eb 1a                	jmp    f0101792 <strfind+0x31>
f0101778:	38 ca                	cmp    %cl,%dl
f010177a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101780:	74 10                	je     f0101792 <strfind+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101782:	83 c0 01             	add    $0x1,%eax
f0101785:	0f b6 10             	movzbl (%eax),%edx
f0101788:	84 d2                	test   %dl,%dl
f010178a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101790:	75 e6                	jne    f0101778 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101792:	5d                   	pop    %ebp
f0101793:	90                   	nop    
f0101794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101798:	c3                   	ret    

f0101799 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101799:	55                   	push   %ebp
f010179a:	89 e5                	mov    %esp,%ebp
f010179c:	83 ec 0c             	sub    $0xc,%esp
f010179f:	89 1c 24             	mov    %ebx,(%esp)
f01017a2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017a6:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01017aa:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017ad:	8b 75 10             	mov    0x10(%ebp),%esi
	char *p;

	if (n == 0)
f01017b0:	85 f6                	test   %esi,%esi
f01017b2:	74 3b                	je     f01017ef <memset+0x56>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01017b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01017ba:	75 2b                	jne    f01017e7 <memset+0x4e>
f01017bc:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017c2:	75 23                	jne    f01017e7 <memset+0x4e>
		c &= 0xFF;
f01017c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01017c8:	89 d3                	mov    %edx,%ebx
f01017ca:	c1 e3 08             	shl    $0x8,%ebx
f01017cd:	89 d0                	mov    %edx,%eax
f01017cf:	c1 e0 18             	shl    $0x18,%eax
f01017d2:	89 d1                	mov    %edx,%ecx
f01017d4:	c1 e1 10             	shl    $0x10,%ecx
f01017d7:	09 c8                	or     %ecx,%eax
f01017d9:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f01017db:	09 d8                	or     %ebx,%eax
f01017dd:	89 f1                	mov    %esi,%ecx
f01017df:	c1 e9 02             	shr    $0x2,%ecx
f01017e2:	fc                   	cld    
f01017e3:	f3 ab                	rep stos %eax,%es:(%edi)
f01017e5:	eb 08                	jmp    f01017ef <memset+0x56>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01017e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017ea:	89 f1                	mov    %esi,%ecx
f01017ec:	fc                   	cld    
f01017ed:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01017ef:	89 f8                	mov    %edi,%eax
f01017f1:	8b 1c 24             	mov    (%esp),%ebx
f01017f4:	8b 74 24 04          	mov    0x4(%esp),%esi
f01017f8:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01017fc:	89 ec                	mov    %ebp,%esp
f01017fe:	5d                   	pop    %ebp
f01017ff:	c3                   	ret    

f0101800 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101800:	55                   	push   %ebp
f0101801:	89 e5                	mov    %esp,%ebp
f0101803:	83 ec 0c             	sub    $0xc,%esp
f0101806:	89 1c 24             	mov    %ebx,(%esp)
f0101809:	89 74 24 04          	mov    %esi,0x4(%esp)
f010180d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101811:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101814:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0101817:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010181a:	89 df                	mov    %ebx,%edi
	if (s < d && s + n > d) {
f010181c:	39 de                	cmp    %ebx,%esi
f010181e:	73 31                	jae    f0101851 <memmove+0x51>
f0101820:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101823:	39 d3                	cmp    %edx,%ebx
f0101825:	73 2a                	jae    f0101851 <memmove+0x51>
		s += n;
		d += n;
f0101827:	8d 34 0b             	lea    (%ebx,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010182a:	89 f0                	mov    %esi,%eax
f010182c:	09 d0                	or     %edx,%eax
f010182e:	a8 03                	test   $0x3,%al
f0101830:	75 13                	jne    f0101845 <memmove+0x45>
f0101832:	f6 c1 03             	test   $0x3,%cl
f0101835:	75 0e                	jne    f0101845 <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0101837:	8d 7e fc             	lea    -0x4(%esi),%edi
f010183a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010183d:	c1 e9 02             	shr    $0x2,%ecx
f0101840:	fd                   	std    
f0101841:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101843:	eb 09                	jmp    f010184e <memmove+0x4e>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101845:	8d 7e ff             	lea    -0x1(%esi),%edi
f0101848:	8d 72 ff             	lea    -0x1(%edx),%esi
f010184b:	fd                   	std    
f010184c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010184e:	fc                   	cld    
f010184f:	eb 18                	jmp    f0101869 <memmove+0x69>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101851:	89 f0                	mov    %esi,%eax
f0101853:	09 f8                	or     %edi,%eax
f0101855:	a8 03                	test   $0x3,%al
f0101857:	75 0d                	jne    f0101866 <memmove+0x66>
f0101859:	f6 c1 03             	test   $0x3,%cl
f010185c:	75 08                	jne    f0101866 <memmove+0x66>
			asm volatile("cld; rep movsl\n"
f010185e:	c1 e9 02             	shr    $0x2,%ecx
f0101861:	fc                   	cld    
f0101862:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101864:	eb 03                	jmp    f0101869 <memmove+0x69>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101866:	fc                   	cld    
f0101867:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101869:	89 d8                	mov    %ebx,%eax
f010186b:	8b 1c 24             	mov    (%esp),%ebx
f010186e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101872:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101876:	89 ec                	mov    %ebp,%esp
f0101878:	5d                   	pop    %ebp
f0101879:	c3                   	ret    

f010187a <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f010187a:	55                   	push   %ebp
f010187b:	89 e5                	mov    %esp,%ebp
f010187d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101880:	8b 45 10             	mov    0x10(%ebp),%eax
f0101883:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101887:	8b 45 0c             	mov    0xc(%ebp),%eax
f010188a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010188e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101891:	89 04 24             	mov    %eax,(%esp)
f0101894:	e8 67 ff ff ff       	call   f0101800 <memmove>
}
f0101899:	c9                   	leave  
f010189a:	c3                   	ret    

f010189b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010189b:	55                   	push   %ebp
f010189c:	89 e5                	mov    %esp,%ebp
f010189e:	57                   	push   %edi
f010189f:	56                   	push   %esi
f01018a0:	53                   	push   %ebx
f01018a1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01018a4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01018a7:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018aa:	85 c0                	test   %eax,%eax
f01018ac:	74 38                	je     f01018e6 <memcmp+0x4b>
		if (*s1 != *s2)
f01018ae:	0f b6 17             	movzbl (%edi),%edx
f01018b1:	0f b6 1e             	movzbl (%esi),%ebx
f01018b4:	38 da                	cmp    %bl,%dl
f01018b6:	74 22                	je     f01018da <memcmp+0x3f>
f01018b8:	eb 14                	jmp    f01018ce <memcmp+0x33>
f01018ba:	0f b6 54 0f 01       	movzbl 0x1(%edi,%ecx,1),%edx
f01018bf:	0f b6 5c 0e 01       	movzbl 0x1(%esi,%ecx,1),%ebx
f01018c4:	83 c1 01             	add    $0x1,%ecx
f01018c7:	83 e8 01             	sub    $0x1,%eax
f01018ca:	38 da                	cmp    %bl,%dl
f01018cc:	74 14                	je     f01018e2 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f01018ce:	0f b6 d2             	movzbl %dl,%edx
f01018d1:	0f b6 c3             	movzbl %bl,%eax
f01018d4:	29 c2                	sub    %eax,%edx
f01018d6:	89 d0                	mov    %edx,%eax
f01018d8:	eb 11                	jmp    f01018eb <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018da:	83 e8 01             	sub    $0x1,%eax
f01018dd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01018e2:	85 c0                	test   %eax,%eax
f01018e4:	75 d4                	jne    f01018ba <memcmp+0x1f>
f01018e6:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f01018eb:	5b                   	pop    %ebx
f01018ec:	5e                   	pop    %esi
f01018ed:	5f                   	pop    %edi
f01018ee:	5d                   	pop    %ebp
f01018ef:	c3                   	ret    

f01018f0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01018f0:	55                   	push   %ebp
f01018f1:	89 e5                	mov    %esp,%ebp
f01018f3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01018f6:	89 c1                	mov    %eax,%ecx
f01018f8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
f01018fb:	39 c8                	cmp    %ecx,%eax
f01018fd:	73 1b                	jae    f010191a <memfind+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
f01018ff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
f0101903:	38 10                	cmp    %dl,(%eax)
f0101905:	75 0b                	jne    f0101912 <memfind+0x22>
f0101907:	eb 11                	jmp    f010191a <memfind+0x2a>
f0101909:	38 10                	cmp    %dl,(%eax)
f010190b:	90                   	nop    
f010190c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101910:	74 08                	je     f010191a <memfind+0x2a>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101912:	83 c0 01             	add    $0x1,%eax
f0101915:	39 c1                	cmp    %eax,%ecx
f0101917:	90                   	nop    
f0101918:	77 ef                	ja     f0101909 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010191a:	5d                   	pop    %ebp
f010191b:	90                   	nop    
f010191c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101920:	c3                   	ret    

f0101921 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101921:	55                   	push   %ebp
f0101922:	89 e5                	mov    %esp,%ebp
f0101924:	57                   	push   %edi
f0101925:	56                   	push   %esi
f0101926:	53                   	push   %ebx
f0101927:	83 ec 04             	sub    $0x4,%esp
f010192a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010192d:	8b 7d 10             	mov    0x10(%ebp),%edi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101930:	0f b6 01             	movzbl (%ecx),%eax
f0101933:	3c 20                	cmp    $0x20,%al
f0101935:	74 04                	je     f010193b <strtol+0x1a>
f0101937:	3c 09                	cmp    $0x9,%al
f0101939:	75 0e                	jne    f0101949 <strtol+0x28>
		s++;
f010193b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010193e:	0f b6 01             	movzbl (%ecx),%eax
f0101941:	3c 20                	cmp    $0x20,%al
f0101943:	74 f6                	je     f010193b <strtol+0x1a>
f0101945:	3c 09                	cmp    $0x9,%al
f0101947:	74 f2                	je     f010193b <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101949:	3c 2b                	cmp    $0x2b,%al
f010194b:	75 0d                	jne    f010195a <strtol+0x39>
		s++;
f010194d:	83 c1 01             	add    $0x1,%ecx
f0101950:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101957:	90                   	nop    
f0101958:	eb 15                	jmp    f010196f <strtol+0x4e>
	else if (*s == '-')
f010195a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101961:	3c 2d                	cmp    $0x2d,%al
f0101963:	75 0a                	jne    f010196f <strtol+0x4e>
		s++, neg = 1;
f0101965:	83 c1 01             	add    $0x1,%ecx
f0101968:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010196f:	85 ff                	test   %edi,%edi
f0101971:	0f 94 c0             	sete   %al
f0101974:	74 05                	je     f010197b <strtol+0x5a>
f0101976:	83 ff 10             	cmp    $0x10,%edi
f0101979:	75 1f                	jne    f010199a <strtol+0x79>
f010197b:	80 39 30             	cmpb   $0x30,(%ecx)
f010197e:	75 1a                	jne    f010199a <strtol+0x79>
f0101980:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101988:	75 10                	jne    f010199a <strtol+0x79>
		s += 2, base = 16;
f010198a:	83 c1 02             	add    $0x2,%ecx
f010198d:	bf 10 00 00 00       	mov    $0x10,%edi
f0101992:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101998:	eb 2d                	jmp    f01019c7 <strtol+0xa6>
	else if (base == 0 && s[0] == '0')
f010199a:	85 ff                	test   %edi,%edi
f010199c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019a0:	75 18                	jne    f01019ba <strtol+0x99>
f01019a2:	80 39 30             	cmpb   $0x30,(%ecx)
f01019a5:	8d 76 00             	lea    0x0(%esi),%esi
f01019a8:	75 18                	jne    f01019c2 <strtol+0xa1>
		s++, base = 8;
f01019aa:	83 c1 01             	add    $0x1,%ecx
f01019ad:	66 bf 08 00          	mov    $0x8,%di
f01019b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01019b8:	eb 0d                	jmp    f01019c7 <strtol+0xa6>
	else if (base == 0)
f01019ba:	84 c0                	test   %al,%al
f01019bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019c0:	74 05                	je     f01019c7 <strtol+0xa6>
f01019c2:	bf 0a 00 00 00       	mov    $0xa,%edi
f01019c7:	be 00 00 00 00       	mov    $0x0,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01019cc:	0f b6 11             	movzbl (%ecx),%edx
f01019cf:	89 d3                	mov    %edx,%ebx
f01019d1:	8d 42 d0             	lea    -0x30(%edx),%eax
f01019d4:	3c 09                	cmp    $0x9,%al
f01019d6:	77 08                	ja     f01019e0 <strtol+0xbf>
			dig = *s - '0';
f01019d8:	0f be c2             	movsbl %dl,%eax
f01019db:	8d 50 d0             	lea    -0x30(%eax),%edx
f01019de:	eb 1c                	jmp    f01019fc <strtol+0xdb>
		else if (*s >= 'a' && *s <= 'z')
f01019e0:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01019e3:	3c 19                	cmp    $0x19,%al
f01019e5:	77 08                	ja     f01019ef <strtol+0xce>
			dig = *s - 'a' + 10;
f01019e7:	0f be c2             	movsbl %dl,%eax
f01019ea:	8d 50 a9             	lea    -0x57(%eax),%edx
f01019ed:	eb 0d                	jmp    f01019fc <strtol+0xdb>
		else if (*s >= 'A' && *s <= 'Z')
f01019ef:	8d 43 bf             	lea    -0x41(%ebx),%eax
f01019f2:	3c 19                	cmp    $0x19,%al
f01019f4:	77 17                	ja     f0101a0d <strtol+0xec>
			dig = *s - 'A' + 10;
f01019f6:	0f be c2             	movsbl %dl,%eax
f01019f9:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
f01019fc:	39 fa                	cmp    %edi,%edx
f01019fe:	7d 0d                	jge    f0101a0d <strtol+0xec>
			break;
		s++, val = (val * base) + dig;
f0101a00:	83 c1 01             	add    $0x1,%ecx
f0101a03:	89 f0                	mov    %esi,%eax
f0101a05:	0f af c7             	imul   %edi,%eax
f0101a08:	8d 34 02             	lea    (%edx,%eax,1),%esi
f0101a0b:	eb bf                	jmp    f01019cc <strtol+0xab>
		// we don't properly detect overflow!
	}
f0101a0d:	89 f0                	mov    %esi,%eax

	if (endptr)
f0101a0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101a13:	74 05                	je     f0101a1a <strtol+0xf9>
		*endptr = (char *) s;
f0101a15:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a18:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
f0101a1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0101a1e:	74 04                	je     f0101a24 <strtol+0x103>
f0101a20:	89 c6                	mov    %eax,%esi
f0101a22:	f7 de                	neg    %esi
}
f0101a24:	89 f0                	mov    %esi,%eax
f0101a26:	83 c4 04             	add    $0x4,%esp
f0101a29:	5b                   	pop    %ebx
f0101a2a:	5e                   	pop    %esi
f0101a2b:	5f                   	pop    %edi
f0101a2c:	5d                   	pop    %ebp
f0101a2d:	c3                   	ret    
	...

f0101a30 <__udivdi3>:
f0101a30:	55                   	push   %ebp
f0101a31:	89 e5                	mov    %esp,%ebp
f0101a33:	57                   	push   %edi
f0101a34:	56                   	push   %esi
f0101a35:	83 ec 1c             	sub    $0x1c,%esp
f0101a38:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a3b:	8b 55 08             	mov    0x8(%ebp),%edx
f0101a3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101a41:	89 c6                	mov    %eax,%esi
f0101a43:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a46:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101a49:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101a4c:	85 c0                	test   %eax,%eax
f0101a4e:	75 38                	jne    f0101a88 <__udivdi3+0x58>
f0101a50:	39 ce                	cmp    %ecx,%esi
f0101a52:	77 4c                	ja     f0101aa0 <__udivdi3+0x70>
f0101a54:	85 f6                	test   %esi,%esi
f0101a56:	75 0d                	jne    f0101a65 <__udivdi3+0x35>
f0101a58:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101a5d:	31 d2                	xor    %edx,%edx
f0101a5f:	89 c8                	mov    %ecx,%eax
f0101a61:	f7 f6                	div    %esi
f0101a63:	89 c6                	mov    %eax,%esi
f0101a65:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101a68:	31 d2                	xor    %edx,%edx
f0101a6a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101a6d:	89 f8                	mov    %edi,%eax
f0101a6f:	f7 f6                	div    %esi
f0101a71:	89 c7                	mov    %eax,%edi
f0101a73:	89 c8                	mov    %ecx,%eax
f0101a75:	f7 f6                	div    %esi
f0101a77:	89 fe                	mov    %edi,%esi
f0101a79:	89 c1                	mov    %eax,%ecx
f0101a7b:	89 c8                	mov    %ecx,%eax
f0101a7d:	89 f2                	mov    %esi,%edx
f0101a7f:	83 c4 1c             	add    $0x1c,%esp
f0101a82:	5e                   	pop    %esi
f0101a83:	5f                   	pop    %edi
f0101a84:	5d                   	pop    %ebp
f0101a85:	c3                   	ret    
f0101a86:	66 90                	xchg   %ax,%ax
f0101a88:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0101a8b:	76 2b                	jbe    f0101ab8 <__udivdi3+0x88>
f0101a8d:	31 c9                	xor    %ecx,%ecx
f0101a8f:	31 f6                	xor    %esi,%esi
f0101a91:	89 c8                	mov    %ecx,%eax
f0101a93:	89 f2                	mov    %esi,%edx
f0101a95:	83 c4 1c             	add    $0x1c,%esp
f0101a98:	5e                   	pop    %esi
f0101a99:	5f                   	pop    %edi
f0101a9a:	5d                   	pop    %ebp
f0101a9b:	c3                   	ret    
f0101a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101aa0:	89 d1                	mov    %edx,%ecx
f0101aa2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101aa5:	89 c8                	mov    %ecx,%eax
f0101aa7:	f7 f6                	div    %esi
f0101aa9:	31 f6                	xor    %esi,%esi
f0101aab:	89 c1                	mov    %eax,%ecx
f0101aad:	89 c8                	mov    %ecx,%eax
f0101aaf:	89 f2                	mov    %esi,%edx
f0101ab1:	83 c4 1c             	add    $0x1c,%esp
f0101ab4:	5e                   	pop    %esi
f0101ab5:	5f                   	pop    %edi
f0101ab6:	5d                   	pop    %ebp
f0101ab7:	c3                   	ret    
f0101ab8:	0f bd f8             	bsr    %eax,%edi
f0101abb:	83 f7 1f             	xor    $0x1f,%edi
f0101abe:	75 20                	jne    f0101ae0 <__udivdi3+0xb0>
f0101ac0:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0101ac3:	72 05                	jb     f0101aca <__udivdi3+0x9a>
f0101ac5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101ac8:	77 c3                	ja     f0101a8d <__udivdi3+0x5d>
f0101aca:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101acf:	31 f6                	xor    %esi,%esi
f0101ad1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101ad8:	eb b7                	jmp    f0101a91 <__udivdi3+0x61>
f0101ada:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101ae0:	89 f9                	mov    %edi,%ecx
f0101ae2:	89 f2                	mov    %esi,%edx
f0101ae4:	d3 e0                	shl    %cl,%eax
f0101ae6:	b9 20 00 00 00       	mov    $0x20,%ecx
f0101aeb:	29 f9                	sub    %edi,%ecx
f0101aed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101af0:	d3 ea                	shr    %cl,%edx
f0101af2:	89 f9                	mov    %edi,%ecx
f0101af4:	d3 e6                	shl    %cl,%esi
f0101af6:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101afa:	09 d0                	or     %edx,%eax
f0101afc:	89 75 f4             	mov    %esi,-0xc(%ebp)
f0101aff:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101b02:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101b05:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101b08:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101b0b:	d3 ee                	shr    %cl,%esi
f0101b0d:	89 f9                	mov    %edi,%ecx
f0101b0f:	d3 e2                	shl    %cl,%edx
f0101b11:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101b15:	d3 e8                	shr    %cl,%eax
f0101b17:	09 d0                	or     %edx,%eax
f0101b19:	89 f2                	mov    %esi,%edx
f0101b1b:	f7 75 f0             	divl   -0x10(%ebp)
f0101b1e:	89 d6                	mov    %edx,%esi
f0101b20:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b26:	f7 65 e0             	mull   -0x20(%ebp)
f0101b29:	39 d6                	cmp    %edx,%esi
f0101b2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101b2e:	72 20                	jb     f0101b50 <__udivdi3+0x120>
f0101b30:	74 0e                	je     f0101b40 <__udivdi3+0x110>
f0101b32:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101b35:	31 f6                	xor    %esi,%esi
f0101b37:	e9 55 ff ff ff       	jmp    f0101a91 <__udivdi3+0x61>
f0101b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101b43:	89 f9                	mov    %edi,%ecx
f0101b45:	d3 e0                	shl    %cl,%eax
f0101b47:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101b4a:	73 e6                	jae    f0101b32 <__udivdi3+0x102>
f0101b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b50:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101b53:	31 f6                	xor    %esi,%esi
f0101b55:	83 e9 01             	sub    $0x1,%ecx
f0101b58:	e9 34 ff ff ff       	jmp    f0101a91 <__udivdi3+0x61>
f0101b5d:	00 00                	add    %al,(%eax)
	...

f0101b60 <__umoddi3>:
f0101b60:	55                   	push   %ebp
f0101b61:	89 e5                	mov    %esp,%ebp
f0101b63:	57                   	push   %edi
f0101b64:	56                   	push   %esi
f0101b65:	83 ec 20             	sub    $0x20,%esp
f0101b68:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101b6e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b71:	89 c7                	mov    %eax,%edi
f0101b73:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b76:	89 4d e8             	mov    %ecx,-0x18(%ebp)
f0101b79:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0101b7c:	85 c0                	test   %eax,%eax
f0101b7e:	75 18                	jne    f0101b98 <__umoddi3+0x38>
f0101b80:	39 f7                	cmp    %esi,%edi
f0101b82:	76 24                	jbe    f0101ba8 <__umoddi3+0x48>
f0101b84:	89 c8                	mov    %ecx,%eax
f0101b86:	89 f2                	mov    %esi,%edx
f0101b88:	f7 f7                	div    %edi
f0101b8a:	89 d0                	mov    %edx,%eax
f0101b8c:	31 d2                	xor    %edx,%edx
f0101b8e:	83 c4 20             	add    $0x20,%esp
f0101b91:	5e                   	pop    %esi
f0101b92:	5f                   	pop    %edi
f0101b93:	5d                   	pop    %ebp
f0101b94:	c3                   	ret    
f0101b95:	8d 76 00             	lea    0x0(%esi),%esi
f0101b98:	39 f0                	cmp    %esi,%eax
f0101b9a:	76 2c                	jbe    f0101bc8 <__umoddi3+0x68>
f0101b9c:	89 c8                	mov    %ecx,%eax
f0101b9e:	89 f2                	mov    %esi,%edx
f0101ba0:	83 c4 20             	add    $0x20,%esp
f0101ba3:	5e                   	pop    %esi
f0101ba4:	5f                   	pop    %edi
f0101ba5:	5d                   	pop    %ebp
f0101ba6:	c3                   	ret    
f0101ba7:	90                   	nop    
f0101ba8:	85 ff                	test   %edi,%edi
f0101baa:	75 0b                	jne    f0101bb7 <__umoddi3+0x57>
f0101bac:	b8 01 00 00 00       	mov    $0x1,%eax
f0101bb1:	31 d2                	xor    %edx,%edx
f0101bb3:	f7 f7                	div    %edi
f0101bb5:	89 c7                	mov    %eax,%edi
f0101bb7:	89 f0                	mov    %esi,%eax
f0101bb9:	31 d2                	xor    %edx,%edx
f0101bbb:	f7 f7                	div    %edi
f0101bbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101bc0:	f7 f7                	div    %edi
f0101bc2:	eb c6                	jmp    f0101b8a <__umoddi3+0x2a>
f0101bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101bc8:	0f bd d0             	bsr    %eax,%edx
f0101bcb:	83 f2 1f             	xor    $0x1f,%edx
f0101bce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101bd1:	75 1d                	jne    f0101bf0 <__umoddi3+0x90>
f0101bd3:	39 f0                	cmp    %esi,%eax
f0101bd5:	0f 83 b5 00 00 00    	jae    f0101c90 <__umoddi3+0x130>
f0101bdb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101bde:	29 f9                	sub    %edi,%ecx
f0101be0:	19 c6                	sbb    %eax,%esi
f0101be2:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0101be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101be8:	89 f2                	mov    %esi,%edx
f0101bea:	eb b4                	jmp    f0101ba0 <__umoddi3+0x40>
f0101bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101bf0:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101bf4:	89 c2                	mov    %eax,%edx
f0101bf6:	b8 20 00 00 00       	mov    $0x20,%eax
f0101bfb:	2b 45 e4             	sub    -0x1c(%ebp),%eax
f0101bfe:	d3 e2                	shl    %cl,%edx
f0101c00:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101c03:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101c07:	89 f8                	mov    %edi,%eax
f0101c09:	d3 e8                	shr    %cl,%eax
f0101c0b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101c0f:	09 d0                	or     %edx,%eax
f0101c11:	89 f2                	mov    %esi,%edx
f0101c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101c16:	89 f0                	mov    %esi,%eax
f0101c18:	d3 e7                	shl    %cl,%edi
f0101c1a:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101c1e:	89 7d f4             	mov    %edi,-0xc(%ebp)
f0101c21:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0101c24:	d3 e8                	shr    %cl,%eax
f0101c26:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101c2a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101c2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101c30:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101c33:	d3 e2                	shl    %cl,%edx
f0101c35:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101c39:	d3 e8                	shr    %cl,%eax
f0101c3b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101c3f:	09 d0                	or     %edx,%eax
f0101c41:	89 f2                	mov    %esi,%edx
f0101c43:	f7 75 f0             	divl   -0x10(%ebp)
f0101c46:	89 d6                	mov    %edx,%esi
f0101c48:	d3 e7                	shl    %cl,%edi
f0101c4a:	f7 65 f4             	mull   -0xc(%ebp)
f0101c4d:	39 d6                	cmp    %edx,%esi
f0101c4f:	73 2f                	jae    f0101c80 <__umoddi3+0x120>
f0101c51:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0101c54:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0101c57:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101c5b:	29 c7                	sub    %eax,%edi
f0101c5d:	19 d6                	sbb    %edx,%esi
f0101c5f:	89 fa                	mov    %edi,%edx
f0101c61:	89 f0                	mov    %esi,%eax
f0101c63:	d3 ea                	shr    %cl,%edx
f0101c65:	0f b6 4d e0          	movzbl -0x20(%ebp),%ecx
f0101c69:	d3 e0                	shl    %cl,%eax
f0101c6b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
f0101c6f:	09 d0                	or     %edx,%eax
f0101c71:	89 f2                	mov    %esi,%edx
f0101c73:	d3 ea                	shr    %cl,%edx
f0101c75:	e9 26 ff ff ff       	jmp    f0101ba0 <__umoddi3+0x40>
f0101c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101c80:	75 d5                	jne    f0101c57 <__umoddi3+0xf7>
f0101c82:	39 c7                	cmp    %eax,%edi
f0101c84:	73 d1                	jae    f0101c57 <__umoddi3+0xf7>
f0101c86:	66 90                	xchg   %ax,%ax
f0101c88:	eb c7                	jmp    f0101c51 <__umoddi3+0xf1>
f0101c8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101c90:	3b 7d ec             	cmp    -0x14(%ebp),%edi
f0101c93:	90                   	nop    
f0101c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c98:	0f 87 47 ff ff ff    	ja     f0101be5 <__umoddi3+0x85>
f0101c9e:	66 90                	xchg   %ax,%ax
f0101ca0:	e9 36 ff ff ff       	jmp    f0101bdb <__umoddi3+0x7b>
