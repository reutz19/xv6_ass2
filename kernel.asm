
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 24 37 10 80       	mov    $0x80103724,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 50 8a 10 	movl   $0x80108a50,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100049:	e8 70 53 00 00       	call   801053be <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 15 11 80       	mov    0x80111594,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801000bd:	e8 1d 53 00 00       	call   801053df <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 15 11 80       	mov    0x80111594,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100104:	e8 38 53 00 00       	call   80105441 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 d6 10 	movl   $0x8010d680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 38 4b 00 00       	call   80104c5c <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 15 11 80       	mov    0x80111590,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010017c:	e8 c0 52 00 00       	call   80105441 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 57 8a 10 80 	movl   $0x80108a57,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 d6 25 00 00       	call   801027ae <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 68 8a 10 80 	movl   $0x80108a68,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 99 25 00 00       	call   801027ae <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 6f 8a 10 80 	movl   $0x80108a6f,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010023c:	e8 9e 51 00 00       	call   801053df <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 15 11 80       	mov    0x80111594,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 95 4a 00 00       	call   80104d37 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801002a9:	e8 93 51 00 00       	call   80105441 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 c1 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801003bb:	e8 1f 50 00 00       	call   801053df <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 76 8a 10 80 	movl   $0x80108a76,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 5a 03 00 00       	call   80100750 <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 7f 8a 10 80 	movl   $0x80108a7f,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 84 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100533:	e8 09 4f 00 00       	call   80105441 <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 86 8a 10 80 	movl   $0x80108a86,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 95 8a 10 80 	movl   $0x80108a95,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 fc 4e 00 00       	call   80105490 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 97 8a 10 80 	movl   $0x80108a97,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x11c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 4b 50 00 00       	call   80105702 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006c6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 c8                	add    %ecx,%eax
801006d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 04 24             	mov    %eax,(%esp)
801006e1:	e8 4d 4f 00 00       	call   80105633 <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 d3 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 ba fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 a6 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 90 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 87 fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 16 69 00 00       	call   80107091 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 0a 69 00 00       	call   80107091 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 fe 68 00 00       	call   80107091 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 f1 68 00 00       	call   80107091 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 1f fe ff ff       	call   801005ca <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801007ba:	e8 20 4c 00 00       	call   801053df <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 37 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 64                	je     8010083a <consoleintr+0x8d>
801007d6:	e9 91 00 00 00       	jmp    8010086c <consoleintr+0xbf>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 55                	je     8010083a <consoleintr+0x8d>
801007e5:	e9 82 00 00 00       	jmp    8010086c <consoleintr+0xbf>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 1f 46 00 00       	call   80104e0e <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100816:	a1 58 18 11 80       	mov    0x80111858,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	3c 0a                	cmp    $0xa,%al
80100833:	75 bf                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100835:	e9 c1 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083a:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100840:	a1 58 18 11 80       	mov    0x80111858,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100856:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010085d:	e8 ee fe ff ff       	call   80100750 <consputc>
      }
      break;
80100862:	e9 94 00 00 00       	jmp    801008fb <consoleintr+0x14e>
80100867:	e9 8f 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100870:	0f 84 84 00 00 00    	je     801008fa <consoleintr+0x14d>
80100876:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
8010087c:	a1 54 18 11 80       	mov    0x80111854,%eax
80100881:	29 c2                	sub    %eax,%edx
80100883:	89 d0                	mov    %edx,%eax
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	77 70                	ja     801008fa <consoleintr+0x14d>
        c = (c == '\r') ? '\n' : c;
8010088a:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010088e:	74 05                	je     80100895 <consoleintr+0xe8>
80100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100893:	eb 05                	jmp    8010089a <consoleintr+0xed>
80100895:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010089d:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 5c 18 11 80    	mov    %edx,0x8011185c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 d4 17 11 80    	mov    %al,-0x7feee82c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008d5:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008e7:	a3 58 18 11 80       	mov    %eax,0x80111858
          wakeup(&input.r);
801008ec:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
801008f3:	e8 3f 44 00 00       	call   80104d37 <wakeup>
        }
      }
      break;
801008f8:	eb 00                	jmp    801008fa <consoleintr+0x14d>
801008fa:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
801008fb:	8b 45 08             	mov    0x8(%ebp),%eax
801008fe:	ff d0                	call   *%eax
80100900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100907:	0f 89 b7 fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010090d:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100914:	e8 28 4b 00 00       	call   80105441 <release>
}
80100919:	c9                   	leave  
8010091a:	c3                   	ret    

8010091b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010091b:	55                   	push   %ebp
8010091c:	89 e5                	mov    %esp,%ebp
8010091e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100921:	8b 45 08             	mov    0x8(%ebp),%eax
80100924:	89 04 24             	mov    %eax,(%esp)
80100927:	e8 8a 10 00 00       	call   801019b6 <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100939:	e8 a1 4a 00 00       	call   801053df <acquire>
  while(n > 0){
8010093e:	e9 aa 00 00 00       	jmp    801009ed <consoleread+0xd2>
    while(input.r == input.w){
80100943:	eb 42                	jmp    80100987 <consoleread+0x6c>
      if(proc->killed){
80100945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010094b:	8b 40 24             	mov    0x24(%eax),%eax
8010094e:	85 c0                	test   %eax,%eax
80100950:	74 21                	je     80100973 <consoleread+0x58>
        release(&input.lock);
80100952:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100959:	e8 e3 4a 00 00       	call   80105441 <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 ff 0e 00 00       	call   80101868 <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 a0 17 11 	movl   $0x801117a0,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
80100982:	e8 d5 42 00 00       	call   80104c5c <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 54 18 11 80    	mov    0x80111854,%edx
8010098d:	a1 58 18 11 80       	mov    0x80111858,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 54 18 11 80       	mov    0x80111854,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 54 18 11 80    	mov    %edx,0x80111854
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
801009ae:	0f be c0             	movsbl %al,%eax
801009b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009b4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009b8:	75 19                	jne    801009d3 <consoleread+0xb8>
      if(n < target){
801009ba:	8b 45 10             	mov    0x10(%ebp),%eax
801009bd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009c0:	73 0f                	jae    801009d1 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009c2:	a1 54 18 11 80       	mov    0x80111854,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 54 18 11 80       	mov    %eax,0x80111854
      }
      break;
801009cf:	eb 26                	jmp    801009f7 <consoleread+0xdc>
801009d1:	eb 24                	jmp    801009f7 <consoleread+0xdc>
    }
    *dst++ = c;
801009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801009d6:	8d 50 01             	lea    0x1(%eax),%edx
801009d9:	89 55 0c             	mov    %edx,0xc(%ebp)
801009dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009df:	88 10                	mov    %dl,(%eax)
    --n;
801009e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009e5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009e9:	75 02                	jne    801009ed <consoleread+0xd2>
      break;
801009eb:	eb 0a                	jmp    801009f7 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f1:	0f 8f 4c ff ff ff    	jg     80100943 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
801009f7:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801009fe:	e8 3e 4a 00 00       	call   80105441 <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 5a 0e 00 00       	call   80101868 <ilock>

  return target - n;
80100a0e:	8b 45 10             	mov    0x10(%ebp),%eax
80100a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a14:	29 c2                	sub    %eax,%edx
80100a16:	89 d0                	mov    %edx,%eax
}
80100a18:	c9                   	leave  
80100a19:	c3                   	ret    

80100a1a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a1a:	55                   	push   %ebp
80100a1b:	89 e5                	mov    %esp,%ebp
80100a1d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	89 04 24             	mov    %eax,(%esp)
80100a26:	e8 8b 0f 00 00       	call   801019b6 <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a32:	e8 a8 49 00 00       	call   801053df <acquire>
  for(i = 0; i < n; i++)
80100a37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a3e:	eb 1d                	jmp    80100a5d <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a46:	01 d0                	add    %edx,%eax
80100a48:	0f b6 00             	movzbl (%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	0f b6 c0             	movzbl %al,%eax
80100a51:	89 04 24             	mov    %eax,(%esp)
80100a54:	e8 f7 fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a60:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a63:	7c db                	jl     80100a40 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a65:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a6c:	e8 d0 49 00 00       	call   80105441 <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 ec 0d 00 00       	call   80101868 <ilock>

  return n;
80100a7c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a7f:	c9                   	leave  
80100a80:	c3                   	ret    

80100a81 <consoleinit>:

void
consoleinit(void)
{
80100a81:	55                   	push   %ebp
80100a82:	89 e5                	mov    %esp,%ebp
80100a84:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a87:	c7 44 24 04 9b 8a 10 	movl   $0x80108a9b,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a96:	e8 23 49 00 00       	call   801053be <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 a3 8a 10 	movl   $0x80108aa3,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100aaa:	e8 0f 49 00 00       	call   801053be <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 0c 22 11 80 1a 	movl   $0x80100a1a,0x8011220c
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 08 22 11 80 1b 	movl   $0x8010091b,0x80112208
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100aca:	00 00 00 

  picenable(IRQ_KBD);
80100acd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ad4:	e8 e8 32 00 00       	call   80103dc1 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 7d 1e 00 00       	call   8010296a <ioapicenable>
}
80100aed:	c9                   	leave  
80100aee:	c3                   	ret    

80100aef <exec>:
#include "defs.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100aef:	55                   	push   %ebp
80100af0:	89 e5                	mov    %esp,%ebp
80100af2:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100af8:	e8 20 29 00 00       	call   8010341d <begin_op>
  if((ip = namei(path)) == 0){
80100afd:	8b 45 08             	mov    0x8(%ebp),%eax
80100b00:	89 04 24             	mov    %eax,(%esp)
80100b03:	e8 0b 19 00 00       	call   80102413 <namei>
80100b08:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b0b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b0f:	75 0f                	jne    80100b20 <exec+0x31>
    end_op();
80100b11:	e8 8b 29 00 00       	call   801034a1 <end_op>
    return -1;
80100b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1b:	e9 f5 03 00 00       	jmp    80100f15 <exec+0x426>
  }
  ilock(ip);
80100b20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b23:	89 04 24             	mov    %eax,(%esp)
80100b26:	e8 3d 0d 00 00       	call   80101868 <ilock>
  pgdir = 0;
80100b2b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b32:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b39:	00 
80100b3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b41:	00 
80100b42:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b4c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b4f:	89 04 24             	mov    %eax,(%esp)
80100b52:	e8 1e 12 00 00       	call   80101d75 <readi>
80100b57:	83 f8 33             	cmp    $0x33,%eax
80100b5a:	77 05                	ja     80100b61 <exec+0x72>
    goto bad;
80100b5c:	e9 88 03 00 00       	jmp    80100ee9 <exec+0x3fa>
  if(elf.magic != ELF_MAGIC)
80100b61:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b67:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b6c:	74 05                	je     80100b73 <exec+0x84>
    goto bad;
80100b6e:	e9 76 03 00 00       	jmp    80100ee9 <exec+0x3fa>

  if((pgdir = setupkvm()) == 0)
80100b73:	e8 6a 76 00 00       	call   801081e2 <setupkvm>
80100b78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b7b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b7f:	75 05                	jne    80100b86 <exec+0x97>
    goto bad;
80100b81:	e9 63 03 00 00       	jmp    80100ee9 <exec+0x3fa>

  // Load program into memory.
  sz = 0;
80100b86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b8d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b94:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100b9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b9d:	e9 cb 00 00 00       	jmp    80100c6d <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ba2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ba5:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bac:	00 
80100bad:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bb1:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bbb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bbe:	89 04 24             	mov    %eax,(%esp)
80100bc1:	e8 af 11 00 00       	call   80101d75 <readi>
80100bc6:	83 f8 20             	cmp    $0x20,%eax
80100bc9:	74 05                	je     80100bd0 <exec+0xe1>
      goto bad;
80100bcb:	e9 19 03 00 00       	jmp    80100ee9 <exec+0x3fa>
    if(ph.type != ELF_PROG_LOAD)
80100bd0:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bd6:	83 f8 01             	cmp    $0x1,%eax
80100bd9:	74 05                	je     80100be0 <exec+0xf1>
      continue;
80100bdb:	e9 80 00 00 00       	jmp    80100c60 <exec+0x171>
    if(ph.memsz < ph.filesz)
80100be0:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100be6:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bec:	39 c2                	cmp    %eax,%edx
80100bee:	73 05                	jae    80100bf5 <exec+0x106>
      goto bad;
80100bf0:	e9 f4 02 00 00       	jmp    80100ee9 <exec+0x3fa>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf5:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfb:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c01:	01 d0                	add    %edx,%eax
80100c03:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c11:	89 04 24             	mov    %eax,(%esp)
80100c14:	e8 97 79 00 00       	call   801085b0 <allocuvm>
80100c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c20:	75 05                	jne    80100c27 <exec+0x138>
      goto bad;
80100c22:	e9 c2 02 00 00       	jmp    80100ee9 <exec+0x3fa>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c27:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c2d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c33:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c39:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c41:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c44:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c48:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c4f:	89 04 24             	mov    %eax,(%esp)
80100c52:	e8 6e 78 00 00       	call   801084c5 <loaduvm>
80100c57:	85 c0                	test   %eax,%eax
80100c59:	79 05                	jns    80100c60 <exec+0x171>
      goto bad;
80100c5b:	e9 89 02 00 00       	jmp    80100ee9 <exec+0x3fa>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c60:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c67:	83 c0 20             	add    $0x20,%eax
80100c6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c6d:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c74:	0f b7 c0             	movzwl %ax,%eax
80100c77:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c7a:	0f 8f 22 ff ff ff    	jg     80100ba2 <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c80:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c83:	89 04 24             	mov    %eax,(%esp)
80100c86:	e8 61 0e 00 00       	call   80101aec <iunlockput>
  end_op();
80100c8b:	e8 11 28 00 00       	call   801034a1 <end_op>
  ip = 0;
80100c90:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9a:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100caa:	05 00 20 00 00       	add    $0x2000,%eax
80100caf:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cbd:	89 04 24             	mov    %eax,(%esp)
80100cc0:	e8 eb 78 00 00       	call   801085b0 <allocuvm>
80100cc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ccc:	75 05                	jne    80100cd3 <exec+0x1e4>
    goto bad;
80100cce:	e9 16 02 00 00       	jmp    80100ee9 <exec+0x3fa>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce2:	89 04 24             	mov    %eax,(%esp)
80100ce5:	e8 f6 7a 00 00       	call   801087e0 <clearpteu>
  sp = sz;
80100cea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ced:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100cf0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cf7:	e9 9a 00 00 00       	jmp    80100d96 <exec+0x2a7>
    if(argc >= MAXARG)
80100cfc:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d00:	76 05                	jbe    80100d07 <exec+0x218>
      goto bad;
80100d02:	e9 e2 01 00 00       	jmp    80100ee9 <exec+0x3fa>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d14:	01 d0                	add    %edx,%eax
80100d16:	8b 00                	mov    (%eax),%eax
80100d18:	89 04 24             	mov    %eax,(%esp)
80100d1b:	e8 7d 4b 00 00       	call   8010589d <strlen>
80100d20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d23:	29 c2                	sub    %eax,%edx
80100d25:	89 d0                	mov    %edx,%eax
80100d27:	83 e8 01             	sub    $0x1,%eax
80100d2a:	83 e0 fc             	and    $0xfffffffc,%eax
80100d2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d3d:	01 d0                	add    %edx,%eax
80100d3f:	8b 00                	mov    (%eax),%eax
80100d41:	89 04 24             	mov    %eax,(%esp)
80100d44:	e8 54 4b 00 00       	call   8010589d <strlen>
80100d49:	83 c0 01             	add    $0x1,%eax
80100d4c:	89 c2                	mov    %eax,%edx
80100d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d51:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d58:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d5b:	01 c8                	add    %ecx,%eax
80100d5d:	8b 00                	mov    (%eax),%eax
80100d5f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d63:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d71:	89 04 24             	mov    %eax,(%esp)
80100d74:	e8 2c 7c 00 00       	call   801089a5 <copyout>
80100d79:	85 c0                	test   %eax,%eax
80100d7b:	79 05                	jns    80100d82 <exec+0x293>
      goto bad;
80100d7d:	e9 67 01 00 00       	jmp    80100ee9 <exec+0x3fa>
    ustack[3+argc] = sp;
80100d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d85:	8d 50 03             	lea    0x3(%eax),%edx
80100d88:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d8b:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d92:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da3:	01 d0                	add    %edx,%eax
80100da5:	8b 00                	mov    (%eax),%eax
80100da7:	85 c0                	test   %eax,%eax
80100da9:	0f 85 4d ff ff ff    	jne    80100cfc <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db2:	83 c0 03             	add    $0x3,%eax
80100db5:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dbc:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dc0:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dc7:	ff ff ff 
  ustack[1] = argc;
80100dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcd:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd6:	83 c0 01             	add    $0x1,%eax
80100dd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de3:	29 d0                	sub    %edx,%eax
80100de5:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	83 c0 04             	add    $0x4,%eax
80100df1:	c1 e0 02             	shl    $0x2,%eax
80100df4:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfa:	83 c0 04             	add    $0x4,%eax
80100dfd:	c1 e0 02             	shl    $0x2,%eax
80100e00:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e04:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e11:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e18:	89 04 24             	mov    %eax,(%esp)
80100e1b:	e8 85 7b 00 00       	call   801089a5 <copyout>
80100e20:	85 c0                	test   %eax,%eax
80100e22:	79 05                	jns    80100e29 <exec+0x33a>
    goto bad;
80100e24:	e9 c0 00 00 00       	jmp    80100ee9 <exec+0x3fa>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e29:	8b 45 08             	mov    0x8(%ebp),%eax
80100e2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e32:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e35:	eb 17                	jmp    80100e4e <exec+0x35f>
    if(*s == '/')
80100e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e3a:	0f b6 00             	movzbl (%eax),%eax
80100e3d:	3c 2f                	cmp    $0x2f,%al
80100e3f:	75 09                	jne    80100e4a <exec+0x35b>
      last = s+1;
80100e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e44:	83 c0 01             	add    $0x1,%eax
80100e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e4a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e51:	0f b6 00             	movzbl (%eax),%eax
80100e54:	84 c0                	test   %al,%al
80100e56:	75 df                	jne    80100e37 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e5e:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e61:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e68:	00 
80100e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e70:	89 14 24             	mov    %edx,(%esp)
80100e73:	e8 db 49 00 00       	call   80105853 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7e:	8b 40 04             	mov    0x4(%eax),%eax
80100e81:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e8a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e8d:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e96:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e99:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea1:	8b 40 18             	mov    0x18(%eax),%eax
80100ea4:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100eaa:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb3:	8b 40 18             	mov    0x18(%eax),%eax
80100eb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb9:	89 50 44             	mov    %edx,0x44(%eax)
  proc->sighandler = DEFSIG_HENDLER;
80100ebc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec2:	c7 40 7c ff ff ff ff 	movl   $0xffffffff,0x7c(%eax)
  switchuvm(proc);
80100ec9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ecf:	89 04 24             	mov    %eax,(%esp)
80100ed2:	e8 fc 73 00 00       	call   801082d3 <switchuvm>
  freevm(oldpgdir);
80100ed7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eda:	89 04 24             	mov    %eax,(%esp)
80100edd:	e8 64 78 00 00       	call   80108746 <freevm>
  return 0;
80100ee2:	b8 00 00 00 00       	mov    $0x0,%eax
80100ee7:	eb 2c                	jmp    80100f15 <exec+0x426>

 bad:
  if(pgdir)
80100ee9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100eed:	74 0b                	je     80100efa <exec+0x40b>
    freevm(pgdir);
80100eef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ef2:	89 04 24             	mov    %eax,(%esp)
80100ef5:	e8 4c 78 00 00       	call   80108746 <freevm>
  if(ip){
80100efa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100efe:	74 10                	je     80100f10 <exec+0x421>
    iunlockput(ip);
80100f00:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f03:	89 04 24             	mov    %eax,(%esp)
80100f06:	e8 e1 0b 00 00       	call   80101aec <iunlockput>
    end_op();
80100f0b:	e8 91 25 00 00       	call   801034a1 <end_op>
  }
  return -1;
80100f10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f15:	c9                   	leave  
80100f16:	c3                   	ret    

80100f17 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f17:	55                   	push   %ebp
80100f18:	89 e5                	mov    %esp,%ebp
80100f1a:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f1d:	c7 44 24 04 a9 8a 10 	movl   $0x80108aa9,0x4(%esp)
80100f24:	80 
80100f25:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f2c:	e8 8d 44 00 00       	call   801053be <initlock>
}
80100f31:	c9                   	leave  
80100f32:	c3                   	ret    

80100f33 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f33:	55                   	push   %ebp
80100f34:	89 e5                	mov    %esp,%ebp
80100f36:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f39:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f40:	e8 9a 44 00 00       	call   801053df <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f45:	c7 45 f4 94 18 11 80 	movl   $0x80111894,-0xc(%ebp)
80100f4c:	eb 29                	jmp    80100f77 <filealloc+0x44>
    if(f->ref == 0){
80100f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f51:	8b 40 04             	mov    0x4(%eax),%eax
80100f54:	85 c0                	test   %eax,%eax
80100f56:	75 1b                	jne    80100f73 <filealloc+0x40>
      f->ref = 1;
80100f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5b:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f62:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f69:	e8 d3 44 00 00       	call   80105441 <release>
      return f;
80100f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f71:	eb 1e                	jmp    80100f91 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f73:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f77:	81 7d f4 f4 21 11 80 	cmpl   $0x801121f4,-0xc(%ebp)
80100f7e:	72 ce                	jb     80100f4e <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f80:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f87:	e8 b5 44 00 00       	call   80105441 <release>
  return 0;
80100f8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f91:	c9                   	leave  
80100f92:	c3                   	ret    

80100f93 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f93:	55                   	push   %ebp
80100f94:	89 e5                	mov    %esp,%ebp
80100f96:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f99:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fa0:	e8 3a 44 00 00       	call   801053df <acquire>
  if(f->ref < 1)
80100fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa8:	8b 40 04             	mov    0x4(%eax),%eax
80100fab:	85 c0                	test   %eax,%eax
80100fad:	7f 0c                	jg     80100fbb <filedup+0x28>
    panic("filedup");
80100faf:	c7 04 24 b0 8a 10 80 	movl   $0x80108ab0,(%esp)
80100fb6:	e8 7f f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbe:	8b 40 04             	mov    0x4(%eax),%eax
80100fc1:	8d 50 01             	lea    0x1(%eax),%edx
80100fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc7:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fca:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fd1:	e8 6b 44 00 00       	call   80105441 <release>
  return f;
80100fd6:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fd9:	c9                   	leave  
80100fda:	c3                   	ret    

80100fdb <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fdb:	55                   	push   %ebp
80100fdc:	89 e5                	mov    %esp,%ebp
80100fde:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fe1:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fe8:	e8 f2 43 00 00       	call   801053df <acquire>
  if(f->ref < 1)
80100fed:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff0:	8b 40 04             	mov    0x4(%eax),%eax
80100ff3:	85 c0                	test   %eax,%eax
80100ff5:	7f 0c                	jg     80101003 <fileclose+0x28>
    panic("fileclose");
80100ff7:	c7 04 24 b8 8a 10 80 	movl   $0x80108ab8,(%esp)
80100ffe:	e8 37 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101003:	8b 45 08             	mov    0x8(%ebp),%eax
80101006:	8b 40 04             	mov    0x4(%eax),%eax
80101009:	8d 50 ff             	lea    -0x1(%eax),%edx
8010100c:	8b 45 08             	mov    0x8(%ebp),%eax
8010100f:	89 50 04             	mov    %edx,0x4(%eax)
80101012:	8b 45 08             	mov    0x8(%ebp),%eax
80101015:	8b 40 04             	mov    0x4(%eax),%eax
80101018:	85 c0                	test   %eax,%eax
8010101a:	7e 11                	jle    8010102d <fileclose+0x52>
    release(&ftable.lock);
8010101c:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101023:	e8 19 44 00 00       	call   80105441 <release>
80101028:	e9 82 00 00 00       	jmp    801010af <fileclose+0xd4>
    return;
  }
  ff = *f;
8010102d:	8b 45 08             	mov    0x8(%ebp),%eax
80101030:	8b 10                	mov    (%eax),%edx
80101032:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101035:	8b 50 04             	mov    0x4(%eax),%edx
80101038:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010103b:	8b 50 08             	mov    0x8(%eax),%edx
8010103e:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101041:	8b 50 0c             	mov    0xc(%eax),%edx
80101044:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101047:	8b 50 10             	mov    0x10(%eax),%edx
8010104a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010104d:	8b 40 14             	mov    0x14(%eax),%eax
80101050:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101053:	8b 45 08             	mov    0x8(%ebp),%eax
80101056:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010105d:	8b 45 08             	mov    0x8(%ebp),%eax
80101060:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101066:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
8010106d:	e8 cf 43 00 00       	call   80105441 <release>
  
  if(ff.type == FD_PIPE)
80101072:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101075:	83 f8 01             	cmp    $0x1,%eax
80101078:	75 18                	jne    80101092 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010107a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010107e:	0f be d0             	movsbl %al,%edx
80101081:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101084:	89 54 24 04          	mov    %edx,0x4(%esp)
80101088:	89 04 24             	mov    %eax,(%esp)
8010108b:	e8 e1 2f 00 00       	call   80104071 <pipeclose>
80101090:	eb 1d                	jmp    801010af <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101092:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101095:	83 f8 02             	cmp    $0x2,%eax
80101098:	75 15                	jne    801010af <fileclose+0xd4>
    begin_op();
8010109a:	e8 7e 23 00 00       	call   8010341d <begin_op>
    iput(ff.ip);
8010109f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010a2:	89 04 24             	mov    %eax,(%esp)
801010a5:	e8 71 09 00 00       	call   80101a1b <iput>
    end_op();
801010aa:	e8 f2 23 00 00       	call   801034a1 <end_op>
  }
}
801010af:	c9                   	leave  
801010b0:	c3                   	ret    

801010b1 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010b1:	55                   	push   %ebp
801010b2:	89 e5                	mov    %esp,%ebp
801010b4:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010b7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ba:	8b 00                	mov    (%eax),%eax
801010bc:	83 f8 02             	cmp    $0x2,%eax
801010bf:	75 38                	jne    801010f9 <filestat+0x48>
    ilock(f->ip);
801010c1:	8b 45 08             	mov    0x8(%ebp),%eax
801010c4:	8b 40 10             	mov    0x10(%eax),%eax
801010c7:	89 04 24             	mov    %eax,(%esp)
801010ca:	e8 99 07 00 00       	call   80101868 <ilock>
    stati(f->ip, st);
801010cf:	8b 45 08             	mov    0x8(%ebp),%eax
801010d2:	8b 40 10             	mov    0x10(%eax),%eax
801010d5:	8b 55 0c             	mov    0xc(%ebp),%edx
801010d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801010dc:	89 04 24             	mov    %eax,(%esp)
801010df:	e8 4c 0c 00 00       	call   80101d30 <stati>
    iunlock(f->ip);
801010e4:	8b 45 08             	mov    0x8(%ebp),%eax
801010e7:	8b 40 10             	mov    0x10(%eax),%eax
801010ea:	89 04 24             	mov    %eax,(%esp)
801010ed:	e8 c4 08 00 00       	call   801019b6 <iunlock>
    return 0;
801010f2:	b8 00 00 00 00       	mov    $0x0,%eax
801010f7:	eb 05                	jmp    801010fe <filestat+0x4d>
  }
  return -1;
801010f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010fe:	c9                   	leave  
801010ff:	c3                   	ret    

80101100 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101100:	55                   	push   %ebp
80101101:	89 e5                	mov    %esp,%ebp
80101103:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101106:	8b 45 08             	mov    0x8(%ebp),%eax
80101109:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010110d:	84 c0                	test   %al,%al
8010110f:	75 0a                	jne    8010111b <fileread+0x1b>
    return -1;
80101111:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101116:	e9 9f 00 00 00       	jmp    801011ba <fileread+0xba>
  if(f->type == FD_PIPE)
8010111b:	8b 45 08             	mov    0x8(%ebp),%eax
8010111e:	8b 00                	mov    (%eax),%eax
80101120:	83 f8 01             	cmp    $0x1,%eax
80101123:	75 1e                	jne    80101143 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101125:	8b 45 08             	mov    0x8(%ebp),%eax
80101128:	8b 40 0c             	mov    0xc(%eax),%eax
8010112b:	8b 55 10             	mov    0x10(%ebp),%edx
8010112e:	89 54 24 08          	mov    %edx,0x8(%esp)
80101132:	8b 55 0c             	mov    0xc(%ebp),%edx
80101135:	89 54 24 04          	mov    %edx,0x4(%esp)
80101139:	89 04 24             	mov    %eax,(%esp)
8010113c:	e8 b1 30 00 00       	call   801041f2 <piperead>
80101141:	eb 77                	jmp    801011ba <fileread+0xba>
  if(f->type == FD_INODE){
80101143:	8b 45 08             	mov    0x8(%ebp),%eax
80101146:	8b 00                	mov    (%eax),%eax
80101148:	83 f8 02             	cmp    $0x2,%eax
8010114b:	75 61                	jne    801011ae <fileread+0xae>
    ilock(f->ip);
8010114d:	8b 45 08             	mov    0x8(%ebp),%eax
80101150:	8b 40 10             	mov    0x10(%eax),%eax
80101153:	89 04 24             	mov    %eax,(%esp)
80101156:	e8 0d 07 00 00       	call   80101868 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010115b:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010115e:	8b 45 08             	mov    0x8(%ebp),%eax
80101161:	8b 50 14             	mov    0x14(%eax),%edx
80101164:	8b 45 08             	mov    0x8(%ebp),%eax
80101167:	8b 40 10             	mov    0x10(%eax),%eax
8010116a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010116e:	89 54 24 08          	mov    %edx,0x8(%esp)
80101172:	8b 55 0c             	mov    0xc(%ebp),%edx
80101175:	89 54 24 04          	mov    %edx,0x4(%esp)
80101179:	89 04 24             	mov    %eax,(%esp)
8010117c:	e8 f4 0b 00 00       	call   80101d75 <readi>
80101181:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101184:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101188:	7e 11                	jle    8010119b <fileread+0x9b>
      f->off += r;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 50 14             	mov    0x14(%eax),%edx
80101190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101193:	01 c2                	add    %eax,%edx
80101195:	8b 45 08             	mov    0x8(%ebp),%eax
80101198:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010119b:	8b 45 08             	mov    0x8(%ebp),%eax
8010119e:	8b 40 10             	mov    0x10(%eax),%eax
801011a1:	89 04 24             	mov    %eax,(%esp)
801011a4:	e8 0d 08 00 00       	call   801019b6 <iunlock>
    return r;
801011a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011ac:	eb 0c                	jmp    801011ba <fileread+0xba>
  }
  panic("fileread");
801011ae:	c7 04 24 c2 8a 10 80 	movl   $0x80108ac2,(%esp)
801011b5:	e8 80 f3 ff ff       	call   8010053a <panic>
}
801011ba:	c9                   	leave  
801011bb:	c3                   	ret    

801011bc <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011bc:	55                   	push   %ebp
801011bd:	89 e5                	mov    %esp,%ebp
801011bf:	53                   	push   %ebx
801011c0:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011c3:	8b 45 08             	mov    0x8(%ebp),%eax
801011c6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011ca:	84 c0                	test   %al,%al
801011cc:	75 0a                	jne    801011d8 <filewrite+0x1c>
    return -1;
801011ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d3:	e9 20 01 00 00       	jmp    801012f8 <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011d8:	8b 45 08             	mov    0x8(%ebp),%eax
801011db:	8b 00                	mov    (%eax),%eax
801011dd:	83 f8 01             	cmp    $0x1,%eax
801011e0:	75 21                	jne    80101203 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011e2:	8b 45 08             	mov    0x8(%ebp),%eax
801011e5:	8b 40 0c             	mov    0xc(%eax),%eax
801011e8:	8b 55 10             	mov    0x10(%ebp),%edx
801011eb:	89 54 24 08          	mov    %edx,0x8(%esp)
801011ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801011f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801011f6:	89 04 24             	mov    %eax,(%esp)
801011f9:	e8 05 2f 00 00       	call   80104103 <pipewrite>
801011fe:	e9 f5 00 00 00       	jmp    801012f8 <filewrite+0x13c>
  if(f->type == FD_INODE){
80101203:	8b 45 08             	mov    0x8(%ebp),%eax
80101206:	8b 00                	mov    (%eax),%eax
80101208:	83 f8 02             	cmp    $0x2,%eax
8010120b:	0f 85 db 00 00 00    	jne    801012ec <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101211:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101218:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010121f:	e9 a8 00 00 00       	jmp    801012cc <filewrite+0x110>
      int n1 = n - i;
80101224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101227:	8b 55 10             	mov    0x10(%ebp),%edx
8010122a:	29 c2                	sub    %eax,%edx
8010122c:	89 d0                	mov    %edx,%eax
8010122e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101234:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101237:	7e 06                	jle    8010123f <filewrite+0x83>
        n1 = max;
80101239:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010123c:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010123f:	e8 d9 21 00 00       	call   8010341d <begin_op>
      ilock(f->ip);
80101244:	8b 45 08             	mov    0x8(%ebp),%eax
80101247:	8b 40 10             	mov    0x10(%eax),%eax
8010124a:	89 04 24             	mov    %eax,(%esp)
8010124d:	e8 16 06 00 00       	call   80101868 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101252:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101255:	8b 45 08             	mov    0x8(%ebp),%eax
80101258:	8b 50 14             	mov    0x14(%eax),%edx
8010125b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010125e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101261:	01 c3                	add    %eax,%ebx
80101263:	8b 45 08             	mov    0x8(%ebp),%eax
80101266:	8b 40 10             	mov    0x10(%eax),%eax
80101269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010126d:	89 54 24 08          	mov    %edx,0x8(%esp)
80101271:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101275:	89 04 24             	mov    %eax,(%esp)
80101278:	e8 5c 0c 00 00       	call   80101ed9 <writei>
8010127d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101280:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101284:	7e 11                	jle    80101297 <filewrite+0xdb>
        f->off += r;
80101286:	8b 45 08             	mov    0x8(%ebp),%eax
80101289:	8b 50 14             	mov    0x14(%eax),%edx
8010128c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010128f:	01 c2                	add    %eax,%edx
80101291:	8b 45 08             	mov    0x8(%ebp),%eax
80101294:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101297:	8b 45 08             	mov    0x8(%ebp),%eax
8010129a:	8b 40 10             	mov    0x10(%eax),%eax
8010129d:	89 04 24             	mov    %eax,(%esp)
801012a0:	e8 11 07 00 00       	call   801019b6 <iunlock>
      end_op();
801012a5:	e8 f7 21 00 00       	call   801034a1 <end_op>

      if(r < 0)
801012aa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012ae:	79 02                	jns    801012b2 <filewrite+0xf6>
        break;
801012b0:	eb 26                	jmp    801012d8 <filewrite+0x11c>
      if(r != n1)
801012b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012b5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012b8:	74 0c                	je     801012c6 <filewrite+0x10a>
        panic("short filewrite");
801012ba:	c7 04 24 cb 8a 10 80 	movl   $0x80108acb,(%esp)
801012c1:	e8 74 f2 ff ff       	call   8010053a <panic>
      i += r;
801012c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c9:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012cf:	3b 45 10             	cmp    0x10(%ebp),%eax
801012d2:	0f 8c 4c ff ff ff    	jl     80101224 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012db:	3b 45 10             	cmp    0x10(%ebp),%eax
801012de:	75 05                	jne    801012e5 <filewrite+0x129>
801012e0:	8b 45 10             	mov    0x10(%ebp),%eax
801012e3:	eb 05                	jmp    801012ea <filewrite+0x12e>
801012e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012ea:	eb 0c                	jmp    801012f8 <filewrite+0x13c>
  }
  panic("filewrite");
801012ec:	c7 04 24 db 8a 10 80 	movl   $0x80108adb,(%esp)
801012f3:	e8 42 f2 ff ff       	call   8010053a <panic>
}
801012f8:	83 c4 24             	add    $0x24,%esp
801012fb:	5b                   	pop    %ebx
801012fc:	5d                   	pop    %ebp
801012fd:	c3                   	ret    

801012fe <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012fe:	55                   	push   %ebp
801012ff:	89 e5                	mov    %esp,%ebp
80101301:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101304:	8b 45 08             	mov    0x8(%ebp),%eax
80101307:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010130e:	00 
8010130f:	89 04 24             	mov    %eax,(%esp)
80101312:	e8 8f ee ff ff       	call   801001a6 <bread>
80101317:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010131a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010131d:	83 c0 18             	add    $0x18,%eax
80101320:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101327:	00 
80101328:	89 44 24 04          	mov    %eax,0x4(%esp)
8010132c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010132f:	89 04 24             	mov    %eax,(%esp)
80101332:	e8 cb 43 00 00       	call   80105702 <memmove>
  brelse(bp);
80101337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010133a:	89 04 24             	mov    %eax,(%esp)
8010133d:	e8 d5 ee ff ff       	call   80100217 <brelse>
}
80101342:	c9                   	leave  
80101343:	c3                   	ret    

80101344 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101344:	55                   	push   %ebp
80101345:	89 e5                	mov    %esp,%ebp
80101347:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010134a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010134d:	8b 45 08             	mov    0x8(%ebp),%eax
80101350:	89 54 24 04          	mov    %edx,0x4(%esp)
80101354:	89 04 24             	mov    %eax,(%esp)
80101357:	e8 4a ee ff ff       	call   801001a6 <bread>
8010135c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010135f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101362:	83 c0 18             	add    $0x18,%eax
80101365:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010136c:	00 
8010136d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101374:	00 
80101375:	89 04 24             	mov    %eax,(%esp)
80101378:	e8 b6 42 00 00       	call   80105633 <memset>
  log_write(bp);
8010137d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101380:	89 04 24             	mov    %eax,(%esp)
80101383:	e8 a0 22 00 00       	call   80103628 <log_write>
  brelse(bp);
80101388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138b:	89 04 24             	mov    %eax,(%esp)
8010138e:	e8 84 ee ff ff       	call   80100217 <brelse>
}
80101393:	c9                   	leave  
80101394:	c3                   	ret    

80101395 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101395:	55                   	push   %ebp
80101396:	89 e5                	mov    %esp,%ebp
80101398:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010139b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013a2:	8b 45 08             	mov    0x8(%ebp),%eax
801013a5:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801013ac:	89 04 24             	mov    %eax,(%esp)
801013af:	e8 4a ff ff ff       	call   801012fe <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013bb:	e9 07 01 00 00       	jmp    801014c7 <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013c9:	85 c0                	test   %eax,%eax
801013cb:	0f 48 c2             	cmovs  %edx,%eax
801013ce:	c1 f8 0c             	sar    $0xc,%eax
801013d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013d4:	c1 ea 03             	shr    $0x3,%edx
801013d7:	01 d0                	add    %edx,%eax
801013d9:	83 c0 03             	add    $0x3,%eax
801013dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801013e0:	8b 45 08             	mov    0x8(%ebp),%eax
801013e3:	89 04 24             	mov    %eax,(%esp)
801013e6:	e8 bb ed ff ff       	call   801001a6 <bread>
801013eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013f5:	e9 9d 00 00 00       	jmp    80101497 <balloc+0x102>
      m = 1 << (bi % 8);
801013fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013fd:	99                   	cltd   
801013fe:	c1 ea 1d             	shr    $0x1d,%edx
80101401:	01 d0                	add    %edx,%eax
80101403:	83 e0 07             	and    $0x7,%eax
80101406:	29 d0                	sub    %edx,%eax
80101408:	ba 01 00 00 00       	mov    $0x1,%edx
8010140d:	89 c1                	mov    %eax,%ecx
8010140f:	d3 e2                	shl    %cl,%edx
80101411:	89 d0                	mov    %edx,%eax
80101413:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101419:	8d 50 07             	lea    0x7(%eax),%edx
8010141c:	85 c0                	test   %eax,%eax
8010141e:	0f 48 c2             	cmovs  %edx,%eax
80101421:	c1 f8 03             	sar    $0x3,%eax
80101424:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101427:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010142c:	0f b6 c0             	movzbl %al,%eax
8010142f:	23 45 e8             	and    -0x18(%ebp),%eax
80101432:	85 c0                	test   %eax,%eax
80101434:	75 5d                	jne    80101493 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101436:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101439:	8d 50 07             	lea    0x7(%eax),%edx
8010143c:	85 c0                	test   %eax,%eax
8010143e:	0f 48 c2             	cmovs  %edx,%eax
80101441:	c1 f8 03             	sar    $0x3,%eax
80101444:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101447:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010144c:	89 d1                	mov    %edx,%ecx
8010144e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101451:	09 ca                	or     %ecx,%edx
80101453:	89 d1                	mov    %edx,%ecx
80101455:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101458:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010145c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010145f:	89 04 24             	mov    %eax,(%esp)
80101462:	e8 c1 21 00 00       	call   80103628 <log_write>
        brelse(bp);
80101467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010146a:	89 04 24             	mov    %eax,(%esp)
8010146d:	e8 a5 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101472:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101475:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101478:	01 c2                	add    %eax,%edx
8010147a:	8b 45 08             	mov    0x8(%ebp),%eax
8010147d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101481:	89 04 24             	mov    %eax,(%esp)
80101484:	e8 bb fe ff ff       	call   80101344 <bzero>
        return b + bi;
80101489:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010148f:	01 d0                	add    %edx,%eax
80101491:	eb 4e                	jmp    801014e1 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101493:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101497:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010149e:	7f 15                	jg     801014b5 <balloc+0x120>
801014a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a6:	01 d0                	add    %edx,%eax
801014a8:	89 c2                	mov    %eax,%edx
801014aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014ad:	39 c2                	cmp    %eax,%edx
801014af:	0f 82 45 ff ff ff    	jb     801013fa <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014b8:	89 04 24             	mov    %eax,(%esp)
801014bb:	e8 57 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014c0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014cd:	39 c2                	cmp    %eax,%edx
801014cf:	0f 82 eb fe ff ff    	jb     801013c0 <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014d5:	c7 04 24 e5 8a 10 80 	movl   $0x80108ae5,(%esp)
801014dc:	e8 59 f0 ff ff       	call   8010053a <panic>
}
801014e1:	c9                   	leave  
801014e2:	c3                   	ret    

801014e3 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014e3:	55                   	push   %ebp
801014e4:	89 e5                	mov    %esp,%ebp
801014e6:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014e9:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801014f0:	8b 45 08             	mov    0x8(%ebp),%eax
801014f3:	89 04 24             	mov    %eax,(%esp)
801014f6:	e8 03 fe ff ff       	call   801012fe <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801014fe:	c1 e8 0c             	shr    $0xc,%eax
80101501:	89 c2                	mov    %eax,%edx
80101503:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101506:	c1 e8 03             	shr    $0x3,%eax
80101509:	01 d0                	add    %edx,%eax
8010150b:	8d 50 03             	lea    0x3(%eax),%edx
8010150e:	8b 45 08             	mov    0x8(%ebp),%eax
80101511:	89 54 24 04          	mov    %edx,0x4(%esp)
80101515:	89 04 24             	mov    %eax,(%esp)
80101518:	e8 89 ec ff ff       	call   801001a6 <bread>
8010151d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101520:	8b 45 0c             	mov    0xc(%ebp),%eax
80101523:	25 ff 0f 00 00       	and    $0xfff,%eax
80101528:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152e:	99                   	cltd   
8010152f:	c1 ea 1d             	shr    $0x1d,%edx
80101532:	01 d0                	add    %edx,%eax
80101534:	83 e0 07             	and    $0x7,%eax
80101537:	29 d0                	sub    %edx,%eax
80101539:	ba 01 00 00 00       	mov    $0x1,%edx
8010153e:	89 c1                	mov    %eax,%ecx
80101540:	d3 e2                	shl    %cl,%edx
80101542:	89 d0                	mov    %edx,%eax
80101544:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154a:	8d 50 07             	lea    0x7(%eax),%edx
8010154d:	85 c0                	test   %eax,%eax
8010154f:	0f 48 c2             	cmovs  %edx,%eax
80101552:	c1 f8 03             	sar    $0x3,%eax
80101555:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101558:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010155d:	0f b6 c0             	movzbl %al,%eax
80101560:	23 45 ec             	and    -0x14(%ebp),%eax
80101563:	85 c0                	test   %eax,%eax
80101565:	75 0c                	jne    80101573 <bfree+0x90>
    panic("freeing free block");
80101567:	c7 04 24 fb 8a 10 80 	movl   $0x80108afb,(%esp)
8010156e:	e8 c7 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101576:	8d 50 07             	lea    0x7(%eax),%edx
80101579:	85 c0                	test   %eax,%eax
8010157b:	0f 48 c2             	cmovs  %edx,%eax
8010157e:	c1 f8 03             	sar    $0x3,%eax
80101581:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101584:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101589:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010158c:	f7 d1                	not    %ecx
8010158e:	21 ca                	and    %ecx,%edx
80101590:	89 d1                	mov    %edx,%ecx
80101592:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101595:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159c:	89 04 24             	mov    %eax,(%esp)
8010159f:	e8 84 20 00 00       	call   80103628 <log_write>
  brelse(bp);
801015a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a7:	89 04 24             	mov    %eax,(%esp)
801015aa:	e8 68 ec ff ff       	call   80100217 <brelse>
}
801015af:	c9                   	leave  
801015b0:	c3                   	ret    

801015b1 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015b1:	55                   	push   %ebp
801015b2:	89 e5                	mov    %esp,%ebp
801015b4:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015b7:	c7 44 24 04 0e 8b 10 	movl   $0x80108b0e,0x4(%esp)
801015be:	80 
801015bf:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801015c6:	e8 f3 3d 00 00       	call   801053be <initlock>
}
801015cb:	c9                   	leave  
801015cc:	c3                   	ret    

801015cd <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015cd:	55                   	push   %ebp
801015ce:	89 e5                	mov    %esp,%ebp
801015d0:	83 ec 38             	sub    $0x38,%esp
801015d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d6:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015da:	8b 45 08             	mov    0x8(%ebp),%eax
801015dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801015e4:	89 04 24             	mov    %eax,(%esp)
801015e7:	e8 12 fd ff ff       	call   801012fe <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015ec:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015f3:	e9 98 00 00 00       	jmp    80101690 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fb:	c1 e8 03             	shr    $0x3,%eax
801015fe:	83 c0 02             	add    $0x2,%eax
80101601:	89 44 24 04          	mov    %eax,0x4(%esp)
80101605:	8b 45 08             	mov    0x8(%ebp),%eax
80101608:	89 04 24             	mov    %eax,(%esp)
8010160b:	e8 96 eb ff ff       	call   801001a6 <bread>
80101610:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101613:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101616:	8d 50 18             	lea    0x18(%eax),%edx
80101619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161c:	83 e0 07             	and    $0x7,%eax
8010161f:	c1 e0 06             	shl    $0x6,%eax
80101622:	01 d0                	add    %edx,%eax
80101624:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101627:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010162a:	0f b7 00             	movzwl (%eax),%eax
8010162d:	66 85 c0             	test   %ax,%ax
80101630:	75 4f                	jne    80101681 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101632:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101639:	00 
8010163a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101641:	00 
80101642:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101645:	89 04 24             	mov    %eax,(%esp)
80101648:	e8 e6 3f 00 00       	call   80105633 <memset>
      dip->type = type;
8010164d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101650:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101654:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101657:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165a:	89 04 24             	mov    %eax,(%esp)
8010165d:	e8 c6 1f 00 00       	call   80103628 <log_write>
      brelse(bp);
80101662:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101665:	89 04 24             	mov    %eax,(%esp)
80101668:	e8 aa eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010166d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101670:	89 44 24 04          	mov    %eax,0x4(%esp)
80101674:	8b 45 08             	mov    0x8(%ebp),%eax
80101677:	89 04 24             	mov    %eax,(%esp)
8010167a:	e8 e5 00 00 00       	call   80101764 <iget>
8010167f:	eb 29                	jmp    801016aa <ialloc+0xdd>
    }
    brelse(bp);
80101681:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101684:	89 04 24             	mov    %eax,(%esp)
80101687:	e8 8b eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010168c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101690:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101693:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101696:	39 c2                	cmp    %eax,%edx
80101698:	0f 82 5a ff ff ff    	jb     801015f8 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010169e:	c7 04 24 15 8b 10 80 	movl   $0x80108b15,(%esp)
801016a5:	e8 90 ee ff ff       	call   8010053a <panic>
}
801016aa:	c9                   	leave  
801016ab:	c3                   	ret    

801016ac <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016ac:	55                   	push   %ebp
801016ad:	89 e5                	mov    %esp,%ebp
801016af:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016b2:	8b 45 08             	mov    0x8(%ebp),%eax
801016b5:	8b 40 04             	mov    0x4(%eax),%eax
801016b8:	c1 e8 03             	shr    $0x3,%eax
801016bb:	8d 50 02             	lea    0x2(%eax),%edx
801016be:	8b 45 08             	mov    0x8(%ebp),%eax
801016c1:	8b 00                	mov    (%eax),%eax
801016c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801016c7:	89 04 24             	mov    %eax,(%esp)
801016ca:	e8 d7 ea ff ff       	call   801001a6 <bread>
801016cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d5:	8d 50 18             	lea    0x18(%eax),%edx
801016d8:	8b 45 08             	mov    0x8(%ebp),%eax
801016db:	8b 40 04             	mov    0x4(%eax),%eax
801016de:	83 e0 07             	and    $0x7,%eax
801016e1:	c1 e0 06             	shl    $0x6,%eax
801016e4:	01 d0                	add    %edx,%eax
801016e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016e9:	8b 45 08             	mov    0x8(%ebp),%eax
801016ec:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f3:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016f6:	8b 45 08             	mov    0x8(%ebp),%eax
801016f9:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101700:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101704:	8b 45 08             	mov    0x8(%ebp),%eax
80101707:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101712:	8b 45 08             	mov    0x8(%ebp),%eax
80101715:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101720:	8b 45 08             	mov    0x8(%ebp),%eax
80101723:	8b 50 18             	mov    0x18(%eax),%edx
80101726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101729:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010172c:	8b 45 08             	mov    0x8(%ebp),%eax
8010172f:	8d 50 1c             	lea    0x1c(%eax),%edx
80101732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101735:	83 c0 0c             	add    $0xc,%eax
80101738:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010173f:	00 
80101740:	89 54 24 04          	mov    %edx,0x4(%esp)
80101744:	89 04 24             	mov    %eax,(%esp)
80101747:	e8 b6 3f 00 00       	call   80105702 <memmove>
  log_write(bp);
8010174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174f:	89 04 24             	mov    %eax,(%esp)
80101752:	e8 d1 1e 00 00       	call   80103628 <log_write>
  brelse(bp);
80101757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175a:	89 04 24             	mov    %eax,(%esp)
8010175d:	e8 b5 ea ff ff       	call   80100217 <brelse>
}
80101762:	c9                   	leave  
80101763:	c3                   	ret    

80101764 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101764:	55                   	push   %ebp
80101765:	89 e5                	mov    %esp,%ebp
80101767:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010176a:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101771:	e8 69 3c 00 00       	call   801053df <acquire>

  // Is the inode already cached?
  empty = 0;
80101776:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010177d:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101784:	eb 59                	jmp    801017df <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101789:	8b 40 08             	mov    0x8(%eax),%eax
8010178c:	85 c0                	test   %eax,%eax
8010178e:	7e 35                	jle    801017c5 <iget+0x61>
80101790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101793:	8b 00                	mov    (%eax),%eax
80101795:	3b 45 08             	cmp    0x8(%ebp),%eax
80101798:	75 2b                	jne    801017c5 <iget+0x61>
8010179a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179d:	8b 40 04             	mov    0x4(%eax),%eax
801017a0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017a3:	75 20                	jne    801017c5 <iget+0x61>
      ip->ref++;
801017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a8:	8b 40 08             	mov    0x8(%eax),%eax
801017ab:	8d 50 01             	lea    0x1(%eax),%edx
801017ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b1:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017b4:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801017bb:	e8 81 3c 00 00       	call   80105441 <release>
      return ip;
801017c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c3:	eb 6f                	jmp    80101834 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017c9:	75 10                	jne    801017db <iget+0x77>
801017cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ce:	8b 40 08             	mov    0x8(%eax),%eax
801017d1:	85 c0                	test   %eax,%eax
801017d3:	75 06                	jne    801017db <iget+0x77>
      empty = ip;
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017db:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017df:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
801017e6:	72 9e                	jb     80101786 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017ec:	75 0c                	jne    801017fa <iget+0x96>
    panic("iget: no inodes");
801017ee:	c7 04 24 27 8b 10 80 	movl   $0x80108b27,(%esp)
801017f5:	e8 40 ed ff ff       	call   8010053a <panic>

  ip = empty;
801017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101803:	8b 55 08             	mov    0x8(%ebp),%edx
80101806:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010180e:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101814:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010181b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101825:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010182c:	e8 10 3c 00 00       	call   80105441 <release>

  return ip;
80101831:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101834:	c9                   	leave  
80101835:	c3                   	ret    

80101836 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101836:	55                   	push   %ebp
80101837:	89 e5                	mov    %esp,%ebp
80101839:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010183c:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101843:	e8 97 3b 00 00       	call   801053df <acquire>
  ip->ref++;
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 08             	mov    0x8(%eax),%eax
8010184e:	8d 50 01             	lea    0x1(%eax),%edx
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101857:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010185e:	e8 de 3b 00 00       	call   80105441 <release>
  return ip;
80101863:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101866:	c9                   	leave  
80101867:	c3                   	ret    

80101868 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101868:	55                   	push   %ebp
80101869:	89 e5                	mov    %esp,%ebp
8010186b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010186e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101872:	74 0a                	je     8010187e <ilock+0x16>
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	8b 40 08             	mov    0x8(%eax),%eax
8010187a:	85 c0                	test   %eax,%eax
8010187c:	7f 0c                	jg     8010188a <ilock+0x22>
    panic("ilock");
8010187e:	c7 04 24 37 8b 10 80 	movl   $0x80108b37,(%esp)
80101885:	e8 b0 ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010188a:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101891:	e8 49 3b 00 00       	call   801053df <acquire>
  while(ip->flags & I_BUSY)
80101896:	eb 13                	jmp    801018ab <ilock+0x43>
    sleep(ip, &icache.lock);
80101898:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
8010189f:	80 
801018a0:	8b 45 08             	mov    0x8(%ebp),%eax
801018a3:	89 04 24             	mov    %eax,(%esp)
801018a6:	e8 b1 33 00 00       	call   80104c5c <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018ab:	8b 45 08             	mov    0x8(%ebp),%eax
801018ae:	8b 40 0c             	mov    0xc(%eax),%eax
801018b1:	83 e0 01             	and    $0x1,%eax
801018b4:	85 c0                	test   %eax,%eax
801018b6:	75 e0                	jne    80101898 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 40 0c             	mov    0xc(%eax),%eax
801018be:	83 c8 01             	or     $0x1,%eax
801018c1:	89 c2                	mov    %eax,%edx
801018c3:	8b 45 08             	mov    0x8(%ebp),%eax
801018c6:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018c9:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801018d0:	e8 6c 3b 00 00       	call   80105441 <release>

  if(!(ip->flags & I_VALID)){
801018d5:	8b 45 08             	mov    0x8(%ebp),%eax
801018d8:	8b 40 0c             	mov    0xc(%eax),%eax
801018db:	83 e0 02             	and    $0x2,%eax
801018de:	85 c0                	test   %eax,%eax
801018e0:	0f 85 ce 00 00 00    	jne    801019b4 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018e6:	8b 45 08             	mov    0x8(%ebp),%eax
801018e9:	8b 40 04             	mov    0x4(%eax),%eax
801018ec:	c1 e8 03             	shr    $0x3,%eax
801018ef:	8d 50 02             	lea    0x2(%eax),%edx
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
801018f5:	8b 00                	mov    (%eax),%eax
801018f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801018fb:	89 04 24             	mov    %eax,(%esp)
801018fe:	e8 a3 e8 ff ff       	call   801001a6 <bread>
80101903:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8d 50 18             	lea    0x18(%eax),%edx
8010190c:	8b 45 08             	mov    0x8(%ebp),%eax
8010190f:	8b 40 04             	mov    0x4(%eax),%eax
80101912:	83 e0 07             	and    $0x7,%eax
80101915:	c1 e0 06             	shl    $0x6,%eax
80101918:	01 d0                	add    %edx,%eax
8010191a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101920:	0f b7 10             	movzwl (%eax),%edx
80101923:	8b 45 08             	mov    0x8(%ebp),%eax
80101926:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010192a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101931:	8b 45 08             	mov    0x8(%ebp),%eax
80101934:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010193f:	8b 45 08             	mov    0x8(%ebp),%eax
80101942:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101946:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101949:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010194d:	8b 45 08             	mov    0x8(%ebp),%eax
80101950:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101957:	8b 50 08             	mov    0x8(%eax),%edx
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101963:	8d 50 0c             	lea    0xc(%eax),%edx
80101966:	8b 45 08             	mov    0x8(%ebp),%eax
80101969:	83 c0 1c             	add    $0x1c,%eax
8010196c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101973:	00 
80101974:	89 54 24 04          	mov    %edx,0x4(%esp)
80101978:	89 04 24             	mov    %eax,(%esp)
8010197b:	e8 82 3d 00 00       	call   80105702 <memmove>
    brelse(bp);
80101980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101983:	89 04 24             	mov    %eax,(%esp)
80101986:	e8 8c e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010198b:	8b 45 08             	mov    0x8(%ebp),%eax
8010198e:	8b 40 0c             	mov    0xc(%eax),%eax
80101991:	83 c8 02             	or     $0x2,%eax
80101994:	89 c2                	mov    %eax,%edx
80101996:	8b 45 08             	mov    0x8(%ebp),%eax
80101999:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010199c:	8b 45 08             	mov    0x8(%ebp),%eax
8010199f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019a3:	66 85 c0             	test   %ax,%ax
801019a6:	75 0c                	jne    801019b4 <ilock+0x14c>
      panic("ilock: no type");
801019a8:	c7 04 24 3d 8b 10 80 	movl   $0x80108b3d,(%esp)
801019af:	e8 86 eb ff ff       	call   8010053a <panic>
  }
}
801019b4:	c9                   	leave  
801019b5:	c3                   	ret    

801019b6 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019b6:	55                   	push   %ebp
801019b7:	89 e5                	mov    %esp,%ebp
801019b9:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019bc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019c0:	74 17                	je     801019d9 <iunlock+0x23>
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8b 40 0c             	mov    0xc(%eax),%eax
801019c8:	83 e0 01             	and    $0x1,%eax
801019cb:	85 c0                	test   %eax,%eax
801019cd:	74 0a                	je     801019d9 <iunlock+0x23>
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	8b 40 08             	mov    0x8(%eax),%eax
801019d5:	85 c0                	test   %eax,%eax
801019d7:	7f 0c                	jg     801019e5 <iunlock+0x2f>
    panic("iunlock");
801019d9:	c7 04 24 4c 8b 10 80 	movl   $0x80108b4c,(%esp)
801019e0:	e8 55 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019e5:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801019ec:	e8 ee 39 00 00       	call   801053df <acquire>
  ip->flags &= ~I_BUSY;
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	8b 40 0c             	mov    0xc(%eax),%eax
801019f7:	83 e0 fe             	and    $0xfffffffe,%eax
801019fa:	89 c2                	mov    %eax,%edx
801019fc:	8b 45 08             	mov    0x8(%ebp),%eax
801019ff:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a02:	8b 45 08             	mov    0x8(%ebp),%eax
80101a05:	89 04 24             	mov    %eax,(%esp)
80101a08:	e8 2a 33 00 00       	call   80104d37 <wakeup>
  release(&icache.lock);
80101a0d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a14:	e8 28 3a 00 00       	call   80105441 <release>
}
80101a19:	c9                   	leave  
80101a1a:	c3                   	ret    

80101a1b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a1b:	55                   	push   %ebp
80101a1c:	89 e5                	mov    %esp,%ebp
80101a1e:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a21:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a28:	e8 b2 39 00 00       	call   801053df <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 08             	mov    0x8(%eax),%eax
80101a33:	83 f8 01             	cmp    $0x1,%eax
80101a36:	0f 85 93 00 00 00    	jne    80101acf <iput+0xb4>
80101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a42:	83 e0 02             	and    $0x2,%eax
80101a45:	85 c0                	test   %eax,%eax
80101a47:	0f 84 82 00 00 00    	je     80101acf <iput+0xb4>
80101a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a50:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a54:	66 85 c0             	test   %ax,%ax
80101a57:	75 76                	jne    80101acf <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	8b 40 0c             	mov    0xc(%eax),%eax
80101a5f:	83 e0 01             	and    $0x1,%eax
80101a62:	85 c0                	test   %eax,%eax
80101a64:	74 0c                	je     80101a72 <iput+0x57>
      panic("iput busy");
80101a66:	c7 04 24 54 8b 10 80 	movl   $0x80108b54,(%esp)
80101a6d:	e8 c8 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	8b 40 0c             	mov    0xc(%eax),%eax
80101a78:	83 c8 01             	or     $0x1,%eax
80101a7b:	89 c2                	mov    %eax,%edx
80101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a80:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a83:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a8a:	e8 b2 39 00 00       	call   80105441 <release>
    itrunc(ip);
80101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a92:	89 04 24             	mov    %eax,(%esp)
80101a95:	e8 7d 01 00 00       	call   80101c17 <itrunc>
    ip->type = 0;
80101a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9d:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	89 04 24             	mov    %eax,(%esp)
80101aa9:	e8 fe fb ff ff       	call   801016ac <iupdate>
    acquire(&icache.lock);
80101aae:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101ab5:	e8 25 39 00 00       	call   801053df <acquire>
    ip->flags = 0;
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac7:	89 04 24             	mov    %eax,(%esp)
80101aca:	e8 68 32 00 00       	call   80104d37 <wakeup>
  }
  ip->ref--;
80101acf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad2:	8b 40 08             	mov    0x8(%eax),%eax
80101ad5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ade:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101ae5:	e8 57 39 00 00       	call   80105441 <release>
}
80101aea:	c9                   	leave  
80101aeb:	c3                   	ret    

80101aec <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101aec:	55                   	push   %ebp
80101aed:	89 e5                	mov    %esp,%ebp
80101aef:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101af2:	8b 45 08             	mov    0x8(%ebp),%eax
80101af5:	89 04 24             	mov    %eax,(%esp)
80101af8:	e8 b9 fe ff ff       	call   801019b6 <iunlock>
  iput(ip);
80101afd:	8b 45 08             	mov    0x8(%ebp),%eax
80101b00:	89 04 24             	mov    %eax,(%esp)
80101b03:	e8 13 ff ff ff       	call   80101a1b <iput>
}
80101b08:	c9                   	leave  
80101b09:	c3                   	ret    

80101b0a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b0a:	55                   	push   %ebp
80101b0b:	89 e5                	mov    %esp,%ebp
80101b0d:	53                   	push   %ebx
80101b0e:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b11:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b15:	77 3e                	ja     80101b55 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b1d:	83 c2 04             	add    $0x4,%edx
80101b20:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b2b:	75 20                	jne    80101b4d <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	8b 00                	mov    (%eax),%eax
80101b32:	89 04 24             	mov    %eax,(%esp)
80101b35:	e8 5b f8 ff ff       	call   80101395 <balloc>
80101b3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b40:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b43:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b49:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b50:	e9 bc 00 00 00       	jmp    80101c11 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b55:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b59:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b5d:	0f 87 a2 00 00 00    	ja     80101c05 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b70:	75 19                	jne    80101b8b <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b72:	8b 45 08             	mov    0x8(%ebp),%eax
80101b75:	8b 00                	mov    (%eax),%eax
80101b77:	89 04 24             	mov    %eax,(%esp)
80101b7a:	e8 16 f8 ff ff       	call   80101395 <balloc>
80101b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b82:	8b 45 08             	mov    0x8(%ebp),%eax
80101b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b88:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8e:	8b 00                	mov    (%eax),%eax
80101b90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b93:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b97:	89 04 24             	mov    %eax,(%esp)
80101b9a:	e8 07 e6 ff ff       	call   801001a6 <bread>
80101b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba5:	83 c0 18             	add    $0x18,%eax
80101ba8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bab:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bb8:	01 d0                	add    %edx,%eax
80101bba:	8b 00                	mov    (%eax),%eax
80101bbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bc3:	75 30                	jne    80101bf5 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bc8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bd2:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	8b 00                	mov    (%eax),%eax
80101bda:	89 04 24             	mov    %eax,(%esp)
80101bdd:	e8 b3 f7 ff ff       	call   80101395 <balloc>
80101be2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be8:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bed:	89 04 24             	mov    %eax,(%esp)
80101bf0:	e8 33 1a 00 00       	call   80103628 <log_write>
    }
    brelse(bp);
80101bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf8:	89 04 24             	mov    %eax,(%esp)
80101bfb:	e8 17 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c03:	eb 0c                	jmp    80101c11 <bmap+0x107>
  }

  panic("bmap: out of range");
80101c05:	c7 04 24 5e 8b 10 80 	movl   $0x80108b5e,(%esp)
80101c0c:	e8 29 e9 ff ff       	call   8010053a <panic>
}
80101c11:	83 c4 24             	add    $0x24,%esp
80101c14:	5b                   	pop    %ebx
80101c15:	5d                   	pop    %ebp
80101c16:	c3                   	ret    

80101c17 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c17:	55                   	push   %ebp
80101c18:	89 e5                	mov    %esp,%ebp
80101c1a:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c24:	eb 44                	jmp    80101c6a <itrunc+0x53>
    if(ip->addrs[i]){
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c2c:	83 c2 04             	add    $0x4,%edx
80101c2f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c33:	85 c0                	test   %eax,%eax
80101c35:	74 2f                	je     80101c66 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c3d:	83 c2 04             	add    $0x4,%edx
80101c40:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c44:	8b 45 08             	mov    0x8(%ebp),%eax
80101c47:	8b 00                	mov    (%eax),%eax
80101c49:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c4d:	89 04 24             	mov    %eax,(%esp)
80101c50:	e8 8e f8 ff ff       	call   801014e3 <bfree>
      ip->addrs[i] = 0;
80101c55:	8b 45 08             	mov    0x8(%ebp),%eax
80101c58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c5b:	83 c2 04             	add    $0x4,%edx
80101c5e:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c65:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c6a:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c6e:	7e b6                	jle    80101c26 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c76:	85 c0                	test   %eax,%eax
80101c78:	0f 84 9b 00 00 00    	je     80101d19 <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c81:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c84:	8b 45 08             	mov    0x8(%ebp),%eax
80101c87:	8b 00                	mov    (%eax),%eax
80101c89:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c8d:	89 04 24             	mov    %eax,(%esp)
80101c90:	e8 11 e5 ff ff       	call   801001a6 <bread>
80101c95:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c9b:	83 c0 18             	add    $0x18,%eax
80101c9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ca1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ca8:	eb 3b                	jmp    80101ce5 <itrunc+0xce>
      if(a[j])
80101caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cb7:	01 d0                	add    %edx,%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	85 c0                	test   %eax,%eax
80101cbd:	74 22                	je     80101ce1 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ccc:	01 d0                	add    %edx,%eax
80101cce:	8b 10                	mov    (%eax),%edx
80101cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd3:	8b 00                	mov    (%eax),%eax
80101cd5:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cd9:	89 04 24             	mov    %eax,(%esp)
80101cdc:	e8 02 f8 ff ff       	call   801014e3 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ce1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 f8 7f             	cmp    $0x7f,%eax
80101ceb:	76 bd                	jbe    80101caa <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ced:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cf0:	89 04 24             	mov    %eax,(%esp)
80101cf3:	e8 1f e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfb:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	8b 00                	mov    (%eax),%eax
80101d03:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d07:	89 04 24             	mov    %eax,(%esp)
80101d0a:	e8 d4 f7 ff ff       	call   801014e3 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d12:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d19:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1c:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d23:	8b 45 08             	mov    0x8(%ebp),%eax
80101d26:	89 04 24             	mov    %eax,(%esp)
80101d29:	e8 7e f9 ff ff       	call   801016ac <iupdate>
}
80101d2e:	c9                   	leave  
80101d2f:	c3                   	ret    

80101d30 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d30:	55                   	push   %ebp
80101d31:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d33:	8b 45 08             	mov    0x8(%ebp),%eax
80101d36:	8b 00                	mov    (%eax),%eax
80101d38:	89 c2                	mov    %eax,%edx
80101d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d3d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d40:	8b 45 08             	mov    0x8(%ebp),%eax
80101d43:	8b 50 04             	mov    0x4(%eax),%edx
80101d46:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d49:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4f:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d53:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d56:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d63:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d67:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6a:	8b 50 18             	mov    0x18(%eax),%edx
80101d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d70:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d73:	5d                   	pop    %ebp
80101d74:	c3                   	ret    

80101d75 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d75:	55                   	push   %ebp
80101d76:	89 e5                	mov    %esp,%ebp
80101d78:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d82:	66 83 f8 03          	cmp    $0x3,%ax
80101d86:	75 60                	jne    80101de8 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d8f:	66 85 c0             	test   %ax,%ax
80101d92:	78 20                	js     80101db4 <readi+0x3f>
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d9b:	66 83 f8 09          	cmp    $0x9,%ax
80101d9f:	7f 13                	jg     80101db4 <readi+0x3f>
80101da1:	8b 45 08             	mov    0x8(%ebp),%eax
80101da4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101da8:	98                   	cwtl   
80101da9:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101db0:	85 c0                	test   %eax,%eax
80101db2:	75 0a                	jne    80101dbe <readi+0x49>
      return -1;
80101db4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101db9:	e9 19 01 00 00       	jmp    80101ed7 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dc5:	98                   	cwtl   
80101dc6:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101dcd:	8b 55 14             	mov    0x14(%ebp),%edx
80101dd0:	89 54 24 08          	mov    %edx,0x8(%esp)
80101dd4:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dd7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ddb:	8b 55 08             	mov    0x8(%ebp),%edx
80101dde:	89 14 24             	mov    %edx,(%esp)
80101de1:	ff d0                	call   *%eax
80101de3:	e9 ef 00 00 00       	jmp    80101ed7 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101de8:	8b 45 08             	mov    0x8(%ebp),%eax
80101deb:	8b 40 18             	mov    0x18(%eax),%eax
80101dee:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df1:	72 0d                	jb     80101e00 <readi+0x8b>
80101df3:	8b 45 14             	mov    0x14(%ebp),%eax
80101df6:	8b 55 10             	mov    0x10(%ebp),%edx
80101df9:	01 d0                	add    %edx,%eax
80101dfb:	3b 45 10             	cmp    0x10(%ebp),%eax
80101dfe:	73 0a                	jae    80101e0a <readi+0x95>
    return -1;
80101e00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e05:	e9 cd 00 00 00       	jmp    80101ed7 <readi+0x162>
  if(off + n > ip->size)
80101e0a:	8b 45 14             	mov    0x14(%ebp),%eax
80101e0d:	8b 55 10             	mov    0x10(%ebp),%edx
80101e10:	01 c2                	add    %eax,%edx
80101e12:	8b 45 08             	mov    0x8(%ebp),%eax
80101e15:	8b 40 18             	mov    0x18(%eax),%eax
80101e18:	39 c2                	cmp    %eax,%edx
80101e1a:	76 0c                	jbe    80101e28 <readi+0xb3>
    n = ip->size - off;
80101e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1f:	8b 40 18             	mov    0x18(%eax),%eax
80101e22:	2b 45 10             	sub    0x10(%ebp),%eax
80101e25:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e2f:	e9 94 00 00 00       	jmp    80101ec8 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e34:	8b 45 10             	mov    0x10(%ebp),%eax
80101e37:	c1 e8 09             	shr    $0x9,%eax
80101e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e41:	89 04 24             	mov    %eax,(%esp)
80101e44:	e8 c1 fc ff ff       	call   80101b0a <bmap>
80101e49:	8b 55 08             	mov    0x8(%ebp),%edx
80101e4c:	8b 12                	mov    (%edx),%edx
80101e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e52:	89 14 24             	mov    %edx,(%esp)
80101e55:	e8 4c e3 ff ff       	call   801001a6 <bread>
80101e5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e5d:	8b 45 10             	mov    0x10(%ebp),%eax
80101e60:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e65:	89 c2                	mov    %eax,%edx
80101e67:	b8 00 02 00 00       	mov    $0x200,%eax
80101e6c:	29 d0                	sub    %edx,%eax
80101e6e:	89 c2                	mov    %eax,%edx
80101e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e73:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e76:	29 c1                	sub    %eax,%ecx
80101e78:	89 c8                	mov    %ecx,%eax
80101e7a:	39 c2                	cmp    %eax,%edx
80101e7c:	0f 46 c2             	cmovbe %edx,%eax
80101e7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e82:	8b 45 10             	mov    0x10(%ebp),%eax
80101e85:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e8a:	8d 50 10             	lea    0x10(%eax),%edx
80101e8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e90:	01 d0                	add    %edx,%eax
80101e92:	8d 50 08             	lea    0x8(%eax),%edx
80101e95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e98:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e9c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea3:	89 04 24             	mov    %eax,(%esp)
80101ea6:	e8 57 38 00 00       	call   80105702 <memmove>
    brelse(bp);
80101eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eae:	89 04 24             	mov    %eax,(%esp)
80101eb1:	e8 61 e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101eb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb9:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ebc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ebf:	01 45 10             	add    %eax,0x10(%ebp)
80101ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec5:	01 45 0c             	add    %eax,0xc(%ebp)
80101ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ecb:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ece:	0f 82 60 ff ff ff    	jb     80101e34 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ed4:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101ed7:	c9                   	leave  
80101ed8:	c3                   	ret    

80101ed9 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ed9:	55                   	push   %ebp
80101eda:	89 e5                	mov    %esp,%ebp
80101edc:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee6:	66 83 f8 03          	cmp    $0x3,%ax
80101eea:	75 60                	jne    80101f4c <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101eec:	8b 45 08             	mov    0x8(%ebp),%eax
80101eef:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef3:	66 85 c0             	test   %ax,%ax
80101ef6:	78 20                	js     80101f18 <writei+0x3f>
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eff:	66 83 f8 09          	cmp    $0x9,%ax
80101f03:	7f 13                	jg     80101f18 <writei+0x3f>
80101f05:	8b 45 08             	mov    0x8(%ebp),%eax
80101f08:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0c:	98                   	cwtl   
80101f0d:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80101f14:	85 c0                	test   %eax,%eax
80101f16:	75 0a                	jne    80101f22 <writei+0x49>
      return -1;
80101f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1d:	e9 44 01 00 00       	jmp    80102066 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f22:	8b 45 08             	mov    0x8(%ebp),%eax
80101f25:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f29:	98                   	cwtl   
80101f2a:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80101f31:	8b 55 14             	mov    0x14(%ebp),%edx
80101f34:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f38:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f3b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f3f:	8b 55 08             	mov    0x8(%ebp),%edx
80101f42:	89 14 24             	mov    %edx,(%esp)
80101f45:	ff d0                	call   *%eax
80101f47:	e9 1a 01 00 00       	jmp    80102066 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4f:	8b 40 18             	mov    0x18(%eax),%eax
80101f52:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f55:	72 0d                	jb     80101f64 <writei+0x8b>
80101f57:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5a:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5d:	01 d0                	add    %edx,%eax
80101f5f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f62:	73 0a                	jae    80101f6e <writei+0x95>
    return -1;
80101f64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f69:	e9 f8 00 00 00       	jmp    80102066 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f6e:	8b 45 14             	mov    0x14(%ebp),%eax
80101f71:	8b 55 10             	mov    0x10(%ebp),%edx
80101f74:	01 d0                	add    %edx,%eax
80101f76:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f7b:	76 0a                	jbe    80101f87 <writei+0xae>
    return -1;
80101f7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f82:	e9 df 00 00 00       	jmp    80102066 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8e:	e9 9f 00 00 00       	jmp    80102032 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f93:	8b 45 10             	mov    0x10(%ebp),%eax
80101f96:	c1 e8 09             	shr    $0x9,%eax
80101f99:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa0:	89 04 24             	mov    %eax,(%esp)
80101fa3:	e8 62 fb ff ff       	call   80101b0a <bmap>
80101fa8:	8b 55 08             	mov    0x8(%ebp),%edx
80101fab:	8b 12                	mov    (%edx),%edx
80101fad:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fb1:	89 14 24             	mov    %edx,(%esp)
80101fb4:	e8 ed e1 ff ff       	call   801001a6 <bread>
80101fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbc:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbf:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc4:	89 c2                	mov    %eax,%edx
80101fc6:	b8 00 02 00 00       	mov    $0x200,%eax
80101fcb:	29 d0                	sub    %edx,%eax
80101fcd:	89 c2                	mov    %eax,%edx
80101fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fd2:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fd5:	29 c1                	sub    %eax,%ecx
80101fd7:	89 c8                	mov    %ecx,%eax
80101fd9:	39 c2                	cmp    %eax,%edx
80101fdb:	0f 46 c2             	cmovbe %edx,%eax
80101fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fe1:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe4:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe9:	8d 50 10             	lea    0x10(%eax),%edx
80101fec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fef:	01 d0                	add    %edx,%eax
80101ff1:	8d 50 08             	lea    0x8(%eax),%edx
80101ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff7:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
80102002:	89 14 24             	mov    %edx,(%esp)
80102005:	e8 f8 36 00 00       	call   80105702 <memmove>
    log_write(bp);
8010200a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200d:	89 04 24             	mov    %eax,(%esp)
80102010:	e8 13 16 00 00       	call   80103628 <log_write>
    brelse(bp);
80102015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102018:	89 04 24             	mov    %eax,(%esp)
8010201b:	e8 f7 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102020:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102023:	01 45 f4             	add    %eax,-0xc(%ebp)
80102026:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102029:	01 45 10             	add    %eax,0x10(%ebp)
8010202c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202f:	01 45 0c             	add    %eax,0xc(%ebp)
80102032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102035:	3b 45 14             	cmp    0x14(%ebp),%eax
80102038:	0f 82 55 ff ff ff    	jb     80101f93 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010203e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102042:	74 1f                	je     80102063 <writei+0x18a>
80102044:	8b 45 08             	mov    0x8(%ebp),%eax
80102047:	8b 40 18             	mov    0x18(%eax),%eax
8010204a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010204d:	73 14                	jae    80102063 <writei+0x18a>
    ip->size = off;
8010204f:	8b 45 08             	mov    0x8(%ebp),%eax
80102052:	8b 55 10             	mov    0x10(%ebp),%edx
80102055:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	89 04 24             	mov    %eax,(%esp)
8010205e:	e8 49 f6 ff ff       	call   801016ac <iupdate>
  }
  return n;
80102063:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102066:	c9                   	leave  
80102067:	c3                   	ret    

80102068 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102068:	55                   	push   %ebp
80102069:	89 e5                	mov    %esp,%ebp
8010206b:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010206e:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102075:	00 
80102076:	8b 45 0c             	mov    0xc(%ebp),%eax
80102079:	89 44 24 04          	mov    %eax,0x4(%esp)
8010207d:	8b 45 08             	mov    0x8(%ebp),%eax
80102080:	89 04 24             	mov    %eax,(%esp)
80102083:	e8 1d 37 00 00       	call   801057a5 <strncmp>
}
80102088:	c9                   	leave  
80102089:	c3                   	ret    

8010208a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010208a:	55                   	push   %ebp
8010208b:	89 e5                	mov    %esp,%ebp
8010208d:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102090:	8b 45 08             	mov    0x8(%ebp),%eax
80102093:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102097:	66 83 f8 01          	cmp    $0x1,%ax
8010209b:	74 0c                	je     801020a9 <dirlookup+0x1f>
    panic("dirlookup not DIR");
8010209d:	c7 04 24 71 8b 10 80 	movl   $0x80108b71,(%esp)
801020a4:	e8 91 e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020b0:	e9 88 00 00 00       	jmp    8010213d <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020b5:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020bc:	00 
801020bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020c0:	89 44 24 08          	mov    %eax,0x8(%esp)
801020c4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801020cb:	8b 45 08             	mov    0x8(%ebp),%eax
801020ce:	89 04 24             	mov    %eax,(%esp)
801020d1:	e8 9f fc ff ff       	call   80101d75 <readi>
801020d6:	83 f8 10             	cmp    $0x10,%eax
801020d9:	74 0c                	je     801020e7 <dirlookup+0x5d>
      panic("dirlink read");
801020db:	c7 04 24 83 8b 10 80 	movl   $0x80108b83,(%esp)
801020e2:	e8 53 e4 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801020e7:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020eb:	66 85 c0             	test   %ax,%ax
801020ee:	75 02                	jne    801020f2 <dirlookup+0x68>
      continue;
801020f0:	eb 47                	jmp    80102139 <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
801020f2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020f5:	83 c0 02             	add    $0x2,%eax
801020f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801020fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801020ff:	89 04 24             	mov    %eax,(%esp)
80102102:	e8 61 ff ff ff       	call   80102068 <namecmp>
80102107:	85 c0                	test   %eax,%eax
80102109:	75 2e                	jne    80102139 <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010210b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010210f:	74 08                	je     80102119 <dirlookup+0x8f>
        *poff = off;
80102111:	8b 45 10             	mov    0x10(%ebp),%eax
80102114:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102117:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102119:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010211d:	0f b7 c0             	movzwl %ax,%eax
80102120:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102123:	8b 45 08             	mov    0x8(%ebp),%eax
80102126:	8b 00                	mov    (%eax),%eax
80102128:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010212b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010212f:	89 04 24             	mov    %eax,(%esp)
80102132:	e8 2d f6 ff ff       	call   80101764 <iget>
80102137:	eb 18                	jmp    80102151 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102139:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010213d:	8b 45 08             	mov    0x8(%ebp),%eax
80102140:	8b 40 18             	mov    0x18(%eax),%eax
80102143:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102146:	0f 87 69 ff ff ff    	ja     801020b5 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010214c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102151:	c9                   	leave  
80102152:	c3                   	ret    

80102153 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102153:	55                   	push   %ebp
80102154:	89 e5                	mov    %esp,%ebp
80102156:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102159:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102160:	00 
80102161:	8b 45 0c             	mov    0xc(%ebp),%eax
80102164:	89 44 24 04          	mov    %eax,0x4(%esp)
80102168:	8b 45 08             	mov    0x8(%ebp),%eax
8010216b:	89 04 24             	mov    %eax,(%esp)
8010216e:	e8 17 ff ff ff       	call   8010208a <dirlookup>
80102173:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102176:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010217a:	74 15                	je     80102191 <dirlink+0x3e>
    iput(ip);
8010217c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010217f:	89 04 24             	mov    %eax,(%esp)
80102182:	e8 94 f8 ff ff       	call   80101a1b <iput>
    return -1;
80102187:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010218c:	e9 b7 00 00 00       	jmp    80102248 <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102191:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102198:	eb 46                	jmp    801021e0 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010219a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010219d:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021a4:	00 
801021a5:	89 44 24 08          	mov    %eax,0x8(%esp)
801021a9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801021b0:	8b 45 08             	mov    0x8(%ebp),%eax
801021b3:	89 04 24             	mov    %eax,(%esp)
801021b6:	e8 ba fb ff ff       	call   80101d75 <readi>
801021bb:	83 f8 10             	cmp    $0x10,%eax
801021be:	74 0c                	je     801021cc <dirlink+0x79>
      panic("dirlink read");
801021c0:	c7 04 24 83 8b 10 80 	movl   $0x80108b83,(%esp)
801021c7:	e8 6e e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801021cc:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021d0:	66 85 c0             	test   %ax,%ax
801021d3:	75 02                	jne    801021d7 <dirlink+0x84>
      break;
801021d5:	eb 16                	jmp    801021ed <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021da:	83 c0 10             	add    $0x10,%eax
801021dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021e3:	8b 45 08             	mov    0x8(%ebp),%eax
801021e6:	8b 40 18             	mov    0x18(%eax),%eax
801021e9:	39 c2                	cmp    %eax,%edx
801021eb:	72 ad                	jb     8010219a <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801021ed:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021f4:	00 
801021f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801021f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801021fc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021ff:	83 c0 02             	add    $0x2,%eax
80102202:	89 04 24             	mov    %eax,(%esp)
80102205:	e8 f1 35 00 00       	call   801057fb <strncpy>
  de.inum = inum;
8010220a:	8b 45 10             	mov    0x10(%ebp),%eax
8010220d:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102214:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010221b:	00 
8010221c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102220:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102223:	89 44 24 04          	mov    %eax,0x4(%esp)
80102227:	8b 45 08             	mov    0x8(%ebp),%eax
8010222a:	89 04 24             	mov    %eax,(%esp)
8010222d:	e8 a7 fc ff ff       	call   80101ed9 <writei>
80102232:	83 f8 10             	cmp    $0x10,%eax
80102235:	74 0c                	je     80102243 <dirlink+0xf0>
    panic("dirlink");
80102237:	c7 04 24 90 8b 10 80 	movl   $0x80108b90,(%esp)
8010223e:	e8 f7 e2 ff ff       	call   8010053a <panic>
  
  return 0;
80102243:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102248:	c9                   	leave  
80102249:	c3                   	ret    

8010224a <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010224a:	55                   	push   %ebp
8010224b:	89 e5                	mov    %esp,%ebp
8010224d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102250:	eb 04                	jmp    80102256 <skipelem+0xc>
    path++;
80102252:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102256:	8b 45 08             	mov    0x8(%ebp),%eax
80102259:	0f b6 00             	movzbl (%eax),%eax
8010225c:	3c 2f                	cmp    $0x2f,%al
8010225e:	74 f2                	je     80102252 <skipelem+0x8>
    path++;
  if(*path == 0)
80102260:	8b 45 08             	mov    0x8(%ebp),%eax
80102263:	0f b6 00             	movzbl (%eax),%eax
80102266:	84 c0                	test   %al,%al
80102268:	75 0a                	jne    80102274 <skipelem+0x2a>
    return 0;
8010226a:	b8 00 00 00 00       	mov    $0x0,%eax
8010226f:	e9 86 00 00 00       	jmp    801022fa <skipelem+0xb0>
  s = path;
80102274:	8b 45 08             	mov    0x8(%ebp),%eax
80102277:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010227a:	eb 04                	jmp    80102280 <skipelem+0x36>
    path++;
8010227c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102280:	8b 45 08             	mov    0x8(%ebp),%eax
80102283:	0f b6 00             	movzbl (%eax),%eax
80102286:	3c 2f                	cmp    $0x2f,%al
80102288:	74 0a                	je     80102294 <skipelem+0x4a>
8010228a:	8b 45 08             	mov    0x8(%ebp),%eax
8010228d:	0f b6 00             	movzbl (%eax),%eax
80102290:	84 c0                	test   %al,%al
80102292:	75 e8                	jne    8010227c <skipelem+0x32>
    path++;
  len = path - s;
80102294:	8b 55 08             	mov    0x8(%ebp),%edx
80102297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229a:	29 c2                	sub    %eax,%edx
8010229c:	89 d0                	mov    %edx,%eax
8010229e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022a1:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022a5:	7e 1c                	jle    801022c3 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
801022a7:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022ae:	00 
801022af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801022b9:	89 04 24             	mov    %eax,(%esp)
801022bc:	e8 41 34 00 00       	call   80105702 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022c1:	eb 2a                	jmp    801022ed <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022c6:	89 44 24 08          	mov    %eax,0x8(%esp)
801022ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d4:	89 04 24             	mov    %eax,(%esp)
801022d7:	e8 26 34 00 00       	call   80105702 <memmove>
    name[len] = 0;
801022dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022df:	8b 45 0c             	mov    0xc(%ebp),%eax
801022e2:	01 d0                	add    %edx,%eax
801022e4:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022e7:	eb 04                	jmp    801022ed <skipelem+0xa3>
    path++;
801022e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022ed:	8b 45 08             	mov    0x8(%ebp),%eax
801022f0:	0f b6 00             	movzbl (%eax),%eax
801022f3:	3c 2f                	cmp    $0x2f,%al
801022f5:	74 f2                	je     801022e9 <skipelem+0x9f>
    path++;
  return path;
801022f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022fa:	c9                   	leave  
801022fb:	c3                   	ret    

801022fc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022fc:	55                   	push   %ebp
801022fd:	89 e5                	mov    %esp,%ebp
801022ff:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	0f b6 00             	movzbl (%eax),%eax
80102308:	3c 2f                	cmp    $0x2f,%al
8010230a:	75 1c                	jne    80102328 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010230c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102313:	00 
80102314:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010231b:	e8 44 f4 ff ff       	call   80101764 <iget>
80102320:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102323:	e9 af 00 00 00       	jmp    801023d7 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102328:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010232e:	8b 40 68             	mov    0x68(%eax),%eax
80102331:	89 04 24             	mov    %eax,(%esp)
80102334:	e8 fd f4 ff ff       	call   80101836 <idup>
80102339:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010233c:	e9 96 00 00 00       	jmp    801023d7 <namex+0xdb>
    ilock(ip);
80102341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102344:	89 04 24             	mov    %eax,(%esp)
80102347:	e8 1c f5 ff ff       	call   80101868 <ilock>
    if(ip->type != T_DIR){
8010234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102353:	66 83 f8 01          	cmp    $0x1,%ax
80102357:	74 15                	je     8010236e <namex+0x72>
      iunlockput(ip);
80102359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235c:	89 04 24             	mov    %eax,(%esp)
8010235f:	e8 88 f7 ff ff       	call   80101aec <iunlockput>
      return 0;
80102364:	b8 00 00 00 00       	mov    $0x0,%eax
80102369:	e9 a3 00 00 00       	jmp    80102411 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
8010236e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102372:	74 1d                	je     80102391 <namex+0x95>
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 13                	jne    80102391 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
8010237e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102381:	89 04 24             	mov    %eax,(%esp)
80102384:	e8 2d f6 ff ff       	call   801019b6 <iunlock>
      return ip;
80102389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238c:	e9 80 00 00 00       	jmp    80102411 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102391:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102398:	00 
80102399:	8b 45 10             	mov    0x10(%ebp),%eax
8010239c:	89 44 24 04          	mov    %eax,0x4(%esp)
801023a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a3:	89 04 24             	mov    %eax,(%esp)
801023a6:	e8 df fc ff ff       	call   8010208a <dirlookup>
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023b2:	75 12                	jne    801023c6 <namex+0xca>
      iunlockput(ip);
801023b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b7:	89 04 24             	mov    %eax,(%esp)
801023ba:	e8 2d f7 ff ff       	call   80101aec <iunlockput>
      return 0;
801023bf:	b8 00 00 00 00       	mov    $0x0,%eax
801023c4:	eb 4b                	jmp    80102411 <namex+0x115>
    }
    iunlockput(ip);
801023c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c9:	89 04 24             	mov    %eax,(%esp)
801023cc:	e8 1b f7 ff ff       	call   80101aec <iunlockput>
    ip = next;
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023d7:	8b 45 10             	mov    0x10(%ebp),%eax
801023da:	89 44 24 04          	mov    %eax,0x4(%esp)
801023de:	8b 45 08             	mov    0x8(%ebp),%eax
801023e1:	89 04 24             	mov    %eax,(%esp)
801023e4:	e8 61 fe ff ff       	call   8010224a <skipelem>
801023e9:	89 45 08             	mov    %eax,0x8(%ebp)
801023ec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023f0:	0f 85 4b ff ff ff    	jne    80102341 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023fa:	74 12                	je     8010240e <namex+0x112>
    iput(ip);
801023fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ff:	89 04 24             	mov    %eax,(%esp)
80102402:	e8 14 f6 ff ff       	call   80101a1b <iput>
    return 0;
80102407:	b8 00 00 00 00       	mov    $0x0,%eax
8010240c:	eb 03                	jmp    80102411 <namex+0x115>
  }
  return ip;
8010240e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102411:	c9                   	leave  
80102412:	c3                   	ret    

80102413 <namei>:

struct inode*
namei(char *path)
{
80102413:	55                   	push   %ebp
80102414:	89 e5                	mov    %esp,%ebp
80102416:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102419:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010241c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102420:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102427:	00 
80102428:	8b 45 08             	mov    0x8(%ebp),%eax
8010242b:	89 04 24             	mov    %eax,(%esp)
8010242e:	e8 c9 fe ff ff       	call   801022fc <namex>
}
80102433:	c9                   	leave  
80102434:	c3                   	ret    

80102435 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102435:	55                   	push   %ebp
80102436:	89 e5                	mov    %esp,%ebp
80102438:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010243b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010243e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102442:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102449:	00 
8010244a:	8b 45 08             	mov    0x8(%ebp),%eax
8010244d:	89 04 24             	mov    %eax,(%esp)
80102450:	e8 a7 fe ff ff       	call   801022fc <namex>
}
80102455:	c9                   	leave  
80102456:	c3                   	ret    

80102457 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102457:	55                   	push   %ebp
80102458:	89 e5                	mov    %esp,%ebp
8010245a:	83 ec 14             	sub    $0x14,%esp
8010245d:	8b 45 08             	mov    0x8(%ebp),%eax
80102460:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102464:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102468:	89 c2                	mov    %eax,%edx
8010246a:	ec                   	in     (%dx),%al
8010246b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010246e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102472:	c9                   	leave  
80102473:	c3                   	ret    

80102474 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102474:	55                   	push   %ebp
80102475:	89 e5                	mov    %esp,%ebp
80102477:	57                   	push   %edi
80102478:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102479:	8b 55 08             	mov    0x8(%ebp),%edx
8010247c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010247f:	8b 45 10             	mov    0x10(%ebp),%eax
80102482:	89 cb                	mov    %ecx,%ebx
80102484:	89 df                	mov    %ebx,%edi
80102486:	89 c1                	mov    %eax,%ecx
80102488:	fc                   	cld    
80102489:	f3 6d                	rep insl (%dx),%es:(%edi)
8010248b:	89 c8                	mov    %ecx,%eax
8010248d:	89 fb                	mov    %edi,%ebx
8010248f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102492:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102495:	5b                   	pop    %ebx
80102496:	5f                   	pop    %edi
80102497:	5d                   	pop    %ebp
80102498:	c3                   	ret    

80102499 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102499:	55                   	push   %ebp
8010249a:	89 e5                	mov    %esp,%ebp
8010249c:	83 ec 08             	sub    $0x8,%esp
8010249f:	8b 55 08             	mov    0x8(%ebp),%edx
801024a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801024a5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024b4:	ee                   	out    %al,(%dx)
}
801024b5:	c9                   	leave  
801024b6:	c3                   	ret    

801024b7 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024b7:	55                   	push   %ebp
801024b8:	89 e5                	mov    %esp,%ebp
801024ba:	56                   	push   %esi
801024bb:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024bc:	8b 55 08             	mov    0x8(%ebp),%edx
801024bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024c2:	8b 45 10             	mov    0x10(%ebp),%eax
801024c5:	89 cb                	mov    %ecx,%ebx
801024c7:	89 de                	mov    %ebx,%esi
801024c9:	89 c1                	mov    %eax,%ecx
801024cb:	fc                   	cld    
801024cc:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024ce:	89 c8                	mov    %ecx,%eax
801024d0:	89 f3                	mov    %esi,%ebx
801024d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024d5:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024d8:	5b                   	pop    %ebx
801024d9:	5e                   	pop    %esi
801024da:	5d                   	pop    %ebp
801024db:	c3                   	ret    

801024dc <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024dc:	55                   	push   %ebp
801024dd:	89 e5                	mov    %esp,%ebp
801024df:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024e2:	90                   	nop
801024e3:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024ea:	e8 68 ff ff ff       	call   80102457 <inb>
801024ef:	0f b6 c0             	movzbl %al,%eax
801024f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024f8:	25 c0 00 00 00       	and    $0xc0,%eax
801024fd:	83 f8 40             	cmp    $0x40,%eax
80102500:	75 e1                	jne    801024e3 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102502:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102506:	74 11                	je     80102519 <idewait+0x3d>
80102508:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010250b:	83 e0 21             	and    $0x21,%eax
8010250e:	85 c0                	test   %eax,%eax
80102510:	74 07                	je     80102519 <idewait+0x3d>
    return -1;
80102512:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102517:	eb 05                	jmp    8010251e <idewait+0x42>
  return 0;
80102519:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010251e:	c9                   	leave  
8010251f:	c3                   	ret    

80102520 <ideinit>:

void
ideinit(void)
{
80102520:	55                   	push   %ebp
80102521:	89 e5                	mov    %esp,%ebp
80102523:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102526:	c7 44 24 04 98 8b 10 	movl   $0x80108b98,0x4(%esp)
8010252d:	80 
8010252e:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102535:	e8 84 2e 00 00       	call   801053be <initlock>
  picenable(IRQ_IDE);
8010253a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102541:	e8 7b 18 00 00       	call   80103dc1 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102546:	a1 60 39 11 80       	mov    0x80113960,%eax
8010254b:	83 e8 01             	sub    $0x1,%eax
8010254e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102552:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102559:	e8 0c 04 00 00       	call   8010296a <ioapicenable>
  idewait(0);
8010255e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102565:	e8 72 ff ff ff       	call   801024dc <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010256a:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102571:	00 
80102572:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102579:	e8 1b ff ff ff       	call   80102499 <outb>
  for(i=0; i<1000; i++){
8010257e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102585:	eb 20                	jmp    801025a7 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102587:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010258e:	e8 c4 fe ff ff       	call   80102457 <inb>
80102593:	84 c0                	test   %al,%al
80102595:	74 0c                	je     801025a3 <ideinit+0x83>
      havedisk1 = 1;
80102597:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
8010259e:	00 00 00 
      break;
801025a1:	eb 0d                	jmp    801025b0 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025a7:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025ae:	7e d7                	jle    80102587 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025b0:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025b7:	00 
801025b8:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025bf:	e8 d5 fe ff ff       	call   80102499 <outb>
}
801025c4:	c9                   	leave  
801025c5:	c3                   	ret    

801025c6 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025c6:	55                   	push   %ebp
801025c7:	89 e5                	mov    %esp,%ebp
801025c9:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025cc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025d0:	75 0c                	jne    801025de <idestart+0x18>
    panic("idestart");
801025d2:	c7 04 24 9c 8b 10 80 	movl   $0x80108b9c,(%esp)
801025d9:	e8 5c df ff ff       	call   8010053a <panic>

  idewait(0);
801025de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025e5:	e8 f2 fe ff ff       	call   801024dc <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025f1:	00 
801025f2:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025f9:	e8 9b fe ff ff       	call   80102499 <outb>
  outb(0x1f2, 1);  // number of sectors
801025fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102605:	00 
80102606:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010260d:	e8 87 fe ff ff       	call   80102499 <outb>
  outb(0x1f3, b->sector & 0xff);
80102612:	8b 45 08             	mov    0x8(%ebp),%eax
80102615:	8b 40 08             	mov    0x8(%eax),%eax
80102618:	0f b6 c0             	movzbl %al,%eax
8010261b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010261f:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102626:	e8 6e fe ff ff       	call   80102499 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010262b:	8b 45 08             	mov    0x8(%ebp),%eax
8010262e:	8b 40 08             	mov    0x8(%eax),%eax
80102631:	c1 e8 08             	shr    $0x8,%eax
80102634:	0f b6 c0             	movzbl %al,%eax
80102637:	89 44 24 04          	mov    %eax,0x4(%esp)
8010263b:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102642:	e8 52 fe ff ff       	call   80102499 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102647:	8b 45 08             	mov    0x8(%ebp),%eax
8010264a:	8b 40 08             	mov    0x8(%eax),%eax
8010264d:	c1 e8 10             	shr    $0x10,%eax
80102650:	0f b6 c0             	movzbl %al,%eax
80102653:	89 44 24 04          	mov    %eax,0x4(%esp)
80102657:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010265e:	e8 36 fe ff ff       	call   80102499 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102663:	8b 45 08             	mov    0x8(%ebp),%eax
80102666:	8b 40 04             	mov    0x4(%eax),%eax
80102669:	83 e0 01             	and    $0x1,%eax
8010266c:	c1 e0 04             	shl    $0x4,%eax
8010266f:	89 c2                	mov    %eax,%edx
80102671:	8b 45 08             	mov    0x8(%ebp),%eax
80102674:	8b 40 08             	mov    0x8(%eax),%eax
80102677:	c1 e8 18             	shr    $0x18,%eax
8010267a:	83 e0 0f             	and    $0xf,%eax
8010267d:	09 d0                	or     %edx,%eax
8010267f:	83 c8 e0             	or     $0xffffffe0,%eax
80102682:	0f b6 c0             	movzbl %al,%eax
80102685:	89 44 24 04          	mov    %eax,0x4(%esp)
80102689:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102690:	e8 04 fe ff ff       	call   80102499 <outb>
  if(b->flags & B_DIRTY){
80102695:	8b 45 08             	mov    0x8(%ebp),%eax
80102698:	8b 00                	mov    (%eax),%eax
8010269a:	83 e0 04             	and    $0x4,%eax
8010269d:	85 c0                	test   %eax,%eax
8010269f:	74 34                	je     801026d5 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026a1:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026a8:	00 
801026a9:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026b0:	e8 e4 fd ff ff       	call   80102499 <outb>
    outsl(0x1f0, b->data, 512/4);
801026b5:	8b 45 08             	mov    0x8(%ebp),%eax
801026b8:	83 c0 18             	add    $0x18,%eax
801026bb:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026c2:	00 
801026c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801026c7:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026ce:	e8 e4 fd ff ff       	call   801024b7 <outsl>
801026d3:	eb 14                	jmp    801026e9 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026d5:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026dc:	00 
801026dd:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026e4:	e8 b0 fd ff ff       	call   80102499 <outb>
  }
}
801026e9:	c9                   	leave  
801026ea:	c3                   	ret    

801026eb <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026eb:	55                   	push   %ebp
801026ec:	89 e5                	mov    %esp,%ebp
801026ee:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026f1:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801026f8:	e8 e2 2c 00 00       	call   801053df <acquire>
  if((b = idequeue) == 0){
801026fd:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102702:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102705:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102709:	75 11                	jne    8010271c <ideintr+0x31>
    release(&idelock);
8010270b:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102712:	e8 2a 2d 00 00       	call   80105441 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102717:	e9 90 00 00 00       	jmp    801027ac <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010271c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271f:	8b 40 14             	mov    0x14(%eax),%eax
80102722:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272a:	8b 00                	mov    (%eax),%eax
8010272c:	83 e0 04             	and    $0x4,%eax
8010272f:	85 c0                	test   %eax,%eax
80102731:	75 2e                	jne    80102761 <ideintr+0x76>
80102733:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010273a:	e8 9d fd ff ff       	call   801024dc <idewait>
8010273f:	85 c0                	test   %eax,%eax
80102741:	78 1e                	js     80102761 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102746:	83 c0 18             	add    $0x18,%eax
80102749:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102750:	00 
80102751:	89 44 24 04          	mov    %eax,0x4(%esp)
80102755:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010275c:	e8 13 fd ff ff       	call   80102474 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102764:	8b 00                	mov    (%eax),%eax
80102766:	83 c8 02             	or     $0x2,%eax
80102769:	89 c2                	mov    %eax,%edx
8010276b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276e:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102773:	8b 00                	mov    (%eax),%eax
80102775:	83 e0 fb             	and    $0xfffffffb,%eax
80102778:	89 c2                	mov    %eax,%edx
8010277a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277d:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010277f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102782:	89 04 24             	mov    %eax,(%esp)
80102785:	e8 ad 25 00 00       	call   80104d37 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010278a:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010278f:	85 c0                	test   %eax,%eax
80102791:	74 0d                	je     801027a0 <ideintr+0xb5>
    idestart(idequeue);
80102793:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102798:	89 04 24             	mov    %eax,(%esp)
8010279b:	e8 26 fe ff ff       	call   801025c6 <idestart>

  release(&idelock);
801027a0:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801027a7:	e8 95 2c 00 00       	call   80105441 <release>
}
801027ac:	c9                   	leave  
801027ad:	c3                   	ret    

801027ae <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027ae:	55                   	push   %ebp
801027af:	89 e5                	mov    %esp,%ebp
801027b1:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027b4:	8b 45 08             	mov    0x8(%ebp),%eax
801027b7:	8b 00                	mov    (%eax),%eax
801027b9:	83 e0 01             	and    $0x1,%eax
801027bc:	85 c0                	test   %eax,%eax
801027be:	75 0c                	jne    801027cc <iderw+0x1e>
    panic("iderw: buf not busy");
801027c0:	c7 04 24 a5 8b 10 80 	movl   $0x80108ba5,(%esp)
801027c7:	e8 6e dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027cc:	8b 45 08             	mov    0x8(%ebp),%eax
801027cf:	8b 00                	mov    (%eax),%eax
801027d1:	83 e0 06             	and    $0x6,%eax
801027d4:	83 f8 02             	cmp    $0x2,%eax
801027d7:	75 0c                	jne    801027e5 <iderw+0x37>
    panic("iderw: nothing to do");
801027d9:	c7 04 24 b9 8b 10 80 	movl   $0x80108bb9,(%esp)
801027e0:	e8 55 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027e5:	8b 45 08             	mov    0x8(%ebp),%eax
801027e8:	8b 40 04             	mov    0x4(%eax),%eax
801027eb:	85 c0                	test   %eax,%eax
801027ed:	74 15                	je     80102804 <iderw+0x56>
801027ef:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801027f4:	85 c0                	test   %eax,%eax
801027f6:	75 0c                	jne    80102804 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027f8:	c7 04 24 ce 8b 10 80 	movl   $0x80108bce,(%esp)
801027ff:	e8 36 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102804:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
8010280b:	e8 cf 2b 00 00       	call   801053df <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102810:	8b 45 08             	mov    0x8(%ebp),%eax
80102813:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010281a:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102821:	eb 0b                	jmp    8010282e <iderw+0x80>
80102823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102826:	8b 00                	mov    (%eax),%eax
80102828:	83 c0 14             	add    $0x14,%eax
8010282b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010282e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102831:	8b 00                	mov    (%eax),%eax
80102833:	85 c0                	test   %eax,%eax
80102835:	75 ec                	jne    80102823 <iderw+0x75>
    ;
  *pp = b;
80102837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010283a:	8b 55 08             	mov    0x8(%ebp),%edx
8010283d:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
8010283f:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102844:	3b 45 08             	cmp    0x8(%ebp),%eax
80102847:	75 0d                	jne    80102856 <iderw+0xa8>
    idestart(b);
80102849:	8b 45 08             	mov    0x8(%ebp),%eax
8010284c:	89 04 24             	mov    %eax,(%esp)
8010284f:	e8 72 fd ff ff       	call   801025c6 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102854:	eb 15                	jmp    8010286b <iderw+0xbd>
80102856:	eb 13                	jmp    8010286b <iderw+0xbd>
    sleep(b, &idelock);
80102858:	c7 44 24 04 20 c6 10 	movl   $0x8010c620,0x4(%esp)
8010285f:	80 
80102860:	8b 45 08             	mov    0x8(%ebp),%eax
80102863:	89 04 24             	mov    %eax,(%esp)
80102866:	e8 f1 23 00 00       	call   80104c5c <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010286b:	8b 45 08             	mov    0x8(%ebp),%eax
8010286e:	8b 00                	mov    (%eax),%eax
80102870:	83 e0 06             	and    $0x6,%eax
80102873:	83 f8 02             	cmp    $0x2,%eax
80102876:	75 e0                	jne    80102858 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80102878:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
8010287f:	e8 bd 2b 00 00       	call   80105441 <release>
}
80102884:	c9                   	leave  
80102885:	c3                   	ret    

80102886 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102886:	55                   	push   %ebp
80102887:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102889:	a1 34 32 11 80       	mov    0x80113234,%eax
8010288e:	8b 55 08             	mov    0x8(%ebp),%edx
80102891:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102893:	a1 34 32 11 80       	mov    0x80113234,%eax
80102898:	8b 40 10             	mov    0x10(%eax),%eax
}
8010289b:	5d                   	pop    %ebp
8010289c:	c3                   	ret    

8010289d <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010289d:	55                   	push   %ebp
8010289e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028a0:	a1 34 32 11 80       	mov    0x80113234,%eax
801028a5:	8b 55 08             	mov    0x8(%ebp),%edx
801028a8:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028aa:	a1 34 32 11 80       	mov    0x80113234,%eax
801028af:	8b 55 0c             	mov    0xc(%ebp),%edx
801028b2:	89 50 10             	mov    %edx,0x10(%eax)
}
801028b5:	5d                   	pop    %ebp
801028b6:	c3                   	ret    

801028b7 <ioapicinit>:

void
ioapicinit(void)
{
801028b7:	55                   	push   %ebp
801028b8:	89 e5                	mov    %esp,%ebp
801028ba:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028bd:	a1 64 33 11 80       	mov    0x80113364,%eax
801028c2:	85 c0                	test   %eax,%eax
801028c4:	75 05                	jne    801028cb <ioapicinit+0x14>
    return;
801028c6:	e9 9d 00 00 00       	jmp    80102968 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028cb:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
801028d2:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028dc:	e8 a5 ff ff ff       	call   80102886 <ioapicread>
801028e1:	c1 e8 10             	shr    $0x10,%eax
801028e4:	25 ff 00 00 00       	and    $0xff,%eax
801028e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028f3:	e8 8e ff ff ff       	call   80102886 <ioapicread>
801028f8:	c1 e8 18             	shr    $0x18,%eax
801028fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801028fe:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102905:	0f b6 c0             	movzbl %al,%eax
80102908:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010290b:	74 0c                	je     80102919 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010290d:	c7 04 24 ec 8b 10 80 	movl   $0x80108bec,(%esp)
80102914:	e8 87 da ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102919:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102920:	eb 3e                	jmp    80102960 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102925:	83 c0 20             	add    $0x20,%eax
80102928:	0d 00 00 01 00       	or     $0x10000,%eax
8010292d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102930:	83 c2 08             	add    $0x8,%edx
80102933:	01 d2                	add    %edx,%edx
80102935:	89 44 24 04          	mov    %eax,0x4(%esp)
80102939:	89 14 24             	mov    %edx,(%esp)
8010293c:	e8 5c ff ff ff       	call   8010289d <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102944:	83 c0 08             	add    $0x8,%eax
80102947:	01 c0                	add    %eax,%eax
80102949:	83 c0 01             	add    $0x1,%eax
8010294c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102953:	00 
80102954:	89 04 24             	mov    %eax,(%esp)
80102957:	e8 41 ff ff ff       	call   8010289d <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010295c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102963:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102966:	7e ba                	jle    80102922 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102968:	c9                   	leave  
80102969:	c3                   	ret    

8010296a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010296a:	55                   	push   %ebp
8010296b:	89 e5                	mov    %esp,%ebp
8010296d:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102970:	a1 64 33 11 80       	mov    0x80113364,%eax
80102975:	85 c0                	test   %eax,%eax
80102977:	75 02                	jne    8010297b <ioapicenable+0x11>
    return;
80102979:	eb 37                	jmp    801029b2 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010297b:	8b 45 08             	mov    0x8(%ebp),%eax
8010297e:	83 c0 20             	add    $0x20,%eax
80102981:	8b 55 08             	mov    0x8(%ebp),%edx
80102984:	83 c2 08             	add    $0x8,%edx
80102987:	01 d2                	add    %edx,%edx
80102989:	89 44 24 04          	mov    %eax,0x4(%esp)
8010298d:	89 14 24             	mov    %edx,(%esp)
80102990:	e8 08 ff ff ff       	call   8010289d <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102995:	8b 45 0c             	mov    0xc(%ebp),%eax
80102998:	c1 e0 18             	shl    $0x18,%eax
8010299b:	8b 55 08             	mov    0x8(%ebp),%edx
8010299e:	83 c2 08             	add    $0x8,%edx
801029a1:	01 d2                	add    %edx,%edx
801029a3:	83 c2 01             	add    $0x1,%edx
801029a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801029aa:	89 14 24             	mov    %edx,(%esp)
801029ad:	e8 eb fe ff ff       	call   8010289d <ioapicwrite>
}
801029b2:	c9                   	leave  
801029b3:	c3                   	ret    

801029b4 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029b4:	55                   	push   %ebp
801029b5:	89 e5                	mov    %esp,%ebp
801029b7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ba:	05 00 00 00 80       	add    $0x80000000,%eax
801029bf:	5d                   	pop    %ebp
801029c0:	c3                   	ret    

801029c1 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029c1:	55                   	push   %ebp
801029c2:	89 e5                	mov    %esp,%ebp
801029c4:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029c7:	c7 44 24 04 1e 8c 10 	movl   $0x80108c1e,0x4(%esp)
801029ce:	80 
801029cf:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
801029d6:	e8 e3 29 00 00       	call   801053be <initlock>
  kmem.use_lock = 0;
801029db:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
801029e2:	00 00 00 
  freerange(vstart, vend);
801029e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801029e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ec:	8b 45 08             	mov    0x8(%ebp),%eax
801029ef:	89 04 24             	mov    %eax,(%esp)
801029f2:	e8 26 00 00 00       	call   80102a1d <freerange>
}
801029f7:	c9                   	leave  
801029f8:	c3                   	ret    

801029f9 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801029f9:	55                   	push   %ebp
801029fa:	89 e5                	mov    %esp,%ebp
801029fc:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801029ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a02:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a06:	8b 45 08             	mov    0x8(%ebp),%eax
80102a09:	89 04 24             	mov    %eax,(%esp)
80102a0c:	e8 0c 00 00 00       	call   80102a1d <freerange>
  kmem.use_lock = 1;
80102a11:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102a18:	00 00 00 
}
80102a1b:	c9                   	leave  
80102a1c:	c3                   	ret    

80102a1d <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a1d:	55                   	push   %ebp
80102a1e:	89 e5                	mov    %esp,%ebp
80102a20:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a23:	8b 45 08             	mov    0x8(%ebp),%eax
80102a26:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a33:	eb 12                	jmp    80102a47 <freerange+0x2a>
    kfree(p);
80102a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a38:	89 04 24             	mov    %eax,(%esp)
80102a3b:	e8 16 00 00 00       	call   80102a56 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a40:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4a:	05 00 10 00 00       	add    $0x1000,%eax
80102a4f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a52:	76 e1                	jbe    80102a35 <freerange+0x18>
    kfree(p);
}
80102a54:	c9                   	leave  
80102a55:	c3                   	ret    

80102a56 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a56:	55                   	push   %ebp
80102a57:	89 e5                	mov    %esp,%ebp
80102a59:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a64:	85 c0                	test   %eax,%eax
80102a66:	75 1b                	jne    80102a83 <kfree+0x2d>
80102a68:	81 7d 08 5c a9 11 80 	cmpl   $0x8011a95c,0x8(%ebp)
80102a6f:	72 12                	jb     80102a83 <kfree+0x2d>
80102a71:	8b 45 08             	mov    0x8(%ebp),%eax
80102a74:	89 04 24             	mov    %eax,(%esp)
80102a77:	e8 38 ff ff ff       	call   801029b4 <v2p>
80102a7c:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a81:	76 0c                	jbe    80102a8f <kfree+0x39>
    panic("kfree");
80102a83:	c7 04 24 23 8c 10 80 	movl   $0x80108c23,(%esp)
80102a8a:	e8 ab da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a8f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a96:	00 
80102a97:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a9e:	00 
80102a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa2:	89 04 24             	mov    %eax,(%esp)
80102aa5:	e8 89 2b 00 00       	call   80105633 <memset>

  if(kmem.use_lock)
80102aaa:	a1 74 32 11 80       	mov    0x80113274,%eax
80102aaf:	85 c0                	test   %eax,%eax
80102ab1:	74 0c                	je     80102abf <kfree+0x69>
    acquire(&kmem.lock);
80102ab3:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102aba:	e8 20 29 00 00       	call   801053df <acquire>
  r = (struct run*)v;
80102abf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ac5:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ace:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad3:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102ad8:	a1 74 32 11 80       	mov    0x80113274,%eax
80102add:	85 c0                	test   %eax,%eax
80102adf:	74 0c                	je     80102aed <kfree+0x97>
    release(&kmem.lock);
80102ae1:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102ae8:	e8 54 29 00 00       	call   80105441 <release>
}
80102aed:	c9                   	leave  
80102aee:	c3                   	ret    

80102aef <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102aef:	55                   	push   %ebp
80102af0:	89 e5                	mov    %esp,%ebp
80102af2:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102af5:	a1 74 32 11 80       	mov    0x80113274,%eax
80102afa:	85 c0                	test   %eax,%eax
80102afc:	74 0c                	je     80102b0a <kalloc+0x1b>
    acquire(&kmem.lock);
80102afe:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b05:	e8 d5 28 00 00       	call   801053df <acquire>
  r = kmem.freelist;
80102b0a:	a1 78 32 11 80       	mov    0x80113278,%eax
80102b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b16:	74 0a                	je     80102b22 <kalloc+0x33>
    kmem.freelist = r->next;
80102b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1b:	8b 00                	mov    (%eax),%eax
80102b1d:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102b22:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b27:	85 c0                	test   %eax,%eax
80102b29:	74 0c                	je     80102b37 <kalloc+0x48>
    release(&kmem.lock);
80102b2b:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b32:	e8 0a 29 00 00       	call   80105441 <release>
  return (char*)r;
80102b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b3a:	c9                   	leave  
80102b3b:	c3                   	ret    

80102b3c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b3c:	55                   	push   %ebp
80102b3d:	89 e5                	mov    %esp,%ebp
80102b3f:	83 ec 14             	sub    $0x14,%esp
80102b42:	8b 45 08             	mov    0x8(%ebp),%eax
80102b45:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b49:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102b4d:	89 c2                	mov    %eax,%edx
80102b4f:	ec                   	in     (%dx),%al
80102b50:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102b53:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b57:	c9                   	leave  
80102b58:	c3                   	ret    

80102b59 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b59:	55                   	push   %ebp
80102b5a:	89 e5                	mov    %esp,%ebp
80102b5c:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b5f:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b66:	e8 d1 ff ff ff       	call   80102b3c <inb>
80102b6b:	0f b6 c0             	movzbl %al,%eax
80102b6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b74:	83 e0 01             	and    $0x1,%eax
80102b77:	85 c0                	test   %eax,%eax
80102b79:	75 0a                	jne    80102b85 <kbdgetc+0x2c>
    return -1;
80102b7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b80:	e9 25 01 00 00       	jmp    80102caa <kbdgetc+0x151>
  data = inb(KBDATAP);
80102b85:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b8c:	e8 ab ff ff ff       	call   80102b3c <inb>
80102b91:	0f b6 c0             	movzbl %al,%eax
80102b94:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102b97:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102b9e:	75 17                	jne    80102bb7 <kbdgetc+0x5e>
    shift |= E0ESC;
80102ba0:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ba5:	83 c8 40             	or     $0x40,%eax
80102ba8:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102bad:	b8 00 00 00 00       	mov    $0x0,%eax
80102bb2:	e9 f3 00 00 00       	jmp    80102caa <kbdgetc+0x151>
  } else if(data & 0x80){
80102bb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bba:	25 80 00 00 00       	and    $0x80,%eax
80102bbf:	85 c0                	test   %eax,%eax
80102bc1:	74 45                	je     80102c08 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bc3:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102bc8:	83 e0 40             	and    $0x40,%eax
80102bcb:	85 c0                	test   %eax,%eax
80102bcd:	75 08                	jne    80102bd7 <kbdgetc+0x7e>
80102bcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bd2:	83 e0 7f             	and    $0x7f,%eax
80102bd5:	eb 03                	jmp    80102bda <kbdgetc+0x81>
80102bd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bda:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102bdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102be0:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102be5:	0f b6 00             	movzbl (%eax),%eax
80102be8:	83 c8 40             	or     $0x40,%eax
80102beb:	0f b6 c0             	movzbl %al,%eax
80102bee:	f7 d0                	not    %eax
80102bf0:	89 c2                	mov    %eax,%edx
80102bf2:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102bf7:	21 d0                	and    %edx,%eax
80102bf9:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102bfe:	b8 00 00 00 00       	mov    $0x0,%eax
80102c03:	e9 a2 00 00 00       	jmp    80102caa <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102c08:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c0d:	83 e0 40             	and    $0x40,%eax
80102c10:	85 c0                	test   %eax,%eax
80102c12:	74 14                	je     80102c28 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c14:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c1b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c20:	83 e0 bf             	and    $0xffffffbf,%eax
80102c23:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102c28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c2b:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c30:	0f b6 00             	movzbl (%eax),%eax
80102c33:	0f b6 d0             	movzbl %al,%edx
80102c36:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c3b:	09 d0                	or     %edx,%eax
80102c3d:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c45:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102c4a:	0f b6 00             	movzbl (%eax),%eax
80102c4d:	0f b6 d0             	movzbl %al,%edx
80102c50:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c55:	31 d0                	xor    %edx,%eax
80102c57:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c5c:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c61:	83 e0 03             	and    $0x3,%eax
80102c64:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102c6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6e:	01 d0                	add    %edx,%eax
80102c70:	0f b6 00             	movzbl (%eax),%eax
80102c73:	0f b6 c0             	movzbl %al,%eax
80102c76:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c79:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c7e:	83 e0 08             	and    $0x8,%eax
80102c81:	85 c0                	test   %eax,%eax
80102c83:	74 22                	je     80102ca7 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102c85:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c89:	76 0c                	jbe    80102c97 <kbdgetc+0x13e>
80102c8b:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102c8f:	77 06                	ja     80102c97 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102c91:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102c95:	eb 10                	jmp    80102ca7 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102c97:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102c9b:	76 0a                	jbe    80102ca7 <kbdgetc+0x14e>
80102c9d:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ca1:	77 04                	ja     80102ca7 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102ca3:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ca7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102caa:	c9                   	leave  
80102cab:	c3                   	ret    

80102cac <kbdintr>:

void
kbdintr(void)
{
80102cac:	55                   	push   %ebp
80102cad:	89 e5                	mov    %esp,%ebp
80102caf:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102cb2:	c7 04 24 59 2b 10 80 	movl   $0x80102b59,(%esp)
80102cb9:	e8 ef da ff ff       	call   801007ad <consoleintr>
}
80102cbe:	c9                   	leave  
80102cbf:	c3                   	ret    

80102cc0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cc0:	55                   	push   %ebp
80102cc1:	89 e5                	mov    %esp,%ebp
80102cc3:	83 ec 14             	sub    $0x14,%esp
80102cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ccd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cd1:	89 c2                	mov    %eax,%edx
80102cd3:	ec                   	in     (%dx),%al
80102cd4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cd7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cdb:	c9                   	leave  
80102cdc:	c3                   	ret    

80102cdd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102cdd:	55                   	push   %ebp
80102cde:	89 e5                	mov    %esp,%ebp
80102ce0:	83 ec 08             	sub    $0x8,%esp
80102ce3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ce9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ced:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cf0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102cf4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102cf8:	ee                   	out    %al,(%dx)
}
80102cf9:	c9                   	leave  
80102cfa:	c3                   	ret    

80102cfb <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cfb:	55                   	push   %ebp
80102cfc:	89 e5                	mov    %esp,%ebp
80102cfe:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d01:	9c                   	pushf  
80102d02:	58                   	pop    %eax
80102d03:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102d06:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102d09:	c9                   	leave  
80102d0a:	c3                   	ret    

80102d0b <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d0b:	55                   	push   %ebp
80102d0c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d0e:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d13:	8b 55 08             	mov    0x8(%ebp),%edx
80102d16:	c1 e2 02             	shl    $0x2,%edx
80102d19:	01 c2                	add    %eax,%edx
80102d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d1e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d20:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d25:	83 c0 20             	add    $0x20,%eax
80102d28:	8b 00                	mov    (%eax),%eax
}
80102d2a:	5d                   	pop    %ebp
80102d2b:	c3                   	ret    

80102d2c <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d2c:	55                   	push   %ebp
80102d2d:	89 e5                	mov    %esp,%ebp
80102d2f:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d32:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d37:	85 c0                	test   %eax,%eax
80102d39:	75 05                	jne    80102d40 <lapicinit+0x14>
    return;
80102d3b:	e9 43 01 00 00       	jmp    80102e83 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d40:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d47:	00 
80102d48:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d4f:	e8 b7 ff ff ff       	call   80102d0b <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d54:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d5b:	00 
80102d5c:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d63:	e8 a3 ff ff ff       	call   80102d0b <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d68:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d6f:	00 
80102d70:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d77:	e8 8f ff ff ff       	call   80102d0b <lapicw>
  lapicw(TICR, 10000000); 
80102d7c:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d83:	00 
80102d84:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d8b:	e8 7b ff ff ff       	call   80102d0b <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d90:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d97:	00 
80102d98:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d9f:	e8 67 ff ff ff       	call   80102d0b <lapicw>
  lapicw(LINT1, MASKED);
80102da4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dab:	00 
80102dac:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102db3:	e8 53 ff ff ff       	call   80102d0b <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102db8:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102dbd:	83 c0 30             	add    $0x30,%eax
80102dc0:	8b 00                	mov    (%eax),%eax
80102dc2:	c1 e8 10             	shr    $0x10,%eax
80102dc5:	0f b6 c0             	movzbl %al,%eax
80102dc8:	83 f8 03             	cmp    $0x3,%eax
80102dcb:	76 14                	jbe    80102de1 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102dcd:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dd4:	00 
80102dd5:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102ddc:	e8 2a ff ff ff       	call   80102d0b <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102de1:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102de8:	00 
80102de9:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102df0:	e8 16 ff ff ff       	call   80102d0b <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102df5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102dfc:	00 
80102dfd:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e04:	e8 02 ff ff ff       	call   80102d0b <lapicw>
  lapicw(ESR, 0);
80102e09:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e10:	00 
80102e11:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e18:	e8 ee fe ff ff       	call   80102d0b <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e24:	00 
80102e25:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e2c:	e8 da fe ff ff       	call   80102d0b <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e38:	00 
80102e39:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e40:	e8 c6 fe ff ff       	call   80102d0b <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e45:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e4c:	00 
80102e4d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e54:	e8 b2 fe ff ff       	call   80102d0b <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e59:	90                   	nop
80102e5a:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e5f:	05 00 03 00 00       	add    $0x300,%eax
80102e64:	8b 00                	mov    (%eax),%eax
80102e66:	25 00 10 00 00       	and    $0x1000,%eax
80102e6b:	85 c0                	test   %eax,%eax
80102e6d:	75 eb                	jne    80102e5a <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e76:	00 
80102e77:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e7e:	e8 88 fe ff ff       	call   80102d0b <lapicw>
}
80102e83:	c9                   	leave  
80102e84:	c3                   	ret    

80102e85 <cpunum>:

int
cpunum(void)
{
80102e85:	55                   	push   %ebp
80102e86:	89 e5                	mov    %esp,%ebp
80102e88:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e8b:	e8 6b fe ff ff       	call   80102cfb <readeflags>
80102e90:	25 00 02 00 00       	and    $0x200,%eax
80102e95:	85 c0                	test   %eax,%eax
80102e97:	74 25                	je     80102ebe <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102e99:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102e9e:	8d 50 01             	lea    0x1(%eax),%edx
80102ea1:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102ea7:	85 c0                	test   %eax,%eax
80102ea9:	75 13                	jne    80102ebe <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eab:	8b 45 04             	mov    0x4(%ebp),%eax
80102eae:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eb2:	c7 04 24 2c 8c 10 80 	movl   $0x80108c2c,(%esp)
80102eb9:	e8 e2 d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102ebe:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102ec3:	85 c0                	test   %eax,%eax
80102ec5:	74 0f                	je     80102ed6 <cpunum+0x51>
    return lapic[ID]>>24;
80102ec7:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102ecc:	83 c0 20             	add    $0x20,%eax
80102ecf:	8b 00                	mov    (%eax),%eax
80102ed1:	c1 e8 18             	shr    $0x18,%eax
80102ed4:	eb 05                	jmp    80102edb <cpunum+0x56>
  return 0;
80102ed6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102edb:	c9                   	leave  
80102edc:	c3                   	ret    

80102edd <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102edd:	55                   	push   %ebp
80102ede:	89 e5                	mov    %esp,%ebp
80102ee0:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ee3:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102ee8:	85 c0                	test   %eax,%eax
80102eea:	74 14                	je     80102f00 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102eec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ef3:	00 
80102ef4:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102efb:	e8 0b fe ff ff       	call   80102d0b <lapicw>
}
80102f00:	c9                   	leave  
80102f01:	c3                   	ret    

80102f02 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f02:	55                   	push   %ebp
80102f03:	89 e5                	mov    %esp,%ebp
}
80102f05:	5d                   	pop    %ebp
80102f06:	c3                   	ret    

80102f07 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f07:	55                   	push   %ebp
80102f08:	89 e5                	mov    %esp,%ebp
80102f0a:	83 ec 1c             	sub    $0x1c,%esp
80102f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80102f10:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f13:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f1a:	00 
80102f1b:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f22:	e8 b6 fd ff ff       	call   80102cdd <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f27:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f2e:	00 
80102f2f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f36:	e8 a2 fd ff ff       	call   80102cdd <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f3b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f42:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f45:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f4d:	8d 50 02             	lea    0x2(%eax),%edx
80102f50:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f53:	c1 e8 04             	shr    $0x4,%eax
80102f56:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f59:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f5d:	c1 e0 18             	shl    $0x18,%eax
80102f60:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f64:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f6b:	e8 9b fd ff ff       	call   80102d0b <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f70:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f77:	00 
80102f78:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f7f:	e8 87 fd ff ff       	call   80102d0b <lapicw>
  microdelay(200);
80102f84:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f8b:	e8 72 ff ff ff       	call   80102f02 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f90:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f97:	00 
80102f98:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f9f:	e8 67 fd ff ff       	call   80102d0b <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102fa4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fab:	e8 52 ff ff ff       	call   80102f02 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fb0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102fb7:	eb 40                	jmp    80102ff9 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fb9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fbd:	c1 e0 18             	shl    $0x18,%eax
80102fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fc4:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fcb:	e8 3b fd ff ff       	call   80102d0b <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fd3:	c1 e8 0c             	shr    $0xc,%eax
80102fd6:	80 cc 06             	or     $0x6,%ah
80102fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fdd:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fe4:	e8 22 fd ff ff       	call   80102d0b <lapicw>
    microdelay(200);
80102fe9:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ff0:	e8 0d ff ff ff       	call   80102f02 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ff5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102ff9:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102ffd:	7e ba                	jle    80102fb9 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102fff:	c9                   	leave  
80103000:	c3                   	ret    

80103001 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103001:	55                   	push   %ebp
80103002:	89 e5                	mov    %esp,%ebp
80103004:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103007:	8b 45 08             	mov    0x8(%ebp),%eax
8010300a:	0f b6 c0             	movzbl %al,%eax
8010300d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103011:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103018:	e8 c0 fc ff ff       	call   80102cdd <outb>
  microdelay(200);
8010301d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103024:	e8 d9 fe ff ff       	call   80102f02 <microdelay>

  return inb(CMOS_RETURN);
80103029:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103030:	e8 8b fc ff ff       	call   80102cc0 <inb>
80103035:	0f b6 c0             	movzbl %al,%eax
}
80103038:	c9                   	leave  
80103039:	c3                   	ret    

8010303a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010303a:	55                   	push   %ebp
8010303b:	89 e5                	mov    %esp,%ebp
8010303d:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103047:	e8 b5 ff ff ff       	call   80103001 <cmos_read>
8010304c:	8b 55 08             	mov    0x8(%ebp),%edx
8010304f:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103051:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103058:	e8 a4 ff ff ff       	call   80103001 <cmos_read>
8010305d:	8b 55 08             	mov    0x8(%ebp),%edx
80103060:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103063:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010306a:	e8 92 ff ff ff       	call   80103001 <cmos_read>
8010306f:	8b 55 08             	mov    0x8(%ebp),%edx
80103072:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103075:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010307c:	e8 80 ff ff ff       	call   80103001 <cmos_read>
80103081:	8b 55 08             	mov    0x8(%ebp),%edx
80103084:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103087:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010308e:	e8 6e ff ff ff       	call   80103001 <cmos_read>
80103093:	8b 55 08             	mov    0x8(%ebp),%edx
80103096:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103099:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801030a0:	e8 5c ff ff ff       	call   80103001 <cmos_read>
801030a5:	8b 55 08             	mov    0x8(%ebp),%edx
801030a8:	89 42 14             	mov    %eax,0x14(%edx)
}
801030ab:	c9                   	leave  
801030ac:	c3                   	ret    

801030ad <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801030ad:	55                   	push   %ebp
801030ae:	89 e5                	mov    %esp,%ebp
801030b0:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801030b3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801030ba:	e8 42 ff ff ff       	call   80103001 <cmos_read>
801030bf:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801030c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030c5:	83 e0 04             	and    $0x4,%eax
801030c8:	85 c0                	test   %eax,%eax
801030ca:	0f 94 c0             	sete   %al
801030cd:	0f b6 c0             	movzbl %al,%eax
801030d0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801030d3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801030d6:	89 04 24             	mov    %eax,(%esp)
801030d9:	e8 5c ff ff ff       	call   8010303a <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801030de:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801030e5:	e8 17 ff ff ff       	call   80103001 <cmos_read>
801030ea:	25 80 00 00 00       	and    $0x80,%eax
801030ef:	85 c0                	test   %eax,%eax
801030f1:	74 02                	je     801030f5 <cmostime+0x48>
        continue;
801030f3:	eb 36                	jmp    8010312b <cmostime+0x7e>
    fill_rtcdate(&t2);
801030f5:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030f8:	89 04 24             	mov    %eax,(%esp)
801030fb:	e8 3a ff ff ff       	call   8010303a <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103100:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103107:	00 
80103108:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010310b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010310f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103112:	89 04 24             	mov    %eax,(%esp)
80103115:	e8 90 25 00 00       	call   801056aa <memcmp>
8010311a:	85 c0                	test   %eax,%eax
8010311c:	75 0d                	jne    8010312b <cmostime+0x7e>
      break;
8010311e:	90                   	nop
  }

  // convert
  if (bcd) {
8010311f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103123:	0f 84 ac 00 00 00    	je     801031d5 <cmostime+0x128>
80103129:	eb 02                	jmp    8010312d <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010312b:	eb a6                	jmp    801030d3 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010312d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103130:	c1 e8 04             	shr    $0x4,%eax
80103133:	89 c2                	mov    %eax,%edx
80103135:	89 d0                	mov    %edx,%eax
80103137:	c1 e0 02             	shl    $0x2,%eax
8010313a:	01 d0                	add    %edx,%eax
8010313c:	01 c0                	add    %eax,%eax
8010313e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103141:	83 e2 0f             	and    $0xf,%edx
80103144:	01 d0                	add    %edx,%eax
80103146:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103149:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010314c:	c1 e8 04             	shr    $0x4,%eax
8010314f:	89 c2                	mov    %eax,%edx
80103151:	89 d0                	mov    %edx,%eax
80103153:	c1 e0 02             	shl    $0x2,%eax
80103156:	01 d0                	add    %edx,%eax
80103158:	01 c0                	add    %eax,%eax
8010315a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010315d:	83 e2 0f             	and    $0xf,%edx
80103160:	01 d0                	add    %edx,%eax
80103162:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103165:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103168:	c1 e8 04             	shr    $0x4,%eax
8010316b:	89 c2                	mov    %eax,%edx
8010316d:	89 d0                	mov    %edx,%eax
8010316f:	c1 e0 02             	shl    $0x2,%eax
80103172:	01 d0                	add    %edx,%eax
80103174:	01 c0                	add    %eax,%eax
80103176:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103179:	83 e2 0f             	and    $0xf,%edx
8010317c:	01 d0                	add    %edx,%eax
8010317e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103181:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103184:	c1 e8 04             	shr    $0x4,%eax
80103187:	89 c2                	mov    %eax,%edx
80103189:	89 d0                	mov    %edx,%eax
8010318b:	c1 e0 02             	shl    $0x2,%eax
8010318e:	01 d0                	add    %edx,%eax
80103190:	01 c0                	add    %eax,%eax
80103192:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103195:	83 e2 0f             	and    $0xf,%edx
80103198:	01 d0                	add    %edx,%eax
8010319a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010319d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801031a0:	c1 e8 04             	shr    $0x4,%eax
801031a3:	89 c2                	mov    %eax,%edx
801031a5:	89 d0                	mov    %edx,%eax
801031a7:	c1 e0 02             	shl    $0x2,%eax
801031aa:	01 d0                	add    %edx,%eax
801031ac:	01 c0                	add    %eax,%eax
801031ae:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031b1:	83 e2 0f             	and    $0xf,%edx
801031b4:	01 d0                	add    %edx,%eax
801031b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801031b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031bc:	c1 e8 04             	shr    $0x4,%eax
801031bf:	89 c2                	mov    %eax,%edx
801031c1:	89 d0                	mov    %edx,%eax
801031c3:	c1 e0 02             	shl    $0x2,%eax
801031c6:	01 d0                	add    %edx,%eax
801031c8:	01 c0                	add    %eax,%eax
801031ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031cd:	83 e2 0f             	and    $0xf,%edx
801031d0:	01 d0                	add    %edx,%eax
801031d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801031d5:	8b 45 08             	mov    0x8(%ebp),%eax
801031d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031db:	89 10                	mov    %edx,(%eax)
801031dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031e0:	89 50 04             	mov    %edx,0x4(%eax)
801031e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031e6:	89 50 08             	mov    %edx,0x8(%eax)
801031e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031ec:	89 50 0c             	mov    %edx,0xc(%eax)
801031ef:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031f2:	89 50 10             	mov    %edx,0x10(%eax)
801031f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031f8:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801031fb:	8b 45 08             	mov    0x8(%ebp),%eax
801031fe:	8b 40 14             	mov    0x14(%eax),%eax
80103201:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103207:	8b 45 08             	mov    0x8(%ebp),%eax
8010320a:	89 50 14             	mov    %edx,0x14(%eax)
}
8010320d:	c9                   	leave  
8010320e:	c3                   	ret    

8010320f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
8010320f:	55                   	push   %ebp
80103210:	89 e5                	mov    %esp,%ebp
80103212:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103215:	c7 44 24 04 58 8c 10 	movl   $0x80108c58,0x4(%esp)
8010321c:	80 
8010321d:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103224:	e8 95 21 00 00       	call   801053be <initlock>
  readsb(ROOTDEV, &sb);
80103229:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010322c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103230:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103237:	e8 c2 e0 ff ff       	call   801012fe <readsb>
  log.start = sb.size - sb.nlog;
8010323c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010323f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103242:	29 c2                	sub    %eax,%edx
80103244:	89 d0                	mov    %edx,%eax
80103246:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
8010324b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010324e:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
80103253:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
8010325a:	00 00 00 
  recover_from_log();
8010325d:	e8 9a 01 00 00       	call   801033fc <recover_from_log>
}
80103262:	c9                   	leave  
80103263:	c3                   	ret    

80103264 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103264:	55                   	push   %ebp
80103265:	89 e5                	mov    %esp,%ebp
80103267:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010326a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103271:	e9 8c 00 00 00       	jmp    80103302 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103276:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010327c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010327f:	01 d0                	add    %edx,%eax
80103281:	83 c0 01             	add    $0x1,%eax
80103284:	89 c2                	mov    %eax,%edx
80103286:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010328b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010328f:	89 04 24             	mov    %eax,(%esp)
80103292:	e8 0f cf ff ff       	call   801001a6 <bread>
80103297:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010329a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010329d:	83 c0 10             	add    $0x10,%eax
801032a0:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801032a7:	89 c2                	mov    %eax,%edx
801032a9:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801032ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801032b2:	89 04 24             	mov    %eax,(%esp)
801032b5:	e8 ec ce ff ff       	call   801001a6 <bread>
801032ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801032bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032c0:	8d 50 18             	lea    0x18(%eax),%edx
801032c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032c6:	83 c0 18             	add    $0x18,%eax
801032c9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801032d0:	00 
801032d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801032d5:	89 04 24             	mov    %eax,(%esp)
801032d8:	e8 25 24 00 00       	call   80105702 <memmove>
    bwrite(dbuf);  // write dst to disk
801032dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e0:	89 04 24             	mov    %eax,(%esp)
801032e3:	e8 f5 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801032e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032eb:	89 04 24             	mov    %eax,(%esp)
801032ee:	e8 24 cf ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801032f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f6:	89 04 24             	mov    %eax,(%esp)
801032f9:	e8 19 cf ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103302:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103307:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010330a:	0f 8f 66 ff ff ff    	jg     80103276 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103310:	c9                   	leave  
80103311:	c3                   	ret    

80103312 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103312:	55                   	push   %ebp
80103313:	89 e5                	mov    %esp,%ebp
80103315:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103318:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010331d:	89 c2                	mov    %eax,%edx
8010331f:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103324:	89 54 24 04          	mov    %edx,0x4(%esp)
80103328:	89 04 24             	mov    %eax,(%esp)
8010332b:	e8 76 ce ff ff       	call   801001a6 <bread>
80103330:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103336:	83 c0 18             	add    $0x18,%eax
80103339:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010333c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010333f:	8b 00                	mov    (%eax),%eax
80103341:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
80103346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010334d:	eb 1b                	jmp    8010336a <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010334f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103352:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103355:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103359:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010335c:	83 c2 10             	add    $0x10,%edx
8010335f:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103366:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010336a:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010336f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103372:	7f db                	jg     8010334f <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103377:	89 04 24             	mov    %eax,(%esp)
8010337a:	e8 98 ce ff ff       	call   80100217 <brelse>
}
8010337f:	c9                   	leave  
80103380:	c3                   	ret    

80103381 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103381:	55                   	push   %ebp
80103382:	89 e5                	mov    %esp,%ebp
80103384:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103387:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010338c:	89 c2                	mov    %eax,%edx
8010338e:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103393:	89 54 24 04          	mov    %edx,0x4(%esp)
80103397:	89 04 24             	mov    %eax,(%esp)
8010339a:	e8 07 ce ff ff       	call   801001a6 <bread>
8010339f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801033a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033a5:	83 c0 18             	add    $0x18,%eax
801033a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801033ab:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
801033b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b4:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033bd:	eb 1b                	jmp    801033da <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c2:	83 c0 10             	add    $0x10,%eax
801033c5:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
801033cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033d2:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801033d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033da:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801033df:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033e2:	7f db                	jg     801033bf <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801033e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e7:	89 04 24             	mov    %eax,(%esp)
801033ea:	e8 ee cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
801033ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033f2:	89 04 24             	mov    %eax,(%esp)
801033f5:	e8 1d ce ff ff       	call   80100217 <brelse>
}
801033fa:	c9                   	leave  
801033fb:	c3                   	ret    

801033fc <recover_from_log>:

static void
recover_from_log(void)
{
801033fc:	55                   	push   %ebp
801033fd:	89 e5                	mov    %esp,%ebp
801033ff:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103402:	e8 0b ff ff ff       	call   80103312 <read_head>
  install_trans(); // if committed, copy from log to disk
80103407:	e8 58 fe ff ff       	call   80103264 <install_trans>
  log.lh.n = 0;
8010340c:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
80103413:	00 00 00 
  write_head(); // clear the log
80103416:	e8 66 ff ff ff       	call   80103381 <write_head>
}
8010341b:	c9                   	leave  
8010341c:	c3                   	ret    

8010341d <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010341d:	55                   	push   %ebp
8010341e:	89 e5                	mov    %esp,%ebp
80103420:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103423:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010342a:	e8 b0 1f 00 00       	call   801053df <acquire>
  while(1){
    if(log.committing){
8010342f:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103434:	85 c0                	test   %eax,%eax
80103436:	74 16                	je     8010344e <begin_op+0x31>
      sleep(&log, &log.lock);
80103438:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
8010343f:	80 
80103440:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103447:	e8 10 18 00 00       	call   80104c5c <sleep>
8010344c:	eb 4f                	jmp    8010349d <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010344e:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
80103454:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103459:	8d 50 01             	lea    0x1(%eax),%edx
8010345c:	89 d0                	mov    %edx,%eax
8010345e:	c1 e0 02             	shl    $0x2,%eax
80103461:	01 d0                	add    %edx,%eax
80103463:	01 c0                	add    %eax,%eax
80103465:	01 c8                	add    %ecx,%eax
80103467:	83 f8 1e             	cmp    $0x1e,%eax
8010346a:	7e 16                	jle    80103482 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010346c:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
80103473:	80 
80103474:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010347b:	e8 dc 17 00 00       	call   80104c5c <sleep>
80103480:	eb 1b                	jmp    8010349d <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103482:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103487:	83 c0 01             	add    $0x1,%eax
8010348a:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
8010348f:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103496:	e8 a6 1f 00 00       	call   80105441 <release>
      break;
8010349b:	eb 02                	jmp    8010349f <begin_op+0x82>
    }
  }
8010349d:	eb 90                	jmp    8010342f <begin_op+0x12>
}
8010349f:	c9                   	leave  
801034a0:	c3                   	ret    

801034a1 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801034a1:	55                   	push   %ebp
801034a2:	89 e5                	mov    %esp,%ebp
801034a4:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801034a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801034ae:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034b5:	e8 25 1f 00 00       	call   801053df <acquire>
  log.outstanding -= 1;
801034ba:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034bf:	83 e8 01             	sub    $0x1,%eax
801034c2:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801034c7:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801034cc:	85 c0                	test   %eax,%eax
801034ce:	74 0c                	je     801034dc <end_op+0x3b>
    panic("log.committing");
801034d0:	c7 04 24 5c 8c 10 80 	movl   $0x80108c5c,(%esp)
801034d7:	e8 5e d0 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
801034dc:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034e1:	85 c0                	test   %eax,%eax
801034e3:	75 13                	jne    801034f8 <end_op+0x57>
    do_commit = 1;
801034e5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801034ec:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801034f3:	00 00 00 
801034f6:	eb 0c                	jmp    80103504 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801034f8:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034ff:	e8 33 18 00 00       	call   80104d37 <wakeup>
  }
  release(&log.lock);
80103504:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010350b:	e8 31 1f 00 00       	call   80105441 <release>

  if(do_commit){
80103510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103514:	74 33                	je     80103549 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103516:	e8 de 00 00 00       	call   801035f9 <commit>
    acquire(&log.lock);
8010351b:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103522:	e8 b8 1e 00 00       	call   801053df <acquire>
    log.committing = 0;
80103527:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
8010352e:	00 00 00 
    wakeup(&log);
80103531:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103538:	e8 fa 17 00 00       	call   80104d37 <wakeup>
    release(&log.lock);
8010353d:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103544:	e8 f8 1e 00 00       	call   80105441 <release>
  }
}
80103549:	c9                   	leave  
8010354a:	c3                   	ret    

8010354b <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010354b:	55                   	push   %ebp
8010354c:	89 e5                	mov    %esp,%ebp
8010354e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103551:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103558:	e9 8c 00 00 00       	jmp    801035e9 <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010355d:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103566:	01 d0                	add    %edx,%eax
80103568:	83 c0 01             	add    $0x1,%eax
8010356b:	89 c2                	mov    %eax,%edx
8010356d:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103572:	89 54 24 04          	mov    %edx,0x4(%esp)
80103576:	89 04 24             	mov    %eax,(%esp)
80103579:	e8 28 cc ff ff       	call   801001a6 <bread>
8010357e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103584:	83 c0 10             	add    $0x10,%eax
80103587:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010358e:	89 c2                	mov    %eax,%edx
80103590:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103595:	89 54 24 04          	mov    %edx,0x4(%esp)
80103599:	89 04 24             	mov    %eax,(%esp)
8010359c:	e8 05 cc ff ff       	call   801001a6 <bread>
801035a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801035a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035a7:	8d 50 18             	lea    0x18(%eax),%edx
801035aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ad:	83 c0 18             	add    $0x18,%eax
801035b0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801035b7:	00 
801035b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801035bc:	89 04 24             	mov    %eax,(%esp)
801035bf:	e8 3e 21 00 00       	call   80105702 <memmove>
    bwrite(to);  // write the log
801035c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035c7:	89 04 24             	mov    %eax,(%esp)
801035ca:	e8 0e cc ff ff       	call   801001dd <bwrite>
    brelse(from); 
801035cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035d2:	89 04 24             	mov    %eax,(%esp)
801035d5:	e8 3d cc ff ff       	call   80100217 <brelse>
    brelse(to);
801035da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035dd:	89 04 24             	mov    %eax,(%esp)
801035e0:	e8 32 cc ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035e9:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801035ee:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035f1:	0f 8f 66 ff ff ff    	jg     8010355d <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801035f7:	c9                   	leave  
801035f8:	c3                   	ret    

801035f9 <commit>:

static void
commit()
{
801035f9:	55                   	push   %ebp
801035fa:	89 e5                	mov    %esp,%ebp
801035fc:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801035ff:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103604:	85 c0                	test   %eax,%eax
80103606:	7e 1e                	jle    80103626 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103608:	e8 3e ff ff ff       	call   8010354b <write_log>
    write_head();    // Write header to disk -- the real commit
8010360d:	e8 6f fd ff ff       	call   80103381 <write_head>
    install_trans(); // Now install writes to home locations
80103612:	e8 4d fc ff ff       	call   80103264 <install_trans>
    log.lh.n = 0; 
80103617:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
8010361e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103621:	e8 5b fd ff ff       	call   80103381 <write_head>
  }
}
80103626:	c9                   	leave  
80103627:	c3                   	ret    

80103628 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103628:	55                   	push   %ebp
80103629:	89 e5                	mov    %esp,%ebp
8010362b:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010362e:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103633:	83 f8 1d             	cmp    $0x1d,%eax
80103636:	7f 12                	jg     8010364a <log_write+0x22>
80103638:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010363d:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103643:	83 ea 01             	sub    $0x1,%edx
80103646:	39 d0                	cmp    %edx,%eax
80103648:	7c 0c                	jl     80103656 <log_write+0x2e>
    panic("too big a transaction");
8010364a:	c7 04 24 6b 8c 10 80 	movl   $0x80108c6b,(%esp)
80103651:	e8 e4 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103656:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010365b:	85 c0                	test   %eax,%eax
8010365d:	7f 0c                	jg     8010366b <log_write+0x43>
    panic("log_write outside of trans");
8010365f:	c7 04 24 81 8c 10 80 	movl   $0x80108c81,(%esp)
80103666:	e8 cf ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010366b:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103672:	e8 68 1d 00 00       	call   801053df <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103677:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367e:	eb 1f                	jmp    8010369f <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103683:	83 c0 10             	add    $0x10,%eax
80103686:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010368d:	89 c2                	mov    %eax,%edx
8010368f:	8b 45 08             	mov    0x8(%ebp),%eax
80103692:	8b 40 08             	mov    0x8(%eax),%eax
80103695:	39 c2                	cmp    %eax,%edx
80103697:	75 02                	jne    8010369b <log_write+0x73>
      break;
80103699:	eb 0e                	jmp    801036a9 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010369b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010369f:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036a4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036a7:	7f d7                	jg     80103680 <log_write+0x58>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
801036a9:	8b 45 08             	mov    0x8(%ebp),%eax
801036ac:	8b 40 08             	mov    0x8(%eax),%eax
801036af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036b2:	83 c2 10             	add    $0x10,%edx
801036b5:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
  if (i == log.lh.n)
801036bc:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036c1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036c4:	75 0d                	jne    801036d3 <log_write+0xab>
    log.lh.n++;
801036c6:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036cb:	83 c0 01             	add    $0x1,%eax
801036ce:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801036d3:	8b 45 08             	mov    0x8(%ebp),%eax
801036d6:	8b 00                	mov    (%eax),%eax
801036d8:	83 c8 04             	or     $0x4,%eax
801036db:	89 c2                	mov    %eax,%edx
801036dd:	8b 45 08             	mov    0x8(%ebp),%eax
801036e0:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801036e2:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801036e9:	e8 53 1d 00 00       	call   80105441 <release>
}
801036ee:	c9                   	leave  
801036ef:	c3                   	ret    

801036f0 <v2p>:
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	8b 45 08             	mov    0x8(%ebp),%eax
801036f6:	05 00 00 00 80       	add    $0x80000000,%eax
801036fb:	5d                   	pop    %ebp
801036fc:	c3                   	ret    

801036fd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801036fd:	55                   	push   %ebp
801036fe:	89 e5                	mov    %esp,%ebp
80103700:	8b 45 08             	mov    0x8(%ebp),%eax
80103703:	05 00 00 00 80       	add    $0x80000000,%eax
80103708:	5d                   	pop    %ebp
80103709:	c3                   	ret    

8010370a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010370a:	55                   	push   %ebp
8010370b:	89 e5                	mov    %esp,%ebp
8010370d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103710:	8b 55 08             	mov    0x8(%ebp),%edx
80103713:	8b 45 0c             	mov    0xc(%ebp),%eax
80103716:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103719:	f0 87 02             	lock xchg %eax,(%edx)
8010371c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010371f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103722:	c9                   	leave  
80103723:	c3                   	ret    

80103724 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103724:	55                   	push   %ebp
80103725:	89 e5                	mov    %esp,%ebp
80103727:	83 e4 f0             	and    $0xfffffff0,%esp
8010372a:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010372d:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103734:	80 
80103735:	c7 04 24 5c a9 11 80 	movl   $0x8011a95c,(%esp)
8010373c:	e8 80 f2 ff ff       	call   801029c1 <kinit1>
  kvmalloc();      // kernel page table
80103741:	e8 59 4b 00 00       	call   8010829f <kvmalloc>
  mpinit();        // collect info about this machine
80103746:	e8 46 04 00 00       	call   80103b91 <mpinit>
  lapicinit();
8010374b:	e8 dc f5 ff ff       	call   80102d2c <lapicinit>
  seginit();       // set up segments
80103750:	e8 dd 44 00 00       	call   80107c32 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103755:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010375b:	0f b6 00             	movzbl (%eax),%eax
8010375e:	0f b6 c0             	movzbl %al,%eax
80103761:	89 44 24 04          	mov    %eax,0x4(%esp)
80103765:	c7 04 24 9c 8c 10 80 	movl   $0x80108c9c,(%esp)
8010376c:	e8 2f cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103771:	e8 79 06 00 00       	call   80103def <picinit>
  ioapicinit();    // another interrupt controller
80103776:	e8 3c f1 ff ff       	call   801028b7 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010377b:	e8 01 d3 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103780:	e8 fc 37 00 00       	call   80106f81 <uartinit>
  pinit();         // process table
80103785:	e8 a3 0b 00 00       	call   8010432d <pinit>
  tvinit();        // trap vectors
8010378a:	e8 a4 33 00 00       	call   80106b33 <tvinit>
  binit();         // buffer cache
8010378f:	e8 a0 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103794:	e8 7e d7 ff ff       	call   80100f17 <fileinit>
  iinit();         // inode cache
80103799:	e8 13 de ff ff       	call   801015b1 <iinit>
  ideinit();       // disk
8010379e:	e8 7d ed ff ff       	call   80102520 <ideinit>
  if(!ismp)
801037a3:	a1 64 33 11 80       	mov    0x80113364,%eax
801037a8:	85 c0                	test   %eax,%eax
801037aa:	75 05                	jne    801037b1 <main+0x8d>
    timerinit();   // uniprocessor timer
801037ac:	e8 c8 32 00 00       	call   80106a79 <timerinit>
  startothers();   // start other processors
801037b1:	e8 7f 00 00 00       	call   80103835 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037b6:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037bd:	8e 
801037be:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037c5:	e8 2f f2 ff ff       	call   801029f9 <kinit2>
  userinit();      // first user process
801037ca:	e8 da 0c 00 00       	call   801044a9 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037cf:	e8 1a 00 00 00       	call   801037ee <mpmain>

801037d4 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037d4:	55                   	push   %ebp
801037d5:	89 e5                	mov    %esp,%ebp
801037d7:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801037da:	e8 d7 4a 00 00       	call   801082b6 <switchkvm>
  seginit();
801037df:	e8 4e 44 00 00       	call   80107c32 <seginit>
  lapicinit();
801037e4:	e8 43 f5 ff ff       	call   80102d2c <lapicinit>
  mpmain();
801037e9:	e8 00 00 00 00       	call   801037ee <mpmain>

801037ee <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037ee:	55                   	push   %ebp
801037ef:	89 e5                	mov    %esp,%ebp
801037f1:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801037f4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037fa:	0f b6 00             	movzbl (%eax),%eax
801037fd:	0f b6 c0             	movzbl %al,%eax
80103800:	89 44 24 04          	mov    %eax,0x4(%esp)
80103804:	c7 04 24 b3 8c 10 80 	movl   $0x80108cb3,(%esp)
8010380b:	e8 90 cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103810:	e8 92 34 00 00       	call   80106ca7 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103815:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010381b:	05 a8 00 00 00       	add    $0xa8,%eax
80103820:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103827:	00 
80103828:	89 04 24             	mov    %eax,(%esp)
8010382b:	e8 da fe ff ff       	call   8010370a <xchg>
  scheduler();     // start running processes
80103830:	e8 66 12 00 00       	call   80104a9b <scheduler>

80103835 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103835:	55                   	push   %ebp
80103836:	89 e5                	mov    %esp,%ebp
80103838:	53                   	push   %ebx
80103839:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010383c:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103843:	e8 b5 fe ff ff       	call   801036fd <p2v>
80103848:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010384b:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103850:	89 44 24 08          	mov    %eax,0x8(%esp)
80103854:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
8010385b:	80 
8010385c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010385f:	89 04 24             	mov    %eax,(%esp)
80103862:	e8 9b 1e 00 00       	call   80105702 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103867:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
8010386e:	e9 85 00 00 00       	jmp    801038f8 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103873:	e8 0d f6 ff ff       	call   80102e85 <cpunum>
80103878:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010387e:	05 80 33 11 80       	add    $0x80113380,%eax
80103883:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103886:	75 02                	jne    8010388a <startothers+0x55>
      continue;
80103888:	eb 67                	jmp    801038f1 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010388a:	e8 60 f2 ff ff       	call   80102aef <kalloc>
8010388f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103895:	83 e8 04             	sub    $0x4,%eax
80103898:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010389b:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038a1:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a6:	83 e8 08             	sub    $0x8,%eax
801038a9:	c7 00 d4 37 10 80    	movl   $0x801037d4,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b2:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038b5:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
801038bc:	e8 2f fe ff ff       	call   801036f0 <v2p>
801038c1:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c6:	89 04 24             	mov    %eax,(%esp)
801038c9:	e8 22 fe ff ff       	call   801036f0 <v2p>
801038ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038d1:	0f b6 12             	movzbl (%edx),%edx
801038d4:	0f b6 d2             	movzbl %dl,%edx
801038d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801038db:	89 14 24             	mov    %edx,(%esp)
801038de:	e8 24 f6 ff ff       	call   80102f07 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038e3:	90                   	nop
801038e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038e7:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801038ed:	85 c0                	test   %eax,%eax
801038ef:	74 f3                	je     801038e4 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038f1:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801038f8:	a1 60 39 11 80       	mov    0x80113960,%eax
801038fd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103903:	05 80 33 11 80       	add    $0x80113380,%eax
80103908:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010390b:	0f 87 62 ff ff ff    	ja     80103873 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103911:	83 c4 24             	add    $0x24,%esp
80103914:	5b                   	pop    %ebx
80103915:	5d                   	pop    %ebp
80103916:	c3                   	ret    

80103917 <p2v>:
80103917:	55                   	push   %ebp
80103918:	89 e5                	mov    %esp,%ebp
8010391a:	8b 45 08             	mov    0x8(%ebp),%eax
8010391d:	05 00 00 00 80       	add    $0x80000000,%eax
80103922:	5d                   	pop    %ebp
80103923:	c3                   	ret    

80103924 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103924:	55                   	push   %ebp
80103925:	89 e5                	mov    %esp,%ebp
80103927:	83 ec 14             	sub    $0x14,%esp
8010392a:	8b 45 08             	mov    0x8(%ebp),%eax
8010392d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103931:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103935:	89 c2                	mov    %eax,%edx
80103937:	ec                   	in     (%dx),%al
80103938:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010393b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010393f:	c9                   	leave  
80103940:	c3                   	ret    

80103941 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103941:	55                   	push   %ebp
80103942:	89 e5                	mov    %esp,%ebp
80103944:	83 ec 08             	sub    $0x8,%esp
80103947:	8b 55 08             	mov    0x8(%ebp),%edx
8010394a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010394d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103951:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103954:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103958:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010395c:	ee                   	out    %al,(%dx)
}
8010395d:	c9                   	leave  
8010395e:	c3                   	ret    

8010395f <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010395f:	55                   	push   %ebp
80103960:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103962:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103967:	89 c2                	mov    %eax,%edx
80103969:	b8 80 33 11 80       	mov    $0x80113380,%eax
8010396e:	29 c2                	sub    %eax,%edx
80103970:	89 d0                	mov    %edx,%eax
80103972:	c1 f8 02             	sar    $0x2,%eax
80103975:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010397b:	5d                   	pop    %ebp
8010397c:	c3                   	ret    

8010397d <sum>:

static uchar
sum(uchar *addr, int len)
{
8010397d:	55                   	push   %ebp
8010397e:	89 e5                	mov    %esp,%ebp
80103980:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103983:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010398a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103991:	eb 15                	jmp    801039a8 <sum+0x2b>
    sum += addr[i];
80103993:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103996:	8b 45 08             	mov    0x8(%ebp),%eax
80103999:	01 d0                	add    %edx,%eax
8010399b:	0f b6 00             	movzbl (%eax),%eax
8010399e:	0f b6 c0             	movzbl %al,%eax
801039a1:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039a4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039ae:	7c e3                	jl     80103993 <sum+0x16>
    sum += addr[i];
  return sum;
801039b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039b3:	c9                   	leave  
801039b4:	c3                   	ret    

801039b5 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039b5:	55                   	push   %ebp
801039b6:	89 e5                	mov    %esp,%ebp
801039b8:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039bb:	8b 45 08             	mov    0x8(%ebp),%eax
801039be:	89 04 24             	mov    %eax,(%esp)
801039c1:	e8 51 ff ff ff       	call   80103917 <p2v>
801039c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801039cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039cf:	01 d0                	add    %edx,%eax
801039d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039da:	eb 3f                	jmp    80103a1b <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039dc:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039e3:	00 
801039e4:	c7 44 24 04 c4 8c 10 	movl   $0x80108cc4,0x4(%esp)
801039eb:	80 
801039ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ef:	89 04 24             	mov    %eax,(%esp)
801039f2:	e8 b3 1c 00 00       	call   801056aa <memcmp>
801039f7:	85 c0                	test   %eax,%eax
801039f9:	75 1c                	jne    80103a17 <mpsearch1+0x62>
801039fb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a02:	00 
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	89 04 24             	mov    %eax,(%esp)
80103a09:	e8 6f ff ff ff       	call   8010397d <sum>
80103a0e:	84 c0                	test   %al,%al
80103a10:	75 05                	jne    80103a17 <mpsearch1+0x62>
      return (struct mp*)p;
80103a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a15:	eb 11                	jmp    80103a28 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a17:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a21:	72 b9                	jb     801039dc <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a28:	c9                   	leave  
80103a29:	c3                   	ret    

80103a2a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a2a:	55                   	push   %ebp
80103a2b:	89 e5                	mov    %esp,%ebp
80103a2d:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a30:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3a:	83 c0 0f             	add    $0xf,%eax
80103a3d:	0f b6 00             	movzbl (%eax),%eax
80103a40:	0f b6 c0             	movzbl %al,%eax
80103a43:	c1 e0 08             	shl    $0x8,%eax
80103a46:	89 c2                	mov    %eax,%edx
80103a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4b:	83 c0 0e             	add    $0xe,%eax
80103a4e:	0f b6 00             	movzbl (%eax),%eax
80103a51:	0f b6 c0             	movzbl %al,%eax
80103a54:	09 d0                	or     %edx,%eax
80103a56:	c1 e0 04             	shl    $0x4,%eax
80103a59:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a60:	74 21                	je     80103a83 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a62:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a69:	00 
80103a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a6d:	89 04 24             	mov    %eax,(%esp)
80103a70:	e8 40 ff ff ff       	call   801039b5 <mpsearch1>
80103a75:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a7c:	74 50                	je     80103ace <mpsearch+0xa4>
      return mp;
80103a7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a81:	eb 5f                	jmp    80103ae2 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a86:	83 c0 14             	add    $0x14,%eax
80103a89:	0f b6 00             	movzbl (%eax),%eax
80103a8c:	0f b6 c0             	movzbl %al,%eax
80103a8f:	c1 e0 08             	shl    $0x8,%eax
80103a92:	89 c2                	mov    %eax,%edx
80103a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a97:	83 c0 13             	add    $0x13,%eax
80103a9a:	0f b6 00             	movzbl (%eax),%eax
80103a9d:	0f b6 c0             	movzbl %al,%eax
80103aa0:	09 d0                	or     %edx,%eax
80103aa2:	c1 e0 0a             	shl    $0xa,%eax
80103aa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aab:	2d 00 04 00 00       	sub    $0x400,%eax
80103ab0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ab7:	00 
80103ab8:	89 04 24             	mov    %eax,(%esp)
80103abb:	e8 f5 fe ff ff       	call   801039b5 <mpsearch1>
80103ac0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ac3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ac7:	74 05                	je     80103ace <mpsearch+0xa4>
      return mp;
80103ac9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103acc:	eb 14                	jmp    80103ae2 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ace:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ad5:	00 
80103ad6:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103add:	e8 d3 fe ff ff       	call   801039b5 <mpsearch1>
}
80103ae2:	c9                   	leave  
80103ae3:	c3                   	ret    

80103ae4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ae4:	55                   	push   %ebp
80103ae5:	89 e5                	mov    %esp,%ebp
80103ae7:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103aea:	e8 3b ff ff ff       	call   80103a2a <mpsearch>
80103aef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103af2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103af6:	74 0a                	je     80103b02 <mpconfig+0x1e>
80103af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afb:	8b 40 04             	mov    0x4(%eax),%eax
80103afe:	85 c0                	test   %eax,%eax
80103b00:	75 0a                	jne    80103b0c <mpconfig+0x28>
    return 0;
80103b02:	b8 00 00 00 00       	mov    $0x0,%eax
80103b07:	e9 83 00 00 00       	jmp    80103b8f <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0f:	8b 40 04             	mov    0x4(%eax),%eax
80103b12:	89 04 24             	mov    %eax,(%esp)
80103b15:	e8 fd fd ff ff       	call   80103917 <p2v>
80103b1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b1d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b24:	00 
80103b25:	c7 44 24 04 c9 8c 10 	movl   $0x80108cc9,0x4(%esp)
80103b2c:	80 
80103b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b30:	89 04 24             	mov    %eax,(%esp)
80103b33:	e8 72 1b 00 00       	call   801056aa <memcmp>
80103b38:	85 c0                	test   %eax,%eax
80103b3a:	74 07                	je     80103b43 <mpconfig+0x5f>
    return 0;
80103b3c:	b8 00 00 00 00       	mov    $0x0,%eax
80103b41:	eb 4c                	jmp    80103b8f <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b46:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b4a:	3c 01                	cmp    $0x1,%al
80103b4c:	74 12                	je     80103b60 <mpconfig+0x7c>
80103b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b51:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b55:	3c 04                	cmp    $0x4,%al
80103b57:	74 07                	je     80103b60 <mpconfig+0x7c>
    return 0;
80103b59:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5e:	eb 2f                	jmp    80103b8f <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b63:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b67:	0f b7 c0             	movzwl %ax,%eax
80103b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b71:	89 04 24             	mov    %eax,(%esp)
80103b74:	e8 04 fe ff ff       	call   8010397d <sum>
80103b79:	84 c0                	test   %al,%al
80103b7b:	74 07                	je     80103b84 <mpconfig+0xa0>
    return 0;
80103b7d:	b8 00 00 00 00       	mov    $0x0,%eax
80103b82:	eb 0b                	jmp    80103b8f <mpconfig+0xab>
  *pmp = mp;
80103b84:	8b 45 08             	mov    0x8(%ebp),%eax
80103b87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b8a:	89 10                	mov    %edx,(%eax)
  return conf;
80103b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b8f:	c9                   	leave  
80103b90:	c3                   	ret    

80103b91 <mpinit>:

void
mpinit(void)
{
80103b91:	55                   	push   %ebp
80103b92:	89 e5                	mov    %esp,%ebp
80103b94:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103b97:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103b9e:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103ba1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103ba4:	89 04 24             	mov    %eax,(%esp)
80103ba7:	e8 38 ff ff ff       	call   80103ae4 <mpconfig>
80103bac:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103baf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bb3:	75 05                	jne    80103bba <mpinit+0x29>
    return;
80103bb5:	e9 9c 01 00 00       	jmp    80103d56 <mpinit+0x1c5>
  ismp = 1;
80103bba:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103bc1:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc7:	8b 40 24             	mov    0x24(%eax),%eax
80103bca:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd2:	83 c0 2c             	add    $0x2c,%eax
80103bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bdb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bdf:	0f b7 d0             	movzwl %ax,%edx
80103be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be5:	01 d0                	add    %edx,%eax
80103be7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bea:	e9 f4 00 00 00       	jmp    80103ce3 <mpinit+0x152>
    switch(*p){
80103bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf2:	0f b6 00             	movzbl (%eax),%eax
80103bf5:	0f b6 c0             	movzbl %al,%eax
80103bf8:	83 f8 04             	cmp    $0x4,%eax
80103bfb:	0f 87 bf 00 00 00    	ja     80103cc0 <mpinit+0x12f>
80103c01:	8b 04 85 0c 8d 10 80 	mov    -0x7fef72f4(,%eax,4),%eax
80103c08:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c13:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c17:	0f b6 d0             	movzbl %al,%edx
80103c1a:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c1f:	39 c2                	cmp    %eax,%edx
80103c21:	74 2d                	je     80103c50 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c26:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c2a:	0f b6 d0             	movzbl %al,%edx
80103c2d:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c32:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c36:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c3a:	c7 04 24 ce 8c 10 80 	movl   $0x80108cce,(%esp)
80103c41:	e8 5a c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c46:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103c4d:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c50:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c53:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c57:	0f b6 c0             	movzbl %al,%eax
80103c5a:	83 e0 02             	and    $0x2,%eax
80103c5d:	85 c0                	test   %eax,%eax
80103c5f:	74 15                	je     80103c76 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103c61:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c66:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c6c:	05 80 33 11 80       	add    $0x80113380,%eax
80103c71:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103c76:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103c7c:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c81:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103c87:	81 c2 80 33 11 80    	add    $0x80113380,%edx
80103c8d:	88 02                	mov    %al,(%edx)
      ncpu++;
80103c8f:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c94:	83 c0 01             	add    $0x1,%eax
80103c97:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103c9c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ca0:	eb 41                	jmp    80103ce3 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103ca8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cab:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103caf:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103cb4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cb8:	eb 29                	jmp    80103ce3 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cba:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cbe:	eb 23                	jmp    80103ce3 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc3:	0f b6 00             	movzbl (%eax),%eax
80103cc6:	0f b6 c0             	movzbl %al,%eax
80103cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ccd:	c7 04 24 ec 8c 10 80 	movl   $0x80108cec,(%esp)
80103cd4:	e8 c7 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103cd9:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103ce0:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ce9:	0f 82 00 ff ff ff    	jb     80103bef <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103cef:	a1 64 33 11 80       	mov    0x80113364,%eax
80103cf4:	85 c0                	test   %eax,%eax
80103cf6:	75 1d                	jne    80103d15 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cf8:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103cff:	00 00 00 
    lapic = 0;
80103d02:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103d09:	00 00 00 
    ioapicid = 0;
80103d0c:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103d13:	eb 41                	jmp    80103d56 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d18:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d1c:	84 c0                	test   %al,%al
80103d1e:	74 36                	je     80103d56 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d20:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d27:	00 
80103d28:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d2f:	e8 0d fc ff ff       	call   80103941 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d34:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d3b:	e8 e4 fb ff ff       	call   80103924 <inb>
80103d40:	83 c8 01             	or     $0x1,%eax
80103d43:	0f b6 c0             	movzbl %al,%eax
80103d46:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d4a:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d51:	e8 eb fb ff ff       	call   80103941 <outb>
  }
}
80103d56:	c9                   	leave  
80103d57:	c3                   	ret    

80103d58 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d58:	55                   	push   %ebp
80103d59:	89 e5                	mov    %esp,%ebp
80103d5b:	83 ec 08             	sub    $0x8,%esp
80103d5e:	8b 55 08             	mov    0x8(%ebp),%edx
80103d61:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d64:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d68:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d6b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d6f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d73:	ee                   	out    %al,(%dx)
}
80103d74:	c9                   	leave  
80103d75:	c3                   	ret    

80103d76 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d76:	55                   	push   %ebp
80103d77:	89 e5                	mov    %esp,%ebp
80103d79:	83 ec 0c             	sub    $0xc,%esp
80103d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d7f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d83:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d87:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103d8d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d91:	0f b6 c0             	movzbl %al,%eax
80103d94:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d98:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d9f:	e8 b4 ff ff ff       	call   80103d58 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103da4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103da8:	66 c1 e8 08          	shr    $0x8,%ax
80103dac:	0f b6 c0             	movzbl %al,%eax
80103daf:	89 44 24 04          	mov    %eax,0x4(%esp)
80103db3:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dba:	e8 99 ff ff ff       	call   80103d58 <outb>
}
80103dbf:	c9                   	leave  
80103dc0:	c3                   	ret    

80103dc1 <picenable>:

void
picenable(int irq)
{
80103dc1:	55                   	push   %ebp
80103dc2:	89 e5                	mov    %esp,%ebp
80103dc4:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dca:	ba 01 00 00 00       	mov    $0x1,%edx
80103dcf:	89 c1                	mov    %eax,%ecx
80103dd1:	d3 e2                	shl    %cl,%edx
80103dd3:	89 d0                	mov    %edx,%eax
80103dd5:	f7 d0                	not    %eax
80103dd7:	89 c2                	mov    %eax,%edx
80103dd9:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103de0:	21 d0                	and    %edx,%eax
80103de2:	0f b7 c0             	movzwl %ax,%eax
80103de5:	89 04 24             	mov    %eax,(%esp)
80103de8:	e8 89 ff ff ff       	call   80103d76 <picsetmask>
}
80103ded:	c9                   	leave  
80103dee:	c3                   	ret    

80103def <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103def:	55                   	push   %ebp
80103df0:	89 e5                	mov    %esp,%ebp
80103df2:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103df5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103dfc:	00 
80103dfd:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e04:	e8 4f ff ff ff       	call   80103d58 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e09:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e10:	00 
80103e11:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e18:	e8 3b ff ff ff       	call   80103d58 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e1d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e24:	00 
80103e25:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e2c:	e8 27 ff ff ff       	call   80103d58 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e31:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e38:	00 
80103e39:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e40:	e8 13 ff ff ff       	call   80103d58 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e45:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e4c:	00 
80103e4d:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e54:	e8 ff fe ff ff       	call   80103d58 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e59:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e60:	00 
80103e61:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e68:	e8 eb fe ff ff       	call   80103d58 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e6d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e74:	00 
80103e75:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e7c:	e8 d7 fe ff ff       	call   80103d58 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e81:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e88:	00 
80103e89:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e90:	e8 c3 fe ff ff       	call   80103d58 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103e95:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103e9c:	00 
80103e9d:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ea4:	e8 af fe ff ff       	call   80103d58 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103ea9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103eb0:	00 
80103eb1:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eb8:	e8 9b fe ff ff       	call   80103d58 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103ebd:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ec4:	00 
80103ec5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ecc:	e8 87 fe ff ff       	call   80103d58 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ed1:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ed8:	00 
80103ed9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ee0:	e8 73 fe ff ff       	call   80103d58 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ee5:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103eec:	00 
80103eed:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ef4:	e8 5f fe ff ff       	call   80103d58 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103ef9:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f00:	00 
80103f01:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f08:	e8 4b fe ff ff       	call   80103d58 <outb>

  if(irqmask != 0xFFFF)
80103f0d:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f14:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f18:	74 12                	je     80103f2c <picinit+0x13d>
    picsetmask(irqmask);
80103f1a:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f21:	0f b7 c0             	movzwl %ax,%eax
80103f24:	89 04 24             	mov    %eax,(%esp)
80103f27:	e8 4a fe ff ff       	call   80103d76 <picsetmask>
}
80103f2c:	c9                   	leave  
80103f2d:	c3                   	ret    

80103f2e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f2e:	55                   	push   %ebp
80103f2f:	89 e5                	mov    %esp,%ebp
80103f31:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f3e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f44:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f47:	8b 10                	mov    (%eax),%edx
80103f49:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f4e:	e8 e0 cf ff ff       	call   80100f33 <filealloc>
80103f53:	8b 55 08             	mov    0x8(%ebp),%edx
80103f56:	89 02                	mov    %eax,(%edx)
80103f58:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5b:	8b 00                	mov    (%eax),%eax
80103f5d:	85 c0                	test   %eax,%eax
80103f5f:	0f 84 c8 00 00 00    	je     8010402d <pipealloc+0xff>
80103f65:	e8 c9 cf ff ff       	call   80100f33 <filealloc>
80103f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f6d:	89 02                	mov    %eax,(%edx)
80103f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f72:	8b 00                	mov    (%eax),%eax
80103f74:	85 c0                	test   %eax,%eax
80103f76:	0f 84 b1 00 00 00    	je     8010402d <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f7c:	e8 6e eb ff ff       	call   80102aef <kalloc>
80103f81:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f88:	75 05                	jne    80103f8f <pipealloc+0x61>
    goto bad;
80103f8a:	e9 9e 00 00 00       	jmp    8010402d <pipealloc+0xff>
  p->readopen = 1;
80103f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f92:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f99:	00 00 00 
  p->writeopen = 1;
80103f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9f:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fa6:	00 00 00 
  p->nwrite = 0;
80103fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fac:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fb3:	00 00 00 
  p->nread = 0;
80103fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fc0:	00 00 00 
  initlock(&p->lock, "pipe");
80103fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc6:	c7 44 24 04 20 8d 10 	movl   $0x80108d20,0x4(%esp)
80103fcd:	80 
80103fce:	89 04 24             	mov    %eax,(%esp)
80103fd1:	e8 e8 13 00 00       	call   801053be <initlock>
  (*f0)->type = FD_PIPE;
80103fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd9:	8b 00                	mov    (%eax),%eax
80103fdb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe4:	8b 00                	mov    (%eax),%eax
80103fe6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fea:	8b 45 08             	mov    0x8(%ebp),%eax
80103fed:	8b 00                	mov    (%eax),%eax
80103fef:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff6:	8b 00                	mov    (%eax),%eax
80103ff8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ffb:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104001:	8b 00                	mov    (%eax),%eax
80104003:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104009:	8b 45 0c             	mov    0xc(%ebp),%eax
8010400c:	8b 00                	mov    (%eax),%eax
8010400e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104012:	8b 45 0c             	mov    0xc(%ebp),%eax
80104015:	8b 00                	mov    (%eax),%eax
80104017:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010401b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010401e:	8b 00                	mov    (%eax),%eax
80104020:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104023:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104026:	b8 00 00 00 00       	mov    $0x0,%eax
8010402b:	eb 42                	jmp    8010406f <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
8010402d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104031:	74 0b                	je     8010403e <pipealloc+0x110>
    kfree((char*)p);
80104033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104036:	89 04 24             	mov    %eax,(%esp)
80104039:	e8 18 ea ff ff       	call   80102a56 <kfree>
  if(*f0)
8010403e:	8b 45 08             	mov    0x8(%ebp),%eax
80104041:	8b 00                	mov    (%eax),%eax
80104043:	85 c0                	test   %eax,%eax
80104045:	74 0d                	je     80104054 <pipealloc+0x126>
    fileclose(*f0);
80104047:	8b 45 08             	mov    0x8(%ebp),%eax
8010404a:	8b 00                	mov    (%eax),%eax
8010404c:	89 04 24             	mov    %eax,(%esp)
8010404f:	e8 87 cf ff ff       	call   80100fdb <fileclose>
  if(*f1)
80104054:	8b 45 0c             	mov    0xc(%ebp),%eax
80104057:	8b 00                	mov    (%eax),%eax
80104059:	85 c0                	test   %eax,%eax
8010405b:	74 0d                	je     8010406a <pipealloc+0x13c>
    fileclose(*f1);
8010405d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104060:	8b 00                	mov    (%eax),%eax
80104062:	89 04 24             	mov    %eax,(%esp)
80104065:	e8 71 cf ff ff       	call   80100fdb <fileclose>
  return -1;
8010406a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010406f:	c9                   	leave  
80104070:	c3                   	ret    

80104071 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104071:	55                   	push   %ebp
80104072:	89 e5                	mov    %esp,%ebp
80104074:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104077:	8b 45 08             	mov    0x8(%ebp),%eax
8010407a:	89 04 24             	mov    %eax,(%esp)
8010407d:	e8 5d 13 00 00       	call   801053df <acquire>
  if(writable){
80104082:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104086:	74 1f                	je     801040a7 <pipeclose+0x36>
    p->writeopen = 0;
80104088:	8b 45 08             	mov    0x8(%ebp),%eax
8010408b:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104092:	00 00 00 
    wakeup(&p->nread);
80104095:	8b 45 08             	mov    0x8(%ebp),%eax
80104098:	05 34 02 00 00       	add    $0x234,%eax
8010409d:	89 04 24             	mov    %eax,(%esp)
801040a0:	e8 92 0c 00 00       	call   80104d37 <wakeup>
801040a5:	eb 1d                	jmp    801040c4 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040a7:	8b 45 08             	mov    0x8(%ebp),%eax
801040aa:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040b1:	00 00 00 
    wakeup(&p->nwrite);
801040b4:	8b 45 08             	mov    0x8(%ebp),%eax
801040b7:	05 38 02 00 00       	add    $0x238,%eax
801040bc:	89 04 24             	mov    %eax,(%esp)
801040bf:	e8 73 0c 00 00       	call   80104d37 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040c4:	8b 45 08             	mov    0x8(%ebp),%eax
801040c7:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040cd:	85 c0                	test   %eax,%eax
801040cf:	75 25                	jne    801040f6 <pipeclose+0x85>
801040d1:	8b 45 08             	mov    0x8(%ebp),%eax
801040d4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040da:	85 c0                	test   %eax,%eax
801040dc:	75 18                	jne    801040f6 <pipeclose+0x85>
    release(&p->lock);
801040de:	8b 45 08             	mov    0x8(%ebp),%eax
801040e1:	89 04 24             	mov    %eax,(%esp)
801040e4:	e8 58 13 00 00       	call   80105441 <release>
    kfree((char*)p);
801040e9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ec:	89 04 24             	mov    %eax,(%esp)
801040ef:	e8 62 e9 ff ff       	call   80102a56 <kfree>
801040f4:	eb 0b                	jmp    80104101 <pipeclose+0x90>
  } else
    release(&p->lock);
801040f6:	8b 45 08             	mov    0x8(%ebp),%eax
801040f9:	89 04 24             	mov    %eax,(%esp)
801040fc:	e8 40 13 00 00       	call   80105441 <release>
}
80104101:	c9                   	leave  
80104102:	c3                   	ret    

80104103 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104103:	55                   	push   %ebp
80104104:	89 e5                	mov    %esp,%ebp
80104106:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104109:	8b 45 08             	mov    0x8(%ebp),%eax
8010410c:	89 04 24             	mov    %eax,(%esp)
8010410f:	e8 cb 12 00 00       	call   801053df <acquire>
  for(i = 0; i < n; i++){
80104114:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010411b:	e9 a6 00 00 00       	jmp    801041c6 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104120:	eb 57                	jmp    80104179 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80104122:	8b 45 08             	mov    0x8(%ebp),%eax
80104125:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010412b:	85 c0                	test   %eax,%eax
8010412d:	74 0d                	je     8010413c <pipewrite+0x39>
8010412f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104135:	8b 40 24             	mov    0x24(%eax),%eax
80104138:	85 c0                	test   %eax,%eax
8010413a:	74 15                	je     80104151 <pipewrite+0x4e>
        release(&p->lock);
8010413c:	8b 45 08             	mov    0x8(%ebp),%eax
8010413f:	89 04 24             	mov    %eax,(%esp)
80104142:	e8 fa 12 00 00       	call   80105441 <release>
        return -1;
80104147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010414c:	e9 9f 00 00 00       	jmp    801041f0 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104151:	8b 45 08             	mov    0x8(%ebp),%eax
80104154:	05 34 02 00 00       	add    $0x234,%eax
80104159:	89 04 24             	mov    %eax,(%esp)
8010415c:	e8 d6 0b 00 00       	call   80104d37 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104161:	8b 45 08             	mov    0x8(%ebp),%eax
80104164:	8b 55 08             	mov    0x8(%ebp),%edx
80104167:	81 c2 38 02 00 00    	add    $0x238,%edx
8010416d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104171:	89 14 24             	mov    %edx,(%esp)
80104174:	e8 e3 0a 00 00       	call   80104c5c <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104179:	8b 45 08             	mov    0x8(%ebp),%eax
8010417c:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104182:	8b 45 08             	mov    0x8(%ebp),%eax
80104185:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010418b:	05 00 02 00 00       	add    $0x200,%eax
80104190:	39 c2                	cmp    %eax,%edx
80104192:	74 8e                	je     80104122 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104194:	8b 45 08             	mov    0x8(%ebp),%eax
80104197:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010419d:	8d 48 01             	lea    0x1(%eax),%ecx
801041a0:	8b 55 08             	mov    0x8(%ebp),%edx
801041a3:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801041a9:	25 ff 01 00 00       	and    $0x1ff,%eax
801041ae:	89 c1                	mov    %eax,%ecx
801041b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b6:	01 d0                	add    %edx,%eax
801041b8:	0f b6 10             	movzbl (%eax),%edx
801041bb:	8b 45 08             	mov    0x8(%ebp),%eax
801041be:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c9:	3b 45 10             	cmp    0x10(%ebp),%eax
801041cc:	0f 8c 4e ff ff ff    	jl     80104120 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041d2:	8b 45 08             	mov    0x8(%ebp),%eax
801041d5:	05 34 02 00 00       	add    $0x234,%eax
801041da:	89 04 24             	mov    %eax,(%esp)
801041dd:	e8 55 0b 00 00       	call   80104d37 <wakeup>
  release(&p->lock);
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	89 04 24             	mov    %eax,(%esp)
801041e8:	e8 54 12 00 00       	call   80105441 <release>
  return n;
801041ed:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041f0:	c9                   	leave  
801041f1:	c3                   	ret    

801041f2 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041f2:	55                   	push   %ebp
801041f3:	89 e5                	mov    %esp,%ebp
801041f5:	53                   	push   %ebx
801041f6:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041f9:	8b 45 08             	mov    0x8(%ebp),%eax
801041fc:	89 04 24             	mov    %eax,(%esp)
801041ff:	e8 db 11 00 00       	call   801053df <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104204:	eb 3a                	jmp    80104240 <piperead+0x4e>
    if(proc->killed){
80104206:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010420c:	8b 40 24             	mov    0x24(%eax),%eax
8010420f:	85 c0                	test   %eax,%eax
80104211:	74 15                	je     80104228 <piperead+0x36>
      release(&p->lock);
80104213:	8b 45 08             	mov    0x8(%ebp),%eax
80104216:	89 04 24             	mov    %eax,(%esp)
80104219:	e8 23 12 00 00       	call   80105441 <release>
      return -1;
8010421e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104223:	e9 b5 00 00 00       	jmp    801042dd <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104228:	8b 45 08             	mov    0x8(%ebp),%eax
8010422b:	8b 55 08             	mov    0x8(%ebp),%edx
8010422e:	81 c2 34 02 00 00    	add    $0x234,%edx
80104234:	89 44 24 04          	mov    %eax,0x4(%esp)
80104238:	89 14 24             	mov    %edx,(%esp)
8010423b:	e8 1c 0a 00 00       	call   80104c5c <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104240:	8b 45 08             	mov    0x8(%ebp),%eax
80104243:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104249:	8b 45 08             	mov    0x8(%ebp),%eax
8010424c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104252:	39 c2                	cmp    %eax,%edx
80104254:	75 0d                	jne    80104263 <piperead+0x71>
80104256:	8b 45 08             	mov    0x8(%ebp),%eax
80104259:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010425f:	85 c0                	test   %eax,%eax
80104261:	75 a3                	jne    80104206 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104263:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010426a:	eb 4b                	jmp    801042b7 <piperead+0xc5>
    if(p->nread == p->nwrite)
8010426c:	8b 45 08             	mov    0x8(%ebp),%eax
8010426f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104275:	8b 45 08             	mov    0x8(%ebp),%eax
80104278:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010427e:	39 c2                	cmp    %eax,%edx
80104280:	75 02                	jne    80104284 <piperead+0x92>
      break;
80104282:	eb 3b                	jmp    801042bf <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104284:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104287:	8b 45 0c             	mov    0xc(%ebp),%eax
8010428a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010428d:	8b 45 08             	mov    0x8(%ebp),%eax
80104290:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104296:	8d 48 01             	lea    0x1(%eax),%ecx
80104299:	8b 55 08             	mov    0x8(%ebp),%edx
8010429c:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801042a2:	25 ff 01 00 00       	and    $0x1ff,%eax
801042a7:	89 c2                	mov    %eax,%edx
801042a9:	8b 45 08             	mov    0x8(%ebp),%eax
801042ac:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801042b1:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ba:	3b 45 10             	cmp    0x10(%ebp),%eax
801042bd:	7c ad                	jl     8010426c <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	05 38 02 00 00       	add    $0x238,%eax
801042c7:	89 04 24             	mov    %eax,(%esp)
801042ca:	e8 68 0a 00 00       	call   80104d37 <wakeup>
  release(&p->lock);
801042cf:	8b 45 08             	mov    0x8(%ebp),%eax
801042d2:	89 04 24             	mov    %eax,(%esp)
801042d5:	e8 67 11 00 00       	call   80105441 <release>
  return i;
801042da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042dd:	83 c4 24             	add    $0x24,%esp
801042e0:	5b                   	pop    %ebx
801042e1:	5d                   	pop    %ebp
801042e2:	c3                   	ret    

801042e3 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042e3:	55                   	push   %ebp
801042e4:	89 e5                	mov    %esp,%ebp
801042e6:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042e9:	9c                   	pushf  
801042ea:	58                   	pop    %eax
801042eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801042ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801042f1:	c9                   	leave  
801042f2:	c3                   	ret    

801042f3 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042f3:	55                   	push   %ebp
801042f4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042f6:	fb                   	sti    
}
801042f7:	5d                   	pop    %ebp
801042f8:	c3                   	ret    

801042f9 <cas>:
  asm volatile("movl %0,%%cr3" : : "r" (val));
}

static inline int 
cas(volatile int *addr, int expected, int newval)
{
801042f9:	55                   	push   %ebp
801042fa:	89 e5                	mov    %esp,%ebp
801042fc:	56                   	push   %esi
801042fd:	53                   	push   %ebx
801042fe:	83 ec 10             	sub    $0x10,%esp
	int result = 0;
80104301:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	
    asm volatile(
80104308:	8b 55 08             	mov    0x8(%ebp),%edx
8010430b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010430e:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104311:	8b 75 08             	mov    0x8(%ebp),%esi
80104314:	89 cb                	mov    %ecx,%ebx
80104316:	f0 0f b1 1a          	lock cmpxchg %ebx,(%edx)
8010431a:	0f 94 c0             	sete   %al
8010431d:	0f b6 c0             	movzbl %al,%eax
80104320:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "successs:\n\t"
      : "=m"(result)
      : "r" (expected), "r" (addr), "r"(newval)
      : "memory");
*/
    return result;
80104323:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104326:	83 c4 10             	add    $0x10,%esp
80104329:	5b                   	pop    %ebx
8010432a:	5e                   	pop    %esi
8010432b:	5d                   	pop    %ebp
8010432c:	c3                   	ret    

8010432d <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010432d:	55                   	push   %ebp
8010432e:	89 e5                	mov    %esp,%ebp
80104330:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104333:	c7 44 24 04 28 8d 10 	movl   $0x80108d28,0x4(%esp)
8010433a:	80 
8010433b:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104342:	e8 77 10 00 00       	call   801053be <initlock>
}
80104347:	c9                   	leave  
80104348:	c3                   	ret    

80104349 <allocpid>:

int 
allocpid(void) 
{
80104349:	55                   	push   %ebp
8010434a:	89 e5                	mov    %esp,%ebp
8010434c:	83 ec 1c             	sub    $0x1c,%esp
  //acquire(&ptable.lock);
  //pid = nextpid++;
  //release(&ptable.lock);

  do{
    pid = nextpid;
8010434f:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104354:	89 45 fc             	mov    %eax,-0x4(%ebp)
  } while(!cas(&nextpid, pid, pid+1));
80104357:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010435a:	83 c0 01             	add    $0x1,%eax
8010435d:	89 44 24 08          	mov    %eax,0x8(%esp)
80104361:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104364:	89 44 24 04          	mov    %eax,0x4(%esp)
80104368:	c7 04 24 04 c0 10 80 	movl   $0x8010c004,(%esp)
8010436f:	e8 85 ff ff ff       	call   801042f9 <cas>
80104374:	85 c0                	test   %eax,%eax
80104376:	74 d7                	je     8010434f <allocpid+0x6>
  //cprintf("alloc pid = %d", pid + 1);
  return pid + 1;
80104378:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010437b:	83 c0 01             	add    $0x1,%eax
}
8010437e:	c9                   	leave  
8010437f:	c3                   	ret    

80104380 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104380:	55                   	push   %ebp
80104381:	89 e5                	mov    %esp,%ebp
80104383:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  //acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104386:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010438d:	eb 4c                	jmp    801043db <allocproc+0x5b>
    //if(p->state == UNUSED)
    if(cas(&p->state, UNUSED, EMBRYO))
8010438f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104392:	83 c0 0c             	add    $0xc,%eax
80104395:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010439c:	00 
8010439d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043a4:	00 
801043a5:	89 04 24             	mov    %eax,(%esp)
801043a8:	e8 4c ff ff ff       	call   801042f9 <cas>
801043ad:	85 c0                	test   %eax,%eax
801043af:	74 23                	je     801043d4 <allocproc+0x54>
      goto found;
801043b1:	90                   	nop

found:
  //p->state = EMBRYO;  
  //release(&ptable.lock);

  p->pid = allocpid();
801043b2:	e8 92 ff ff ff       	call   80104349 <allocpid>
801043b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ba:	89 42 10             	mov    %eax,0x10(%edx)

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043bd:	e8 2d e7 ff ff       	call   80102aef <kalloc>
801043c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043c5:	89 42 08             	mov    %eax,0x8(%edx)
801043c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cb:	8b 40 08             	mov    0x8(%eax),%eax
801043ce:	85 c0                	test   %eax,%eax
801043d0:	75 30                	jne    80104402 <allocproc+0x82>
801043d2:	eb 1a                	jmp    801043ee <allocproc+0x6e>
{
  struct proc *p;
  char *sp;

  //acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043d4:	81 45 f4 9c 01 00 00 	addl   $0x19c,-0xc(%ebp)
801043db:	81 7d f4 b4 a0 11 80 	cmpl   $0x8011a0b4,-0xc(%ebp)
801043e2:	72 ab                	jb     8010438f <allocproc+0xf>
    //if(p->state == UNUSED)
    if(cas(&p->state, UNUSED, EMBRYO))
      goto found;
  //release(&ptable.lock);
  return 0;
801043e4:	b8 00 00 00 00       	mov    $0x0,%eax
801043e9:	e9 b9 00 00 00       	jmp    801044a7 <allocproc+0x127>

  p->pid = allocpid();

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043f8:	b8 00 00 00 00       	mov    $0x0,%eax
801043fd:	e9 a5 00 00 00       	jmp    801044a7 <allocproc+0x127>
  }
  sp = p->kstack + KSTACKSIZE;
80104402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104405:	8b 40 08             	mov    0x8(%eax),%eax
80104408:	05 00 10 00 00       	add    $0x1000,%eax
8010440d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  

  //initialize cstack
  struct cstackframe *csf;
  for(csf = p->pending_signals.frames; csf < &p->pending_signals.frames[MAX_CSTACK_FRAMES]; csf++) {
80104410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104413:	83 e8 80             	sub    $0xffffff80,%eax
80104416:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104419:	eb 0e                	jmp    80104429 <allocproc+0xa9>
    csf->used = 0;
8010441b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010441e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  sp = p->kstack + KSTACKSIZE;
  

  //initialize cstack
  struct cstackframe *csf;
  for(csf = p->pending_signals.frames; csf < &p->pending_signals.frames[MAX_CSTACK_FRAMES]; csf++) {
80104425:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
80104429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442c:	05 48 01 00 00       	add    $0x148,%eax
80104431:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104434:	77 e5                	ja     8010441b <allocproc+0x9b>
    csf->used = 0;
  }
  p->pending_signals.head = 0;
80104436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104439:	c7 80 48 01 00 00 00 	movl   $0x0,0x148(%eax)
80104440:	00 00 00 

  // available for handeling signal 
  p->handling_signal = 0;
80104443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104446:	c7 80 98 01 00 00 00 	movl   $0x0,0x198(%eax)
8010444d:	00 00 00 

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104450:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104457:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010445a:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010445d:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80104461:	ba e9 6a 10 80       	mov    $0x80106ae9,%edx
80104466:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104469:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010446b:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
8010446f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104472:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104475:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010447e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104485:	00 
80104486:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010448d:	00 
8010448e:	89 04 24             	mov    %eax,(%esp)
80104491:	e8 9d 11 00 00       	call   80105633 <memset>
  p->context->eip = (uint)forkret;
80104496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104499:	8b 40 1c             	mov    0x1c(%eax),%eax
8010449c:	ba 30 4c 10 80       	mov    $0x80104c30,%edx
801044a1:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801044a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044a7:	c9                   	leave  
801044a8:	c3                   	ret    

801044a9 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801044a9:	55                   	push   %ebp
801044aa:	89 e5                	mov    %esp,%ebp
801044ac:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044af:	e8 cc fe ff ff       	call   80104380 <allocproc>
801044b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ba:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
801044bf:	e8 1e 3d 00 00       	call   801081e2 <setupkvm>
801044c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044c7:	89 42 04             	mov    %eax,0x4(%edx)
801044ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cd:	8b 40 04             	mov    0x4(%eax),%eax
801044d0:	85 c0                	test   %eax,%eax
801044d2:	75 0c                	jne    801044e0 <userinit+0x37>
    panic("userinit: out of memory?");
801044d4:	c7 04 24 2f 8d 10 80 	movl   $0x80108d2f,(%esp)
801044db:	e8 5a c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044e0:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e8:	8b 40 04             	mov    0x4(%eax),%eax
801044eb:	89 54 24 08          	mov    %edx,0x8(%esp)
801044ef:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
801044f6:	80 
801044f7:	89 04 24             	mov    %eax,(%esp)
801044fa:	e8 3b 3f 00 00       	call   8010843a <inituvm>
  p->sz = PGSIZE;
801044ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104502:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	8b 40 18             	mov    0x18(%eax),%eax
8010450e:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104515:	00 
80104516:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010451d:	00 
8010451e:	89 04 24             	mov    %eax,(%esp)
80104521:	e8 0d 11 00 00       	call   80105633 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104529:	8b 40 18             	mov    0x18(%eax),%eax
8010452c:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104535:	8b 40 18             	mov    0x18(%eax),%eax
80104538:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010453e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104541:	8b 40 18             	mov    0x18(%eax),%eax
80104544:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104547:	8b 52 18             	mov    0x18(%edx),%edx
8010454a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010454e:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104555:	8b 40 18             	mov    0x18(%eax),%eax
80104558:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010455b:	8b 52 18             	mov    0x18(%edx),%edx
8010455e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104562:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104569:	8b 40 18             	mov    0x18(%eax),%eax
8010456c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104576:	8b 40 18             	mov    0x18(%eax),%eax
80104579:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104583:	8b 40 18             	mov    0x18(%eax),%eax
80104586:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010458d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104590:	83 c0 6c             	add    $0x6c,%eax
80104593:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010459a:	00 
8010459b:	c7 44 24 04 48 8d 10 	movl   $0x80108d48,0x4(%esp)
801045a2:	80 
801045a3:	89 04 24             	mov    %eax,(%esp)
801045a6:	e8 a8 12 00 00       	call   80105853 <safestrcpy>
  p->cwd = namei("/");
801045ab:	c7 04 24 51 8d 10 80 	movl   $0x80108d51,(%esp)
801045b2:	e8 5c de ff ff       	call   80102413 <namei>
801045b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ba:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045c7:	c9                   	leave  
801045c8:	c3                   	ret    

801045c9 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045c9:	55                   	push   %ebp
801045ca:	89 e5                	mov    %esp,%ebp
801045cc:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d5:	8b 00                	mov    (%eax),%eax
801045d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045de:	7e 34                	jle    80104614 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045e0:	8b 55 08             	mov    0x8(%ebp),%edx
801045e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e6:	01 c2                	add    %eax,%edx
801045e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045ee:	8b 40 04             	mov    0x4(%eax),%eax
801045f1:	89 54 24 08          	mov    %edx,0x8(%esp)
801045f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f8:	89 54 24 04          	mov    %edx,0x4(%esp)
801045fc:	89 04 24             	mov    %eax,(%esp)
801045ff:	e8 ac 3f 00 00       	call   801085b0 <allocuvm>
80104604:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104607:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010460b:	75 41                	jne    8010464e <growproc+0x85>
      return -1;
8010460d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104612:	eb 58                	jmp    8010466c <growproc+0xa3>
  } else if(n < 0){
80104614:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104618:	79 34                	jns    8010464e <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010461a:	8b 55 08             	mov    0x8(%ebp),%edx
8010461d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104620:	01 c2                	add    %eax,%edx
80104622:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104628:	8b 40 04             	mov    0x4(%eax),%eax
8010462b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010462f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104632:	89 54 24 04          	mov    %edx,0x4(%esp)
80104636:	89 04 24             	mov    %eax,(%esp)
80104639:	e8 4c 40 00 00       	call   8010868a <deallocuvm>
8010463e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104641:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104645:	75 07                	jne    8010464e <growproc+0x85>
      return -1;
80104647:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010464c:	eb 1e                	jmp    8010466c <growproc+0xa3>
  }
  proc->sz = sz;
8010464e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104654:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104657:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104659:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010465f:	89 04 24             	mov    %eax,(%esp)
80104662:	e8 6c 3c 00 00       	call   801082d3 <switchuvm>
  return 0;
80104667:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010466c:	c9                   	leave  
8010466d:	c3                   	ret    

8010466e <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010466e:	55                   	push   %ebp
8010466f:	89 e5                	mov    %esp,%ebp
80104671:	57                   	push   %edi
80104672:	56                   	push   %esi
80104673:	53                   	push   %ebx
80104674:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104677:	e8 04 fd ff ff       	call   80104380 <allocproc>
8010467c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010467f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104683:	75 0a                	jne    8010468f <fork+0x21>
    return -1;
80104685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010468a:	e9 61 01 00 00       	jmp    801047f0 <fork+0x182>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010468f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104695:	8b 10                	mov    (%eax),%edx
80104697:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010469d:	8b 40 04             	mov    0x4(%eax),%eax
801046a0:	89 54 24 04          	mov    %edx,0x4(%esp)
801046a4:	89 04 24             	mov    %eax,(%esp)
801046a7:	e8 7a 41 00 00       	call   80108826 <copyuvm>
801046ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046af:	89 42 04             	mov    %eax,0x4(%edx)
801046b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b5:	8b 40 04             	mov    0x4(%eax),%eax
801046b8:	85 c0                	test   %eax,%eax
801046ba:	75 2c                	jne    801046e8 <fork+0x7a>
    kfree(np->kstack);
801046bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bf:	8b 40 08             	mov    0x8(%eax),%eax
801046c2:	89 04 24             	mov    %eax,(%esp)
801046c5:	e8 8c e3 ff ff       	call   80102a56 <kfree>
    np->kstack = 0;
801046ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046cd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e3:	e9 08 01 00 00       	jmp    801047f0 <fork+0x182>
  }
  np->sz = proc->sz;
801046e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ee:	8b 10                	mov    (%eax),%edx
801046f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f3:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046f5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ff:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104702:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104705:	8b 50 18             	mov    0x18(%eax),%edx
80104708:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470e:	8b 40 18             	mov    0x18(%eax),%eax
80104711:	89 c3                	mov    %eax,%ebx
80104713:	b8 13 00 00 00       	mov    $0x13,%eax
80104718:	89 d7                	mov    %edx,%edi
8010471a:	89 de                	mov    %ebx,%esi
8010471c:	89 c1                	mov    %eax,%ecx
8010471e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104720:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104723:	8b 40 18             	mov    0x18(%eax),%eax
80104726:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010472d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104734:	eb 3d                	jmp    80104773 <fork+0x105>
    if(proc->ofile[i])
80104736:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010473f:	83 c2 08             	add    $0x8,%edx
80104742:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104746:	85 c0                	test   %eax,%eax
80104748:	74 25                	je     8010476f <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010474a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104750:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104753:	83 c2 08             	add    $0x8,%edx
80104756:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010475a:	89 04 24             	mov    %eax,(%esp)
8010475d:	e8 31 c8 ff ff       	call   80100f93 <filedup>
80104762:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104765:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104768:	83 c1 08             	add    $0x8,%ecx
8010476b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010476f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104773:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104777:	7e bd                	jle    80104736 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104779:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010477f:	8b 40 68             	mov    0x68(%eax),%eax
80104782:	89 04 24             	mov    %eax,(%esp)
80104785:	e8 ac d0 ff ff       	call   80101836 <idup>
8010478a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010478d:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104790:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104796:	8d 50 6c             	lea    0x6c(%eax),%edx
80104799:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479c:	83 c0 6c             	add    $0x6c,%eax
8010479f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047a6:	00 
801047a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801047ab:	89 04 24             	mov    %eax,(%esp)
801047ae:	e8 a0 10 00 00       	call   80105853 <safestrcpy>
  //copy signal handler
  np->sighandler = proc->sighandler; 
801047b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b9:	8b 50 7c             	mov    0x7c(%eax),%edx
801047bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047bf:	89 50 7c             	mov    %edx,0x7c(%eax)
  pid = np->pid;
801047c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c5:	8b 40 10             	mov    0x10(%eax),%eax
801047c8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801047cb:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801047d2:	e8 08 0c 00 00       	call   801053df <acquire>
  np->state = RUNNABLE;
801047d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047da:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047e1:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801047e8:	e8 54 0c 00 00       	call   80105441 <release>
  
  return pid;
801047ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047f0:	83 c4 2c             	add    $0x2c,%esp
801047f3:	5b                   	pop    %ebx
801047f4:	5e                   	pop    %esi
801047f5:	5f                   	pop    %edi
801047f6:	5d                   	pop    %ebp
801047f7:	c3                   	ret    

801047f8 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047f8:	55                   	push   %ebp
801047f9:	89 e5                	mov    %esp,%ebp
801047fb:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047fe:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104805:	a1 68 c6 10 80       	mov    0x8010c668,%eax
8010480a:	39 c2                	cmp    %eax,%edx
8010480c:	75 0c                	jne    8010481a <exit+0x22>
    panic("init exiting");
8010480e:	c7 04 24 53 8d 10 80 	movl   $0x80108d53,(%esp)
80104815:	e8 20 bd ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010481a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104821:	eb 44                	jmp    80104867 <exit+0x6f>
    if(proc->ofile[fd]){
80104823:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104829:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010482c:	83 c2 08             	add    $0x8,%edx
8010482f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104833:	85 c0                	test   %eax,%eax
80104835:	74 2c                	je     80104863 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104837:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104840:	83 c2 08             	add    $0x8,%edx
80104843:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104847:	89 04 24             	mov    %eax,(%esp)
8010484a:	e8 8c c7 ff ff       	call   80100fdb <fileclose>
      proc->ofile[fd] = 0;
8010484f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104855:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104858:	83 c2 08             	add    $0x8,%edx
8010485b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104862:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104863:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104867:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010486b:	7e b6                	jle    80104823 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010486d:	e8 ab eb ff ff       	call   8010341d <begin_op>
  iput(proc->cwd);
80104872:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104878:	8b 40 68             	mov    0x68(%eax),%eax
8010487b:	89 04 24             	mov    %eax,(%esp)
8010487e:	e8 98 d1 ff ff       	call   80101a1b <iput>
  end_op();
80104883:	e8 19 ec ff ff       	call   801034a1 <end_op>
  proc->cwd = 0;
80104888:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104895:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010489c:	e8 3e 0b 00 00       	call   801053df <acquire>

  proc->state = ZOMBIE;
801048a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a7:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801048ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b4:	8b 40 14             	mov    0x14(%eax),%eax
801048b7:	89 04 24             	mov    %eax,(%esp)
801048ba:	e8 2b 04 00 00       	call   80104cea <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048bf:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801048c6:	eb 3b                	jmp    80104903 <exit+0x10b>
    if(p->parent == proc){
801048c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048cb:	8b 50 14             	mov    0x14(%eax),%edx
801048ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d4:	39 c2                	cmp    %eax,%edx
801048d6:	75 24                	jne    801048fc <exit+0x104>
      p->parent = initproc;
801048d8:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
801048de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e1:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e7:	8b 40 0c             	mov    0xc(%eax),%eax
801048ea:	83 f8 05             	cmp    $0x5,%eax
801048ed:	75 0d                	jne    801048fc <exit+0x104>
        wakeup1(initproc);
801048ef:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801048f4:	89 04 24             	mov    %eax,(%esp)
801048f7:	e8 ee 03 00 00       	call   80104cea <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048fc:	81 45 f4 9c 01 00 00 	addl   $0x19c,-0xc(%ebp)
80104903:	81 7d f4 b4 a0 11 80 	cmpl   $0x8011a0b4,-0xc(%ebp)
8010490a:	72 bc                	jb     801048c8 <exit+0xd0>
    }
  }

  // Jump into the scheduler, never to return.
  
  sched();
8010490c:	e8 3b 02 00 00       	call   80104b4c <sched>
  panic("zombie exit");
80104911:	c7 04 24 60 8d 10 80 	movl   $0x80108d60,(%esp)
80104918:	e8 1d bc ff ff       	call   8010053a <panic>

8010491d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010491d:	55                   	push   %ebp
8010491e:	89 e5                	mov    %esp,%ebp
80104920:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104923:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010492a:	e8 b0 0a 00 00       	call   801053df <acquire>
  for(;;){
    proc->chan = (int)proc;
8010492f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104935:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010493c:	89 50 20             	mov    %edx,0x20(%eax)
    proc->state = SLEEPING;    
8010493f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104945:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
    // Scan through table looking for zombie children.
    havekids = 0;
8010494c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104953:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010495a:	e9 84 00 00 00       	jmp    801049e3 <wait+0xc6>
      if(p->parent != proc)
8010495f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104962:	8b 50 14             	mov    0x14(%eax),%edx
80104965:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496b:	39 c2                	cmp    %eax,%edx
8010496d:	74 02                	je     80104971 <wait+0x54>
        continue;
8010496f:	eb 6b                	jmp    801049dc <wait+0xbf>
      havekids = 1;
80104971:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497b:	8b 40 0c             	mov    0xc(%eax),%eax
8010497e:	83 f8 05             	cmp    $0x5,%eax
80104981:	75 59                	jne    801049dc <wait+0xbf>
        // Found one.
        pid = p->pid;
80104983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104986:	8b 40 10             	mov    0x10(%eax),%eax
80104989:	89 45 ec             	mov    %eax,-0x14(%ebp)
        p->state = UNUSED;
8010498c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104999:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ad:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)

        proc->chan = 0;
801049b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b7:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
        proc->state = RUNNING;
801049be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c4:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        release(&ptable.lock);
801049cb:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801049d2:	e8 6a 0a 00 00       	call   80105441 <release>
        return pid;
801049d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049da:	eb 5e                	jmp    80104a3a <wait+0x11d>
  for(;;){
    proc->chan = (int)proc;
    proc->state = SLEEPING;    
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049dc:	81 45 f4 9c 01 00 00 	addl   $0x19c,-0xc(%ebp)
801049e3:	81 7d f4 b4 a0 11 80 	cmpl   $0x8011a0b4,-0xc(%ebp)
801049ea:	0f 82 6f ff ff ff    	jb     8010495f <wait+0x42>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049f4:	74 0d                	je     80104a03 <wait+0xe6>
801049f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fc:	8b 40 24             	mov    0x24(%eax),%eax
801049ff:	85 c0                	test   %eax,%eax
80104a01:	74 2d                	je     80104a30 <wait+0x113>
      proc->chan = 0;
80104a03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a09:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      proc->state = RUNNING;      
80104a10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a16:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      release(&ptable.lock);
80104a1d:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104a24:	e8 18 0a 00 00       	call   80105441 <release>
      return -1;
80104a29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a2e:	eb 0a                	jmp    80104a3a <wait+0x11d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sched();
80104a30:	e8 17 01 00 00       	call   80104b4c <sched>
  }
80104a35:	e9 f5 fe ff ff       	jmp    8010492f <wait+0x12>
}
80104a3a:	c9                   	leave  
80104a3b:	c3                   	ret    

80104a3c <freeproc>:

void 
freeproc(struct proc *p)
{
80104a3c:	55                   	push   %ebp
80104a3d:	89 e5                	mov    %esp,%ebp
80104a3f:	83 ec 18             	sub    $0x18,%esp
  if (!p || p->state != ZOMBIE)
80104a42:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a46:	74 0b                	je     80104a53 <freeproc+0x17>
80104a48:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4b:	8b 40 0c             	mov    0xc(%eax),%eax
80104a4e:	83 f8 05             	cmp    $0x5,%eax
80104a51:	74 0c                	je     80104a5f <freeproc+0x23>
    panic("freeproc not zombie");
80104a53:	c7 04 24 6c 8d 10 80 	movl   $0x80108d6c,(%esp)
80104a5a:	e8 db ba ff ff       	call   8010053a <panic>
  kfree(p->kstack);
80104a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a62:	8b 40 08             	mov    0x8(%eax),%eax
80104a65:	89 04 24             	mov    %eax,(%esp)
80104a68:	e8 e9 df ff ff       	call   80102a56 <kfree>
  p->kstack = 0;
80104a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a70:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  freevm(p->pgdir);
80104a77:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7a:	8b 40 04             	mov    0x4(%eax),%eax
80104a7d:	89 04 24             	mov    %eax,(%esp)
80104a80:	e8 c1 3c 00 00       	call   80108746 <freevm>
  p->killed = 0;
80104a85:	8b 45 08             	mov    0x8(%ebp),%eax
80104a88:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
  p->chan = 0;
80104a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a92:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
}
80104a99:	c9                   	leave  
80104a9a:	c3                   	ret    

80104a9b <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a9b:	55                   	push   %ebp
80104a9c:	89 e5                	mov    %esp,%ebp
80104a9e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104aa1:	e8 4d f8 ff ff       	call   801042f3 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104aa6:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104aad:	e8 2d 09 00 00       	call   801053df <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ab2:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104ab9:	eb 77                	jmp    80104b32 <scheduler+0x97>
      if(p->state != RUNNABLE)
80104abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abe:	8b 40 0c             	mov    0xc(%eax),%eax
80104ac1:	83 f8 03             	cmp    $0x3,%eax
80104ac4:	74 02                	je     80104ac8 <scheduler+0x2d>
        continue;
80104ac6:	eb 63                	jmp    80104b2b <scheduler+0x90>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acb:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad4:	89 04 24             	mov    %eax,(%esp)
80104ad7:	e8 f7 37 00 00       	call   801082d3 <switchuvm>
      p->state = RUNNING;
80104adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adf:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104ae6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aec:	8b 40 1c             	mov    0x1c(%eax),%eax
80104aef:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104af6:	83 c2 04             	add    $0x4,%edx
80104af9:	89 44 24 04          	mov    %eax,0x4(%esp)
80104afd:	89 14 24             	mov    %edx,(%esp)
80104b00:	e8 bf 0d 00 00       	call   801058c4 <swtch>
      switchkvm();
80104b05:	e8 ac 37 00 00       	call   801082b6 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104b0a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104b11:	00 00 00 00 
      if (p->state == ZOMBIE)
80104b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b18:	8b 40 0c             	mov    0xc(%eax),%eax
80104b1b:	83 f8 05             	cmp    $0x5,%eax
80104b1e:	75 0b                	jne    80104b2b <scheduler+0x90>
        freeproc(p);
80104b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b23:	89 04 24             	mov    %eax,(%esp)
80104b26:	e8 11 ff ff ff       	call   80104a3c <freeproc>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b2b:	81 45 f4 9c 01 00 00 	addl   $0x19c,-0xc(%ebp)
80104b32:	81 7d f4 b4 a0 11 80 	cmpl   $0x8011a0b4,-0xc(%ebp)
80104b39:	72 80                	jb     80104abb <scheduler+0x20>
      // It should have changed its p->state before coming back.
      proc = 0;
      if (p->state == ZOMBIE)
        freeproc(p);
    }
    release(&ptable.lock);
80104b3b:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104b42:	e8 fa 08 00 00       	call   80105441 <release>

  }
80104b47:	e9 55 ff ff ff       	jmp    80104aa1 <scheduler+0x6>

80104b4c <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104b4c:	55                   	push   %ebp
80104b4d:	89 e5                	mov    %esp,%ebp
80104b4f:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104b52:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104b59:	e8 ab 09 00 00       	call   80105509 <holding>
80104b5e:	85 c0                	test   %eax,%eax
80104b60:	75 0c                	jne    80104b6e <sched+0x22>
    panic("sched ptable.lock");
80104b62:	c7 04 24 80 8d 10 80 	movl   $0x80108d80,(%esp)
80104b69:	e8 cc b9 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104b6e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b74:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104b7a:	83 f8 01             	cmp    $0x1,%eax
80104b7d:	74 0c                	je     80104b8b <sched+0x3f>
    panic("sched locks");
80104b7f:	c7 04 24 92 8d 10 80 	movl   $0x80108d92,(%esp)
80104b86:	e8 af b9 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104b8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b91:	8b 40 0c             	mov    0xc(%eax),%eax
80104b94:	83 f8 04             	cmp    $0x4,%eax
80104b97:	75 0c                	jne    80104ba5 <sched+0x59>
    panic("sched running");
80104b99:	c7 04 24 9e 8d 10 80 	movl   $0x80108d9e,(%esp)
80104ba0:	e8 95 b9 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104ba5:	e8 39 f7 ff ff       	call   801042e3 <readeflags>
80104baa:	25 00 02 00 00       	and    $0x200,%eax
80104baf:	85 c0                	test   %eax,%eax
80104bb1:	74 0c                	je     80104bbf <sched+0x73>
    panic("sched interruptible");
80104bb3:	c7 04 24 ac 8d 10 80 	movl   $0x80108dac,(%esp)
80104bba:	e8 7b b9 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104bbf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bc5:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104bce:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bd4:	8b 40 04             	mov    0x4(%eax),%eax
80104bd7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bde:	83 c2 1c             	add    $0x1c,%edx
80104be1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104be5:	89 14 24             	mov    %edx,(%esp)
80104be8:	e8 d7 0c 00 00       	call   801058c4 <swtch>
  cpu->intena = intena;
80104bed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bf3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bf6:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104bfc:	c9                   	leave  
80104bfd:	c3                   	ret    

80104bfe <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104bfe:	55                   	push   %ebp
80104bff:	89 e5                	mov    %esp,%ebp
80104c01:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104c04:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104c0b:	e8 cf 07 00 00       	call   801053df <acquire>
  proc->state = RUNNABLE;
80104c10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c16:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104c1d:	e8 2a ff ff ff       	call   80104b4c <sched>
  release(&ptable.lock);
80104c22:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104c29:	e8 13 08 00 00       	call   80105441 <release>
}
80104c2e:	c9                   	leave  
80104c2f:	c3                   	ret    

80104c30 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104c30:	55                   	push   %ebp
80104c31:	89 e5                	mov    %esp,%ebp
80104c33:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104c36:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104c3d:	e8 ff 07 00 00       	call   80105441 <release>

  if (first) {
80104c42:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104c47:	85 c0                	test   %eax,%eax
80104c49:	74 0f                	je     80104c5a <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104c4b:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80104c52:	00 00 00 
    initlog();
80104c55:	e8 b5 e5 ff ff       	call   8010320f <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104c5a:	c9                   	leave  
80104c5b:	c3                   	ret    

80104c5c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c5c:	55                   	push   %ebp
80104c5d:	89 e5                	mov    %esp,%ebp
80104c5f:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104c62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c68:	85 c0                	test   %eax,%eax
80104c6a:	75 0c                	jne    80104c78 <sleep+0x1c>
    panic("sleep");
80104c6c:	c7 04 24 c0 8d 10 80 	movl   $0x80108dc0,(%esp)
80104c73:	e8 c2 b8 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104c78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c7c:	75 0c                	jne    80104c8a <sleep+0x2e>
    panic("sleep without lk");
80104c7e:	c7 04 24 c6 8d 10 80 	movl   $0x80108dc6,(%esp)
80104c85:	e8 b0 b8 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c8a:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104c91:	74 17                	je     80104caa <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c93:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104c9a:	e8 40 07 00 00       	call   801053df <acquire>
    release(lk);
80104c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ca2:	89 04 24             	mov    %eax,(%esp)
80104ca5:	e8 97 07 00 00       	call   80105441 <release>
  }

  // Go to sleep.
  proc->chan = (int)chan;
80104caa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cb0:	8b 55 08             	mov    0x8(%ebp),%edx
80104cb3:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104cb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cbc:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)


  sched();
80104cc3:	e8 84 fe ff ff       	call   80104b4c <sched>

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104cc8:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104ccf:	74 17                	je     80104ce8 <sleep+0x8c>
    release(&ptable.lock);
80104cd1:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104cd8:	e8 64 07 00 00       	call   80105441 <release>
    acquire(lk);
80104cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ce0:	89 04 24             	mov    %eax,(%esp)
80104ce3:	e8 f7 06 00 00       	call   801053df <acquire>
  }
}
80104ce8:	c9                   	leave  
80104ce9:	c3                   	ret    

80104cea <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cea:	55                   	push   %ebp
80104ceb:	89 e5                	mov    %esp,%ebp
80104ced:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cf0:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
80104cf7:	eb 33                	jmp    80104d2c <wakeup1+0x42>
    if(p->state == SLEEPING && p->chan == (int)chan){
80104cf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cfc:	8b 40 0c             	mov    0xc(%eax),%eax
80104cff:	83 f8 02             	cmp    $0x2,%eax
80104d02:	75 21                	jne    80104d25 <wakeup1+0x3b>
80104d04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d07:	8b 50 20             	mov    0x20(%eax),%edx
80104d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0d:	39 c2                	cmp    %eax,%edx
80104d0f:	75 14                	jne    80104d25 <wakeup1+0x3b>
      // Tidy up.
      p->chan = 0;
80104d11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d14:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      p->state = RUNNABLE;
80104d1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d1e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d25:	81 45 fc 9c 01 00 00 	addl   $0x19c,-0x4(%ebp)
80104d2c:	81 7d fc b4 a0 11 80 	cmpl   $0x8011a0b4,-0x4(%ebp)
80104d33:	72 c4                	jb     80104cf9 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == (int)chan){
      // Tidy up.
      p->chan = 0;
      p->state = RUNNABLE;
    }
}
80104d35:	c9                   	leave  
80104d36:	c3                   	ret    

80104d37 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d37:	55                   	push   %ebp
80104d38:	89 e5                	mov    %esp,%ebp
80104d3a:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104d3d:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d44:	e8 96 06 00 00       	call   801053df <acquire>
  wakeup1(chan);
80104d49:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4c:	89 04 24             	mov    %eax,(%esp)
80104d4f:	e8 96 ff ff ff       	call   80104cea <wakeup1>
  release(&ptable.lock);
80104d54:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d5b:	e8 e1 06 00 00       	call   80105441 <release>
}
80104d60:	c9                   	leave  
80104d61:	c3                   	ret    

80104d62 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d62:	55                   	push   %ebp
80104d63:	89 e5                	mov    %esp,%ebp
80104d65:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
cprintf("my input pid is %d go over %d procs\n", pid, NPROC );
80104d68:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80104d6f:	00 
80104d70:	8b 45 08             	mov    0x8(%ebp),%eax
80104d73:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d77:	c7 04 24 d8 8d 10 80 	movl   $0x80108dd8,(%esp)
80104d7e:	e8 1d b6 ff ff       	call   801003a0 <cprintf>
  acquire(&ptable.lock);
80104d83:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d8a:	e8 50 06 00 00       	call   801053df <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d8f:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104d96:	eb 66                	jmp    80104dfe <kill+0x9c>
    
    cprintf("my pid is %d\n", p->pid );
80104d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9b:	8b 40 10             	mov    0x10(%eax),%eax
80104d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104da2:	c7 04 24 fd 8d 10 80 	movl   $0x80108dfd,(%esp)
80104da9:	e8 f2 b5 ff ff       	call   801003a0 <cprintf>
    if(p->pid == pid){
80104dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db1:	8b 40 10             	mov    0x10(%eax),%eax
80104db4:	3b 45 08             	cmp    0x8(%ebp),%eax
80104db7:	75 32                	jne    80104deb <kill+0x89>
      p->killed = 1;
80104db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc6:	8b 40 0c             	mov    0xc(%eax),%eax
80104dc9:	83 f8 02             	cmp    $0x2,%eax
80104dcc:	75 0a                	jne    80104dd8 <kill+0x76>
        p->state = RUNNABLE;
80104dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104dd8:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104ddf:	e8 5d 06 00 00       	call   80105441 <release>
      return 0;
80104de4:	b8 00 00 00 00       	mov    $0x0,%eax
80104de9:	eb 21                	jmp    80104e0c <kill+0xaa>

      //int pid_test = p->pid;
      //cas(&pid_test, pid_test, 1);
      //cprintf("res = %d,    pid = %d", res, pid_test);
//  cprintf("i'm in kill ! outside for loop, my pid is %d\n", p->pid );
    release(&ptable.lock);
80104deb:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104df2:	e8 4a 06 00 00       	call   80105441 <release>
kill(int pid)
{
  struct proc *p;
cprintf("my input pid is %d go over %d procs\n", pid, NPROC );
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104df7:	81 45 f4 9c 01 00 00 	addl   $0x19c,-0xc(%ebp)
80104dfe:	81 7d f4 b4 a0 11 80 	cmpl   $0x8011a0b4,-0xc(%ebp)
80104e05:	72 91                	jb     80104d98 <kill+0x36>
      //cprintf("res = %d,    pid = %d", res, pid_test);
//  cprintf("i'm in kill ! outside for loop, my pid is %d\n", p->pid );
    release(&ptable.lock);
  }
  
  return -1;
80104e07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e0c:	c9                   	leave  
80104e0d:	c3                   	ret    

80104e0e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104e0e:	55                   	push   %ebp
80104e0f:	89 e5                	mov    %esp,%ebp
80104e11:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e14:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80104e1b:	e9 e3 00 00 00       	jmp    80104f03 <procdump+0xf5>
    if(p->state == UNUSED)
80104e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e23:	8b 40 0c             	mov    0xc(%eax),%eax
80104e26:	85 c0                	test   %eax,%eax
80104e28:	75 05                	jne    80104e2f <procdump+0x21>
      continue;
80104e2a:	e9 cd 00 00 00       	jmp    80104efc <procdump+0xee>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e32:	8b 40 0c             	mov    0xc(%eax),%eax
80104e35:	85 c0                	test   %eax,%eax
80104e37:	78 2e                	js     80104e67 <procdump+0x59>
80104e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3c:	8b 40 0c             	mov    0xc(%eax),%eax
80104e3f:	83 f8 05             	cmp    $0x5,%eax
80104e42:	77 23                	ja     80104e67 <procdump+0x59>
80104e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e47:	8b 40 0c             	mov    0xc(%eax),%eax
80104e4a:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80104e51:	85 c0                	test   %eax,%eax
80104e53:	74 12                	je     80104e67 <procdump+0x59>
      state = states[p->state];
80104e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e58:	8b 40 0c             	mov    0xc(%eax),%eax
80104e5b:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80104e62:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e65:	eb 07                	jmp    80104e6e <procdump+0x60>
    else
      state = "???";
80104e67:	c7 45 ec 0b 8e 10 80 	movl   $0x80108e0b,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e71:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e77:	8b 40 10             	mov    0x10(%eax),%eax
80104e7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104e7e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104e81:	89 54 24 08          	mov    %edx,0x8(%esp)
80104e85:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e89:	c7 04 24 0f 8e 10 80 	movl   $0x80108e0f,(%esp)
80104e90:	e8 0b b5 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e98:	8b 40 0c             	mov    0xc(%eax),%eax
80104e9b:	83 f8 02             	cmp    $0x2,%eax
80104e9e:	75 50                	jne    80104ef0 <procdump+0xe2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea3:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ea6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea9:	83 c0 08             	add    $0x8,%eax
80104eac:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104eaf:	89 54 24 04          	mov    %edx,0x4(%esp)
80104eb3:	89 04 24             	mov    %eax,(%esp)
80104eb6:	e8 d5 05 00 00       	call   80105490 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104ebb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ec2:	eb 1b                	jmp    80104edf <procdump+0xd1>
        cprintf(" %p", pc[i]);
80104ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ecf:	c7 04 24 18 8e 10 80 	movl   $0x80108e18,(%esp)
80104ed6:	e8 c5 b4 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104edb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104edf:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ee3:	7f 0b                	jg     80104ef0 <procdump+0xe2>
80104ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104eec:	85 c0                	test   %eax,%eax
80104eee:	75 d4                	jne    80104ec4 <procdump+0xb6>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104ef0:	c7 04 24 1c 8e 10 80 	movl   $0x80108e1c,(%esp)
80104ef7:	e8 a4 b4 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104efc:	81 45 f0 9c 01 00 00 	addl   $0x19c,-0x10(%ebp)
80104f03:	81 7d f0 b4 a0 11 80 	cmpl   $0x8011a0b4,-0x10(%ebp)
80104f0a:	0f 82 10 ff ff ff    	jb     80104e20 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104f10:	c9                   	leave  
80104f11:	c3                   	ret    

80104f12 <sigset>:

void* 
sigset(void* new_handler)
{
80104f12:	55                   	push   %ebp
80104f13:	89 e5                	mov    %esp,%ebp
80104f15:	83 ec 10             	sub    $0x10,%esp
  sig_handler oldhandler = proc->sighandler; 
80104f18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f1e:	8b 40 7c             	mov    0x7c(%eax),%eax
80104f21:	89 45 fc             	mov    %eax,-0x4(%ebp)
  proc->sighandler = new_handler;
80104f24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f2a:	8b 55 08             	mov    0x8(%ebp),%edx
80104f2d:	89 50 7c             	mov    %edx,0x7c(%eax)
  return oldhandler;
80104f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f33:	c9                   	leave  
80104f34:	c3                   	ret    

80104f35 <sigsend>:

int
sigsend(int dest_pid, int value)
{
80104f35:	55                   	push   %ebp
80104f36:	89 e5                	mov    %esp,%ebp
80104f38:	83 ec 28             	sub    $0x28,%esp
  struct proc *p; 

  cprintf("sigsend - value %d\n", value);
80104f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f42:	c7 04 24 1e 8e 10 80 	movl   $0x80108e1e,(%esp)
80104f49:	e8 52 b4 ff ff       	call   801003a0 <cprintf>
  cprintf("sigsend - dest_pid %d\n", dest_pid);
80104f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f51:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f55:	c7 04 24 32 8e 10 80 	movl   $0x80108e32,(%esp)
80104f5c:	e8 3f b4 ff ff       	call   801003a0 <cprintf>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104f61:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104f68:	eb 59                	jmp    80104fc3 <sigsend+0x8e>
    if (p->pid == dest_pid) {
80104f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6d:	8b 40 10             	mov    0x10(%eax),%eax
80104f70:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f73:	75 47                	jne    80104fbc <sigsend+0x87>
      //found dest_pid process
  
      //if push succeed wakeup current proc and return 0
      if (push(&p->pending_signals, proc->pid, dest_pid, value)) 
80104f75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f7b:	8b 40 10             	mov    0x10(%eax),%eax
80104f7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f81:	8d 8a 80 00 00 00    	lea    0x80(%edx),%ecx
80104f87:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f8a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f8e:	8b 55 08             	mov    0x8(%ebp),%edx
80104f91:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f95:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f99:	89 0c 24             	mov    %ecx,(%esp)
80104f9c:	e8 d0 00 00 00       	call   80105071 <push>
80104fa1:	85 c0                	test   %eax,%eax
80104fa3:	74 15                	je     80104fba <sigsend+0x85>
      {
        wakeup((void*)p->chan);
80104fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa8:	8b 40 20             	mov    0x20(%eax),%eax
80104fab:	89 04 24             	mov    %eax,(%esp)
80104fae:	e8 84 fd ff ff       	call   80104d37 <wakeup>
        return 0;
80104fb3:	b8 00 00 00 00       	mov    $0x0,%eax
80104fb8:	eb 17                	jmp    80104fd1 <sigsend+0x9c>
      }
      break;
80104fba:	eb 10                	jmp    80104fcc <sigsend+0x97>
  struct proc *p; 

  cprintf("sigsend - value %d\n", value);
  cprintf("sigsend - dest_pid %d\n", dest_pid);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104fbc:	81 45 f4 9c 01 00 00 	addl   $0x19c,-0xc(%ebp)
80104fc3:	81 7d f4 b4 a0 11 80 	cmpl   $0x8011a0b4,-0xc(%ebp)
80104fca:	72 9e                	jb     80104f6a <sigsend+0x35>
        return 0;
      }
      break;
    }
  }
  return -1;  
80104fcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fd1:	c9                   	leave  
80104fd2:	c3                   	ret    

80104fd3 <sigret>:


int
sigret(void)
{
80104fd3:	55                   	push   %ebp
80104fd4:	89 e5                	mov    %esp,%ebp
80104fd6:	57                   	push   %edi
80104fd7:	56                   	push   %esi
80104fd8:	53                   	push   %ebx
  // restore origin user stack
  *(proc->tf) = proc->old_tf; 
80104fd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fdf:	8b 50 18             	mov    0x18(%eax),%edx
80104fe2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fe8:	8d 98 4c 01 00 00    	lea    0x14c(%eax),%ebx
80104fee:	b8 13 00 00 00       	mov    $0x13,%eax
80104ff3:	89 d7                	mov    %edx,%edi
80104ff5:	89 de                	mov    %ebx,%esi
80104ff7:	89 c1                	mov    %eax,%ecx
80104ff9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  //*(proc->tf) = *(proc->old_tf);  //TODO: change to line above

  //finish handling signal so we could handle the next one
  proc->handling_signal = 0;
80104ffb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105001:	c7 80 98 01 00 00 00 	movl   $0x0,0x198(%eax)
80105008:	00 00 00 
  return 0;
8010500b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105010:	5b                   	pop    %ebx
80105011:	5e                   	pop    %esi
80105012:	5f                   	pop    %edi
80105013:	5d                   	pop    %ebp
80105014:	c3                   	ret    

80105015 <sigpause>:

int
sigpause(void)
{
80105015:	55                   	push   %ebp
80105016:	89 e5                	mov    %esp,%ebp
80105018:	83 ec 18             	sub    $0x18,%esp
  if (is_empty(&(proc->pending_signals))) {
8010501b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105021:	83 e8 80             	sub    $0xffffff80,%eax
80105024:	89 04 24             	mov    %eax,(%esp)
80105027:	e8 5b 01 00 00       	call   80105187 <is_empty>
8010502c:	85 c0                	test   %eax,%eax
8010502e:	74 3a                	je     8010506a <sigpause+0x55>
    acquire(&ptable.lock);
80105030:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105037:	e8 a3 03 00 00       	call   801053df <acquire>
    //do {
      proc->chan = (int)proc;
8010503c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105042:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105049:	89 50 20             	mov    %edx,0x20(%eax)
    //} while (!cas(&proc->chan, 0, 1));

    proc->state = SLEEPING;
8010504c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105052:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
    sched();
80105059:	e8 ee fa ff ff       	call   80104b4c <sched>
    release(&ptable.lock);
8010505e:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105065:	e8 d7 03 00 00       	call   80105441 <release>
  }

  return 0;
8010506a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010506f:	c9                   	leave  
80105070:	c3                   	ret    

80105071 <push>:


// -------------- cstack implementation ------------
int 
push(struct cstack *cstack, int sender_pid, int recepient_pid, int value)
{
80105071:	55                   	push   %ebp
80105072:	89 e5                	mov    %esp,%ebp
80105074:	83 ec 28             	sub    $0x28,%esp
  struct cstackframe *csf;
  for(csf = cstack->frames; csf < &cstack->frames[MAX_CSTACK_FRAMES]; csf++) {
80105077:	8b 45 08             	mov    0x8(%ebp),%eax
8010507a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010507d:	eb 48                	jmp    801050c7 <push+0x56>
    if(cas(&csf->used, 0, 1)) 
8010507f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105082:	83 c0 0c             	add    $0xc,%eax
80105085:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010508c:	00 
8010508d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105094:	00 
80105095:	89 04 24             	mov    %eax,(%esp)
80105098:	e8 5c f2 ff ff       	call   801042f9 <cas>
8010509d:	85 c0                	test   %eax,%eax
8010509f:	74 1d                	je     801050be <push+0x4d>
      goto found;
801050a1:	90                   	nop
  return 0;

  //found an unused signal
  found:
  // copy values
  csf->sender_pid = sender_pid;
801050a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a5:	8b 55 0c             	mov    0xc(%ebp),%edx
801050a8:	89 10                	mov    %edx,(%eax)
  csf->recepient_pid = recepient_pid;
801050aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ad:	8b 55 10             	mov    0x10(%ebp),%edx
801050b0:	89 50 04             	mov    %edx,0x4(%eax)
  csf->value = value;
801050b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b6:	8b 55 14             	mov    0x14(%ebp),%edx
801050b9:	89 50 08             	mov    %edx,0x8(%eax)
801050bc:	eb 20                	jmp    801050de <push+0x6d>
// -------------- cstack implementation ------------
int 
push(struct cstack *cstack, int sender_pid, int recepient_pid, int value)
{
  struct cstackframe *csf;
  for(csf = cstack->frames; csf < &cstack->frames[MAX_CSTACK_FRAMES]; csf++) {
801050be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c1:	83 c0 14             	add    $0x14,%eax
801050c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050c7:	8b 45 08             	mov    0x8(%ebp),%eax
801050ca:	8d 90 c8 00 00 00    	lea    0xc8(%eax),%edx
801050d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d3:	39 c2                	cmp    %eax,%edx
801050d5:	77 a8                	ja     8010507f <push+0xe>
    if(cas(&csf->used, 0, 1)) 
      goto found;
  }

  //stack is full
  return 0;
801050d7:	b8 00 00 00 00       	mov    $0x0,%eax
801050dc:	eb 60                	jmp    8010513e <push+0xcd>
  csf->sender_pid = sender_pid;
  csf->recepient_pid = recepient_pid;
  csf->value = value;
  
  do {
    csf->next = cstack->head;
801050de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e1:	8b 55 08             	mov    0x8(%ebp),%edx
801050e4:	8b 92 c8 00 00 00    	mov    0xc8(%edx),%edx
801050ea:	89 50 10             	mov    %edx,0x10(%eax)
  } while (!cas((int*)&(cstack->head), (int)csf->next, (int)&csf));
801050ed:	8d 55 f4             	lea    -0xc(%ebp),%edx
801050f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f3:	8b 40 10             	mov    0x10(%eax),%eax
801050f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050f9:	81 c1 c8 00 00 00    	add    $0xc8,%ecx
801050ff:	89 54 24 08          	mov    %edx,0x8(%esp)
80105103:	89 44 24 04          	mov    %eax,0x4(%esp)
80105107:	89 0c 24             	mov    %ecx,(%esp)
8010510a:	e8 ea f1 ff ff       	call   801042f9 <cas>
8010510f:	85 c0                	test   %eax,%eax
80105111:	74 cb                	je     801050de <push+0x6d>

  cprintf("push - value %d\n", value);
80105113:	8b 45 14             	mov    0x14(%ebp),%eax
80105116:	89 44 24 04          	mov    %eax,0x4(%esp)
8010511a:	c7 04 24 49 8e 10 80 	movl   $0x80108e49,(%esp)
80105121:	e8 7a b2 ff ff       	call   801003a0 <cprintf>
  cprintf("push - sender_pid %d\n", sender_pid);
80105126:	8b 45 0c             	mov    0xc(%ebp),%eax
80105129:	89 44 24 04          	mov    %eax,0x4(%esp)
8010512d:	c7 04 24 5a 8e 10 80 	movl   $0x80108e5a,(%esp)
80105134:	e8 67 b2 ff ff       	call   801003a0 <cprintf>

  return 1;
80105139:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010513e:	c9                   	leave  
8010513f:	c3                   	ret    

80105140 <pop>:

struct cstackframe*
pop(struct cstack *cstack)
{
80105140:	55                   	push   %ebp
80105141:	89 e5                	mov    %esp,%ebp
80105143:	83 ec 1c             	sub    $0x1c,%esp
  struct cstackframe *csf;
  struct cstackframe *next;
  
  do {
    csf = cstack->head;
80105146:	8b 45 08             	mov    0x8(%ebp),%eax
80105149:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
8010514f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (!csf)
80105152:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105156:	75 07                	jne    8010515f <pop+0x1f>
      return 0;
80105158:	b8 00 00 00 00       	mov    $0x0,%eax
8010515d:	eb 26                	jmp    80105185 <pop+0x45>

  } while (!cas((int*)&(cstack->head), (int)csf, (int)&next));
8010515f:	8d 55 f8             	lea    -0x8(%ebp),%edx
80105162:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105165:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105168:	81 c1 c8 00 00 00    	add    $0xc8,%ecx
8010516e:	89 54 24 08          	mov    %edx,0x8(%esp)
80105172:	89 44 24 04          	mov    %eax,0x4(%esp)
80105176:	89 0c 24             	mov    %ecx,(%esp)
80105179:	e8 7b f1 ff ff       	call   801042f9 <cas>
8010517e:	85 c0                	test   %eax,%eax
80105180:	74 c4                	je     80105146 <pop+0x6>
  
  //csf->used = 0;
  return csf;
80105182:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105185:	c9                   	leave  
80105186:	c3                   	ret    

80105187 <is_empty>:

int
is_empty(struct cstack *cstack)
{
80105187:	55                   	push   %ebp
80105188:	89 e5                	mov    %esp,%ebp
  return cstack->head == 0 ? 1 : 0;
8010518a:	8b 45 08             	mov    0x8(%ebp),%eax
8010518d:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80105193:	85 c0                	test   %eax,%eax
80105195:	0f 94 c0             	sete   %al
80105198:	0f b6 c0             	movzbl %al,%eax
}
8010519b:	5d                   	pop    %ebp
8010519c:	c3                   	ret    

8010519d <fix_tf>:

void
fix_tf(void)
{ 
8010519d:	55                   	push   %ebp
8010519e:	89 e5                	mov    %esp,%ebp
801051a0:	57                   	push   %edi
801051a1:	56                   	push   %esi
801051a2:	53                   	push   %ebx
801051a3:	83 ec 2c             	sub    $0x2c,%esp
  if (proc == 0)  //no proccess
801051a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051ac:	85 c0                	test   %eax,%eax
801051ae:	75 05                	jne    801051b5 <fix_tf+0x18>
    return;
801051b0:	e9 cb 01 00 00       	jmp    80105380 <fix_tf+0x1e3>

  if (((proc->tf->cs) & 3) != DPL_USER) //has no user privilge
801051b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051bb:	8b 40 18             	mov    0x18(%eax),%eax
801051be:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801051c2:	0f b7 c0             	movzwl %ax,%eax
801051c5:	83 e0 03             	and    $0x3,%eax
801051c8:	83 f8 03             	cmp    $0x3,%eax
801051cb:	74 05                	je     801051d2 <fix_tf+0x35>
    return;
801051cd:	e9 ae 01 00 00       	jmp    80105380 <fix_tf+0x1e3>

  // if proc already handling a signal then return
  if (proc->handling_signal == 1)
801051d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051d8:	8b 80 98 01 00 00    	mov    0x198(%eax),%eax
801051de:	83 f8 01             	cmp    $0x1,%eax
801051e1:	75 05                	jne    801051e8 <fix_tf+0x4b>
    goto done;
801051e3:	e9 98 01 00 00       	jmp    80105380 <fix_tf+0x1e3>

  struct cstackframe *new_signal;
  // no pending signal in the stack  OR  signal_handler is default
  if(!(new_signal = pop(&proc->pending_signals)) || proc->sighandler == DEFSIG_HENDLER)
801051e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051ee:	83 e8 80             	sub    $0xffffff80,%eax
801051f1:	89 04 24             	mov    %eax,(%esp)
801051f4:	e8 47 ff ff ff       	call   80105140 <pop>
801051f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801051fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80105200:	0f 84 7a 01 00 00    	je     80105380 <fix_tf+0x1e3>
80105206:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010520c:	8b 40 7c             	mov    0x7c(%eax),%eax
8010520f:	83 f8 ff             	cmp    $0xffffffff,%eax
80105212:	0f 84 68 01 00 00    	je     80105380 <fix_tf+0x1e3>
    goto done; 
  //else, we have a pending signal and a handler: 

  // back-up the old trap-frame for handeling user stack
  proc->old_tf = *(proc->tf);
80105218:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010521f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105225:	8b 40 18             	mov    0x18(%eax),%eax
80105228:	8d 9a 4c 01 00 00    	lea    0x14c(%edx),%ebx
8010522e:	89 c2                	mov    %eax,%edx
80105230:	b8 13 00 00 00       	mov    $0x13,%eax
80105235:	89 df                	mov    %ebx,%edi
80105237:	89 d6                	mov    %edx,%esi
80105239:	89 c1                	mov    %eax,%ecx
8010523b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  //*(proc->old_tf) = *(proc->tf);//TODO: change to line above 

  // up the flag for preventing proc to handle more than 1 signal
  proc->handling_signal = 1;
8010523d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105243:	c7 80 98 01 00 00 01 	movl   $0x1,0x198(%eax)
8010524a:	00 00 00 

  int addr_space; 
  // int esp_backup;

  int stam = 0;
8010524d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  if (1 == stam) {
80105254:	83 7d e0 01          	cmpl   $0x1,-0x20(%ebp)
80105258:	75 07                	jne    80105261 <fix_tf+0xc4>
    goToStack: // lable#1
    asm volatile("movl $24, %eax; int $64"); //movl $SYS_sigret, %eax; int $T_SYSCALL; 
8010525a:	b8 18 00 00 00       	mov    $0x18,%eax
8010525f:	cd 40                	int    $0x40
    returnFromStack:; // lable#2
  }

  new_signal->used = 0;
80105261:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105264:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  addr_space = 8;//&&goToStack - &&returnFromStack;
8010526b:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)

  cprintf("&&goToStack=0x%x &&returnFromStack=0x%x", 
80105272:	c7 44 24 08 61 52 10 	movl   $0x80105261,0x8(%esp)
80105279:	80 
8010527a:	c7 44 24 04 5a 52 10 	movl   $0x8010525a,0x4(%esp)
80105281:	80 
80105282:	c7 04 24 70 8e 10 80 	movl   $0x80108e70,(%esp)
80105289:	e8 12 b1 ff ff       	call   801003a0 <cprintf>
    &&goToStack, &&returnFromStack);
  //esp_backup = proc->tf->esp - 4;

  proc->tf->esp -= addr_space;
8010528e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105294:	8b 40 18             	mov    0x18(%eax),%eax
80105297:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010529e:	8b 52 18             	mov    0x18(%edx),%edx
801052a1:	8b 4a 44             	mov    0x44(%edx),%ecx
801052a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801052a7:	29 d1                	sub    %edx,%ecx
801052a9:	89 ca                	mov    %ecx,%edx
801052ab:	89 50 44             	mov    %edx,0x44(%eax)
  memmove((void *)proc->tf->esp, &&goToStack, addr_space);
801052ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
801052b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052b7:	8b 40 18             	mov    0x18(%eax),%eax
801052ba:	8b 40 44             	mov    0x44(%eax),%eax
801052bd:	89 54 24 08          	mov    %edx,0x8(%esp)
801052c1:	c7 44 24 04 5a 52 10 	movl   $0x8010525a,0x4(%esp)
801052c8:	80 
801052c9:	89 04 24             	mov    %eax,(%esp)
801052cc:	e8 31 04 00 00       	call   80105702 <memmove>

  proc->tf->esp -= 4;
801052d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052d7:	8b 40 18             	mov    0x18(%eax),%eax
801052da:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052e1:	8b 52 18             	mov    0x18(%edx),%edx
801052e4:	8b 52 44             	mov    0x44(%edx),%edx
801052e7:	83 ea 04             	sub    $0x4,%edx
801052ea:	89 50 44             	mov    %edx,0x44(%eax)
  *(uint *)proc->tf->esp = new_signal->value;      //param 2
801052ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052f3:	8b 40 18             	mov    0x18(%eax),%eax
801052f6:	8b 40 44             	mov    0x44(%eax),%eax
801052f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801052fc:	8b 52 08             	mov    0x8(%edx),%edx
801052ff:	89 10                	mov    %edx,(%eax)

  proc->tf->esp -= 4;
80105301:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105307:	8b 40 18             	mov    0x18(%eax),%eax
8010530a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105311:	8b 52 18             	mov    0x18(%edx),%edx
80105314:	8b 52 44             	mov    0x44(%edx),%edx
80105317:	83 ea 04             	sub    $0x4,%edx
8010531a:	89 50 44             	mov    %edx,0x44(%eax)
  *(uint *)proc->tf->esp = new_signal->sender_pid; //param 1
8010531d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105323:	8b 40 18             	mov    0x18(%eax),%eax
80105326:	8b 40 44             	mov    0x44(%eax),%eax
80105329:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010532c:	8b 12                	mov    (%edx),%edx
8010532e:	89 10                	mov    %edx,(%eax)

  proc->tf->esp -= 4;
80105330:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105336:	8b 40 18             	mov    0x18(%eax),%eax
80105339:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105340:	8b 52 18             	mov    0x18(%edx),%edx
80105343:	8b 52 44             	mov    0x44(%edx),%edx
80105346:	83 ea 04             	sub    $0x4,%edx
80105349:	89 50 44             	mov    %edx,0x44(%eax)
  *(uint *)proc->tf->esp = proc->tf->esp + 12;     //address for return 
8010534c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105352:	8b 40 18             	mov    0x18(%eax),%eax
80105355:	8b 40 44             	mov    0x44(%eax),%eax
80105358:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010535f:	8b 52 18             	mov    0x18(%edx),%edx
80105362:	8b 52 44             	mov    0x44(%edx),%edx
80105365:	83 c2 0c             	add    $0xc,%edx
80105368:	89 10                	mov    %edx,(%eax)

  proc->tf->eip = (int)proc->sighandler;    
8010536a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105370:	8b 40 18             	mov    0x18(%eax),%eax
80105373:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010537a:	8b 52 7c             	mov    0x7c(%edx),%edx
8010537d:	89 50 38             	mov    %edx,0x38(%eax)

  done:;
80105380:	83 c4 2c             	add    $0x2c,%esp
80105383:	5b                   	pop    %ebx
80105384:	5e                   	pop    %esi
80105385:	5f                   	pop    %edi
80105386:	5d                   	pop    %ebp
80105387:	c3                   	ret    

80105388 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105388:	55                   	push   %ebp
80105389:	89 e5                	mov    %esp,%ebp
8010538b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010538e:	9c                   	pushf  
8010538f:	58                   	pop    %eax
80105390:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105393:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105396:	c9                   	leave  
80105397:	c3                   	ret    

80105398 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105398:	55                   	push   %ebp
80105399:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010539b:	fa                   	cli    
}
8010539c:	5d                   	pop    %ebp
8010539d:	c3                   	ret    

8010539e <sti>:

static inline void
sti(void)
{
8010539e:	55                   	push   %ebp
8010539f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801053a1:	fb                   	sti    
}
801053a2:	5d                   	pop    %ebp
801053a3:	c3                   	ret    

801053a4 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801053a4:	55                   	push   %ebp
801053a5:	89 e5                	mov    %esp,%ebp
801053a7:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801053aa:	8b 55 08             	mov    0x8(%ebp),%edx
801053ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053b3:	f0 87 02             	lock xchg %eax,(%edx)
801053b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801053b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053bc:	c9                   	leave  
801053bd:	c3                   	ret    

801053be <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801053be:	55                   	push   %ebp
801053bf:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801053c1:	8b 45 08             	mov    0x8(%ebp),%eax
801053c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801053c7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801053ca:	8b 45 08             	mov    0x8(%ebp),%eax
801053cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801053d3:	8b 45 08             	mov    0x8(%ebp),%eax
801053d6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801053dd:	5d                   	pop    %ebp
801053de:	c3                   	ret    

801053df <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801053df:	55                   	push   %ebp
801053e0:	89 e5                	mov    %esp,%ebp
801053e2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801053e5:	e8 49 01 00 00       	call   80105533 <pushcli>
  if(holding(lk))
801053ea:	8b 45 08             	mov    0x8(%ebp),%eax
801053ed:	89 04 24             	mov    %eax,(%esp)
801053f0:	e8 14 01 00 00       	call   80105509 <holding>
801053f5:	85 c0                	test   %eax,%eax
801053f7:	74 0c                	je     80105405 <acquire+0x26>
    panic("acquire");
801053f9:	c7 04 24 c2 8e 10 80 	movl   $0x80108ec2,(%esp)
80105400:	e8 35 b1 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105405:	90                   	nop
80105406:	8b 45 08             	mov    0x8(%ebp),%eax
80105409:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105410:	00 
80105411:	89 04 24             	mov    %eax,(%esp)
80105414:	e8 8b ff ff ff       	call   801053a4 <xchg>
80105419:	85 c0                	test   %eax,%eax
8010541b:	75 e9                	jne    80105406 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010541d:	8b 45 08             	mov    0x8(%ebp),%eax
80105420:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105427:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010542a:	8b 45 08             	mov    0x8(%ebp),%eax
8010542d:	83 c0 0c             	add    $0xc,%eax
80105430:	89 44 24 04          	mov    %eax,0x4(%esp)
80105434:	8d 45 08             	lea    0x8(%ebp),%eax
80105437:	89 04 24             	mov    %eax,(%esp)
8010543a:	e8 51 00 00 00       	call   80105490 <getcallerpcs>
}
8010543f:	c9                   	leave  
80105440:	c3                   	ret    

80105441 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105441:	55                   	push   %ebp
80105442:	89 e5                	mov    %esp,%ebp
80105444:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105447:	8b 45 08             	mov    0x8(%ebp),%eax
8010544a:	89 04 24             	mov    %eax,(%esp)
8010544d:	e8 b7 00 00 00       	call   80105509 <holding>
80105452:	85 c0                	test   %eax,%eax
80105454:	75 0c                	jne    80105462 <release+0x21>
    panic("release");
80105456:	c7 04 24 ca 8e 10 80 	movl   $0x80108eca,(%esp)
8010545d:	e8 d8 b0 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80105462:	8b 45 08             	mov    0x8(%ebp),%eax
80105465:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010546c:	8b 45 08             	mov    0x8(%ebp),%eax
8010546f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105476:	8b 45 08             	mov    0x8(%ebp),%eax
80105479:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105480:	00 
80105481:	89 04 24             	mov    %eax,(%esp)
80105484:	e8 1b ff ff ff       	call   801053a4 <xchg>

  popcli();
80105489:	e8 e9 00 00 00       	call   80105577 <popcli>
}
8010548e:	c9                   	leave  
8010548f:	c3                   	ret    

80105490 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105490:	55                   	push   %ebp
80105491:	89 e5                	mov    %esp,%ebp
80105493:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105496:	8b 45 08             	mov    0x8(%ebp),%eax
80105499:	83 e8 08             	sub    $0x8,%eax
8010549c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010549f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801054a6:	eb 38                	jmp    801054e0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801054a8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801054ac:	74 38                	je     801054e6 <getcallerpcs+0x56>
801054ae:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801054b5:	76 2f                	jbe    801054e6 <getcallerpcs+0x56>
801054b7:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801054bb:	74 29                	je     801054e6 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
801054bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801054c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ca:	01 c2                	add    %eax,%edx
801054cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054cf:	8b 40 04             	mov    0x4(%eax),%eax
801054d2:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801054d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d7:	8b 00                	mov    (%eax),%eax
801054d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801054dc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054e0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054e4:	7e c2                	jle    801054a8 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054e6:	eb 19                	jmp    80105501 <getcallerpcs+0x71>
    pcs[i] = 0;
801054e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801054f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f5:	01 d0                	add    %edx,%eax
801054f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054fd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105501:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105505:	7e e1                	jle    801054e8 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105507:	c9                   	leave  
80105508:	c3                   	ret    

80105509 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105509:	55                   	push   %ebp
8010550a:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010550c:	8b 45 08             	mov    0x8(%ebp),%eax
8010550f:	8b 00                	mov    (%eax),%eax
80105511:	85 c0                	test   %eax,%eax
80105513:	74 17                	je     8010552c <holding+0x23>
80105515:	8b 45 08             	mov    0x8(%ebp),%eax
80105518:	8b 50 08             	mov    0x8(%eax),%edx
8010551b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105521:	39 c2                	cmp    %eax,%edx
80105523:	75 07                	jne    8010552c <holding+0x23>
80105525:	b8 01 00 00 00       	mov    $0x1,%eax
8010552a:	eb 05                	jmp    80105531 <holding+0x28>
8010552c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105531:	5d                   	pop    %ebp
80105532:	c3                   	ret    

80105533 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105533:	55                   	push   %ebp
80105534:	89 e5                	mov    %esp,%ebp
80105536:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105539:	e8 4a fe ff ff       	call   80105388 <readeflags>
8010553e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105541:	e8 52 fe ff ff       	call   80105398 <cli>
  if(cpu->ncli++ == 0)
80105546:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010554d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105553:	8d 48 01             	lea    0x1(%eax),%ecx
80105556:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010555c:	85 c0                	test   %eax,%eax
8010555e:	75 15                	jne    80105575 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105560:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105566:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105569:	81 e2 00 02 00 00    	and    $0x200,%edx
8010556f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105575:	c9                   	leave  
80105576:	c3                   	ret    

80105577 <popcli>:

void
popcli(void)
{
80105577:	55                   	push   %ebp
80105578:	89 e5                	mov    %esp,%ebp
8010557a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010557d:	e8 06 fe ff ff       	call   80105388 <readeflags>
80105582:	25 00 02 00 00       	and    $0x200,%eax
80105587:	85 c0                	test   %eax,%eax
80105589:	74 0c                	je     80105597 <popcli+0x20>
    panic("popcli - interruptible");
8010558b:	c7 04 24 d2 8e 10 80 	movl   $0x80108ed2,(%esp)
80105592:	e8 a3 af ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105597:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010559d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801055a3:	83 ea 01             	sub    $0x1,%edx
801055a6:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801055ac:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801055b2:	85 c0                	test   %eax,%eax
801055b4:	79 0c                	jns    801055c2 <popcli+0x4b>
    panic("popcli");
801055b6:	c7 04 24 e9 8e 10 80 	movl   $0x80108ee9,(%esp)
801055bd:	e8 78 af ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
801055c2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055c8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801055ce:	85 c0                	test   %eax,%eax
801055d0:	75 15                	jne    801055e7 <popcli+0x70>
801055d2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055d8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801055de:	85 c0                	test   %eax,%eax
801055e0:	74 05                	je     801055e7 <popcli+0x70>
    sti();
801055e2:	e8 b7 fd ff ff       	call   8010539e <sti>
}
801055e7:	c9                   	leave  
801055e8:	c3                   	ret    

801055e9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801055e9:	55                   	push   %ebp
801055ea:	89 e5                	mov    %esp,%ebp
801055ec:	57                   	push   %edi
801055ed:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801055ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055f1:	8b 55 10             	mov    0x10(%ebp),%edx
801055f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f7:	89 cb                	mov    %ecx,%ebx
801055f9:	89 df                	mov    %ebx,%edi
801055fb:	89 d1                	mov    %edx,%ecx
801055fd:	fc                   	cld    
801055fe:	f3 aa                	rep stos %al,%es:(%edi)
80105600:	89 ca                	mov    %ecx,%edx
80105602:	89 fb                	mov    %edi,%ebx
80105604:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105607:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010560a:	5b                   	pop    %ebx
8010560b:	5f                   	pop    %edi
8010560c:	5d                   	pop    %ebp
8010560d:	c3                   	ret    

8010560e <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010560e:	55                   	push   %ebp
8010560f:	89 e5                	mov    %esp,%ebp
80105611:	57                   	push   %edi
80105612:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105613:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105616:	8b 55 10             	mov    0x10(%ebp),%edx
80105619:	8b 45 0c             	mov    0xc(%ebp),%eax
8010561c:	89 cb                	mov    %ecx,%ebx
8010561e:	89 df                	mov    %ebx,%edi
80105620:	89 d1                	mov    %edx,%ecx
80105622:	fc                   	cld    
80105623:	f3 ab                	rep stos %eax,%es:(%edi)
80105625:	89 ca                	mov    %ecx,%edx
80105627:	89 fb                	mov    %edi,%ebx
80105629:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010562c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010562f:	5b                   	pop    %ebx
80105630:	5f                   	pop    %edi
80105631:	5d                   	pop    %ebp
80105632:	c3                   	ret    

80105633 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105633:	55                   	push   %ebp
80105634:	89 e5                	mov    %esp,%ebp
80105636:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105639:	8b 45 08             	mov    0x8(%ebp),%eax
8010563c:	83 e0 03             	and    $0x3,%eax
8010563f:	85 c0                	test   %eax,%eax
80105641:	75 49                	jne    8010568c <memset+0x59>
80105643:	8b 45 10             	mov    0x10(%ebp),%eax
80105646:	83 e0 03             	and    $0x3,%eax
80105649:	85 c0                	test   %eax,%eax
8010564b:	75 3f                	jne    8010568c <memset+0x59>
    c &= 0xFF;
8010564d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105654:	8b 45 10             	mov    0x10(%ebp),%eax
80105657:	c1 e8 02             	shr    $0x2,%eax
8010565a:	89 c2                	mov    %eax,%edx
8010565c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010565f:	c1 e0 18             	shl    $0x18,%eax
80105662:	89 c1                	mov    %eax,%ecx
80105664:	8b 45 0c             	mov    0xc(%ebp),%eax
80105667:	c1 e0 10             	shl    $0x10,%eax
8010566a:	09 c1                	or     %eax,%ecx
8010566c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010566f:	c1 e0 08             	shl    $0x8,%eax
80105672:	09 c8                	or     %ecx,%eax
80105674:	0b 45 0c             	or     0xc(%ebp),%eax
80105677:	89 54 24 08          	mov    %edx,0x8(%esp)
8010567b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010567f:	8b 45 08             	mov    0x8(%ebp),%eax
80105682:	89 04 24             	mov    %eax,(%esp)
80105685:	e8 84 ff ff ff       	call   8010560e <stosl>
8010568a:	eb 19                	jmp    801056a5 <memset+0x72>
  } else
    stosb(dst, c, n);
8010568c:	8b 45 10             	mov    0x10(%ebp),%eax
8010568f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105693:	8b 45 0c             	mov    0xc(%ebp),%eax
80105696:	89 44 24 04          	mov    %eax,0x4(%esp)
8010569a:	8b 45 08             	mov    0x8(%ebp),%eax
8010569d:	89 04 24             	mov    %eax,(%esp)
801056a0:	e8 44 ff ff ff       	call   801055e9 <stosb>
  return dst;
801056a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056a8:	c9                   	leave  
801056a9:	c3                   	ret    

801056aa <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801056aa:	55                   	push   %ebp
801056ab:	89 e5                	mov    %esp,%ebp
801056ad:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801056b0:	8b 45 08             	mov    0x8(%ebp),%eax
801056b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801056b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801056bc:	eb 30                	jmp    801056ee <memcmp+0x44>
    if(*s1 != *s2)
801056be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c1:	0f b6 10             	movzbl (%eax),%edx
801056c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056c7:	0f b6 00             	movzbl (%eax),%eax
801056ca:	38 c2                	cmp    %al,%dl
801056cc:	74 18                	je     801056e6 <memcmp+0x3c>
      return *s1 - *s2;
801056ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056d1:	0f b6 00             	movzbl (%eax),%eax
801056d4:	0f b6 d0             	movzbl %al,%edx
801056d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056da:	0f b6 00             	movzbl (%eax),%eax
801056dd:	0f b6 c0             	movzbl %al,%eax
801056e0:	29 c2                	sub    %eax,%edx
801056e2:	89 d0                	mov    %edx,%eax
801056e4:	eb 1a                	jmp    80105700 <memcmp+0x56>
    s1++, s2++;
801056e6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056ea:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801056ee:	8b 45 10             	mov    0x10(%ebp),%eax
801056f1:	8d 50 ff             	lea    -0x1(%eax),%edx
801056f4:	89 55 10             	mov    %edx,0x10(%ebp)
801056f7:	85 c0                	test   %eax,%eax
801056f9:	75 c3                	jne    801056be <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801056fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105700:	c9                   	leave  
80105701:	c3                   	ret    

80105702 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105702:	55                   	push   %ebp
80105703:	89 e5                	mov    %esp,%ebp
80105705:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105708:	8b 45 0c             	mov    0xc(%ebp),%eax
8010570b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010570e:	8b 45 08             	mov    0x8(%ebp),%eax
80105711:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105714:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105717:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010571a:	73 3d                	jae    80105759 <memmove+0x57>
8010571c:	8b 45 10             	mov    0x10(%ebp),%eax
8010571f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105722:	01 d0                	add    %edx,%eax
80105724:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105727:	76 30                	jbe    80105759 <memmove+0x57>
    s += n;
80105729:	8b 45 10             	mov    0x10(%ebp),%eax
8010572c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010572f:	8b 45 10             	mov    0x10(%ebp),%eax
80105732:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105735:	eb 13                	jmp    8010574a <memmove+0x48>
      *--d = *--s;
80105737:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010573b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010573f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105742:	0f b6 10             	movzbl (%eax),%edx
80105745:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105748:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010574a:	8b 45 10             	mov    0x10(%ebp),%eax
8010574d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105750:	89 55 10             	mov    %edx,0x10(%ebp)
80105753:	85 c0                	test   %eax,%eax
80105755:	75 e0                	jne    80105737 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105757:	eb 26                	jmp    8010577f <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105759:	eb 17                	jmp    80105772 <memmove+0x70>
      *d++ = *s++;
8010575b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010575e:	8d 50 01             	lea    0x1(%eax),%edx
80105761:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105764:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105767:	8d 4a 01             	lea    0x1(%edx),%ecx
8010576a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010576d:	0f b6 12             	movzbl (%edx),%edx
80105770:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105772:	8b 45 10             	mov    0x10(%ebp),%eax
80105775:	8d 50 ff             	lea    -0x1(%eax),%edx
80105778:	89 55 10             	mov    %edx,0x10(%ebp)
8010577b:	85 c0                	test   %eax,%eax
8010577d:	75 dc                	jne    8010575b <memmove+0x59>
      *d++ = *s++;

  return dst;
8010577f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105782:	c9                   	leave  
80105783:	c3                   	ret    

80105784 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105784:	55                   	push   %ebp
80105785:	89 e5                	mov    %esp,%ebp
80105787:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010578a:	8b 45 10             	mov    0x10(%ebp),%eax
8010578d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105791:	8b 45 0c             	mov    0xc(%ebp),%eax
80105794:	89 44 24 04          	mov    %eax,0x4(%esp)
80105798:	8b 45 08             	mov    0x8(%ebp),%eax
8010579b:	89 04 24             	mov    %eax,(%esp)
8010579e:	e8 5f ff ff ff       	call   80105702 <memmove>
}
801057a3:	c9                   	leave  
801057a4:	c3                   	ret    

801057a5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801057a5:	55                   	push   %ebp
801057a6:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801057a8:	eb 0c                	jmp    801057b6 <strncmp+0x11>
    n--, p++, q++;
801057aa:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057ae:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801057b2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801057b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057ba:	74 1a                	je     801057d6 <strncmp+0x31>
801057bc:	8b 45 08             	mov    0x8(%ebp),%eax
801057bf:	0f b6 00             	movzbl (%eax),%eax
801057c2:	84 c0                	test   %al,%al
801057c4:	74 10                	je     801057d6 <strncmp+0x31>
801057c6:	8b 45 08             	mov    0x8(%ebp),%eax
801057c9:	0f b6 10             	movzbl (%eax),%edx
801057cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801057cf:	0f b6 00             	movzbl (%eax),%eax
801057d2:	38 c2                	cmp    %al,%dl
801057d4:	74 d4                	je     801057aa <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801057d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057da:	75 07                	jne    801057e3 <strncmp+0x3e>
    return 0;
801057dc:	b8 00 00 00 00       	mov    $0x0,%eax
801057e1:	eb 16                	jmp    801057f9 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801057e3:	8b 45 08             	mov    0x8(%ebp),%eax
801057e6:	0f b6 00             	movzbl (%eax),%eax
801057e9:	0f b6 d0             	movzbl %al,%edx
801057ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ef:	0f b6 00             	movzbl (%eax),%eax
801057f2:	0f b6 c0             	movzbl %al,%eax
801057f5:	29 c2                	sub    %eax,%edx
801057f7:	89 d0                	mov    %edx,%eax
}
801057f9:	5d                   	pop    %ebp
801057fa:	c3                   	ret    

801057fb <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801057fb:	55                   	push   %ebp
801057fc:	89 e5                	mov    %esp,%ebp
801057fe:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105801:	8b 45 08             	mov    0x8(%ebp),%eax
80105804:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105807:	90                   	nop
80105808:	8b 45 10             	mov    0x10(%ebp),%eax
8010580b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010580e:	89 55 10             	mov    %edx,0x10(%ebp)
80105811:	85 c0                	test   %eax,%eax
80105813:	7e 1e                	jle    80105833 <strncpy+0x38>
80105815:	8b 45 08             	mov    0x8(%ebp),%eax
80105818:	8d 50 01             	lea    0x1(%eax),%edx
8010581b:	89 55 08             	mov    %edx,0x8(%ebp)
8010581e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105821:	8d 4a 01             	lea    0x1(%edx),%ecx
80105824:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105827:	0f b6 12             	movzbl (%edx),%edx
8010582a:	88 10                	mov    %dl,(%eax)
8010582c:	0f b6 00             	movzbl (%eax),%eax
8010582f:	84 c0                	test   %al,%al
80105831:	75 d5                	jne    80105808 <strncpy+0xd>
    ;
  while(n-- > 0)
80105833:	eb 0c                	jmp    80105841 <strncpy+0x46>
    *s++ = 0;
80105835:	8b 45 08             	mov    0x8(%ebp),%eax
80105838:	8d 50 01             	lea    0x1(%eax),%edx
8010583b:	89 55 08             	mov    %edx,0x8(%ebp)
8010583e:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105841:	8b 45 10             	mov    0x10(%ebp),%eax
80105844:	8d 50 ff             	lea    -0x1(%eax),%edx
80105847:	89 55 10             	mov    %edx,0x10(%ebp)
8010584a:	85 c0                	test   %eax,%eax
8010584c:	7f e7                	jg     80105835 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010584e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105851:	c9                   	leave  
80105852:	c3                   	ret    

80105853 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105853:	55                   	push   %ebp
80105854:	89 e5                	mov    %esp,%ebp
80105856:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105859:	8b 45 08             	mov    0x8(%ebp),%eax
8010585c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010585f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105863:	7f 05                	jg     8010586a <safestrcpy+0x17>
    return os;
80105865:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105868:	eb 31                	jmp    8010589b <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010586a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010586e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105872:	7e 1e                	jle    80105892 <safestrcpy+0x3f>
80105874:	8b 45 08             	mov    0x8(%ebp),%eax
80105877:	8d 50 01             	lea    0x1(%eax),%edx
8010587a:	89 55 08             	mov    %edx,0x8(%ebp)
8010587d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105880:	8d 4a 01             	lea    0x1(%edx),%ecx
80105883:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105886:	0f b6 12             	movzbl (%edx),%edx
80105889:	88 10                	mov    %dl,(%eax)
8010588b:	0f b6 00             	movzbl (%eax),%eax
8010588e:	84 c0                	test   %al,%al
80105890:	75 d8                	jne    8010586a <safestrcpy+0x17>
    ;
  *s = 0;
80105892:	8b 45 08             	mov    0x8(%ebp),%eax
80105895:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105898:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010589b:	c9                   	leave  
8010589c:	c3                   	ret    

8010589d <strlen>:

int
strlen(const char *s)
{
8010589d:	55                   	push   %ebp
8010589e:	89 e5                	mov    %esp,%ebp
801058a0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801058a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801058aa:	eb 04                	jmp    801058b0 <strlen+0x13>
801058ac:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801058b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058b3:	8b 45 08             	mov    0x8(%ebp),%eax
801058b6:	01 d0                	add    %edx,%eax
801058b8:	0f b6 00             	movzbl (%eax),%eax
801058bb:	84 c0                	test   %al,%al
801058bd:	75 ed                	jne    801058ac <strlen+0xf>
    ;
  return n;
801058bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058c2:	c9                   	leave  
801058c3:	c3                   	ret    

801058c4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801058c4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801058c8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801058cc:	55                   	push   %ebp
  pushl %ebx
801058cd:	53                   	push   %ebx
  pushl %esi
801058ce:	56                   	push   %esi
  pushl %edi
801058cf:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801058d0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801058d2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801058d4:	5f                   	pop    %edi
  popl %esi
801058d5:	5e                   	pop    %esi
  popl %ebx
801058d6:	5b                   	pop    %ebx
  popl %ebp
801058d7:	5d                   	pop    %ebp
  ret
801058d8:	c3                   	ret    

801058d9 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801058d9:	55                   	push   %ebp
801058da:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801058dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058e2:	8b 00                	mov    (%eax),%eax
801058e4:	3b 45 08             	cmp    0x8(%ebp),%eax
801058e7:	76 12                	jbe    801058fb <fetchint+0x22>
801058e9:	8b 45 08             	mov    0x8(%ebp),%eax
801058ec:	8d 50 04             	lea    0x4(%eax),%edx
801058ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f5:	8b 00                	mov    (%eax),%eax
801058f7:	39 c2                	cmp    %eax,%edx
801058f9:	76 07                	jbe    80105902 <fetchint+0x29>
    return -1;
801058fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105900:	eb 0f                	jmp    80105911 <fetchint+0x38>
  *ip = *(int*)(addr);
80105902:	8b 45 08             	mov    0x8(%ebp),%eax
80105905:	8b 10                	mov    (%eax),%edx
80105907:	8b 45 0c             	mov    0xc(%ebp),%eax
8010590a:	89 10                	mov    %edx,(%eax)
  return 0;
8010590c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105911:	5d                   	pop    %ebp
80105912:	c3                   	ret    

80105913 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105913:	55                   	push   %ebp
80105914:	89 e5                	mov    %esp,%ebp
80105916:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105919:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010591f:	8b 00                	mov    (%eax),%eax
80105921:	3b 45 08             	cmp    0x8(%ebp),%eax
80105924:	77 07                	ja     8010592d <fetchstr+0x1a>
    return -1;
80105926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592b:	eb 46                	jmp    80105973 <fetchstr+0x60>
  *pp = (char*)addr;
8010592d:	8b 55 08             	mov    0x8(%ebp),%edx
80105930:	8b 45 0c             	mov    0xc(%ebp),%eax
80105933:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105935:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010593b:	8b 00                	mov    (%eax),%eax
8010593d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105940:	8b 45 0c             	mov    0xc(%ebp),%eax
80105943:	8b 00                	mov    (%eax),%eax
80105945:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105948:	eb 1c                	jmp    80105966 <fetchstr+0x53>
    if(*s == 0)
8010594a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010594d:	0f b6 00             	movzbl (%eax),%eax
80105950:	84 c0                	test   %al,%al
80105952:	75 0e                	jne    80105962 <fetchstr+0x4f>
      return s - *pp;
80105954:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105957:	8b 45 0c             	mov    0xc(%ebp),%eax
8010595a:	8b 00                	mov    (%eax),%eax
8010595c:	29 c2                	sub    %eax,%edx
8010595e:	89 d0                	mov    %edx,%eax
80105960:	eb 11                	jmp    80105973 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105962:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105966:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105969:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010596c:	72 dc                	jb     8010594a <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010596e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105973:	c9                   	leave  
80105974:	c3                   	ret    

80105975 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105975:	55                   	push   %ebp
80105976:	89 e5                	mov    %esp,%ebp
80105978:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010597b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105981:	8b 40 18             	mov    0x18(%eax),%eax
80105984:	8b 50 44             	mov    0x44(%eax),%edx
80105987:	8b 45 08             	mov    0x8(%ebp),%eax
8010598a:	c1 e0 02             	shl    $0x2,%eax
8010598d:	01 d0                	add    %edx,%eax
8010598f:	8d 50 04             	lea    0x4(%eax),%edx
80105992:	8b 45 0c             	mov    0xc(%ebp),%eax
80105995:	89 44 24 04          	mov    %eax,0x4(%esp)
80105999:	89 14 24             	mov    %edx,(%esp)
8010599c:	e8 38 ff ff ff       	call   801058d9 <fetchint>
}
801059a1:	c9                   	leave  
801059a2:	c3                   	ret    

801059a3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801059a3:	55                   	push   %ebp
801059a4:	89 e5                	mov    %esp,%ebp
801059a6:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801059a9:	8d 45 fc             	lea    -0x4(%ebp),%eax
801059ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801059b0:	8b 45 08             	mov    0x8(%ebp),%eax
801059b3:	89 04 24             	mov    %eax,(%esp)
801059b6:	e8 ba ff ff ff       	call   80105975 <argint>
801059bb:	85 c0                	test   %eax,%eax
801059bd:	79 07                	jns    801059c6 <argptr+0x23>
    return -1;
801059bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c4:	eb 3d                	jmp    80105a03 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801059c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059c9:	89 c2                	mov    %eax,%edx
801059cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059d1:	8b 00                	mov    (%eax),%eax
801059d3:	39 c2                	cmp    %eax,%edx
801059d5:	73 16                	jae    801059ed <argptr+0x4a>
801059d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059da:	89 c2                	mov    %eax,%edx
801059dc:	8b 45 10             	mov    0x10(%ebp),%eax
801059df:	01 c2                	add    %eax,%edx
801059e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059e7:	8b 00                	mov    (%eax),%eax
801059e9:	39 c2                	cmp    %eax,%edx
801059eb:	76 07                	jbe    801059f4 <argptr+0x51>
    return -1;
801059ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f2:	eb 0f                	jmp    80105a03 <argptr+0x60>
  *pp = (char*)i;
801059f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059f7:	89 c2                	mov    %eax,%edx
801059f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801059fc:	89 10                	mov    %edx,(%eax)
  return 0;
801059fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a03:	c9                   	leave  
80105a04:	c3                   	ret    

80105a05 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105a05:	55                   	push   %ebp
80105a06:	89 e5                	mov    %esp,%ebp
80105a08:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105a0b:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a12:	8b 45 08             	mov    0x8(%ebp),%eax
80105a15:	89 04 24             	mov    %eax,(%esp)
80105a18:	e8 58 ff ff ff       	call   80105975 <argint>
80105a1d:	85 c0                	test   %eax,%eax
80105a1f:	79 07                	jns    80105a28 <argstr+0x23>
    return -1;
80105a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a26:	eb 12                	jmp    80105a3a <argstr+0x35>
  return fetchstr(addr, pp);
80105a28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a2e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a32:	89 04 24             	mov    %eax,(%esp)
80105a35:	e8 d9 fe ff ff       	call   80105913 <fetchstr>
}
80105a3a:	c9                   	leave  
80105a3b:	c3                   	ret    

80105a3c <syscall>:
[SYS_sigpause] sys_sigpause,
};

void
syscall(void)
{
80105a3c:	55                   	push   %ebp
80105a3d:	89 e5                	mov    %esp,%ebp
80105a3f:	53                   	push   %ebx
80105a40:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105a43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a49:	8b 40 18             	mov    0x18(%eax),%eax
80105a4c:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a56:	7e 30                	jle    80105a88 <syscall+0x4c>
80105a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5b:	83 f8 19             	cmp    $0x19,%eax
80105a5e:	77 28                	ja     80105a88 <syscall+0x4c>
80105a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a63:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a6a:	85 c0                	test   %eax,%eax
80105a6c:	74 1a                	je     80105a88 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105a6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a74:	8b 58 18             	mov    0x18(%eax),%ebx
80105a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7a:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a81:	ff d0                	call   *%eax
80105a83:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105a86:	eb 3d                	jmp    80105ac5 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105a88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a8e:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105a91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105a97:	8b 40 10             	mov    0x10(%eax),%eax
80105a9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a9d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105aa1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aa9:	c7 04 24 f0 8e 10 80 	movl   $0x80108ef0,(%esp)
80105ab0:	e8 eb a8 ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105ab5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105abb:	8b 40 18             	mov    0x18(%eax),%eax
80105abe:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105ac5:	83 c4 24             	add    $0x24,%esp
80105ac8:	5b                   	pop    %ebx
80105ac9:	5d                   	pop    %ebp
80105aca:	c3                   	ret    

80105acb <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105acb:	55                   	push   %ebp
80105acc:	89 e5                	mov    %esp,%ebp
80105ace:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105ad1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80105adb:	89 04 24             	mov    %eax,(%esp)
80105ade:	e8 92 fe ff ff       	call   80105975 <argint>
80105ae3:	85 c0                	test   %eax,%eax
80105ae5:	79 07                	jns    80105aee <argfd+0x23>
    return -1;
80105ae7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aec:	eb 50                	jmp    80105b3e <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af1:	85 c0                	test   %eax,%eax
80105af3:	78 21                	js     80105b16 <argfd+0x4b>
80105af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af8:	83 f8 0f             	cmp    $0xf,%eax
80105afb:	7f 19                	jg     80105b16 <argfd+0x4b>
80105afd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b06:	83 c2 08             	add    $0x8,%edx
80105b09:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b14:	75 07                	jne    80105b1d <argfd+0x52>
    return -1;
80105b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1b:	eb 21                	jmp    80105b3e <argfd+0x73>
  if(pfd)
80105b1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b21:	74 08                	je     80105b2b <argfd+0x60>
    *pfd = fd;
80105b23:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b26:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b29:	89 10                	mov    %edx,(%eax)
  if(pf)
80105b2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b2f:	74 08                	je     80105b39 <argfd+0x6e>
    *pf = f;
80105b31:	8b 45 10             	mov    0x10(%ebp),%eax
80105b34:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b37:	89 10                	mov    %edx,(%eax)
  return 0;
80105b39:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b3e:	c9                   	leave  
80105b3f:	c3                   	ret    

80105b40 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105b40:	55                   	push   %ebp
80105b41:	89 e5                	mov    %esp,%ebp
80105b43:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b46:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105b4d:	eb 30                	jmp    80105b7f <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105b4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b55:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b58:	83 c2 08             	add    $0x8,%edx
80105b5b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b5f:	85 c0                	test   %eax,%eax
80105b61:	75 18                	jne    80105b7b <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105b63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b69:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b6c:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b6f:	8b 55 08             	mov    0x8(%ebp),%edx
80105b72:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b79:	eb 0f                	jmp    80105b8a <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b7b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105b7f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105b83:	7e ca                	jle    80105b4f <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b8a:	c9                   	leave  
80105b8b:	c3                   	ret    

80105b8c <sys_dup>:

int
sys_dup(void)
{
80105b8c:	55                   	push   %ebp
80105b8d:	89 e5                	mov    %esp,%ebp
80105b8f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105b92:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b95:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ba0:	00 
80105ba1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ba8:	e8 1e ff ff ff       	call   80105acb <argfd>
80105bad:	85 c0                	test   %eax,%eax
80105baf:	79 07                	jns    80105bb8 <sys_dup+0x2c>
    return -1;
80105bb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb6:	eb 29                	jmp    80105be1 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbb:	89 04 24             	mov    %eax,(%esp)
80105bbe:	e8 7d ff ff ff       	call   80105b40 <fdalloc>
80105bc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bca:	79 07                	jns    80105bd3 <sys_dup+0x47>
    return -1;
80105bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd1:	eb 0e                	jmp    80105be1 <sys_dup+0x55>
  filedup(f);
80105bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd6:	89 04 24             	mov    %eax,(%esp)
80105bd9:	e8 b5 b3 ff ff       	call   80100f93 <filedup>
  return fd;
80105bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105be1:	c9                   	leave  
80105be2:	c3                   	ret    

80105be3 <sys_read>:

int
sys_read(void)
{
80105be3:	55                   	push   %ebp
80105be4:	89 e5                	mov    %esp,%ebp
80105be6:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105be9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bec:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bf0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105bf7:	00 
80105bf8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bff:	e8 c7 fe ff ff       	call   80105acb <argfd>
80105c04:	85 c0                	test   %eax,%eax
80105c06:	78 35                	js     80105c3d <sys_read+0x5a>
80105c08:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c0f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105c16:	e8 5a fd ff ff       	call   80105975 <argint>
80105c1b:	85 c0                	test   %eax,%eax
80105c1d:	78 1e                	js     80105c3d <sys_read+0x5a>
80105c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c22:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c26:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c29:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c34:	e8 6a fd ff ff       	call   801059a3 <argptr>
80105c39:	85 c0                	test   %eax,%eax
80105c3b:	79 07                	jns    80105c44 <sys_read+0x61>
    return -1;
80105c3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c42:	eb 19                	jmp    80105c5d <sys_read+0x7a>
  return fileread(f, p, n);
80105c44:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c47:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c51:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c55:	89 04 24             	mov    %eax,(%esp)
80105c58:	e8 a3 b4 ff ff       	call   80101100 <fileread>
}
80105c5d:	c9                   	leave  
80105c5e:	c3                   	ret    

80105c5f <sys_write>:

int
sys_write(void)
{
80105c5f:	55                   	push   %ebp
80105c60:	89 e5                	mov    %esp,%ebp
80105c62:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c65:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c68:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c73:	00 
80105c74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c7b:	e8 4b fe ff ff       	call   80105acb <argfd>
80105c80:	85 c0                	test   %eax,%eax
80105c82:	78 35                	js     80105cb9 <sys_write+0x5a>
80105c84:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c87:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c8b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105c92:	e8 de fc ff ff       	call   80105975 <argint>
80105c97:	85 c0                	test   %eax,%eax
80105c99:	78 1e                	js     80105cb9 <sys_write+0x5a>
80105c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ca2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ca9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cb0:	e8 ee fc ff ff       	call   801059a3 <argptr>
80105cb5:	85 c0                	test   %eax,%eax
80105cb7:	79 07                	jns    80105cc0 <sys_write+0x61>
    return -1;
80105cb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cbe:	eb 19                	jmp    80105cd9 <sys_write+0x7a>
  return filewrite(f, p, n);
80105cc0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105cc3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ccd:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cd1:	89 04 24             	mov    %eax,(%esp)
80105cd4:	e8 e3 b4 ff ff       	call   801011bc <filewrite>
}
80105cd9:	c9                   	leave  
80105cda:	c3                   	ret    

80105cdb <sys_close>:

int
sys_close(void)
{
80105cdb:	55                   	push   %ebp
80105cdc:	89 e5                	mov    %esp,%ebp
80105cde:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105ce1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ce4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cf6:	e8 d0 fd ff ff       	call   80105acb <argfd>
80105cfb:	85 c0                	test   %eax,%eax
80105cfd:	79 07                	jns    80105d06 <sys_close+0x2b>
    return -1;
80105cff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d04:	eb 24                	jmp    80105d2a <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105d06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d0f:	83 c2 08             	add    $0x8,%edx
80105d12:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d19:	00 
  fileclose(f);
80105d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1d:	89 04 24             	mov    %eax,(%esp)
80105d20:	e8 b6 b2 ff ff       	call   80100fdb <fileclose>
  return 0;
80105d25:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d2a:	c9                   	leave  
80105d2b:	c3                   	ret    

80105d2c <sys_fstat>:

int
sys_fstat(void)
{
80105d2c:	55                   	push   %ebp
80105d2d:	89 e5                	mov    %esp,%ebp
80105d2f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d35:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d40:	00 
80105d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d48:	e8 7e fd ff ff       	call   80105acb <argfd>
80105d4d:	85 c0                	test   %eax,%eax
80105d4f:	78 1f                	js     80105d70 <sys_fstat+0x44>
80105d51:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105d58:	00 
80105d59:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d67:	e8 37 fc ff ff       	call   801059a3 <argptr>
80105d6c:	85 c0                	test   %eax,%eax
80105d6e:	79 07                	jns    80105d77 <sys_fstat+0x4b>
    return -1;
80105d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d75:	eb 12                	jmp    80105d89 <sys_fstat+0x5d>
  return filestat(f, st);
80105d77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d81:	89 04 24             	mov    %eax,(%esp)
80105d84:	e8 28 b3 ff ff       	call   801010b1 <filestat>
}
80105d89:	c9                   	leave  
80105d8a:	c3                   	ret    

80105d8b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d8b:	55                   	push   %ebp
80105d8c:	89 e5                	mov    %esp,%ebp
80105d8e:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d91:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d94:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d9f:	e8 61 fc ff ff       	call   80105a05 <argstr>
80105da4:	85 c0                	test   %eax,%eax
80105da6:	78 17                	js     80105dbf <sys_link+0x34>
80105da8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105dab:	89 44 24 04          	mov    %eax,0x4(%esp)
80105daf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105db6:	e8 4a fc ff ff       	call   80105a05 <argstr>
80105dbb:	85 c0                	test   %eax,%eax
80105dbd:	79 0a                	jns    80105dc9 <sys_link+0x3e>
    return -1;
80105dbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc4:	e9 42 01 00 00       	jmp    80105f0b <sys_link+0x180>

  begin_op();
80105dc9:	e8 4f d6 ff ff       	call   8010341d <begin_op>
  if((ip = namei(old)) == 0){
80105dce:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105dd1:	89 04 24             	mov    %eax,(%esp)
80105dd4:	e8 3a c6 ff ff       	call   80102413 <namei>
80105dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ddc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105de0:	75 0f                	jne    80105df1 <sys_link+0x66>
    end_op();
80105de2:	e8 ba d6 ff ff       	call   801034a1 <end_op>
    return -1;
80105de7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dec:	e9 1a 01 00 00       	jmp    80105f0b <sys_link+0x180>
  }

  ilock(ip);
80105df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df4:	89 04 24             	mov    %eax,(%esp)
80105df7:	e8 6c ba ff ff       	call   80101868 <ilock>
  if(ip->type == T_DIR){
80105dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dff:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e03:	66 83 f8 01          	cmp    $0x1,%ax
80105e07:	75 1a                	jne    80105e23 <sys_link+0x98>
    iunlockput(ip);
80105e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0c:	89 04 24             	mov    %eax,(%esp)
80105e0f:	e8 d8 bc ff ff       	call   80101aec <iunlockput>
    end_op();
80105e14:	e8 88 d6 ff ff       	call   801034a1 <end_op>
    return -1;
80105e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1e:	e9 e8 00 00 00       	jmp    80105f0b <sys_link+0x180>
  }

  ip->nlink++;
80105e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e26:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e2a:	8d 50 01             	lea    0x1(%eax),%edx
80105e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e30:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e37:	89 04 24             	mov    %eax,(%esp)
80105e3a:	e8 6d b8 ff ff       	call   801016ac <iupdate>
  iunlock(ip);
80105e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e42:	89 04 24             	mov    %eax,(%esp)
80105e45:	e8 6c bb ff ff       	call   801019b6 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105e4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e4d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105e50:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e54:	89 04 24             	mov    %eax,(%esp)
80105e57:	e8 d9 c5 ff ff       	call   80102435 <nameiparent>
80105e5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e5f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e63:	75 02                	jne    80105e67 <sys_link+0xdc>
    goto bad;
80105e65:	eb 68                	jmp    80105ecf <sys_link+0x144>
  ilock(dp);
80105e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6a:	89 04 24             	mov    %eax,(%esp)
80105e6d:	e8 f6 b9 ff ff       	call   80101868 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e75:	8b 10                	mov    (%eax),%edx
80105e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7a:	8b 00                	mov    (%eax),%eax
80105e7c:	39 c2                	cmp    %eax,%edx
80105e7e:	75 20                	jne    80105ea0 <sys_link+0x115>
80105e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e83:	8b 40 04             	mov    0x4(%eax),%eax
80105e86:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e8a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e94:	89 04 24             	mov    %eax,(%esp)
80105e97:	e8 b7 c2 ff ff       	call   80102153 <dirlink>
80105e9c:	85 c0                	test   %eax,%eax
80105e9e:	79 0d                	jns    80105ead <sys_link+0x122>
    iunlockput(dp);
80105ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea3:	89 04 24             	mov    %eax,(%esp)
80105ea6:	e8 41 bc ff ff       	call   80101aec <iunlockput>
    goto bad;
80105eab:	eb 22                	jmp    80105ecf <sys_link+0x144>
  }
  iunlockput(dp);
80105ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb0:	89 04 24             	mov    %eax,(%esp)
80105eb3:	e8 34 bc ff ff       	call   80101aec <iunlockput>
  iput(ip);
80105eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebb:	89 04 24             	mov    %eax,(%esp)
80105ebe:	e8 58 bb ff ff       	call   80101a1b <iput>

  end_op();
80105ec3:	e8 d9 d5 ff ff       	call   801034a1 <end_op>

  return 0;
80105ec8:	b8 00 00 00 00       	mov    $0x0,%eax
80105ecd:	eb 3c                	jmp    80105f0b <sys_link+0x180>

bad:
  ilock(ip);
80105ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed2:	89 04 24             	mov    %eax,(%esp)
80105ed5:	e8 8e b9 ff ff       	call   80101868 <ilock>
  ip->nlink--;
80105eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edd:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ee1:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee7:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eee:	89 04 24             	mov    %eax,(%esp)
80105ef1:	e8 b6 b7 ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
80105ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef9:	89 04 24             	mov    %eax,(%esp)
80105efc:	e8 eb bb ff ff       	call   80101aec <iunlockput>
  end_op();
80105f01:	e8 9b d5 ff ff       	call   801034a1 <end_op>
  return -1;
80105f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f0b:	c9                   	leave  
80105f0c:	c3                   	ret    

80105f0d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105f0d:	55                   	push   %ebp
80105f0e:	89 e5                	mov    %esp,%ebp
80105f10:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f13:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105f1a:	eb 4b                	jmp    80105f67 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105f26:	00 
80105f27:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f2b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f32:	8b 45 08             	mov    0x8(%ebp),%eax
80105f35:	89 04 24             	mov    %eax,(%esp)
80105f38:	e8 38 be ff ff       	call   80101d75 <readi>
80105f3d:	83 f8 10             	cmp    $0x10,%eax
80105f40:	74 0c                	je     80105f4e <isdirempty+0x41>
      panic("isdirempty: readi");
80105f42:	c7 04 24 0c 8f 10 80 	movl   $0x80108f0c,(%esp)
80105f49:	e8 ec a5 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105f4e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105f52:	66 85 c0             	test   %ax,%ax
80105f55:	74 07                	je     80105f5e <isdirempty+0x51>
      return 0;
80105f57:	b8 00 00 00 00       	mov    $0x0,%eax
80105f5c:	eb 1b                	jmp    80105f79 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f61:	83 c0 10             	add    $0x10,%eax
80105f64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80105f6d:	8b 40 18             	mov    0x18(%eax),%eax
80105f70:	39 c2                	cmp    %eax,%edx
80105f72:	72 a8                	jb     80105f1c <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105f74:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f79:	c9                   	leave  
80105f7a:	c3                   	ret    

80105f7b <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f7b:	55                   	push   %ebp
80105f7c:	89 e5                	mov    %esp,%ebp
80105f7e:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f81:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f84:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f8f:	e8 71 fa ff ff       	call   80105a05 <argstr>
80105f94:	85 c0                	test   %eax,%eax
80105f96:	79 0a                	jns    80105fa2 <sys_unlink+0x27>
    return -1;
80105f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f9d:	e9 af 01 00 00       	jmp    80106151 <sys_unlink+0x1d6>

  begin_op();
80105fa2:	e8 76 d4 ff ff       	call   8010341d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105fa7:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105faa:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105fad:	89 54 24 04          	mov    %edx,0x4(%esp)
80105fb1:	89 04 24             	mov    %eax,(%esp)
80105fb4:	e8 7c c4 ff ff       	call   80102435 <nameiparent>
80105fb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fbc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fc0:	75 0f                	jne    80105fd1 <sys_unlink+0x56>
    end_op();
80105fc2:	e8 da d4 ff ff       	call   801034a1 <end_op>
    return -1;
80105fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fcc:	e9 80 01 00 00       	jmp    80106151 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd4:	89 04 24             	mov    %eax,(%esp)
80105fd7:	e8 8c b8 ff ff       	call   80101868 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105fdc:	c7 44 24 04 1e 8f 10 	movl   $0x80108f1e,0x4(%esp)
80105fe3:	80 
80105fe4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fe7:	89 04 24             	mov    %eax,(%esp)
80105fea:	e8 79 c0 ff ff       	call   80102068 <namecmp>
80105fef:	85 c0                	test   %eax,%eax
80105ff1:	0f 84 45 01 00 00    	je     8010613c <sys_unlink+0x1c1>
80105ff7:	c7 44 24 04 20 8f 10 	movl   $0x80108f20,0x4(%esp)
80105ffe:	80 
80105fff:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106002:	89 04 24             	mov    %eax,(%esp)
80106005:	e8 5e c0 ff ff       	call   80102068 <namecmp>
8010600a:	85 c0                	test   %eax,%eax
8010600c:	0f 84 2a 01 00 00    	je     8010613c <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106012:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106015:	89 44 24 08          	mov    %eax,0x8(%esp)
80106019:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010601c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106023:	89 04 24             	mov    %eax,(%esp)
80106026:	e8 5f c0 ff ff       	call   8010208a <dirlookup>
8010602b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010602e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106032:	75 05                	jne    80106039 <sys_unlink+0xbe>
    goto bad;
80106034:	e9 03 01 00 00       	jmp    8010613c <sys_unlink+0x1c1>
  ilock(ip);
80106039:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603c:	89 04 24             	mov    %eax,(%esp)
8010603f:	e8 24 b8 ff ff       	call   80101868 <ilock>

  if(ip->nlink < 1)
80106044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106047:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010604b:	66 85 c0             	test   %ax,%ax
8010604e:	7f 0c                	jg     8010605c <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80106050:	c7 04 24 23 8f 10 80 	movl   $0x80108f23,(%esp)
80106057:	e8 de a4 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010605c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106063:	66 83 f8 01          	cmp    $0x1,%ax
80106067:	75 1f                	jne    80106088 <sys_unlink+0x10d>
80106069:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606c:	89 04 24             	mov    %eax,(%esp)
8010606f:	e8 99 fe ff ff       	call   80105f0d <isdirempty>
80106074:	85 c0                	test   %eax,%eax
80106076:	75 10                	jne    80106088 <sys_unlink+0x10d>
    iunlockput(ip);
80106078:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607b:	89 04 24             	mov    %eax,(%esp)
8010607e:	e8 69 ba ff ff       	call   80101aec <iunlockput>
    goto bad;
80106083:	e9 b4 00 00 00       	jmp    8010613c <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80106088:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010608f:	00 
80106090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106097:	00 
80106098:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010609b:	89 04 24             	mov    %eax,(%esp)
8010609e:	e8 90 f5 ff ff       	call   80105633 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801060a3:	8b 45 c8             	mov    -0x38(%ebp),%eax
801060a6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801060ad:	00 
801060ae:	89 44 24 08          	mov    %eax,0x8(%esp)
801060b2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801060b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bc:	89 04 24             	mov    %eax,(%esp)
801060bf:	e8 15 be ff ff       	call   80101ed9 <writei>
801060c4:	83 f8 10             	cmp    $0x10,%eax
801060c7:	74 0c                	je     801060d5 <sys_unlink+0x15a>
    panic("unlink: writei");
801060c9:	c7 04 24 35 8f 10 80 	movl   $0x80108f35,(%esp)
801060d0:	e8 65 a4 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
801060d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060dc:	66 83 f8 01          	cmp    $0x1,%ax
801060e0:	75 1c                	jne    801060fe <sys_unlink+0x183>
    dp->nlink--;
801060e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060e9:	8d 50 ff             	lea    -0x1(%eax),%edx
801060ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ef:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801060f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f6:	89 04 24             	mov    %eax,(%esp)
801060f9:	e8 ae b5 ff ff       	call   801016ac <iupdate>
  }
  iunlockput(dp);
801060fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106101:	89 04 24             	mov    %eax,(%esp)
80106104:	e8 e3 b9 ff ff       	call   80101aec <iunlockput>

  ip->nlink--;
80106109:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010610c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106110:	8d 50 ff             	lea    -0x1(%eax),%edx
80106113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106116:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010611a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611d:	89 04 24             	mov    %eax,(%esp)
80106120:	e8 87 b5 ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
80106125:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106128:	89 04 24             	mov    %eax,(%esp)
8010612b:	e8 bc b9 ff ff       	call   80101aec <iunlockput>

  end_op();
80106130:	e8 6c d3 ff ff       	call   801034a1 <end_op>

  return 0;
80106135:	b8 00 00 00 00       	mov    $0x0,%eax
8010613a:	eb 15                	jmp    80106151 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
8010613c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613f:	89 04 24             	mov    %eax,(%esp)
80106142:	e8 a5 b9 ff ff       	call   80101aec <iunlockput>
  end_op();
80106147:	e8 55 d3 ff ff       	call   801034a1 <end_op>
  return -1;
8010614c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106151:	c9                   	leave  
80106152:	c3                   	ret    

80106153 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106153:	55                   	push   %ebp
80106154:	89 e5                	mov    %esp,%ebp
80106156:	83 ec 48             	sub    $0x48,%esp
80106159:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010615c:	8b 55 10             	mov    0x10(%ebp),%edx
8010615f:	8b 45 14             	mov    0x14(%ebp),%eax
80106162:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106166:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010616a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010616e:	8d 45 de             	lea    -0x22(%ebp),%eax
80106171:	89 44 24 04          	mov    %eax,0x4(%esp)
80106175:	8b 45 08             	mov    0x8(%ebp),%eax
80106178:	89 04 24             	mov    %eax,(%esp)
8010617b:	e8 b5 c2 ff ff       	call   80102435 <nameiparent>
80106180:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106183:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106187:	75 0a                	jne    80106193 <create+0x40>
    return 0;
80106189:	b8 00 00 00 00       	mov    $0x0,%eax
8010618e:	e9 7e 01 00 00       	jmp    80106311 <create+0x1be>
  ilock(dp);
80106193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106196:	89 04 24             	mov    %eax,(%esp)
80106199:	e8 ca b6 ff ff       	call   80101868 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010619e:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801061a5:	8d 45 de             	lea    -0x22(%ebp),%eax
801061a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061af:	89 04 24             	mov    %eax,(%esp)
801061b2:	e8 d3 be ff ff       	call   8010208a <dirlookup>
801061b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061be:	74 47                	je     80106207 <create+0xb4>
    iunlockput(dp);
801061c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c3:	89 04 24             	mov    %eax,(%esp)
801061c6:	e8 21 b9 ff ff       	call   80101aec <iunlockput>
    ilock(ip);
801061cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ce:	89 04 24             	mov    %eax,(%esp)
801061d1:	e8 92 b6 ff ff       	call   80101868 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801061d6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801061db:	75 15                	jne    801061f2 <create+0x9f>
801061dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061e4:	66 83 f8 02          	cmp    $0x2,%ax
801061e8:	75 08                	jne    801061f2 <create+0x9f>
      return ip;
801061ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ed:	e9 1f 01 00 00       	jmp    80106311 <create+0x1be>
    iunlockput(ip);
801061f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f5:	89 04 24             	mov    %eax,(%esp)
801061f8:	e8 ef b8 ff ff       	call   80101aec <iunlockput>
    return 0;
801061fd:	b8 00 00 00 00       	mov    $0x0,%eax
80106202:	e9 0a 01 00 00       	jmp    80106311 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106207:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010620b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620e:	8b 00                	mov    (%eax),%eax
80106210:	89 54 24 04          	mov    %edx,0x4(%esp)
80106214:	89 04 24             	mov    %eax,(%esp)
80106217:	e8 b1 b3 ff ff       	call   801015cd <ialloc>
8010621c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010621f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106223:	75 0c                	jne    80106231 <create+0xde>
    panic("create: ialloc");
80106225:	c7 04 24 44 8f 10 80 	movl   $0x80108f44,(%esp)
8010622c:	e8 09 a3 ff ff       	call   8010053a <panic>

  ilock(ip);
80106231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106234:	89 04 24             	mov    %eax,(%esp)
80106237:	e8 2c b6 ff ff       	call   80101868 <ilock>
  ip->major = major;
8010623c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623f:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106243:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106247:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624a:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010624e:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106255:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010625b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010625e:	89 04 24             	mov    %eax,(%esp)
80106261:	e8 46 b4 ff ff       	call   801016ac <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106266:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010626b:	75 6a                	jne    801062d7 <create+0x184>
    dp->nlink++;  // for ".."
8010626d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106270:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106274:	8d 50 01             	lea    0x1(%eax),%edx
80106277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010627e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106281:	89 04 24             	mov    %eax,(%esp)
80106284:	e8 23 b4 ff ff       	call   801016ac <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106289:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010628c:	8b 40 04             	mov    0x4(%eax),%eax
8010628f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106293:	c7 44 24 04 1e 8f 10 	movl   $0x80108f1e,0x4(%esp)
8010629a:	80 
8010629b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629e:	89 04 24             	mov    %eax,(%esp)
801062a1:	e8 ad be ff ff       	call   80102153 <dirlink>
801062a6:	85 c0                	test   %eax,%eax
801062a8:	78 21                	js     801062cb <create+0x178>
801062aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ad:	8b 40 04             	mov    0x4(%eax),%eax
801062b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801062b4:	c7 44 24 04 20 8f 10 	movl   $0x80108f20,0x4(%esp)
801062bb:	80 
801062bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bf:	89 04 24             	mov    %eax,(%esp)
801062c2:	e8 8c be ff ff       	call   80102153 <dirlink>
801062c7:	85 c0                	test   %eax,%eax
801062c9:	79 0c                	jns    801062d7 <create+0x184>
      panic("create dots");
801062cb:	c7 04 24 53 8f 10 80 	movl   $0x80108f53,(%esp)
801062d2:	e8 63 a2 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801062d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062da:	8b 40 04             	mov    0x4(%eax),%eax
801062dd:	89 44 24 08          	mov    %eax,0x8(%esp)
801062e1:	8d 45 de             	lea    -0x22(%ebp),%eax
801062e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801062e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062eb:	89 04 24             	mov    %eax,(%esp)
801062ee:	e8 60 be ff ff       	call   80102153 <dirlink>
801062f3:	85 c0                	test   %eax,%eax
801062f5:	79 0c                	jns    80106303 <create+0x1b0>
    panic("create: dirlink");
801062f7:	c7 04 24 5f 8f 10 80 	movl   $0x80108f5f,(%esp)
801062fe:	e8 37 a2 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80106303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106306:	89 04 24             	mov    %eax,(%esp)
80106309:	e8 de b7 ff ff       	call   80101aec <iunlockput>

  return ip;
8010630e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106311:	c9                   	leave  
80106312:	c3                   	ret    

80106313 <sys_open>:

int
sys_open(void)
{
80106313:	55                   	push   %ebp
80106314:	89 e5                	mov    %esp,%ebp
80106316:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106319:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010631c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106327:	e8 d9 f6 ff ff       	call   80105a05 <argstr>
8010632c:	85 c0                	test   %eax,%eax
8010632e:	78 17                	js     80106347 <sys_open+0x34>
80106330:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106333:	89 44 24 04          	mov    %eax,0x4(%esp)
80106337:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010633e:	e8 32 f6 ff ff       	call   80105975 <argint>
80106343:	85 c0                	test   %eax,%eax
80106345:	79 0a                	jns    80106351 <sys_open+0x3e>
    return -1;
80106347:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634c:	e9 5c 01 00 00       	jmp    801064ad <sys_open+0x19a>

  begin_op();
80106351:	e8 c7 d0 ff ff       	call   8010341d <begin_op>

  if(omode & O_CREATE){
80106356:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106359:	25 00 02 00 00       	and    $0x200,%eax
8010635e:	85 c0                	test   %eax,%eax
80106360:	74 3b                	je     8010639d <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106362:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106365:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010636c:	00 
8010636d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106374:	00 
80106375:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010637c:	00 
8010637d:	89 04 24             	mov    %eax,(%esp)
80106380:	e8 ce fd ff ff       	call   80106153 <create>
80106385:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106388:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010638c:	75 6b                	jne    801063f9 <sys_open+0xe6>
      end_op();
8010638e:	e8 0e d1 ff ff       	call   801034a1 <end_op>
      return -1;
80106393:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106398:	e9 10 01 00 00       	jmp    801064ad <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
8010639d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063a0:	89 04 24             	mov    %eax,(%esp)
801063a3:	e8 6b c0 ff ff       	call   80102413 <namei>
801063a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063af:	75 0f                	jne    801063c0 <sys_open+0xad>
      end_op();
801063b1:	e8 eb d0 ff ff       	call   801034a1 <end_op>
      return -1;
801063b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bb:	e9 ed 00 00 00       	jmp    801064ad <sys_open+0x19a>
    }
    ilock(ip);
801063c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c3:	89 04 24             	mov    %eax,(%esp)
801063c6:	e8 9d b4 ff ff       	call   80101868 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801063cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ce:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801063d2:	66 83 f8 01          	cmp    $0x1,%ax
801063d6:	75 21                	jne    801063f9 <sys_open+0xe6>
801063d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063db:	85 c0                	test   %eax,%eax
801063dd:	74 1a                	je     801063f9 <sys_open+0xe6>
      iunlockput(ip);
801063df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e2:	89 04 24             	mov    %eax,(%esp)
801063e5:	e8 02 b7 ff ff       	call   80101aec <iunlockput>
      end_op();
801063ea:	e8 b2 d0 ff ff       	call   801034a1 <end_op>
      return -1;
801063ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f4:	e9 b4 00 00 00       	jmp    801064ad <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801063f9:	e8 35 ab ff ff       	call   80100f33 <filealloc>
801063fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106401:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106405:	74 14                	je     8010641b <sys_open+0x108>
80106407:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640a:	89 04 24             	mov    %eax,(%esp)
8010640d:	e8 2e f7 ff ff       	call   80105b40 <fdalloc>
80106412:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106415:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106419:	79 28                	jns    80106443 <sys_open+0x130>
    if(f)
8010641b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010641f:	74 0b                	je     8010642c <sys_open+0x119>
      fileclose(f);
80106421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106424:	89 04 24             	mov    %eax,(%esp)
80106427:	e8 af ab ff ff       	call   80100fdb <fileclose>
    iunlockput(ip);
8010642c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642f:	89 04 24             	mov    %eax,(%esp)
80106432:	e8 b5 b6 ff ff       	call   80101aec <iunlockput>
    end_op();
80106437:	e8 65 d0 ff ff       	call   801034a1 <end_op>
    return -1;
8010643c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106441:	eb 6a                	jmp    801064ad <sys_open+0x19a>
  }
  iunlock(ip);
80106443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106446:	89 04 24             	mov    %eax,(%esp)
80106449:	e8 68 b5 ff ff       	call   801019b6 <iunlock>
  end_op();
8010644e:	e8 4e d0 ff ff       	call   801034a1 <end_op>

  f->type = FD_INODE;
80106453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106456:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010645c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106462:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106465:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106468:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010646f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106472:	83 e0 01             	and    $0x1,%eax
80106475:	85 c0                	test   %eax,%eax
80106477:	0f 94 c0             	sete   %al
8010647a:	89 c2                	mov    %eax,%edx
8010647c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106482:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106485:	83 e0 01             	and    $0x1,%eax
80106488:	85 c0                	test   %eax,%eax
8010648a:	75 0a                	jne    80106496 <sys_open+0x183>
8010648c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010648f:	83 e0 02             	and    $0x2,%eax
80106492:	85 c0                	test   %eax,%eax
80106494:	74 07                	je     8010649d <sys_open+0x18a>
80106496:	b8 01 00 00 00       	mov    $0x1,%eax
8010649b:	eb 05                	jmp    801064a2 <sys_open+0x18f>
8010649d:	b8 00 00 00 00       	mov    $0x0,%eax
801064a2:	89 c2                	mov    %eax,%edx
801064a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a7:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801064aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801064ad:	c9                   	leave  
801064ae:	c3                   	ret    

801064af <sys_mkdir>:

int
sys_mkdir(void)
{
801064af:	55                   	push   %ebp
801064b0:	89 e5                	mov    %esp,%ebp
801064b2:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801064b5:	e8 63 cf ff ff       	call   8010341d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801064ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801064c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064c8:	e8 38 f5 ff ff       	call   80105a05 <argstr>
801064cd:	85 c0                	test   %eax,%eax
801064cf:	78 2c                	js     801064fd <sys_mkdir+0x4e>
801064d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801064db:	00 
801064dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801064e3:	00 
801064e4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801064eb:	00 
801064ec:	89 04 24             	mov    %eax,(%esp)
801064ef:	e8 5f fc ff ff       	call   80106153 <create>
801064f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064fb:	75 0c                	jne    80106509 <sys_mkdir+0x5a>
    end_op();
801064fd:	e8 9f cf ff ff       	call   801034a1 <end_op>
    return -1;
80106502:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106507:	eb 15                	jmp    8010651e <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650c:	89 04 24             	mov    %eax,(%esp)
8010650f:	e8 d8 b5 ff ff       	call   80101aec <iunlockput>
  end_op();
80106514:	e8 88 cf ff ff       	call   801034a1 <end_op>
  return 0;
80106519:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010651e:	c9                   	leave  
8010651f:	c3                   	ret    

80106520 <sys_mknod>:

int
sys_mknod(void)
{
80106520:	55                   	push   %ebp
80106521:	89 e5                	mov    %esp,%ebp
80106523:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106526:	e8 f2 ce ff ff       	call   8010341d <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010652b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010652e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106532:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106539:	e8 c7 f4 ff ff       	call   80105a05 <argstr>
8010653e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106541:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106545:	78 5e                	js     801065a5 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106547:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010654a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010654e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106555:	e8 1b f4 ff ff       	call   80105975 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010655a:	85 c0                	test   %eax,%eax
8010655c:	78 47                	js     801065a5 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010655e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106561:	89 44 24 04          	mov    %eax,0x4(%esp)
80106565:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010656c:	e8 04 f4 ff ff       	call   80105975 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106571:	85 c0                	test   %eax,%eax
80106573:	78 30                	js     801065a5 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106578:	0f bf c8             	movswl %ax,%ecx
8010657b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010657e:	0f bf d0             	movswl %ax,%edx
80106581:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106584:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106588:	89 54 24 08          	mov    %edx,0x8(%esp)
8010658c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106593:	00 
80106594:	89 04 24             	mov    %eax,(%esp)
80106597:	e8 b7 fb ff ff       	call   80106153 <create>
8010659c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010659f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065a3:	75 0c                	jne    801065b1 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801065a5:	e8 f7 ce ff ff       	call   801034a1 <end_op>
    return -1;
801065aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065af:	eb 15                	jmp    801065c6 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801065b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b4:	89 04 24             	mov    %eax,(%esp)
801065b7:	e8 30 b5 ff ff       	call   80101aec <iunlockput>
  end_op();
801065bc:	e8 e0 ce ff ff       	call   801034a1 <end_op>
  return 0;
801065c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065c6:	c9                   	leave  
801065c7:	c3                   	ret    

801065c8 <sys_chdir>:

int
sys_chdir(void)
{
801065c8:	55                   	push   %ebp
801065c9:	89 e5                	mov    %esp,%ebp
801065cb:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801065ce:	e8 4a ce ff ff       	call   8010341d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801065d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801065da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065e1:	e8 1f f4 ff ff       	call   80105a05 <argstr>
801065e6:	85 c0                	test   %eax,%eax
801065e8:	78 14                	js     801065fe <sys_chdir+0x36>
801065ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ed:	89 04 24             	mov    %eax,(%esp)
801065f0:	e8 1e be ff ff       	call   80102413 <namei>
801065f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065fc:	75 0c                	jne    8010660a <sys_chdir+0x42>
    end_op();
801065fe:	e8 9e ce ff ff       	call   801034a1 <end_op>
    return -1;
80106603:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106608:	eb 61                	jmp    8010666b <sys_chdir+0xa3>
  }
  ilock(ip);
8010660a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010660d:	89 04 24             	mov    %eax,(%esp)
80106610:	e8 53 b2 ff ff       	call   80101868 <ilock>
  if(ip->type != T_DIR){
80106615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106618:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010661c:	66 83 f8 01          	cmp    $0x1,%ax
80106620:	74 17                	je     80106639 <sys_chdir+0x71>
    iunlockput(ip);
80106622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106625:	89 04 24             	mov    %eax,(%esp)
80106628:	e8 bf b4 ff ff       	call   80101aec <iunlockput>
    end_op();
8010662d:	e8 6f ce ff ff       	call   801034a1 <end_op>
    return -1;
80106632:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106637:	eb 32                	jmp    8010666b <sys_chdir+0xa3>
  }
  iunlock(ip);
80106639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010663c:	89 04 24             	mov    %eax,(%esp)
8010663f:	e8 72 b3 ff ff       	call   801019b6 <iunlock>
  iput(proc->cwd);
80106644:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010664a:	8b 40 68             	mov    0x68(%eax),%eax
8010664d:	89 04 24             	mov    %eax,(%esp)
80106650:	e8 c6 b3 ff ff       	call   80101a1b <iput>
  end_op();
80106655:	e8 47 ce ff ff       	call   801034a1 <end_op>
  proc->cwd = ip;
8010665a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106660:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106663:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106666:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010666b:	c9                   	leave  
8010666c:	c3                   	ret    

8010666d <sys_exec>:

int
sys_exec(void)
{
8010666d:	55                   	push   %ebp
8010666e:	89 e5                	mov    %esp,%ebp
80106670:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106676:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106679:	89 44 24 04          	mov    %eax,0x4(%esp)
8010667d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106684:	e8 7c f3 ff ff       	call   80105a05 <argstr>
80106689:	85 c0                	test   %eax,%eax
8010668b:	78 1a                	js     801066a7 <sys_exec+0x3a>
8010668d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106693:	89 44 24 04          	mov    %eax,0x4(%esp)
80106697:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010669e:	e8 d2 f2 ff ff       	call   80105975 <argint>
801066a3:	85 c0                	test   %eax,%eax
801066a5:	79 0a                	jns    801066b1 <sys_exec+0x44>
    return -1;
801066a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ac:	e9 c8 00 00 00       	jmp    80106779 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
801066b1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801066b8:	00 
801066b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801066c0:	00 
801066c1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066c7:	89 04 24             	mov    %eax,(%esp)
801066ca:	e8 64 ef ff ff       	call   80105633 <memset>
  for(i=0;; i++){
801066cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801066d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d9:	83 f8 1f             	cmp    $0x1f,%eax
801066dc:	76 0a                	jbe    801066e8 <sys_exec+0x7b>
      return -1;
801066de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e3:	e9 91 00 00 00       	jmp    80106779 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801066e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066eb:	c1 e0 02             	shl    $0x2,%eax
801066ee:	89 c2                	mov    %eax,%edx
801066f0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801066f6:	01 c2                	add    %eax,%edx
801066f8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801066fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106702:	89 14 24             	mov    %edx,(%esp)
80106705:	e8 cf f1 ff ff       	call   801058d9 <fetchint>
8010670a:	85 c0                	test   %eax,%eax
8010670c:	79 07                	jns    80106715 <sys_exec+0xa8>
      return -1;
8010670e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106713:	eb 64                	jmp    80106779 <sys_exec+0x10c>
    if(uarg == 0){
80106715:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010671b:	85 c0                	test   %eax,%eax
8010671d:	75 26                	jne    80106745 <sys_exec+0xd8>
      argv[i] = 0;
8010671f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106722:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106729:	00 00 00 00 
      break;
8010672d:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010672e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106731:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106737:	89 54 24 04          	mov    %edx,0x4(%esp)
8010673b:	89 04 24             	mov    %eax,(%esp)
8010673e:	e8 ac a3 ff ff       	call   80100aef <exec>
80106743:	eb 34                	jmp    80106779 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106745:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010674b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010674e:	c1 e2 02             	shl    $0x2,%edx
80106751:	01 c2                	add    %eax,%edx
80106753:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106759:	89 54 24 04          	mov    %edx,0x4(%esp)
8010675d:	89 04 24             	mov    %eax,(%esp)
80106760:	e8 ae f1 ff ff       	call   80105913 <fetchstr>
80106765:	85 c0                	test   %eax,%eax
80106767:	79 07                	jns    80106770 <sys_exec+0x103>
      return -1;
80106769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676e:	eb 09                	jmp    80106779 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106770:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106774:	e9 5d ff ff ff       	jmp    801066d6 <sys_exec+0x69>
  return exec(path, argv);
}
80106779:	c9                   	leave  
8010677a:	c3                   	ret    

8010677b <sys_pipe>:

int
sys_pipe(void)
{
8010677b:	55                   	push   %ebp
8010677c:	89 e5                	mov    %esp,%ebp
8010677e:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106781:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106788:	00 
80106789:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010678c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106790:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106797:	e8 07 f2 ff ff       	call   801059a3 <argptr>
8010679c:	85 c0                	test   %eax,%eax
8010679e:	79 0a                	jns    801067aa <sys_pipe+0x2f>
    return -1;
801067a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a5:	e9 9b 00 00 00       	jmp    80106845 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801067aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801067ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801067b1:	8d 45 e8             	lea    -0x18(%ebp),%eax
801067b4:	89 04 24             	mov    %eax,(%esp)
801067b7:	e8 72 d7 ff ff       	call   80103f2e <pipealloc>
801067bc:	85 c0                	test   %eax,%eax
801067be:	79 07                	jns    801067c7 <sys_pipe+0x4c>
    return -1;
801067c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c5:	eb 7e                	jmp    80106845 <sys_pipe+0xca>
  fd0 = -1;
801067c7:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801067ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067d1:	89 04 24             	mov    %eax,(%esp)
801067d4:	e8 67 f3 ff ff       	call   80105b40 <fdalloc>
801067d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067e0:	78 14                	js     801067f6 <sys_pipe+0x7b>
801067e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067e5:	89 04 24             	mov    %eax,(%esp)
801067e8:	e8 53 f3 ff ff       	call   80105b40 <fdalloc>
801067ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067f4:	79 37                	jns    8010682d <sys_pipe+0xb2>
    if(fd0 >= 0)
801067f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067fa:	78 14                	js     80106810 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801067fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106802:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106805:	83 c2 08             	add    $0x8,%edx
80106808:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010680f:	00 
    fileclose(rf);
80106810:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106813:	89 04 24             	mov    %eax,(%esp)
80106816:	e8 c0 a7 ff ff       	call   80100fdb <fileclose>
    fileclose(wf);
8010681b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010681e:	89 04 24             	mov    %eax,(%esp)
80106821:	e8 b5 a7 ff ff       	call   80100fdb <fileclose>
    return -1;
80106826:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010682b:	eb 18                	jmp    80106845 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010682d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106830:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106833:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106835:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106838:	8d 50 04             	lea    0x4(%eax),%edx
8010683b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010683e:	89 02                	mov    %eax,(%edx)
  return 0;
80106840:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106845:	c9                   	leave  
80106846:	c3                   	ret    

80106847 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106847:	55                   	push   %ebp
80106848:	89 e5                	mov    %esp,%ebp
8010684a:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010684d:	e8 1c de ff ff       	call   8010466e <fork>
}
80106852:	c9                   	leave  
80106853:	c3                   	ret    

80106854 <sys_exit>:

int
sys_exit(void)
{
80106854:	55                   	push   %ebp
80106855:	89 e5                	mov    %esp,%ebp
80106857:	83 ec 08             	sub    $0x8,%esp
  exit();
8010685a:	e8 99 df ff ff       	call   801047f8 <exit>
  return 0;  // not reached
8010685f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106864:	c9                   	leave  
80106865:	c3                   	ret    

80106866 <sys_wait>:

int
sys_wait(void)
{
80106866:	55                   	push   %ebp
80106867:	89 e5                	mov    %esp,%ebp
80106869:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010686c:	e8 ac e0 ff ff       	call   8010491d <wait>
}
80106871:	c9                   	leave  
80106872:	c3                   	ret    

80106873 <sys_kill>:

int
sys_kill(void)
{
80106873:	55                   	push   %ebp
80106874:	89 e5                	mov    %esp,%ebp
80106876:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106879:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010687c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106880:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106887:	e8 e9 f0 ff ff       	call   80105975 <argint>
8010688c:	85 c0                	test   %eax,%eax
8010688e:	79 07                	jns    80106897 <sys_kill+0x24>
    return -1;
80106890:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106895:	eb 0b                	jmp    801068a2 <sys_kill+0x2f>
  return kill(pid);
80106897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689a:	89 04 24             	mov    %eax,(%esp)
8010689d:	e8 c0 e4 ff ff       	call   80104d62 <kill>
}
801068a2:	c9                   	leave  
801068a3:	c3                   	ret    

801068a4 <sys_getpid>:

int
sys_getpid(void)
{
801068a4:	55                   	push   %ebp
801068a5:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801068a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068ad:	8b 40 10             	mov    0x10(%eax),%eax
}
801068b0:	5d                   	pop    %ebp
801068b1:	c3                   	ret    

801068b2 <sys_sbrk>:

int
sys_sbrk(void)
{
801068b2:	55                   	push   %ebp
801068b3:	89 e5                	mov    %esp,%ebp
801068b5:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801068b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801068bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068c6:	e8 aa f0 ff ff       	call   80105975 <argint>
801068cb:	85 c0                	test   %eax,%eax
801068cd:	79 07                	jns    801068d6 <sys_sbrk+0x24>
    return -1;
801068cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d4:	eb 24                	jmp    801068fa <sys_sbrk+0x48>
  addr = proc->sz;
801068d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068dc:	8b 00                	mov    (%eax),%eax
801068de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801068e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e4:	89 04 24             	mov    %eax,(%esp)
801068e7:	e8 dd dc ff ff       	call   801045c9 <growproc>
801068ec:	85 c0                	test   %eax,%eax
801068ee:	79 07                	jns    801068f7 <sys_sbrk+0x45>
    return -1;
801068f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f5:	eb 03                	jmp    801068fa <sys_sbrk+0x48>
  return addr;
801068f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068fa:	c9                   	leave  
801068fb:	c3                   	ret    

801068fc <sys_sleep>:

int
sys_sleep(void)
{
801068fc:	55                   	push   %ebp
801068fd:	89 e5                	mov    %esp,%ebp
801068ff:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106902:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106905:	89 44 24 04          	mov    %eax,0x4(%esp)
80106909:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106910:	e8 60 f0 ff ff       	call   80105975 <argint>
80106915:	85 c0                	test   %eax,%eax
80106917:	79 07                	jns    80106920 <sys_sleep+0x24>
    return -1;
80106919:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010691e:	eb 6c                	jmp    8010698c <sys_sleep+0x90>
  acquire(&tickslock);
80106920:	c7 04 24 c0 a0 11 80 	movl   $0x8011a0c0,(%esp)
80106927:	e8 b3 ea ff ff       	call   801053df <acquire>
  ticks0 = ticks;
8010692c:	a1 00 a9 11 80       	mov    0x8011a900,%eax
80106931:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106934:	eb 34                	jmp    8010696a <sys_sleep+0x6e>
    if(proc->killed){
80106936:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010693c:	8b 40 24             	mov    0x24(%eax),%eax
8010693f:	85 c0                	test   %eax,%eax
80106941:	74 13                	je     80106956 <sys_sleep+0x5a>
      release(&tickslock);
80106943:	c7 04 24 c0 a0 11 80 	movl   $0x8011a0c0,(%esp)
8010694a:	e8 f2 ea ff ff       	call   80105441 <release>
      return -1;
8010694f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106954:	eb 36                	jmp    8010698c <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106956:	c7 44 24 04 c0 a0 11 	movl   $0x8011a0c0,0x4(%esp)
8010695d:	80 
8010695e:	c7 04 24 00 a9 11 80 	movl   $0x8011a900,(%esp)
80106965:	e8 f2 e2 ff ff       	call   80104c5c <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010696a:	a1 00 a9 11 80       	mov    0x8011a900,%eax
8010696f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106972:	89 c2                	mov    %eax,%edx
80106974:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106977:	39 c2                	cmp    %eax,%edx
80106979:	72 bb                	jb     80106936 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010697b:	c7 04 24 c0 a0 11 80 	movl   $0x8011a0c0,(%esp)
80106982:	e8 ba ea ff ff       	call   80105441 <release>
  return 0;
80106987:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010698c:	c9                   	leave  
8010698d:	c3                   	ret    

8010698e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010698e:	55                   	push   %ebp
8010698f:	89 e5                	mov    %esp,%ebp
80106991:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106994:	c7 04 24 c0 a0 11 80 	movl   $0x8011a0c0,(%esp)
8010699b:	e8 3f ea ff ff       	call   801053df <acquire>
  xticks = ticks;
801069a0:	a1 00 a9 11 80       	mov    0x8011a900,%eax
801069a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801069a8:	c7 04 24 c0 a0 11 80 	movl   $0x8011a0c0,(%esp)
801069af:	e8 8d ea ff ff       	call   80105441 <release>
  return xticks;
801069b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069b7:	c9                   	leave  
801069b8:	c3                   	ret    

801069b9 <sys_sigset>:

int
sys_sigset(void)
{
801069b9:	55                   	push   %ebp
801069ba:	89 e5                	mov    %esp,%ebp
801069bc:	83 ec 28             	sub    $0x28,%esp
  sig_handler new_handler;

  if(argptr(0, (char**)&new_handler, sizeof(sig_handler)) < 0)
801069bf:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801069c6:	00 
801069c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801069ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069d5:	e8 c9 ef ff ff       	call   801059a3 <argptr>
801069da:	85 c0                	test   %eax,%eax
801069dc:	79 07                	jns    801069e5 <sys_sigset+0x2c>
    return -1;
801069de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e3:	eb 0b                	jmp    801069f0 <sys_sigset+0x37>
  return (int) sigset(new_handler);
801069e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e8:	89 04 24             	mov    %eax,(%esp)
801069eb:	e8 22 e5 ff ff       	call   80104f12 <sigset>
}
801069f0:	c9                   	leave  
801069f1:	c3                   	ret    

801069f2 <sys_sigsend>:

int
sys_sigsend(void)
{
801069f2:	55                   	push   %ebp
801069f3:	89 e5                	mov    %esp,%ebp
801069f5:	83 ec 28             	sub    $0x28,%esp
  int dest_pid;
  int value;

  if(argint(0, &dest_pid) < 0 || argint(1, &value) < 0)
801069f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801069ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a06:	e8 6a ef ff ff       	call   80105975 <argint>
80106a0b:	85 c0                	test   %eax,%eax
80106a0d:	78 17                	js     80106a26 <sys_sigsend+0x34>
80106a0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a12:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a1d:	e8 53 ef ff ff       	call   80105975 <argint>
80106a22:	85 c0                	test   %eax,%eax
80106a24:	79 07                	jns    80106a2d <sys_sigsend+0x3b>
    return -1;
80106a26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a2b:	eb 12                	jmp    80106a3f <sys_sigsend+0x4d>
  return sigsend(dest_pid, value);
80106a2d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a33:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a37:	89 04 24             	mov    %eax,(%esp)
80106a3a:	e8 f6 e4 ff ff       	call   80104f35 <sigsend>
}
80106a3f:	c9                   	leave  
80106a40:	c3                   	ret    

80106a41 <sys_sigret>:

int
sys_sigret(void)
{
80106a41:	55                   	push   %ebp
80106a42:	89 e5                	mov    %esp,%ebp
80106a44:	83 ec 08             	sub    $0x8,%esp
  return sigret();
80106a47:	e8 87 e5 ff ff       	call   80104fd3 <sigret>
}
80106a4c:	c9                   	leave  
80106a4d:	c3                   	ret    

80106a4e <sys_sigpause>:

int
sys_sigpause(void)
{
80106a4e:	55                   	push   %ebp
80106a4f:	89 e5                	mov    %esp,%ebp
80106a51:	83 ec 08             	sub    $0x8,%esp
  return sigpause();
80106a54:	e8 bc e5 ff ff       	call   80105015 <sigpause>
}
80106a59:	c9                   	leave  
80106a5a:	c3                   	ret    

80106a5b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106a5b:	55                   	push   %ebp
80106a5c:	89 e5                	mov    %esp,%ebp
80106a5e:	83 ec 08             	sub    $0x8,%esp
80106a61:	8b 55 08             	mov    0x8(%ebp),%edx
80106a64:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a67:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106a6b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a6e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106a72:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106a76:	ee                   	out    %al,(%dx)
}
80106a77:	c9                   	leave  
80106a78:	c3                   	ret    

80106a79 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106a79:	55                   	push   %ebp
80106a7a:	89 e5                	mov    %esp,%ebp
80106a7c:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106a7f:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106a86:	00 
80106a87:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106a8e:	e8 c8 ff ff ff       	call   80106a5b <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106a93:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106a9a:	00 
80106a9b:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106aa2:	e8 b4 ff ff ff       	call   80106a5b <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106aa7:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106aae:	00 
80106aaf:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106ab6:	e8 a0 ff ff ff       	call   80106a5b <outb>
  picenable(IRQ_TIMER);
80106abb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ac2:	e8 fa d2 ff ff       	call   80103dc1 <picenable>
}
80106ac7:	c9                   	leave  
80106ac8:	c3                   	ret    

80106ac9 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ac9:	1e                   	push   %ds
  pushl %es
80106aca:	06                   	push   %es
  pushl %fs
80106acb:	0f a0                	push   %fs
  pushl %gs
80106acd:	0f a8                	push   %gs
  pushal
80106acf:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106ad0:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106ad4:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106ad6:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106ad8:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106adc:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106ade:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106ae0:	54                   	push   %esp
  call trap
80106ae1:	e8 dd 01 00 00       	call   80106cc3 <trap>
  addl $4, %esp
80106ae6:	83 c4 04             	add    $0x4,%esp

80106ae9 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  call fix_tf
80106ae9:	e8 af e6 ff ff       	call   8010519d <fix_tf>
  popal
80106aee:	61                   	popa   
  popl %gs
80106aef:	0f a9                	pop    %gs
  popl %fs
80106af1:	0f a1                	pop    %fs
  popl %es
80106af3:	07                   	pop    %es
  popl %ds
80106af4:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106af5:	83 c4 08             	add    $0x8,%esp
  iret
80106af8:	cf                   	iret   

80106af9 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106af9:	55                   	push   %ebp
80106afa:	89 e5                	mov    %esp,%ebp
80106afc:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106aff:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b02:	83 e8 01             	sub    $0x1,%eax
80106b05:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b09:	8b 45 08             	mov    0x8(%ebp),%eax
80106b0c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b10:	8b 45 08             	mov    0x8(%ebp),%eax
80106b13:	c1 e8 10             	shr    $0x10,%eax
80106b16:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106b1a:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b1d:	0f 01 18             	lidtl  (%eax)
}
80106b20:	c9                   	leave  
80106b21:	c3                   	ret    

80106b22 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106b22:	55                   	push   %ebp
80106b23:	89 e5                	mov    %esp,%ebp
80106b25:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b28:	0f 20 d0             	mov    %cr2,%eax
80106b2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b31:	c9                   	leave  
80106b32:	c3                   	ret    

80106b33 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b33:	55                   	push   %ebp
80106b34:	89 e5                	mov    %esp,%ebp
80106b36:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b40:	e9 c3 00 00 00       	jmp    80106c08 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b48:	8b 04 85 a8 c0 10 80 	mov    -0x7fef3f58(,%eax,4),%eax
80106b4f:	89 c2                	mov    %eax,%edx
80106b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b54:	66 89 14 c5 00 a1 11 	mov    %dx,-0x7fee5f00(,%eax,8)
80106b5b:	80 
80106b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5f:	66 c7 04 c5 02 a1 11 	movw   $0x8,-0x7fee5efe(,%eax,8)
80106b66:	80 08 00 
80106b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6c:	0f b6 14 c5 04 a1 11 	movzbl -0x7fee5efc(,%eax,8),%edx
80106b73:	80 
80106b74:	83 e2 e0             	and    $0xffffffe0,%edx
80106b77:	88 14 c5 04 a1 11 80 	mov    %dl,-0x7fee5efc(,%eax,8)
80106b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b81:	0f b6 14 c5 04 a1 11 	movzbl -0x7fee5efc(,%eax,8),%edx
80106b88:	80 
80106b89:	83 e2 1f             	and    $0x1f,%edx
80106b8c:	88 14 c5 04 a1 11 80 	mov    %dl,-0x7fee5efc(,%eax,8)
80106b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b96:	0f b6 14 c5 05 a1 11 	movzbl -0x7fee5efb(,%eax,8),%edx
80106b9d:	80 
80106b9e:	83 e2 f0             	and    $0xfffffff0,%edx
80106ba1:	83 ca 0e             	or     $0xe,%edx
80106ba4:	88 14 c5 05 a1 11 80 	mov    %dl,-0x7fee5efb(,%eax,8)
80106bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bae:	0f b6 14 c5 05 a1 11 	movzbl -0x7fee5efb(,%eax,8),%edx
80106bb5:	80 
80106bb6:	83 e2 ef             	and    $0xffffffef,%edx
80106bb9:	88 14 c5 05 a1 11 80 	mov    %dl,-0x7fee5efb(,%eax,8)
80106bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc3:	0f b6 14 c5 05 a1 11 	movzbl -0x7fee5efb(,%eax,8),%edx
80106bca:	80 
80106bcb:	83 e2 9f             	and    $0xffffff9f,%edx
80106bce:	88 14 c5 05 a1 11 80 	mov    %dl,-0x7fee5efb(,%eax,8)
80106bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd8:	0f b6 14 c5 05 a1 11 	movzbl -0x7fee5efb(,%eax,8),%edx
80106bdf:	80 
80106be0:	83 ca 80             	or     $0xffffff80,%edx
80106be3:	88 14 c5 05 a1 11 80 	mov    %dl,-0x7fee5efb(,%eax,8)
80106bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bed:	8b 04 85 a8 c0 10 80 	mov    -0x7fef3f58(,%eax,4),%eax
80106bf4:	c1 e8 10             	shr    $0x10,%eax
80106bf7:	89 c2                	mov    %eax,%edx
80106bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bfc:	66 89 14 c5 06 a1 11 	mov    %dx,-0x7fee5efa(,%eax,8)
80106c03:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106c04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c08:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c0f:	0f 8e 30 ff ff ff    	jle    80106b45 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c15:	a1 a8 c1 10 80       	mov    0x8010c1a8,%eax
80106c1a:	66 a3 00 a3 11 80    	mov    %ax,0x8011a300
80106c20:	66 c7 05 02 a3 11 80 	movw   $0x8,0x8011a302
80106c27:	08 00 
80106c29:	0f b6 05 04 a3 11 80 	movzbl 0x8011a304,%eax
80106c30:	83 e0 e0             	and    $0xffffffe0,%eax
80106c33:	a2 04 a3 11 80       	mov    %al,0x8011a304
80106c38:	0f b6 05 04 a3 11 80 	movzbl 0x8011a304,%eax
80106c3f:	83 e0 1f             	and    $0x1f,%eax
80106c42:	a2 04 a3 11 80       	mov    %al,0x8011a304
80106c47:	0f b6 05 05 a3 11 80 	movzbl 0x8011a305,%eax
80106c4e:	83 c8 0f             	or     $0xf,%eax
80106c51:	a2 05 a3 11 80       	mov    %al,0x8011a305
80106c56:	0f b6 05 05 a3 11 80 	movzbl 0x8011a305,%eax
80106c5d:	83 e0 ef             	and    $0xffffffef,%eax
80106c60:	a2 05 a3 11 80       	mov    %al,0x8011a305
80106c65:	0f b6 05 05 a3 11 80 	movzbl 0x8011a305,%eax
80106c6c:	83 c8 60             	or     $0x60,%eax
80106c6f:	a2 05 a3 11 80       	mov    %al,0x8011a305
80106c74:	0f b6 05 05 a3 11 80 	movzbl 0x8011a305,%eax
80106c7b:	83 c8 80             	or     $0xffffff80,%eax
80106c7e:	a2 05 a3 11 80       	mov    %al,0x8011a305
80106c83:	a1 a8 c1 10 80       	mov    0x8010c1a8,%eax
80106c88:	c1 e8 10             	shr    $0x10,%eax
80106c8b:	66 a3 06 a3 11 80    	mov    %ax,0x8011a306
  
  initlock(&tickslock, "time");
80106c91:	c7 44 24 04 70 8f 10 	movl   $0x80108f70,0x4(%esp)
80106c98:	80 
80106c99:	c7 04 24 c0 a0 11 80 	movl   $0x8011a0c0,(%esp)
80106ca0:	e8 19 e7 ff ff       	call   801053be <initlock>
}
80106ca5:	c9                   	leave  
80106ca6:	c3                   	ret    

80106ca7 <idtinit>:

void
idtinit(void)
{
80106ca7:	55                   	push   %ebp
80106ca8:	89 e5                	mov    %esp,%ebp
80106caa:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106cad:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106cb4:	00 
80106cb5:	c7 04 24 00 a1 11 80 	movl   $0x8011a100,(%esp)
80106cbc:	e8 38 fe ff ff       	call   80106af9 <lidt>
}
80106cc1:	c9                   	leave  
80106cc2:	c3                   	ret    

80106cc3 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106cc3:	55                   	push   %ebp
80106cc4:	89 e5                	mov    %esp,%ebp
80106cc6:	57                   	push   %edi
80106cc7:	56                   	push   %esi
80106cc8:	53                   	push   %ebx
80106cc9:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80106ccf:	8b 40 30             	mov    0x30(%eax),%eax
80106cd2:	83 f8 40             	cmp    $0x40,%eax
80106cd5:	75 3f                	jne    80106d16 <trap+0x53>
    if(proc->killed)
80106cd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cdd:	8b 40 24             	mov    0x24(%eax),%eax
80106ce0:	85 c0                	test   %eax,%eax
80106ce2:	74 05                	je     80106ce9 <trap+0x26>
      exit();
80106ce4:	e8 0f db ff ff       	call   801047f8 <exit>
    proc->tf = tf;
80106ce9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cef:	8b 55 08             	mov    0x8(%ebp),%edx
80106cf2:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106cf5:	e8 42 ed ff ff       	call   80105a3c <syscall>
    if(proc->killed)
80106cfa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d00:	8b 40 24             	mov    0x24(%eax),%eax
80106d03:	85 c0                	test   %eax,%eax
80106d05:	74 0a                	je     80106d11 <trap+0x4e>
      exit();
80106d07:	e8 ec da ff ff       	call   801047f8 <exit>
    return;
80106d0c:	e9 2d 02 00 00       	jmp    80106f3e <trap+0x27b>
80106d11:	e9 28 02 00 00       	jmp    80106f3e <trap+0x27b>
  }

  switch(tf->trapno){
80106d16:	8b 45 08             	mov    0x8(%ebp),%eax
80106d19:	8b 40 30             	mov    0x30(%eax),%eax
80106d1c:	83 e8 20             	sub    $0x20,%eax
80106d1f:	83 f8 1f             	cmp    $0x1f,%eax
80106d22:	0f 87 bc 00 00 00    	ja     80106de4 <trap+0x121>
80106d28:	8b 04 85 18 90 10 80 	mov    -0x7fef6fe8(,%eax,4),%eax
80106d2f:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106d31:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d37:	0f b6 00             	movzbl (%eax),%eax
80106d3a:	84 c0                	test   %al,%al
80106d3c:	75 31                	jne    80106d6f <trap+0xac>
      acquire(&tickslock);
80106d3e:	c7 04 24 c0 a0 11 80 	movl   $0x8011a0c0,(%esp)
80106d45:	e8 95 e6 ff ff       	call   801053df <acquire>
      ticks++;
80106d4a:	a1 00 a9 11 80       	mov    0x8011a900,%eax
80106d4f:	83 c0 01             	add    $0x1,%eax
80106d52:	a3 00 a9 11 80       	mov    %eax,0x8011a900
      wakeup(&ticks);
80106d57:	c7 04 24 00 a9 11 80 	movl   $0x8011a900,(%esp)
80106d5e:	e8 d4 df ff ff       	call   80104d37 <wakeup>
      release(&tickslock);
80106d63:	c7 04 24 c0 a0 11 80 	movl   $0x8011a0c0,(%esp)
80106d6a:	e8 d2 e6 ff ff       	call   80105441 <release>
    }
    lapiceoi();
80106d6f:	e8 69 c1 ff ff       	call   80102edd <lapiceoi>
    break;
80106d74:	e9 41 01 00 00       	jmp    80106eba <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d79:	e8 6d b9 ff ff       	call   801026eb <ideintr>
    lapiceoi();
80106d7e:	e8 5a c1 ff ff       	call   80102edd <lapiceoi>
    break;
80106d83:	e9 32 01 00 00       	jmp    80106eba <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d88:	e8 1f bf ff ff       	call   80102cac <kbdintr>
    lapiceoi();
80106d8d:	e8 4b c1 ff ff       	call   80102edd <lapiceoi>
    break;
80106d92:	e9 23 01 00 00       	jmp    80106eba <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d97:	e8 97 03 00 00       	call   80107133 <uartintr>
    lapiceoi();
80106d9c:	e8 3c c1 ff ff       	call   80102edd <lapiceoi>
    break;
80106da1:	e9 14 01 00 00       	jmp    80106eba <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106da6:	8b 45 08             	mov    0x8(%ebp),%eax
80106da9:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106dac:	8b 45 08             	mov    0x8(%ebp),%eax
80106daf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106db3:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106db6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106dbc:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dbf:	0f b6 c0             	movzbl %al,%eax
80106dc2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106dc6:	89 54 24 08          	mov    %edx,0x8(%esp)
80106dca:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dce:	c7 04 24 78 8f 10 80 	movl   $0x80108f78,(%esp)
80106dd5:	e8 c6 95 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106dda:	e8 fe c0 ff ff       	call   80102edd <lapiceoi>
    break;
80106ddf:	e9 d6 00 00 00       	jmp    80106eba <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106de4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dea:	85 c0                	test   %eax,%eax
80106dec:	74 11                	je     80106dff <trap+0x13c>
80106dee:	8b 45 08             	mov    0x8(%ebp),%eax
80106df1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106df5:	0f b7 c0             	movzwl %ax,%eax
80106df8:	83 e0 03             	and    $0x3,%eax
80106dfb:	85 c0                	test   %eax,%eax
80106dfd:	75 46                	jne    80106e45 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106dff:	e8 1e fd ff ff       	call   80106b22 <rcr2>
80106e04:	8b 55 08             	mov    0x8(%ebp),%edx
80106e07:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106e0a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106e11:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e14:	0f b6 ca             	movzbl %dl,%ecx
80106e17:	8b 55 08             	mov    0x8(%ebp),%edx
80106e1a:	8b 52 30             	mov    0x30(%edx),%edx
80106e1d:	89 44 24 10          	mov    %eax,0x10(%esp)
80106e21:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106e25:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106e29:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e2d:	c7 04 24 9c 8f 10 80 	movl   $0x80108f9c,(%esp)
80106e34:	e8 67 95 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106e39:	c7 04 24 ce 8f 10 80 	movl   $0x80108fce,(%esp)
80106e40:	e8 f5 96 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e45:	e8 d8 fc ff ff       	call   80106b22 <rcr2>
80106e4a:	89 c2                	mov    %eax,%edx
80106e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e4f:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e52:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e58:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e5b:	0f b6 f0             	movzbl %al,%esi
80106e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80106e61:	8b 58 34             	mov    0x34(%eax),%ebx
80106e64:	8b 45 08             	mov    0x8(%ebp),%eax
80106e67:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e70:	83 c0 6c             	add    $0x6c,%eax
80106e73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106e76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e7c:	8b 40 10             	mov    0x10(%eax),%eax
80106e7f:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106e83:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106e87:	89 74 24 14          	mov    %esi,0x14(%esp)
80106e8b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106e8f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106e93:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106e96:	89 74 24 08          	mov    %esi,0x8(%esp)
80106e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e9e:	c7 04 24 d4 8f 10 80 	movl   $0x80108fd4,(%esp)
80106ea5:	e8 f6 94 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106eaa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eb0:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106eb7:	eb 01                	jmp    80106eba <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106eb9:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106eba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ec0:	85 c0                	test   %eax,%eax
80106ec2:	74 24                	je     80106ee8 <trap+0x225>
80106ec4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eca:	8b 40 24             	mov    0x24(%eax),%eax
80106ecd:	85 c0                	test   %eax,%eax
80106ecf:	74 17                	je     80106ee8 <trap+0x225>
80106ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ed8:	0f b7 c0             	movzwl %ax,%eax
80106edb:	83 e0 03             	and    $0x3,%eax
80106ede:	83 f8 03             	cmp    $0x3,%eax
80106ee1:	75 05                	jne    80106ee8 <trap+0x225>
    exit();
80106ee3:	e8 10 d9 ff ff       	call   801047f8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106ee8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eee:	85 c0                	test   %eax,%eax
80106ef0:	74 1e                	je     80106f10 <trap+0x24d>
80106ef2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ef8:	8b 40 0c             	mov    0xc(%eax),%eax
80106efb:	83 f8 04             	cmp    $0x4,%eax
80106efe:	75 10                	jne    80106f10 <trap+0x24d>
80106f00:	8b 45 08             	mov    0x8(%ebp),%eax
80106f03:	8b 40 30             	mov    0x30(%eax),%eax
80106f06:	83 f8 20             	cmp    $0x20,%eax
80106f09:	75 05                	jne    80106f10 <trap+0x24d>
    yield();
80106f0b:	e8 ee dc ff ff       	call   80104bfe <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106f10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f16:	85 c0                	test   %eax,%eax
80106f18:	74 24                	je     80106f3e <trap+0x27b>
80106f1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f20:	8b 40 24             	mov    0x24(%eax),%eax
80106f23:	85 c0                	test   %eax,%eax
80106f25:	74 17                	je     80106f3e <trap+0x27b>
80106f27:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f2e:	0f b7 c0             	movzwl %ax,%eax
80106f31:	83 e0 03             	and    $0x3,%eax
80106f34:	83 f8 03             	cmp    $0x3,%eax
80106f37:	75 05                	jne    80106f3e <trap+0x27b>
    exit();
80106f39:	e8 ba d8 ff ff       	call   801047f8 <exit>
}
80106f3e:	83 c4 3c             	add    $0x3c,%esp
80106f41:	5b                   	pop    %ebx
80106f42:	5e                   	pop    %esi
80106f43:	5f                   	pop    %edi
80106f44:	5d                   	pop    %ebp
80106f45:	c3                   	ret    

80106f46 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106f46:	55                   	push   %ebp
80106f47:	89 e5                	mov    %esp,%ebp
80106f49:	83 ec 14             	sub    $0x14,%esp
80106f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f53:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f57:	89 c2                	mov    %eax,%edx
80106f59:	ec                   	in     (%dx),%al
80106f5a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f5d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f61:	c9                   	leave  
80106f62:	c3                   	ret    

80106f63 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106f63:	55                   	push   %ebp
80106f64:	89 e5                	mov    %esp,%ebp
80106f66:	83 ec 08             	sub    $0x8,%esp
80106f69:	8b 55 08             	mov    0x8(%ebp),%edx
80106f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f6f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106f73:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f76:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f7a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f7e:	ee                   	out    %al,(%dx)
}
80106f7f:	c9                   	leave  
80106f80:	c3                   	ret    

80106f81 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f81:	55                   	push   %ebp
80106f82:	89 e5                	mov    %esp,%ebp
80106f84:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106f8e:	00 
80106f8f:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106f96:	e8 c8 ff ff ff       	call   80106f63 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f9b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106fa2:	00 
80106fa3:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106faa:	e8 b4 ff ff ff       	call   80106f63 <outb>
  outb(COM1+0, 115200/9600);
80106faf:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106fb6:	00 
80106fb7:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106fbe:	e8 a0 ff ff ff       	call   80106f63 <outb>
  outb(COM1+1, 0);
80106fc3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106fca:	00 
80106fcb:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106fd2:	e8 8c ff ff ff       	call   80106f63 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fd7:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106fde:	00 
80106fdf:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106fe6:	e8 78 ff ff ff       	call   80106f63 <outb>
  outb(COM1+4, 0);
80106feb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ff2:	00 
80106ff3:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106ffa:	e8 64 ff ff ff       	call   80106f63 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106fff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107006:	00 
80107007:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010700e:	e8 50 ff ff ff       	call   80106f63 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107013:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010701a:	e8 27 ff ff ff       	call   80106f46 <inb>
8010701f:	3c ff                	cmp    $0xff,%al
80107021:	75 02                	jne    80107025 <uartinit+0xa4>
    return;
80107023:	eb 6a                	jmp    8010708f <uartinit+0x10e>
  uart = 1;
80107025:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
8010702c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010702f:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107036:	e8 0b ff ff ff       	call   80106f46 <inb>
  inb(COM1+0);
8010703b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107042:	e8 ff fe ff ff       	call   80106f46 <inb>
  picenable(IRQ_COM1);
80107047:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010704e:	e8 6e cd ff ff       	call   80103dc1 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107053:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010705a:	00 
8010705b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107062:	e8 03 b9 ff ff       	call   8010296a <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107067:	c7 45 f4 98 90 10 80 	movl   $0x80109098,-0xc(%ebp)
8010706e:	eb 15                	jmp    80107085 <uartinit+0x104>
    uartputc(*p);
80107070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107073:	0f b6 00             	movzbl (%eax),%eax
80107076:	0f be c0             	movsbl %al,%eax
80107079:	89 04 24             	mov    %eax,(%esp)
8010707c:	e8 10 00 00 00       	call   80107091 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107081:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107088:	0f b6 00             	movzbl (%eax),%eax
8010708b:	84 c0                	test   %al,%al
8010708d:	75 e1                	jne    80107070 <uartinit+0xef>
    uartputc(*p);
}
8010708f:	c9                   	leave  
80107090:	c3                   	ret    

80107091 <uartputc>:

void
uartputc(int c)
{
80107091:	55                   	push   %ebp
80107092:	89 e5                	mov    %esp,%ebp
80107094:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107097:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010709c:	85 c0                	test   %eax,%eax
8010709e:	75 02                	jne    801070a2 <uartputc+0x11>
    return;
801070a0:	eb 4b                	jmp    801070ed <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070a9:	eb 10                	jmp    801070bb <uartputc+0x2a>
    microdelay(10);
801070ab:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801070b2:	e8 4b be ff ff       	call   80102f02 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070bb:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070bf:	7f 16                	jg     801070d7 <uartputc+0x46>
801070c1:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801070c8:	e8 79 fe ff ff       	call   80106f46 <inb>
801070cd:	0f b6 c0             	movzbl %al,%eax
801070d0:	83 e0 20             	and    $0x20,%eax
801070d3:	85 c0                	test   %eax,%eax
801070d5:	74 d4                	je     801070ab <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801070d7:	8b 45 08             	mov    0x8(%ebp),%eax
801070da:	0f b6 c0             	movzbl %al,%eax
801070dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801070e1:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801070e8:	e8 76 fe ff ff       	call   80106f63 <outb>
}
801070ed:	c9                   	leave  
801070ee:	c3                   	ret    

801070ef <uartgetc>:

static int
uartgetc(void)
{
801070ef:	55                   	push   %ebp
801070f0:	89 e5                	mov    %esp,%ebp
801070f2:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801070f5:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801070fa:	85 c0                	test   %eax,%eax
801070fc:	75 07                	jne    80107105 <uartgetc+0x16>
    return -1;
801070fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107103:	eb 2c                	jmp    80107131 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107105:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010710c:	e8 35 fe ff ff       	call   80106f46 <inb>
80107111:	0f b6 c0             	movzbl %al,%eax
80107114:	83 e0 01             	and    $0x1,%eax
80107117:	85 c0                	test   %eax,%eax
80107119:	75 07                	jne    80107122 <uartgetc+0x33>
    return -1;
8010711b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107120:	eb 0f                	jmp    80107131 <uartgetc+0x42>
  return inb(COM1+0);
80107122:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107129:	e8 18 fe ff ff       	call   80106f46 <inb>
8010712e:	0f b6 c0             	movzbl %al,%eax
}
80107131:	c9                   	leave  
80107132:	c3                   	ret    

80107133 <uartintr>:

void
uartintr(void)
{
80107133:	55                   	push   %ebp
80107134:	89 e5                	mov    %esp,%ebp
80107136:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107139:	c7 04 24 ef 70 10 80 	movl   $0x801070ef,(%esp)
80107140:	e8 68 96 ff ff       	call   801007ad <consoleintr>
}
80107145:	c9                   	leave  
80107146:	c3                   	ret    

80107147 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $0
80107149:	6a 00                	push   $0x0
  jmp alltraps
8010714b:	e9 79 f9 ff ff       	jmp    80106ac9 <alltraps>

80107150 <vector1>:
.globl vector1
vector1:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $1
80107152:	6a 01                	push   $0x1
  jmp alltraps
80107154:	e9 70 f9 ff ff       	jmp    80106ac9 <alltraps>

80107159 <vector2>:
.globl vector2
vector2:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $2
8010715b:	6a 02                	push   $0x2
  jmp alltraps
8010715d:	e9 67 f9 ff ff       	jmp    80106ac9 <alltraps>

80107162 <vector3>:
.globl vector3
vector3:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $3
80107164:	6a 03                	push   $0x3
  jmp alltraps
80107166:	e9 5e f9 ff ff       	jmp    80106ac9 <alltraps>

8010716b <vector4>:
.globl vector4
vector4:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $4
8010716d:	6a 04                	push   $0x4
  jmp alltraps
8010716f:	e9 55 f9 ff ff       	jmp    80106ac9 <alltraps>

80107174 <vector5>:
.globl vector5
vector5:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $5
80107176:	6a 05                	push   $0x5
  jmp alltraps
80107178:	e9 4c f9 ff ff       	jmp    80106ac9 <alltraps>

8010717d <vector6>:
.globl vector6
vector6:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $6
8010717f:	6a 06                	push   $0x6
  jmp alltraps
80107181:	e9 43 f9 ff ff       	jmp    80106ac9 <alltraps>

80107186 <vector7>:
.globl vector7
vector7:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $7
80107188:	6a 07                	push   $0x7
  jmp alltraps
8010718a:	e9 3a f9 ff ff       	jmp    80106ac9 <alltraps>

8010718f <vector8>:
.globl vector8
vector8:
  pushl $8
8010718f:	6a 08                	push   $0x8
  jmp alltraps
80107191:	e9 33 f9 ff ff       	jmp    80106ac9 <alltraps>

80107196 <vector9>:
.globl vector9
vector9:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $9
80107198:	6a 09                	push   $0x9
  jmp alltraps
8010719a:	e9 2a f9 ff ff       	jmp    80106ac9 <alltraps>

8010719f <vector10>:
.globl vector10
vector10:
  pushl $10
8010719f:	6a 0a                	push   $0xa
  jmp alltraps
801071a1:	e9 23 f9 ff ff       	jmp    80106ac9 <alltraps>

801071a6 <vector11>:
.globl vector11
vector11:
  pushl $11
801071a6:	6a 0b                	push   $0xb
  jmp alltraps
801071a8:	e9 1c f9 ff ff       	jmp    80106ac9 <alltraps>

801071ad <vector12>:
.globl vector12
vector12:
  pushl $12
801071ad:	6a 0c                	push   $0xc
  jmp alltraps
801071af:	e9 15 f9 ff ff       	jmp    80106ac9 <alltraps>

801071b4 <vector13>:
.globl vector13
vector13:
  pushl $13
801071b4:	6a 0d                	push   $0xd
  jmp alltraps
801071b6:	e9 0e f9 ff ff       	jmp    80106ac9 <alltraps>

801071bb <vector14>:
.globl vector14
vector14:
  pushl $14
801071bb:	6a 0e                	push   $0xe
  jmp alltraps
801071bd:	e9 07 f9 ff ff       	jmp    80106ac9 <alltraps>

801071c2 <vector15>:
.globl vector15
vector15:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $15
801071c4:	6a 0f                	push   $0xf
  jmp alltraps
801071c6:	e9 fe f8 ff ff       	jmp    80106ac9 <alltraps>

801071cb <vector16>:
.globl vector16
vector16:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $16
801071cd:	6a 10                	push   $0x10
  jmp alltraps
801071cf:	e9 f5 f8 ff ff       	jmp    80106ac9 <alltraps>

801071d4 <vector17>:
.globl vector17
vector17:
  pushl $17
801071d4:	6a 11                	push   $0x11
  jmp alltraps
801071d6:	e9 ee f8 ff ff       	jmp    80106ac9 <alltraps>

801071db <vector18>:
.globl vector18
vector18:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $18
801071dd:	6a 12                	push   $0x12
  jmp alltraps
801071df:	e9 e5 f8 ff ff       	jmp    80106ac9 <alltraps>

801071e4 <vector19>:
.globl vector19
vector19:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $19
801071e6:	6a 13                	push   $0x13
  jmp alltraps
801071e8:	e9 dc f8 ff ff       	jmp    80106ac9 <alltraps>

801071ed <vector20>:
.globl vector20
vector20:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $20
801071ef:	6a 14                	push   $0x14
  jmp alltraps
801071f1:	e9 d3 f8 ff ff       	jmp    80106ac9 <alltraps>

801071f6 <vector21>:
.globl vector21
vector21:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $21
801071f8:	6a 15                	push   $0x15
  jmp alltraps
801071fa:	e9 ca f8 ff ff       	jmp    80106ac9 <alltraps>

801071ff <vector22>:
.globl vector22
vector22:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $22
80107201:	6a 16                	push   $0x16
  jmp alltraps
80107203:	e9 c1 f8 ff ff       	jmp    80106ac9 <alltraps>

80107208 <vector23>:
.globl vector23
vector23:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $23
8010720a:	6a 17                	push   $0x17
  jmp alltraps
8010720c:	e9 b8 f8 ff ff       	jmp    80106ac9 <alltraps>

80107211 <vector24>:
.globl vector24
vector24:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $24
80107213:	6a 18                	push   $0x18
  jmp alltraps
80107215:	e9 af f8 ff ff       	jmp    80106ac9 <alltraps>

8010721a <vector25>:
.globl vector25
vector25:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $25
8010721c:	6a 19                	push   $0x19
  jmp alltraps
8010721e:	e9 a6 f8 ff ff       	jmp    80106ac9 <alltraps>

80107223 <vector26>:
.globl vector26
vector26:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $26
80107225:	6a 1a                	push   $0x1a
  jmp alltraps
80107227:	e9 9d f8 ff ff       	jmp    80106ac9 <alltraps>

8010722c <vector27>:
.globl vector27
vector27:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $27
8010722e:	6a 1b                	push   $0x1b
  jmp alltraps
80107230:	e9 94 f8 ff ff       	jmp    80106ac9 <alltraps>

80107235 <vector28>:
.globl vector28
vector28:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $28
80107237:	6a 1c                	push   $0x1c
  jmp alltraps
80107239:	e9 8b f8 ff ff       	jmp    80106ac9 <alltraps>

8010723e <vector29>:
.globl vector29
vector29:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $29
80107240:	6a 1d                	push   $0x1d
  jmp alltraps
80107242:	e9 82 f8 ff ff       	jmp    80106ac9 <alltraps>

80107247 <vector30>:
.globl vector30
vector30:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $30
80107249:	6a 1e                	push   $0x1e
  jmp alltraps
8010724b:	e9 79 f8 ff ff       	jmp    80106ac9 <alltraps>

80107250 <vector31>:
.globl vector31
vector31:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $31
80107252:	6a 1f                	push   $0x1f
  jmp alltraps
80107254:	e9 70 f8 ff ff       	jmp    80106ac9 <alltraps>

80107259 <vector32>:
.globl vector32
vector32:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $32
8010725b:	6a 20                	push   $0x20
  jmp alltraps
8010725d:	e9 67 f8 ff ff       	jmp    80106ac9 <alltraps>

80107262 <vector33>:
.globl vector33
vector33:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $33
80107264:	6a 21                	push   $0x21
  jmp alltraps
80107266:	e9 5e f8 ff ff       	jmp    80106ac9 <alltraps>

8010726b <vector34>:
.globl vector34
vector34:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $34
8010726d:	6a 22                	push   $0x22
  jmp alltraps
8010726f:	e9 55 f8 ff ff       	jmp    80106ac9 <alltraps>

80107274 <vector35>:
.globl vector35
vector35:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $35
80107276:	6a 23                	push   $0x23
  jmp alltraps
80107278:	e9 4c f8 ff ff       	jmp    80106ac9 <alltraps>

8010727d <vector36>:
.globl vector36
vector36:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $36
8010727f:	6a 24                	push   $0x24
  jmp alltraps
80107281:	e9 43 f8 ff ff       	jmp    80106ac9 <alltraps>

80107286 <vector37>:
.globl vector37
vector37:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $37
80107288:	6a 25                	push   $0x25
  jmp alltraps
8010728a:	e9 3a f8 ff ff       	jmp    80106ac9 <alltraps>

8010728f <vector38>:
.globl vector38
vector38:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $38
80107291:	6a 26                	push   $0x26
  jmp alltraps
80107293:	e9 31 f8 ff ff       	jmp    80106ac9 <alltraps>

80107298 <vector39>:
.globl vector39
vector39:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $39
8010729a:	6a 27                	push   $0x27
  jmp alltraps
8010729c:	e9 28 f8 ff ff       	jmp    80106ac9 <alltraps>

801072a1 <vector40>:
.globl vector40
vector40:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $40
801072a3:	6a 28                	push   $0x28
  jmp alltraps
801072a5:	e9 1f f8 ff ff       	jmp    80106ac9 <alltraps>

801072aa <vector41>:
.globl vector41
vector41:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $41
801072ac:	6a 29                	push   $0x29
  jmp alltraps
801072ae:	e9 16 f8 ff ff       	jmp    80106ac9 <alltraps>

801072b3 <vector42>:
.globl vector42
vector42:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $42
801072b5:	6a 2a                	push   $0x2a
  jmp alltraps
801072b7:	e9 0d f8 ff ff       	jmp    80106ac9 <alltraps>

801072bc <vector43>:
.globl vector43
vector43:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $43
801072be:	6a 2b                	push   $0x2b
  jmp alltraps
801072c0:	e9 04 f8 ff ff       	jmp    80106ac9 <alltraps>

801072c5 <vector44>:
.globl vector44
vector44:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $44
801072c7:	6a 2c                	push   $0x2c
  jmp alltraps
801072c9:	e9 fb f7 ff ff       	jmp    80106ac9 <alltraps>

801072ce <vector45>:
.globl vector45
vector45:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $45
801072d0:	6a 2d                	push   $0x2d
  jmp alltraps
801072d2:	e9 f2 f7 ff ff       	jmp    80106ac9 <alltraps>

801072d7 <vector46>:
.globl vector46
vector46:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $46
801072d9:	6a 2e                	push   $0x2e
  jmp alltraps
801072db:	e9 e9 f7 ff ff       	jmp    80106ac9 <alltraps>

801072e0 <vector47>:
.globl vector47
vector47:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $47
801072e2:	6a 2f                	push   $0x2f
  jmp alltraps
801072e4:	e9 e0 f7 ff ff       	jmp    80106ac9 <alltraps>

801072e9 <vector48>:
.globl vector48
vector48:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $48
801072eb:	6a 30                	push   $0x30
  jmp alltraps
801072ed:	e9 d7 f7 ff ff       	jmp    80106ac9 <alltraps>

801072f2 <vector49>:
.globl vector49
vector49:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $49
801072f4:	6a 31                	push   $0x31
  jmp alltraps
801072f6:	e9 ce f7 ff ff       	jmp    80106ac9 <alltraps>

801072fb <vector50>:
.globl vector50
vector50:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $50
801072fd:	6a 32                	push   $0x32
  jmp alltraps
801072ff:	e9 c5 f7 ff ff       	jmp    80106ac9 <alltraps>

80107304 <vector51>:
.globl vector51
vector51:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $51
80107306:	6a 33                	push   $0x33
  jmp alltraps
80107308:	e9 bc f7 ff ff       	jmp    80106ac9 <alltraps>

8010730d <vector52>:
.globl vector52
vector52:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $52
8010730f:	6a 34                	push   $0x34
  jmp alltraps
80107311:	e9 b3 f7 ff ff       	jmp    80106ac9 <alltraps>

80107316 <vector53>:
.globl vector53
vector53:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $53
80107318:	6a 35                	push   $0x35
  jmp alltraps
8010731a:	e9 aa f7 ff ff       	jmp    80106ac9 <alltraps>

8010731f <vector54>:
.globl vector54
vector54:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $54
80107321:	6a 36                	push   $0x36
  jmp alltraps
80107323:	e9 a1 f7 ff ff       	jmp    80106ac9 <alltraps>

80107328 <vector55>:
.globl vector55
vector55:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $55
8010732a:	6a 37                	push   $0x37
  jmp alltraps
8010732c:	e9 98 f7 ff ff       	jmp    80106ac9 <alltraps>

80107331 <vector56>:
.globl vector56
vector56:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $56
80107333:	6a 38                	push   $0x38
  jmp alltraps
80107335:	e9 8f f7 ff ff       	jmp    80106ac9 <alltraps>

8010733a <vector57>:
.globl vector57
vector57:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $57
8010733c:	6a 39                	push   $0x39
  jmp alltraps
8010733e:	e9 86 f7 ff ff       	jmp    80106ac9 <alltraps>

80107343 <vector58>:
.globl vector58
vector58:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $58
80107345:	6a 3a                	push   $0x3a
  jmp alltraps
80107347:	e9 7d f7 ff ff       	jmp    80106ac9 <alltraps>

8010734c <vector59>:
.globl vector59
vector59:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $59
8010734e:	6a 3b                	push   $0x3b
  jmp alltraps
80107350:	e9 74 f7 ff ff       	jmp    80106ac9 <alltraps>

80107355 <vector60>:
.globl vector60
vector60:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $60
80107357:	6a 3c                	push   $0x3c
  jmp alltraps
80107359:	e9 6b f7 ff ff       	jmp    80106ac9 <alltraps>

8010735e <vector61>:
.globl vector61
vector61:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $61
80107360:	6a 3d                	push   $0x3d
  jmp alltraps
80107362:	e9 62 f7 ff ff       	jmp    80106ac9 <alltraps>

80107367 <vector62>:
.globl vector62
vector62:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $62
80107369:	6a 3e                	push   $0x3e
  jmp alltraps
8010736b:	e9 59 f7 ff ff       	jmp    80106ac9 <alltraps>

80107370 <vector63>:
.globl vector63
vector63:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $63
80107372:	6a 3f                	push   $0x3f
  jmp alltraps
80107374:	e9 50 f7 ff ff       	jmp    80106ac9 <alltraps>

80107379 <vector64>:
.globl vector64
vector64:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $64
8010737b:	6a 40                	push   $0x40
  jmp alltraps
8010737d:	e9 47 f7 ff ff       	jmp    80106ac9 <alltraps>

80107382 <vector65>:
.globl vector65
vector65:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $65
80107384:	6a 41                	push   $0x41
  jmp alltraps
80107386:	e9 3e f7 ff ff       	jmp    80106ac9 <alltraps>

8010738b <vector66>:
.globl vector66
vector66:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $66
8010738d:	6a 42                	push   $0x42
  jmp alltraps
8010738f:	e9 35 f7 ff ff       	jmp    80106ac9 <alltraps>

80107394 <vector67>:
.globl vector67
vector67:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $67
80107396:	6a 43                	push   $0x43
  jmp alltraps
80107398:	e9 2c f7 ff ff       	jmp    80106ac9 <alltraps>

8010739d <vector68>:
.globl vector68
vector68:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $68
8010739f:	6a 44                	push   $0x44
  jmp alltraps
801073a1:	e9 23 f7 ff ff       	jmp    80106ac9 <alltraps>

801073a6 <vector69>:
.globl vector69
vector69:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $69
801073a8:	6a 45                	push   $0x45
  jmp alltraps
801073aa:	e9 1a f7 ff ff       	jmp    80106ac9 <alltraps>

801073af <vector70>:
.globl vector70
vector70:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $70
801073b1:	6a 46                	push   $0x46
  jmp alltraps
801073b3:	e9 11 f7 ff ff       	jmp    80106ac9 <alltraps>

801073b8 <vector71>:
.globl vector71
vector71:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $71
801073ba:	6a 47                	push   $0x47
  jmp alltraps
801073bc:	e9 08 f7 ff ff       	jmp    80106ac9 <alltraps>

801073c1 <vector72>:
.globl vector72
vector72:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $72
801073c3:	6a 48                	push   $0x48
  jmp alltraps
801073c5:	e9 ff f6 ff ff       	jmp    80106ac9 <alltraps>

801073ca <vector73>:
.globl vector73
vector73:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $73
801073cc:	6a 49                	push   $0x49
  jmp alltraps
801073ce:	e9 f6 f6 ff ff       	jmp    80106ac9 <alltraps>

801073d3 <vector74>:
.globl vector74
vector74:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $74
801073d5:	6a 4a                	push   $0x4a
  jmp alltraps
801073d7:	e9 ed f6 ff ff       	jmp    80106ac9 <alltraps>

801073dc <vector75>:
.globl vector75
vector75:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $75
801073de:	6a 4b                	push   $0x4b
  jmp alltraps
801073e0:	e9 e4 f6 ff ff       	jmp    80106ac9 <alltraps>

801073e5 <vector76>:
.globl vector76
vector76:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $76
801073e7:	6a 4c                	push   $0x4c
  jmp alltraps
801073e9:	e9 db f6 ff ff       	jmp    80106ac9 <alltraps>

801073ee <vector77>:
.globl vector77
vector77:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $77
801073f0:	6a 4d                	push   $0x4d
  jmp alltraps
801073f2:	e9 d2 f6 ff ff       	jmp    80106ac9 <alltraps>

801073f7 <vector78>:
.globl vector78
vector78:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $78
801073f9:	6a 4e                	push   $0x4e
  jmp alltraps
801073fb:	e9 c9 f6 ff ff       	jmp    80106ac9 <alltraps>

80107400 <vector79>:
.globl vector79
vector79:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $79
80107402:	6a 4f                	push   $0x4f
  jmp alltraps
80107404:	e9 c0 f6 ff ff       	jmp    80106ac9 <alltraps>

80107409 <vector80>:
.globl vector80
vector80:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $80
8010740b:	6a 50                	push   $0x50
  jmp alltraps
8010740d:	e9 b7 f6 ff ff       	jmp    80106ac9 <alltraps>

80107412 <vector81>:
.globl vector81
vector81:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $81
80107414:	6a 51                	push   $0x51
  jmp alltraps
80107416:	e9 ae f6 ff ff       	jmp    80106ac9 <alltraps>

8010741b <vector82>:
.globl vector82
vector82:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $82
8010741d:	6a 52                	push   $0x52
  jmp alltraps
8010741f:	e9 a5 f6 ff ff       	jmp    80106ac9 <alltraps>

80107424 <vector83>:
.globl vector83
vector83:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $83
80107426:	6a 53                	push   $0x53
  jmp alltraps
80107428:	e9 9c f6 ff ff       	jmp    80106ac9 <alltraps>

8010742d <vector84>:
.globl vector84
vector84:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $84
8010742f:	6a 54                	push   $0x54
  jmp alltraps
80107431:	e9 93 f6 ff ff       	jmp    80106ac9 <alltraps>

80107436 <vector85>:
.globl vector85
vector85:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $85
80107438:	6a 55                	push   $0x55
  jmp alltraps
8010743a:	e9 8a f6 ff ff       	jmp    80106ac9 <alltraps>

8010743f <vector86>:
.globl vector86
vector86:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $86
80107441:	6a 56                	push   $0x56
  jmp alltraps
80107443:	e9 81 f6 ff ff       	jmp    80106ac9 <alltraps>

80107448 <vector87>:
.globl vector87
vector87:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $87
8010744a:	6a 57                	push   $0x57
  jmp alltraps
8010744c:	e9 78 f6 ff ff       	jmp    80106ac9 <alltraps>

80107451 <vector88>:
.globl vector88
vector88:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $88
80107453:	6a 58                	push   $0x58
  jmp alltraps
80107455:	e9 6f f6 ff ff       	jmp    80106ac9 <alltraps>

8010745a <vector89>:
.globl vector89
vector89:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $89
8010745c:	6a 59                	push   $0x59
  jmp alltraps
8010745e:	e9 66 f6 ff ff       	jmp    80106ac9 <alltraps>

80107463 <vector90>:
.globl vector90
vector90:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $90
80107465:	6a 5a                	push   $0x5a
  jmp alltraps
80107467:	e9 5d f6 ff ff       	jmp    80106ac9 <alltraps>

8010746c <vector91>:
.globl vector91
vector91:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $91
8010746e:	6a 5b                	push   $0x5b
  jmp alltraps
80107470:	e9 54 f6 ff ff       	jmp    80106ac9 <alltraps>

80107475 <vector92>:
.globl vector92
vector92:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $92
80107477:	6a 5c                	push   $0x5c
  jmp alltraps
80107479:	e9 4b f6 ff ff       	jmp    80106ac9 <alltraps>

8010747e <vector93>:
.globl vector93
vector93:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $93
80107480:	6a 5d                	push   $0x5d
  jmp alltraps
80107482:	e9 42 f6 ff ff       	jmp    80106ac9 <alltraps>

80107487 <vector94>:
.globl vector94
vector94:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $94
80107489:	6a 5e                	push   $0x5e
  jmp alltraps
8010748b:	e9 39 f6 ff ff       	jmp    80106ac9 <alltraps>

80107490 <vector95>:
.globl vector95
vector95:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $95
80107492:	6a 5f                	push   $0x5f
  jmp alltraps
80107494:	e9 30 f6 ff ff       	jmp    80106ac9 <alltraps>

80107499 <vector96>:
.globl vector96
vector96:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $96
8010749b:	6a 60                	push   $0x60
  jmp alltraps
8010749d:	e9 27 f6 ff ff       	jmp    80106ac9 <alltraps>

801074a2 <vector97>:
.globl vector97
vector97:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $97
801074a4:	6a 61                	push   $0x61
  jmp alltraps
801074a6:	e9 1e f6 ff ff       	jmp    80106ac9 <alltraps>

801074ab <vector98>:
.globl vector98
vector98:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $98
801074ad:	6a 62                	push   $0x62
  jmp alltraps
801074af:	e9 15 f6 ff ff       	jmp    80106ac9 <alltraps>

801074b4 <vector99>:
.globl vector99
vector99:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $99
801074b6:	6a 63                	push   $0x63
  jmp alltraps
801074b8:	e9 0c f6 ff ff       	jmp    80106ac9 <alltraps>

801074bd <vector100>:
.globl vector100
vector100:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $100
801074bf:	6a 64                	push   $0x64
  jmp alltraps
801074c1:	e9 03 f6 ff ff       	jmp    80106ac9 <alltraps>

801074c6 <vector101>:
.globl vector101
vector101:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $101
801074c8:	6a 65                	push   $0x65
  jmp alltraps
801074ca:	e9 fa f5 ff ff       	jmp    80106ac9 <alltraps>

801074cf <vector102>:
.globl vector102
vector102:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $102
801074d1:	6a 66                	push   $0x66
  jmp alltraps
801074d3:	e9 f1 f5 ff ff       	jmp    80106ac9 <alltraps>

801074d8 <vector103>:
.globl vector103
vector103:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $103
801074da:	6a 67                	push   $0x67
  jmp alltraps
801074dc:	e9 e8 f5 ff ff       	jmp    80106ac9 <alltraps>

801074e1 <vector104>:
.globl vector104
vector104:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $104
801074e3:	6a 68                	push   $0x68
  jmp alltraps
801074e5:	e9 df f5 ff ff       	jmp    80106ac9 <alltraps>

801074ea <vector105>:
.globl vector105
vector105:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $105
801074ec:	6a 69                	push   $0x69
  jmp alltraps
801074ee:	e9 d6 f5 ff ff       	jmp    80106ac9 <alltraps>

801074f3 <vector106>:
.globl vector106
vector106:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $106
801074f5:	6a 6a                	push   $0x6a
  jmp alltraps
801074f7:	e9 cd f5 ff ff       	jmp    80106ac9 <alltraps>

801074fc <vector107>:
.globl vector107
vector107:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $107
801074fe:	6a 6b                	push   $0x6b
  jmp alltraps
80107500:	e9 c4 f5 ff ff       	jmp    80106ac9 <alltraps>

80107505 <vector108>:
.globl vector108
vector108:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $108
80107507:	6a 6c                	push   $0x6c
  jmp alltraps
80107509:	e9 bb f5 ff ff       	jmp    80106ac9 <alltraps>

8010750e <vector109>:
.globl vector109
vector109:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $109
80107510:	6a 6d                	push   $0x6d
  jmp alltraps
80107512:	e9 b2 f5 ff ff       	jmp    80106ac9 <alltraps>

80107517 <vector110>:
.globl vector110
vector110:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $110
80107519:	6a 6e                	push   $0x6e
  jmp alltraps
8010751b:	e9 a9 f5 ff ff       	jmp    80106ac9 <alltraps>

80107520 <vector111>:
.globl vector111
vector111:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $111
80107522:	6a 6f                	push   $0x6f
  jmp alltraps
80107524:	e9 a0 f5 ff ff       	jmp    80106ac9 <alltraps>

80107529 <vector112>:
.globl vector112
vector112:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $112
8010752b:	6a 70                	push   $0x70
  jmp alltraps
8010752d:	e9 97 f5 ff ff       	jmp    80106ac9 <alltraps>

80107532 <vector113>:
.globl vector113
vector113:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $113
80107534:	6a 71                	push   $0x71
  jmp alltraps
80107536:	e9 8e f5 ff ff       	jmp    80106ac9 <alltraps>

8010753b <vector114>:
.globl vector114
vector114:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $114
8010753d:	6a 72                	push   $0x72
  jmp alltraps
8010753f:	e9 85 f5 ff ff       	jmp    80106ac9 <alltraps>

80107544 <vector115>:
.globl vector115
vector115:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $115
80107546:	6a 73                	push   $0x73
  jmp alltraps
80107548:	e9 7c f5 ff ff       	jmp    80106ac9 <alltraps>

8010754d <vector116>:
.globl vector116
vector116:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $116
8010754f:	6a 74                	push   $0x74
  jmp alltraps
80107551:	e9 73 f5 ff ff       	jmp    80106ac9 <alltraps>

80107556 <vector117>:
.globl vector117
vector117:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $117
80107558:	6a 75                	push   $0x75
  jmp alltraps
8010755a:	e9 6a f5 ff ff       	jmp    80106ac9 <alltraps>

8010755f <vector118>:
.globl vector118
vector118:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $118
80107561:	6a 76                	push   $0x76
  jmp alltraps
80107563:	e9 61 f5 ff ff       	jmp    80106ac9 <alltraps>

80107568 <vector119>:
.globl vector119
vector119:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $119
8010756a:	6a 77                	push   $0x77
  jmp alltraps
8010756c:	e9 58 f5 ff ff       	jmp    80106ac9 <alltraps>

80107571 <vector120>:
.globl vector120
vector120:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $120
80107573:	6a 78                	push   $0x78
  jmp alltraps
80107575:	e9 4f f5 ff ff       	jmp    80106ac9 <alltraps>

8010757a <vector121>:
.globl vector121
vector121:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $121
8010757c:	6a 79                	push   $0x79
  jmp alltraps
8010757e:	e9 46 f5 ff ff       	jmp    80106ac9 <alltraps>

80107583 <vector122>:
.globl vector122
vector122:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $122
80107585:	6a 7a                	push   $0x7a
  jmp alltraps
80107587:	e9 3d f5 ff ff       	jmp    80106ac9 <alltraps>

8010758c <vector123>:
.globl vector123
vector123:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $123
8010758e:	6a 7b                	push   $0x7b
  jmp alltraps
80107590:	e9 34 f5 ff ff       	jmp    80106ac9 <alltraps>

80107595 <vector124>:
.globl vector124
vector124:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $124
80107597:	6a 7c                	push   $0x7c
  jmp alltraps
80107599:	e9 2b f5 ff ff       	jmp    80106ac9 <alltraps>

8010759e <vector125>:
.globl vector125
vector125:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $125
801075a0:	6a 7d                	push   $0x7d
  jmp alltraps
801075a2:	e9 22 f5 ff ff       	jmp    80106ac9 <alltraps>

801075a7 <vector126>:
.globl vector126
vector126:
  pushl $0
801075a7:	6a 00                	push   $0x0
  pushl $126
801075a9:	6a 7e                	push   $0x7e
  jmp alltraps
801075ab:	e9 19 f5 ff ff       	jmp    80106ac9 <alltraps>

801075b0 <vector127>:
.globl vector127
vector127:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $127
801075b2:	6a 7f                	push   $0x7f
  jmp alltraps
801075b4:	e9 10 f5 ff ff       	jmp    80106ac9 <alltraps>

801075b9 <vector128>:
.globl vector128
vector128:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $128
801075bb:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075c0:	e9 04 f5 ff ff       	jmp    80106ac9 <alltraps>

801075c5 <vector129>:
.globl vector129
vector129:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $129
801075c7:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075cc:	e9 f8 f4 ff ff       	jmp    80106ac9 <alltraps>

801075d1 <vector130>:
.globl vector130
vector130:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $130
801075d3:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075d8:	e9 ec f4 ff ff       	jmp    80106ac9 <alltraps>

801075dd <vector131>:
.globl vector131
vector131:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $131
801075df:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075e4:	e9 e0 f4 ff ff       	jmp    80106ac9 <alltraps>

801075e9 <vector132>:
.globl vector132
vector132:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $132
801075eb:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075f0:	e9 d4 f4 ff ff       	jmp    80106ac9 <alltraps>

801075f5 <vector133>:
.globl vector133
vector133:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $133
801075f7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801075fc:	e9 c8 f4 ff ff       	jmp    80106ac9 <alltraps>

80107601 <vector134>:
.globl vector134
vector134:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $134
80107603:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107608:	e9 bc f4 ff ff       	jmp    80106ac9 <alltraps>

8010760d <vector135>:
.globl vector135
vector135:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $135
8010760f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107614:	e9 b0 f4 ff ff       	jmp    80106ac9 <alltraps>

80107619 <vector136>:
.globl vector136
vector136:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $136
8010761b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107620:	e9 a4 f4 ff ff       	jmp    80106ac9 <alltraps>

80107625 <vector137>:
.globl vector137
vector137:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $137
80107627:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010762c:	e9 98 f4 ff ff       	jmp    80106ac9 <alltraps>

80107631 <vector138>:
.globl vector138
vector138:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $138
80107633:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107638:	e9 8c f4 ff ff       	jmp    80106ac9 <alltraps>

8010763d <vector139>:
.globl vector139
vector139:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $139
8010763f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107644:	e9 80 f4 ff ff       	jmp    80106ac9 <alltraps>

80107649 <vector140>:
.globl vector140
vector140:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $140
8010764b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107650:	e9 74 f4 ff ff       	jmp    80106ac9 <alltraps>

80107655 <vector141>:
.globl vector141
vector141:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $141
80107657:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010765c:	e9 68 f4 ff ff       	jmp    80106ac9 <alltraps>

80107661 <vector142>:
.globl vector142
vector142:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $142
80107663:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107668:	e9 5c f4 ff ff       	jmp    80106ac9 <alltraps>

8010766d <vector143>:
.globl vector143
vector143:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $143
8010766f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107674:	e9 50 f4 ff ff       	jmp    80106ac9 <alltraps>

80107679 <vector144>:
.globl vector144
vector144:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $144
8010767b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107680:	e9 44 f4 ff ff       	jmp    80106ac9 <alltraps>

80107685 <vector145>:
.globl vector145
vector145:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $145
80107687:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010768c:	e9 38 f4 ff ff       	jmp    80106ac9 <alltraps>

80107691 <vector146>:
.globl vector146
vector146:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $146
80107693:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107698:	e9 2c f4 ff ff       	jmp    80106ac9 <alltraps>

8010769d <vector147>:
.globl vector147
vector147:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $147
8010769f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076a4:	e9 20 f4 ff ff       	jmp    80106ac9 <alltraps>

801076a9 <vector148>:
.globl vector148
vector148:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $148
801076ab:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076b0:	e9 14 f4 ff ff       	jmp    80106ac9 <alltraps>

801076b5 <vector149>:
.globl vector149
vector149:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $149
801076b7:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076bc:	e9 08 f4 ff ff       	jmp    80106ac9 <alltraps>

801076c1 <vector150>:
.globl vector150
vector150:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $150
801076c3:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076c8:	e9 fc f3 ff ff       	jmp    80106ac9 <alltraps>

801076cd <vector151>:
.globl vector151
vector151:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $151
801076cf:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076d4:	e9 f0 f3 ff ff       	jmp    80106ac9 <alltraps>

801076d9 <vector152>:
.globl vector152
vector152:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $152
801076db:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076e0:	e9 e4 f3 ff ff       	jmp    80106ac9 <alltraps>

801076e5 <vector153>:
.globl vector153
vector153:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $153
801076e7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076ec:	e9 d8 f3 ff ff       	jmp    80106ac9 <alltraps>

801076f1 <vector154>:
.globl vector154
vector154:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $154
801076f3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801076f8:	e9 cc f3 ff ff       	jmp    80106ac9 <alltraps>

801076fd <vector155>:
.globl vector155
vector155:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $155
801076ff:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107704:	e9 c0 f3 ff ff       	jmp    80106ac9 <alltraps>

80107709 <vector156>:
.globl vector156
vector156:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $156
8010770b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107710:	e9 b4 f3 ff ff       	jmp    80106ac9 <alltraps>

80107715 <vector157>:
.globl vector157
vector157:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $157
80107717:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010771c:	e9 a8 f3 ff ff       	jmp    80106ac9 <alltraps>

80107721 <vector158>:
.globl vector158
vector158:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $158
80107723:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107728:	e9 9c f3 ff ff       	jmp    80106ac9 <alltraps>

8010772d <vector159>:
.globl vector159
vector159:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $159
8010772f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107734:	e9 90 f3 ff ff       	jmp    80106ac9 <alltraps>

80107739 <vector160>:
.globl vector160
vector160:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $160
8010773b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107740:	e9 84 f3 ff ff       	jmp    80106ac9 <alltraps>

80107745 <vector161>:
.globl vector161
vector161:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $161
80107747:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010774c:	e9 78 f3 ff ff       	jmp    80106ac9 <alltraps>

80107751 <vector162>:
.globl vector162
vector162:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $162
80107753:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107758:	e9 6c f3 ff ff       	jmp    80106ac9 <alltraps>

8010775d <vector163>:
.globl vector163
vector163:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $163
8010775f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107764:	e9 60 f3 ff ff       	jmp    80106ac9 <alltraps>

80107769 <vector164>:
.globl vector164
vector164:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $164
8010776b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107770:	e9 54 f3 ff ff       	jmp    80106ac9 <alltraps>

80107775 <vector165>:
.globl vector165
vector165:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $165
80107777:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010777c:	e9 48 f3 ff ff       	jmp    80106ac9 <alltraps>

80107781 <vector166>:
.globl vector166
vector166:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $166
80107783:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107788:	e9 3c f3 ff ff       	jmp    80106ac9 <alltraps>

8010778d <vector167>:
.globl vector167
vector167:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $167
8010778f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107794:	e9 30 f3 ff ff       	jmp    80106ac9 <alltraps>

80107799 <vector168>:
.globl vector168
vector168:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $168
8010779b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077a0:	e9 24 f3 ff ff       	jmp    80106ac9 <alltraps>

801077a5 <vector169>:
.globl vector169
vector169:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $169
801077a7:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077ac:	e9 18 f3 ff ff       	jmp    80106ac9 <alltraps>

801077b1 <vector170>:
.globl vector170
vector170:
  pushl $0
801077b1:	6a 00                	push   $0x0
  pushl $170
801077b3:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077b8:	e9 0c f3 ff ff       	jmp    80106ac9 <alltraps>

801077bd <vector171>:
.globl vector171
vector171:
  pushl $0
801077bd:	6a 00                	push   $0x0
  pushl $171
801077bf:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077c4:	e9 00 f3 ff ff       	jmp    80106ac9 <alltraps>

801077c9 <vector172>:
.globl vector172
vector172:
  pushl $0
801077c9:	6a 00                	push   $0x0
  pushl $172
801077cb:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077d0:	e9 f4 f2 ff ff       	jmp    80106ac9 <alltraps>

801077d5 <vector173>:
.globl vector173
vector173:
  pushl $0
801077d5:	6a 00                	push   $0x0
  pushl $173
801077d7:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077dc:	e9 e8 f2 ff ff       	jmp    80106ac9 <alltraps>

801077e1 <vector174>:
.globl vector174
vector174:
  pushl $0
801077e1:	6a 00                	push   $0x0
  pushl $174
801077e3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801077e8:	e9 dc f2 ff ff       	jmp    80106ac9 <alltraps>

801077ed <vector175>:
.globl vector175
vector175:
  pushl $0
801077ed:	6a 00                	push   $0x0
  pushl $175
801077ef:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801077f4:	e9 d0 f2 ff ff       	jmp    80106ac9 <alltraps>

801077f9 <vector176>:
.globl vector176
vector176:
  pushl $0
801077f9:	6a 00                	push   $0x0
  pushl $176
801077fb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107800:	e9 c4 f2 ff ff       	jmp    80106ac9 <alltraps>

80107805 <vector177>:
.globl vector177
vector177:
  pushl $0
80107805:	6a 00                	push   $0x0
  pushl $177
80107807:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010780c:	e9 b8 f2 ff ff       	jmp    80106ac9 <alltraps>

80107811 <vector178>:
.globl vector178
vector178:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $178
80107813:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107818:	e9 ac f2 ff ff       	jmp    80106ac9 <alltraps>

8010781d <vector179>:
.globl vector179
vector179:
  pushl $0
8010781d:	6a 00                	push   $0x0
  pushl $179
8010781f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107824:	e9 a0 f2 ff ff       	jmp    80106ac9 <alltraps>

80107829 <vector180>:
.globl vector180
vector180:
  pushl $0
80107829:	6a 00                	push   $0x0
  pushl $180
8010782b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107830:	e9 94 f2 ff ff       	jmp    80106ac9 <alltraps>

80107835 <vector181>:
.globl vector181
vector181:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $181
80107837:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010783c:	e9 88 f2 ff ff       	jmp    80106ac9 <alltraps>

80107841 <vector182>:
.globl vector182
vector182:
  pushl $0
80107841:	6a 00                	push   $0x0
  pushl $182
80107843:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107848:	e9 7c f2 ff ff       	jmp    80106ac9 <alltraps>

8010784d <vector183>:
.globl vector183
vector183:
  pushl $0
8010784d:	6a 00                	push   $0x0
  pushl $183
8010784f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107854:	e9 70 f2 ff ff       	jmp    80106ac9 <alltraps>

80107859 <vector184>:
.globl vector184
vector184:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $184
8010785b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107860:	e9 64 f2 ff ff       	jmp    80106ac9 <alltraps>

80107865 <vector185>:
.globl vector185
vector185:
  pushl $0
80107865:	6a 00                	push   $0x0
  pushl $185
80107867:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010786c:	e9 58 f2 ff ff       	jmp    80106ac9 <alltraps>

80107871 <vector186>:
.globl vector186
vector186:
  pushl $0
80107871:	6a 00                	push   $0x0
  pushl $186
80107873:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107878:	e9 4c f2 ff ff       	jmp    80106ac9 <alltraps>

8010787d <vector187>:
.globl vector187
vector187:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $187
8010787f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107884:	e9 40 f2 ff ff       	jmp    80106ac9 <alltraps>

80107889 <vector188>:
.globl vector188
vector188:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $188
8010788b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107890:	e9 34 f2 ff ff       	jmp    80106ac9 <alltraps>

80107895 <vector189>:
.globl vector189
vector189:
  pushl $0
80107895:	6a 00                	push   $0x0
  pushl $189
80107897:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010789c:	e9 28 f2 ff ff       	jmp    80106ac9 <alltraps>

801078a1 <vector190>:
.globl vector190
vector190:
  pushl $0
801078a1:	6a 00                	push   $0x0
  pushl $190
801078a3:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078a8:	e9 1c f2 ff ff       	jmp    80106ac9 <alltraps>

801078ad <vector191>:
.globl vector191
vector191:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $191
801078af:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078b4:	e9 10 f2 ff ff       	jmp    80106ac9 <alltraps>

801078b9 <vector192>:
.globl vector192
vector192:
  pushl $0
801078b9:	6a 00                	push   $0x0
  pushl $192
801078bb:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078c0:	e9 04 f2 ff ff       	jmp    80106ac9 <alltraps>

801078c5 <vector193>:
.globl vector193
vector193:
  pushl $0
801078c5:	6a 00                	push   $0x0
  pushl $193
801078c7:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078cc:	e9 f8 f1 ff ff       	jmp    80106ac9 <alltraps>

801078d1 <vector194>:
.globl vector194
vector194:
  pushl $0
801078d1:	6a 00                	push   $0x0
  pushl $194
801078d3:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078d8:	e9 ec f1 ff ff       	jmp    80106ac9 <alltraps>

801078dd <vector195>:
.globl vector195
vector195:
  pushl $0
801078dd:	6a 00                	push   $0x0
  pushl $195
801078df:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078e4:	e9 e0 f1 ff ff       	jmp    80106ac9 <alltraps>

801078e9 <vector196>:
.globl vector196
vector196:
  pushl $0
801078e9:	6a 00                	push   $0x0
  pushl $196
801078eb:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078f0:	e9 d4 f1 ff ff       	jmp    80106ac9 <alltraps>

801078f5 <vector197>:
.globl vector197
vector197:
  pushl $0
801078f5:	6a 00                	push   $0x0
  pushl $197
801078f7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801078fc:	e9 c8 f1 ff ff       	jmp    80106ac9 <alltraps>

80107901 <vector198>:
.globl vector198
vector198:
  pushl $0
80107901:	6a 00                	push   $0x0
  pushl $198
80107903:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107908:	e9 bc f1 ff ff       	jmp    80106ac9 <alltraps>

8010790d <vector199>:
.globl vector199
vector199:
  pushl $0
8010790d:	6a 00                	push   $0x0
  pushl $199
8010790f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107914:	e9 b0 f1 ff ff       	jmp    80106ac9 <alltraps>

80107919 <vector200>:
.globl vector200
vector200:
  pushl $0
80107919:	6a 00                	push   $0x0
  pushl $200
8010791b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107920:	e9 a4 f1 ff ff       	jmp    80106ac9 <alltraps>

80107925 <vector201>:
.globl vector201
vector201:
  pushl $0
80107925:	6a 00                	push   $0x0
  pushl $201
80107927:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010792c:	e9 98 f1 ff ff       	jmp    80106ac9 <alltraps>

80107931 <vector202>:
.globl vector202
vector202:
  pushl $0
80107931:	6a 00                	push   $0x0
  pushl $202
80107933:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107938:	e9 8c f1 ff ff       	jmp    80106ac9 <alltraps>

8010793d <vector203>:
.globl vector203
vector203:
  pushl $0
8010793d:	6a 00                	push   $0x0
  pushl $203
8010793f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107944:	e9 80 f1 ff ff       	jmp    80106ac9 <alltraps>

80107949 <vector204>:
.globl vector204
vector204:
  pushl $0
80107949:	6a 00                	push   $0x0
  pushl $204
8010794b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107950:	e9 74 f1 ff ff       	jmp    80106ac9 <alltraps>

80107955 <vector205>:
.globl vector205
vector205:
  pushl $0
80107955:	6a 00                	push   $0x0
  pushl $205
80107957:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010795c:	e9 68 f1 ff ff       	jmp    80106ac9 <alltraps>

80107961 <vector206>:
.globl vector206
vector206:
  pushl $0
80107961:	6a 00                	push   $0x0
  pushl $206
80107963:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107968:	e9 5c f1 ff ff       	jmp    80106ac9 <alltraps>

8010796d <vector207>:
.globl vector207
vector207:
  pushl $0
8010796d:	6a 00                	push   $0x0
  pushl $207
8010796f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107974:	e9 50 f1 ff ff       	jmp    80106ac9 <alltraps>

80107979 <vector208>:
.globl vector208
vector208:
  pushl $0
80107979:	6a 00                	push   $0x0
  pushl $208
8010797b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107980:	e9 44 f1 ff ff       	jmp    80106ac9 <alltraps>

80107985 <vector209>:
.globl vector209
vector209:
  pushl $0
80107985:	6a 00                	push   $0x0
  pushl $209
80107987:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010798c:	e9 38 f1 ff ff       	jmp    80106ac9 <alltraps>

80107991 <vector210>:
.globl vector210
vector210:
  pushl $0
80107991:	6a 00                	push   $0x0
  pushl $210
80107993:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107998:	e9 2c f1 ff ff       	jmp    80106ac9 <alltraps>

8010799d <vector211>:
.globl vector211
vector211:
  pushl $0
8010799d:	6a 00                	push   $0x0
  pushl $211
8010799f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079a4:	e9 20 f1 ff ff       	jmp    80106ac9 <alltraps>

801079a9 <vector212>:
.globl vector212
vector212:
  pushl $0
801079a9:	6a 00                	push   $0x0
  pushl $212
801079ab:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079b0:	e9 14 f1 ff ff       	jmp    80106ac9 <alltraps>

801079b5 <vector213>:
.globl vector213
vector213:
  pushl $0
801079b5:	6a 00                	push   $0x0
  pushl $213
801079b7:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079bc:	e9 08 f1 ff ff       	jmp    80106ac9 <alltraps>

801079c1 <vector214>:
.globl vector214
vector214:
  pushl $0
801079c1:	6a 00                	push   $0x0
  pushl $214
801079c3:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079c8:	e9 fc f0 ff ff       	jmp    80106ac9 <alltraps>

801079cd <vector215>:
.globl vector215
vector215:
  pushl $0
801079cd:	6a 00                	push   $0x0
  pushl $215
801079cf:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079d4:	e9 f0 f0 ff ff       	jmp    80106ac9 <alltraps>

801079d9 <vector216>:
.globl vector216
vector216:
  pushl $0
801079d9:	6a 00                	push   $0x0
  pushl $216
801079db:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079e0:	e9 e4 f0 ff ff       	jmp    80106ac9 <alltraps>

801079e5 <vector217>:
.globl vector217
vector217:
  pushl $0
801079e5:	6a 00                	push   $0x0
  pushl $217
801079e7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079ec:	e9 d8 f0 ff ff       	jmp    80106ac9 <alltraps>

801079f1 <vector218>:
.globl vector218
vector218:
  pushl $0
801079f1:	6a 00                	push   $0x0
  pushl $218
801079f3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801079f8:	e9 cc f0 ff ff       	jmp    80106ac9 <alltraps>

801079fd <vector219>:
.globl vector219
vector219:
  pushl $0
801079fd:	6a 00                	push   $0x0
  pushl $219
801079ff:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a04:	e9 c0 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a09 <vector220>:
.globl vector220
vector220:
  pushl $0
80107a09:	6a 00                	push   $0x0
  pushl $220
80107a0b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a10:	e9 b4 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a15 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a15:	6a 00                	push   $0x0
  pushl $221
80107a17:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a1c:	e9 a8 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a21 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a21:	6a 00                	push   $0x0
  pushl $222
80107a23:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a28:	e9 9c f0 ff ff       	jmp    80106ac9 <alltraps>

80107a2d <vector223>:
.globl vector223
vector223:
  pushl $0
80107a2d:	6a 00                	push   $0x0
  pushl $223
80107a2f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a34:	e9 90 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a39 <vector224>:
.globl vector224
vector224:
  pushl $0
80107a39:	6a 00                	push   $0x0
  pushl $224
80107a3b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a40:	e9 84 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a45 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a45:	6a 00                	push   $0x0
  pushl $225
80107a47:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a4c:	e9 78 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a51 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a51:	6a 00                	push   $0x0
  pushl $226
80107a53:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a58:	e9 6c f0 ff ff       	jmp    80106ac9 <alltraps>

80107a5d <vector227>:
.globl vector227
vector227:
  pushl $0
80107a5d:	6a 00                	push   $0x0
  pushl $227
80107a5f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a64:	e9 60 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a69 <vector228>:
.globl vector228
vector228:
  pushl $0
80107a69:	6a 00                	push   $0x0
  pushl $228
80107a6b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a70:	e9 54 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a75 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a75:	6a 00                	push   $0x0
  pushl $229
80107a77:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a7c:	e9 48 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a81 <vector230>:
.globl vector230
vector230:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $230
80107a83:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a88:	e9 3c f0 ff ff       	jmp    80106ac9 <alltraps>

80107a8d <vector231>:
.globl vector231
vector231:
  pushl $0
80107a8d:	6a 00                	push   $0x0
  pushl $231
80107a8f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a94:	e9 30 f0 ff ff       	jmp    80106ac9 <alltraps>

80107a99 <vector232>:
.globl vector232
vector232:
  pushl $0
80107a99:	6a 00                	push   $0x0
  pushl $232
80107a9b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107aa0:	e9 24 f0 ff ff       	jmp    80106ac9 <alltraps>

80107aa5 <vector233>:
.globl vector233
vector233:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $233
80107aa7:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107aac:	e9 18 f0 ff ff       	jmp    80106ac9 <alltraps>

80107ab1 <vector234>:
.globl vector234
vector234:
  pushl $0
80107ab1:	6a 00                	push   $0x0
  pushl $234
80107ab3:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ab8:	e9 0c f0 ff ff       	jmp    80106ac9 <alltraps>

80107abd <vector235>:
.globl vector235
vector235:
  pushl $0
80107abd:	6a 00                	push   $0x0
  pushl $235
80107abf:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107ac4:	e9 00 f0 ff ff       	jmp    80106ac9 <alltraps>

80107ac9 <vector236>:
.globl vector236
vector236:
  pushl $0
80107ac9:	6a 00                	push   $0x0
  pushl $236
80107acb:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107ad0:	e9 f4 ef ff ff       	jmp    80106ac9 <alltraps>

80107ad5 <vector237>:
.globl vector237
vector237:
  pushl $0
80107ad5:	6a 00                	push   $0x0
  pushl $237
80107ad7:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107adc:	e9 e8 ef ff ff       	jmp    80106ac9 <alltraps>

80107ae1 <vector238>:
.globl vector238
vector238:
  pushl $0
80107ae1:	6a 00                	push   $0x0
  pushl $238
80107ae3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107ae8:	e9 dc ef ff ff       	jmp    80106ac9 <alltraps>

80107aed <vector239>:
.globl vector239
vector239:
  pushl $0
80107aed:	6a 00                	push   $0x0
  pushl $239
80107aef:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107af4:	e9 d0 ef ff ff       	jmp    80106ac9 <alltraps>

80107af9 <vector240>:
.globl vector240
vector240:
  pushl $0
80107af9:	6a 00                	push   $0x0
  pushl $240
80107afb:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b00:	e9 c4 ef ff ff       	jmp    80106ac9 <alltraps>

80107b05 <vector241>:
.globl vector241
vector241:
  pushl $0
80107b05:	6a 00                	push   $0x0
  pushl $241
80107b07:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b0c:	e9 b8 ef ff ff       	jmp    80106ac9 <alltraps>

80107b11 <vector242>:
.globl vector242
vector242:
  pushl $0
80107b11:	6a 00                	push   $0x0
  pushl $242
80107b13:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b18:	e9 ac ef ff ff       	jmp    80106ac9 <alltraps>

80107b1d <vector243>:
.globl vector243
vector243:
  pushl $0
80107b1d:	6a 00                	push   $0x0
  pushl $243
80107b1f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b24:	e9 a0 ef ff ff       	jmp    80106ac9 <alltraps>

80107b29 <vector244>:
.globl vector244
vector244:
  pushl $0
80107b29:	6a 00                	push   $0x0
  pushl $244
80107b2b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b30:	e9 94 ef ff ff       	jmp    80106ac9 <alltraps>

80107b35 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b35:	6a 00                	push   $0x0
  pushl $245
80107b37:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b3c:	e9 88 ef ff ff       	jmp    80106ac9 <alltraps>

80107b41 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b41:	6a 00                	push   $0x0
  pushl $246
80107b43:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b48:	e9 7c ef ff ff       	jmp    80106ac9 <alltraps>

80107b4d <vector247>:
.globl vector247
vector247:
  pushl $0
80107b4d:	6a 00                	push   $0x0
  pushl $247
80107b4f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b54:	e9 70 ef ff ff       	jmp    80106ac9 <alltraps>

80107b59 <vector248>:
.globl vector248
vector248:
  pushl $0
80107b59:	6a 00                	push   $0x0
  pushl $248
80107b5b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b60:	e9 64 ef ff ff       	jmp    80106ac9 <alltraps>

80107b65 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b65:	6a 00                	push   $0x0
  pushl $249
80107b67:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b6c:	e9 58 ef ff ff       	jmp    80106ac9 <alltraps>

80107b71 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $250
80107b73:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b78:	e9 4c ef ff ff       	jmp    80106ac9 <alltraps>

80107b7d <vector251>:
.globl vector251
vector251:
  pushl $0
80107b7d:	6a 00                	push   $0x0
  pushl $251
80107b7f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b84:	e9 40 ef ff ff       	jmp    80106ac9 <alltraps>

80107b89 <vector252>:
.globl vector252
vector252:
  pushl $0
80107b89:	6a 00                	push   $0x0
  pushl $252
80107b8b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b90:	e9 34 ef ff ff       	jmp    80106ac9 <alltraps>

80107b95 <vector253>:
.globl vector253
vector253:
  pushl $0
80107b95:	6a 00                	push   $0x0
  pushl $253
80107b97:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b9c:	e9 28 ef ff ff       	jmp    80106ac9 <alltraps>

80107ba1 <vector254>:
.globl vector254
vector254:
  pushl $0
80107ba1:	6a 00                	push   $0x0
  pushl $254
80107ba3:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107ba8:	e9 1c ef ff ff       	jmp    80106ac9 <alltraps>

80107bad <vector255>:
.globl vector255
vector255:
  pushl $0
80107bad:	6a 00                	push   $0x0
  pushl $255
80107baf:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bb4:	e9 10 ef ff ff       	jmp    80106ac9 <alltraps>

80107bb9 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107bb9:	55                   	push   %ebp
80107bba:	89 e5                	mov    %esp,%ebp
80107bbc:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bc2:	83 e8 01             	sub    $0x1,%eax
80107bc5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80107bcc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80107bd3:	c1 e8 10             	shr    $0x10,%eax
80107bd6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107bda:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bdd:	0f 01 10             	lgdtl  (%eax)
}
80107be0:	c9                   	leave  
80107be1:	c3                   	ret    

80107be2 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107be2:	55                   	push   %ebp
80107be3:	89 e5                	mov    %esp,%ebp
80107be5:	83 ec 04             	sub    $0x4,%esp
80107be8:	8b 45 08             	mov    0x8(%ebp),%eax
80107beb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107bef:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107bf3:	0f 00 d8             	ltr    %ax
}
80107bf6:	c9                   	leave  
80107bf7:	c3                   	ret    

80107bf8 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107bf8:	55                   	push   %ebp
80107bf9:	89 e5                	mov    %esp,%ebp
80107bfb:	83 ec 04             	sub    $0x4,%esp
80107bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80107c01:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107c05:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c09:	8e e8                	mov    %eax,%gs
}
80107c0b:	c9                   	leave  
80107c0c:	c3                   	ret    

80107c0d <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107c0d:	55                   	push   %ebp
80107c0e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c10:	8b 45 08             	mov    0x8(%ebp),%eax
80107c13:	0f 22 d8             	mov    %eax,%cr3
}
80107c16:	5d                   	pop    %ebp
80107c17:	c3                   	ret    

80107c18 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107c18:	55                   	push   %ebp
80107c19:	89 e5                	mov    %esp,%ebp
80107c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c1e:	05 00 00 00 80       	add    $0x80000000,%eax
80107c23:	5d                   	pop    %ebp
80107c24:	c3                   	ret    

80107c25 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107c25:	55                   	push   %ebp
80107c26:	89 e5                	mov    %esp,%ebp
80107c28:	8b 45 08             	mov    0x8(%ebp),%eax
80107c2b:	05 00 00 00 80       	add    $0x80000000,%eax
80107c30:	5d                   	pop    %ebp
80107c31:	c3                   	ret    

80107c32 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c32:	55                   	push   %ebp
80107c33:	89 e5                	mov    %esp,%ebp
80107c35:	53                   	push   %ebx
80107c36:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107c39:	e8 47 b2 ff ff       	call   80102e85 <cpunum>
80107c3e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107c44:	05 80 33 11 80       	add    $0x80113380,%eax
80107c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c58:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c61:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c68:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c6c:	83 e2 f0             	and    $0xfffffff0,%edx
80107c6f:	83 ca 0a             	or     $0xa,%edx
80107c72:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c78:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c7c:	83 ca 10             	or     $0x10,%edx
80107c7f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c85:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c89:	83 e2 9f             	and    $0xffffff9f,%edx
80107c8c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c92:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c96:	83 ca 80             	or     $0xffffff80,%edx
80107c99:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ca3:	83 ca 0f             	or     $0xf,%edx
80107ca6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cac:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cb0:	83 e2 ef             	and    $0xffffffef,%edx
80107cb3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cbd:	83 e2 df             	and    $0xffffffdf,%edx
80107cc0:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cca:	83 ca 40             	or     $0x40,%edx
80107ccd:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cd7:	83 ca 80             	or     $0xffffff80,%edx
80107cda:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce0:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce7:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107cee:	ff ff 
80107cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf3:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107cfa:	00 00 
80107cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cff:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d10:	83 e2 f0             	and    $0xfffffff0,%edx
80107d13:	83 ca 02             	or     $0x2,%edx
80107d16:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d26:	83 ca 10             	or     $0x10,%edx
80107d29:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d32:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d39:	83 e2 9f             	and    $0xffffff9f,%edx
80107d3c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d45:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d4c:	83 ca 80             	or     $0xffffff80,%edx
80107d4f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d58:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d5f:	83 ca 0f             	or     $0xf,%edx
80107d62:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d72:	83 e2 ef             	and    $0xffffffef,%edx
80107d75:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d85:	83 e2 df             	and    $0xffffffdf,%edx
80107d88:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d91:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d98:	83 ca 40             	or     $0x40,%edx
80107d9b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dab:	83 ca 80             	or     $0xffffff80,%edx
80107dae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc1:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107dc8:	ff ff 
80107dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcd:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107dd4:	00 00 
80107dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd9:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107dea:	83 e2 f0             	and    $0xfffffff0,%edx
80107ded:	83 ca 0a             	or     $0xa,%edx
80107df0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e00:	83 ca 10             	or     $0x10,%edx
80107e03:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e13:	83 ca 60             	or     $0x60,%edx
80107e16:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e26:	83 ca 80             	or     $0xffffff80,%edx
80107e29:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e32:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e39:	83 ca 0f             	or     $0xf,%edx
80107e3c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e45:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e4c:	83 e2 ef             	and    $0xffffffef,%edx
80107e4f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e5f:	83 e2 df             	and    $0xffffffdf,%edx
80107e62:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e72:	83 ca 40             	or     $0x40,%edx
80107e75:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e85:	83 ca 80             	or     $0xffffff80,%edx
80107e88:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e91:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9b:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107ea2:	ff ff 
80107ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea7:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107eae:	00 00 
80107eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb3:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebd:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ec4:	83 e2 f0             	and    $0xfffffff0,%edx
80107ec7:	83 ca 02             	or     $0x2,%edx
80107eca:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107eda:	83 ca 10             	or     $0x10,%edx
80107edd:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107eed:	83 ca 60             	or     $0x60,%edx
80107ef0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f00:	83 ca 80             	or     $0xffffff80,%edx
80107f03:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f13:	83 ca 0f             	or     $0xf,%edx
80107f16:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f26:	83 e2 ef             	and    $0xffffffef,%edx
80107f29:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f32:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f39:	83 e2 df             	and    $0xffffffdf,%edx
80107f3c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f45:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f4c:	83 ca 40             	or     $0x40,%edx
80107f4f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f5f:	83 ca 80             	or     $0xffffff80,%edx
80107f62:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6b:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f75:	05 b4 00 00 00       	add    $0xb4,%eax
80107f7a:	89 c3                	mov    %eax,%ebx
80107f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7f:	05 b4 00 00 00       	add    $0xb4,%eax
80107f84:	c1 e8 10             	shr    $0x10,%eax
80107f87:	89 c1                	mov    %eax,%ecx
80107f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8c:	05 b4 00 00 00       	add    $0xb4,%eax
80107f91:	c1 e8 18             	shr    $0x18,%eax
80107f94:	89 c2                	mov    %eax,%edx
80107f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f99:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107fa0:	00 00 
80107fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa5:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faf:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb8:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107fbf:	83 e1 f0             	and    $0xfffffff0,%ecx
80107fc2:	83 c9 02             	or     $0x2,%ecx
80107fc5:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fce:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107fd5:	83 c9 10             	or     $0x10,%ecx
80107fd8:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe1:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107fe8:	83 e1 9f             	and    $0xffffff9f,%ecx
80107feb:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff4:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ffb:	83 c9 80             	or     $0xffffff80,%ecx
80107ffe:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108004:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108007:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010800e:	83 e1 f0             	and    $0xfffffff0,%ecx
80108011:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108021:	83 e1 ef             	and    $0xffffffef,%ecx
80108024:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010802a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802d:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108034:	83 e1 df             	and    $0xffffffdf,%ecx
80108037:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010803d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108040:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108047:	83 c9 40             	or     $0x40,%ecx
8010804a:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108053:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010805a:	83 c9 80             	or     $0xffffff80,%ecx
8010805d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108066:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010806c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806f:	83 c0 70             	add    $0x70,%eax
80108072:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108079:	00 
8010807a:	89 04 24             	mov    %eax,(%esp)
8010807d:	e8 37 fb ff ff       	call   80107bb9 <lgdt>
  loadgs(SEG_KCPU << 3);
80108082:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108089:	e8 6a fb ff ff       	call   80107bf8 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
8010808e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108091:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108097:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010809e:	00 00 00 00 
}
801080a2:	83 c4 24             	add    $0x24,%esp
801080a5:	5b                   	pop    %ebx
801080a6:	5d                   	pop    %ebp
801080a7:	c3                   	ret    

801080a8 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801080a8:	55                   	push   %ebp
801080a9:	89 e5                	mov    %esp,%ebp
801080ab:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801080ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b1:	c1 e8 16             	shr    $0x16,%eax
801080b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080bb:	8b 45 08             	mov    0x8(%ebp),%eax
801080be:	01 d0                	add    %edx,%eax
801080c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801080c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c6:	8b 00                	mov    (%eax),%eax
801080c8:	83 e0 01             	and    $0x1,%eax
801080cb:	85 c0                	test   %eax,%eax
801080cd:	74 17                	je     801080e6 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801080cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d2:	8b 00                	mov    (%eax),%eax
801080d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080d9:	89 04 24             	mov    %eax,(%esp)
801080dc:	e8 44 fb ff ff       	call   80107c25 <p2v>
801080e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080e4:	eb 4b                	jmp    80108131 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801080e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801080ea:	74 0e                	je     801080fa <walkpgdir+0x52>
801080ec:	e8 fe a9 ff ff       	call   80102aef <kalloc>
801080f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801080f8:	75 07                	jne    80108101 <walkpgdir+0x59>
      return 0;
801080fa:	b8 00 00 00 00       	mov    $0x0,%eax
801080ff:	eb 47                	jmp    80108148 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108101:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108108:	00 
80108109:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108110:	00 
80108111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108114:	89 04 24             	mov    %eax,(%esp)
80108117:	e8 17 d5 ff ff       	call   80105633 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010811c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811f:	89 04 24             	mov    %eax,(%esp)
80108122:	e8 f1 fa ff ff       	call   80107c18 <v2p>
80108127:	83 c8 07             	or     $0x7,%eax
8010812a:	89 c2                	mov    %eax,%edx
8010812c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010812f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108131:	8b 45 0c             	mov    0xc(%ebp),%eax
80108134:	c1 e8 0c             	shr    $0xc,%eax
80108137:	25 ff 03 00 00       	and    $0x3ff,%eax
8010813c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108146:	01 d0                	add    %edx,%eax
}
80108148:	c9                   	leave  
80108149:	c3                   	ret    

8010814a <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010814a:	55                   	push   %ebp
8010814b:	89 e5                	mov    %esp,%ebp
8010814d:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108150:	8b 45 0c             	mov    0xc(%ebp),%eax
80108153:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010815b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010815e:	8b 45 10             	mov    0x10(%ebp),%eax
80108161:	01 d0                	add    %edx,%eax
80108163:	83 e8 01             	sub    $0x1,%eax
80108166:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010816b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010816e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108175:	00 
80108176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108179:	89 44 24 04          	mov    %eax,0x4(%esp)
8010817d:	8b 45 08             	mov    0x8(%ebp),%eax
80108180:	89 04 24             	mov    %eax,(%esp)
80108183:	e8 20 ff ff ff       	call   801080a8 <walkpgdir>
80108188:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010818b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010818f:	75 07                	jne    80108198 <mappages+0x4e>
      return -1;
80108191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108196:	eb 48                	jmp    801081e0 <mappages+0x96>
    if(*pte & PTE_P)
80108198:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010819b:	8b 00                	mov    (%eax),%eax
8010819d:	83 e0 01             	and    $0x1,%eax
801081a0:	85 c0                	test   %eax,%eax
801081a2:	74 0c                	je     801081b0 <mappages+0x66>
      panic("remap");
801081a4:	c7 04 24 a0 90 10 80 	movl   $0x801090a0,(%esp)
801081ab:	e8 8a 83 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
801081b0:	8b 45 18             	mov    0x18(%ebp),%eax
801081b3:	0b 45 14             	or     0x14(%ebp),%eax
801081b6:	83 c8 01             	or     $0x1,%eax
801081b9:	89 c2                	mov    %eax,%edx
801081bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081be:	89 10                	mov    %edx,(%eax)
    if(a == last)
801081c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801081c6:	75 08                	jne    801081d0 <mappages+0x86>
      break;
801081c8:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801081c9:	b8 00 00 00 00       	mov    $0x0,%eax
801081ce:	eb 10                	jmp    801081e0 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801081d0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801081d7:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801081de:	eb 8e                	jmp    8010816e <mappages+0x24>
  return 0;
}
801081e0:	c9                   	leave  
801081e1:	c3                   	ret    

801081e2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801081e2:	55                   	push   %ebp
801081e3:	89 e5                	mov    %esp,%ebp
801081e5:	53                   	push   %ebx
801081e6:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801081e9:	e8 01 a9 ff ff       	call   80102aef <kalloc>
801081ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081f5:	75 0a                	jne    80108201 <setupkvm+0x1f>
    return 0;
801081f7:	b8 00 00 00 00       	mov    $0x0,%eax
801081fc:	e9 98 00 00 00       	jmp    80108299 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108201:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108208:	00 
80108209:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108210:	00 
80108211:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108214:	89 04 24             	mov    %eax,(%esp)
80108217:	e8 17 d4 ff ff       	call   80105633 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010821c:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108223:	e8 fd f9 ff ff       	call   80107c25 <p2v>
80108228:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010822d:	76 0c                	jbe    8010823b <setupkvm+0x59>
    panic("PHYSTOP too high");
8010822f:	c7 04 24 a6 90 10 80 	movl   $0x801090a6,(%esp)
80108236:	e8 ff 82 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010823b:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108242:	eb 49                	jmp    8010828d <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108247:	8b 48 0c             	mov    0xc(%eax),%ecx
8010824a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824d:	8b 50 04             	mov    0x4(%eax),%edx
80108250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108253:	8b 58 08             	mov    0x8(%eax),%ebx
80108256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108259:	8b 40 04             	mov    0x4(%eax),%eax
8010825c:	29 c3                	sub    %eax,%ebx
8010825e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108261:	8b 00                	mov    (%eax),%eax
80108263:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108267:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010826b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010826f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108273:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108276:	89 04 24             	mov    %eax,(%esp)
80108279:	e8 cc fe ff ff       	call   8010814a <mappages>
8010827e:	85 c0                	test   %eax,%eax
80108280:	79 07                	jns    80108289 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108282:	b8 00 00 00 00       	mov    $0x0,%eax
80108287:	eb 10                	jmp    80108299 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108289:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010828d:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108294:	72 ae                	jb     80108244 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108296:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108299:	83 c4 34             	add    $0x34,%esp
8010829c:	5b                   	pop    %ebx
8010829d:	5d                   	pop    %ebp
8010829e:	c3                   	ret    

8010829f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010829f:	55                   	push   %ebp
801082a0:	89 e5                	mov    %esp,%ebp
801082a2:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801082a5:	e8 38 ff ff ff       	call   801081e2 <setupkvm>
801082aa:	a3 58 a9 11 80       	mov    %eax,0x8011a958
  switchkvm();
801082af:	e8 02 00 00 00       	call   801082b6 <switchkvm>
}
801082b4:	c9                   	leave  
801082b5:	c3                   	ret    

801082b6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801082b6:	55                   	push   %ebp
801082b7:	89 e5                	mov    %esp,%ebp
801082b9:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801082bc:	a1 58 a9 11 80       	mov    0x8011a958,%eax
801082c1:	89 04 24             	mov    %eax,(%esp)
801082c4:	e8 4f f9 ff ff       	call   80107c18 <v2p>
801082c9:	89 04 24             	mov    %eax,(%esp)
801082cc:	e8 3c f9 ff ff       	call   80107c0d <lcr3>
}
801082d1:	c9                   	leave  
801082d2:	c3                   	ret    

801082d3 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801082d3:	55                   	push   %ebp
801082d4:	89 e5                	mov    %esp,%ebp
801082d6:	53                   	push   %ebx
801082d7:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801082da:	e8 54 d2 ff ff       	call   80105533 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801082df:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082e5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801082ec:	83 c2 08             	add    $0x8,%edx
801082ef:	89 d3                	mov    %edx,%ebx
801082f1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801082f8:	83 c2 08             	add    $0x8,%edx
801082fb:	c1 ea 10             	shr    $0x10,%edx
801082fe:	89 d1                	mov    %edx,%ecx
80108300:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108307:	83 c2 08             	add    $0x8,%edx
8010830a:	c1 ea 18             	shr    $0x18,%edx
8010830d:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108314:	67 00 
80108316:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
8010831d:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108323:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010832a:	83 e1 f0             	and    $0xfffffff0,%ecx
8010832d:	83 c9 09             	or     $0x9,%ecx
80108330:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108336:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010833d:	83 c9 10             	or     $0x10,%ecx
80108340:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108346:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010834d:	83 e1 9f             	and    $0xffffff9f,%ecx
80108350:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108356:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010835d:	83 c9 80             	or     $0xffffff80,%ecx
80108360:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108366:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010836d:	83 e1 f0             	and    $0xfffffff0,%ecx
80108370:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108376:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010837d:	83 e1 ef             	and    $0xffffffef,%ecx
80108380:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108386:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010838d:	83 e1 df             	and    $0xffffffdf,%ecx
80108390:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108396:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010839d:	83 c9 40             	or     $0x40,%ecx
801083a0:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083a6:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801083ad:	83 e1 7f             	and    $0x7f,%ecx
801083b0:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083b6:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801083bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083c2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801083c9:	83 e2 ef             	and    $0xffffffef,%edx
801083cc:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801083d2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083d8:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801083de:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801083eb:	8b 52 08             	mov    0x8(%edx),%edx
801083ee:	81 c2 00 10 00 00    	add    $0x1000,%edx
801083f4:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801083f7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801083fe:	e8 df f7 ff ff       	call   80107be2 <ltr>
  if(p->pgdir == 0)
80108403:	8b 45 08             	mov    0x8(%ebp),%eax
80108406:	8b 40 04             	mov    0x4(%eax),%eax
80108409:	85 c0                	test   %eax,%eax
8010840b:	75 0c                	jne    80108419 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
8010840d:	c7 04 24 b7 90 10 80 	movl   $0x801090b7,(%esp)
80108414:	e8 21 81 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108419:	8b 45 08             	mov    0x8(%ebp),%eax
8010841c:	8b 40 04             	mov    0x4(%eax),%eax
8010841f:	89 04 24             	mov    %eax,(%esp)
80108422:	e8 f1 f7 ff ff       	call   80107c18 <v2p>
80108427:	89 04 24             	mov    %eax,(%esp)
8010842a:	e8 de f7 ff ff       	call   80107c0d <lcr3>
  popcli();
8010842f:	e8 43 d1 ff ff       	call   80105577 <popcli>
}
80108434:	83 c4 14             	add    $0x14,%esp
80108437:	5b                   	pop    %ebx
80108438:	5d                   	pop    %ebp
80108439:	c3                   	ret    

8010843a <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010843a:	55                   	push   %ebp
8010843b:	89 e5                	mov    %esp,%ebp
8010843d:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108440:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108447:	76 0c                	jbe    80108455 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108449:	c7 04 24 cb 90 10 80 	movl   $0x801090cb,(%esp)
80108450:	e8 e5 80 ff ff       	call   8010053a <panic>
  mem = kalloc();
80108455:	e8 95 a6 ff ff       	call   80102aef <kalloc>
8010845a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010845d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108464:	00 
80108465:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010846c:	00 
8010846d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108470:	89 04 24             	mov    %eax,(%esp)
80108473:	e8 bb d1 ff ff       	call   80105633 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847b:	89 04 24             	mov    %eax,(%esp)
8010847e:	e8 95 f7 ff ff       	call   80107c18 <v2p>
80108483:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010848a:	00 
8010848b:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010848f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108496:	00 
80108497:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010849e:	00 
8010849f:	8b 45 08             	mov    0x8(%ebp),%eax
801084a2:	89 04 24             	mov    %eax,(%esp)
801084a5:	e8 a0 fc ff ff       	call   8010814a <mappages>
  memmove(mem, init, sz);
801084aa:	8b 45 10             	mov    0x10(%ebp),%eax
801084ad:	89 44 24 08          	mov    %eax,0x8(%esp)
801084b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801084b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801084b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bb:	89 04 24             	mov    %eax,(%esp)
801084be:	e8 3f d2 ff ff       	call   80105702 <memmove>
}
801084c3:	c9                   	leave  
801084c4:	c3                   	ret    

801084c5 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801084c5:	55                   	push   %ebp
801084c6:	89 e5                	mov    %esp,%ebp
801084c8:	53                   	push   %ebx
801084c9:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801084cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801084cf:	25 ff 0f 00 00       	and    $0xfff,%eax
801084d4:	85 c0                	test   %eax,%eax
801084d6:	74 0c                	je     801084e4 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801084d8:	c7 04 24 e8 90 10 80 	movl   $0x801090e8,(%esp)
801084df:	e8 56 80 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
801084e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084eb:	e9 a9 00 00 00       	jmp    80108599 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801084f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f3:	8b 55 0c             	mov    0xc(%ebp),%edx
801084f6:	01 d0                	add    %edx,%eax
801084f8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084ff:	00 
80108500:	89 44 24 04          	mov    %eax,0x4(%esp)
80108504:	8b 45 08             	mov    0x8(%ebp),%eax
80108507:	89 04 24             	mov    %eax,(%esp)
8010850a:	e8 99 fb ff ff       	call   801080a8 <walkpgdir>
8010850f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108512:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108516:	75 0c                	jne    80108524 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108518:	c7 04 24 0b 91 10 80 	movl   $0x8010910b,(%esp)
8010851f:	e8 16 80 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108524:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108527:	8b 00                	mov    (%eax),%eax
80108529:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010852e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108534:	8b 55 18             	mov    0x18(%ebp),%edx
80108537:	29 c2                	sub    %eax,%edx
80108539:	89 d0                	mov    %edx,%eax
8010853b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108540:	77 0f                	ja     80108551 <loaduvm+0x8c>
      n = sz - i;
80108542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108545:	8b 55 18             	mov    0x18(%ebp),%edx
80108548:	29 c2                	sub    %eax,%edx
8010854a:	89 d0                	mov    %edx,%eax
8010854c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010854f:	eb 07                	jmp    80108558 <loaduvm+0x93>
    else
      n = PGSIZE;
80108551:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855b:	8b 55 14             	mov    0x14(%ebp),%edx
8010855e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108561:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108564:	89 04 24             	mov    %eax,(%esp)
80108567:	e8 b9 f6 ff ff       	call   80107c25 <p2v>
8010856c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010856f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108573:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108577:	89 44 24 04          	mov    %eax,0x4(%esp)
8010857b:	8b 45 10             	mov    0x10(%ebp),%eax
8010857e:	89 04 24             	mov    %eax,(%esp)
80108581:	e8 ef 97 ff ff       	call   80101d75 <readi>
80108586:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108589:	74 07                	je     80108592 <loaduvm+0xcd>
      return -1;
8010858b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108590:	eb 18                	jmp    801085aa <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108592:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859c:	3b 45 18             	cmp    0x18(%ebp),%eax
8010859f:	0f 82 4b ff ff ff    	jb     801084f0 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801085a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085aa:	83 c4 24             	add    $0x24,%esp
801085ad:	5b                   	pop    %ebx
801085ae:	5d                   	pop    %ebp
801085af:	c3                   	ret    

801085b0 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801085b0:	55                   	push   %ebp
801085b1:	89 e5                	mov    %esp,%ebp
801085b3:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801085b6:	8b 45 10             	mov    0x10(%ebp),%eax
801085b9:	85 c0                	test   %eax,%eax
801085bb:	79 0a                	jns    801085c7 <allocuvm+0x17>
    return 0;
801085bd:	b8 00 00 00 00       	mov    $0x0,%eax
801085c2:	e9 c1 00 00 00       	jmp    80108688 <allocuvm+0xd8>
  if(newsz < oldsz)
801085c7:	8b 45 10             	mov    0x10(%ebp),%eax
801085ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085cd:	73 08                	jae    801085d7 <allocuvm+0x27>
    return oldsz;
801085cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801085d2:	e9 b1 00 00 00       	jmp    80108688 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801085d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801085da:	05 ff 0f 00 00       	add    $0xfff,%eax
801085df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801085e7:	e9 8d 00 00 00       	jmp    80108679 <allocuvm+0xc9>
    mem = kalloc();
801085ec:	e8 fe a4 ff ff       	call   80102aef <kalloc>
801085f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801085f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085f8:	75 2c                	jne    80108626 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801085fa:	c7 04 24 29 91 10 80 	movl   $0x80109129,(%esp)
80108601:	e8 9a 7d ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108606:	8b 45 0c             	mov    0xc(%ebp),%eax
80108609:	89 44 24 08          	mov    %eax,0x8(%esp)
8010860d:	8b 45 10             	mov    0x10(%ebp),%eax
80108610:	89 44 24 04          	mov    %eax,0x4(%esp)
80108614:	8b 45 08             	mov    0x8(%ebp),%eax
80108617:	89 04 24             	mov    %eax,(%esp)
8010861a:	e8 6b 00 00 00       	call   8010868a <deallocuvm>
      return 0;
8010861f:	b8 00 00 00 00       	mov    $0x0,%eax
80108624:	eb 62                	jmp    80108688 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108626:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010862d:	00 
8010862e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108635:	00 
80108636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108639:	89 04 24             	mov    %eax,(%esp)
8010863c:	e8 f2 cf ff ff       	call   80105633 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108644:	89 04 24             	mov    %eax,(%esp)
80108647:	e8 cc f5 ff ff       	call   80107c18 <v2p>
8010864c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010864f:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108656:	00 
80108657:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010865b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108662:	00 
80108663:	89 54 24 04          	mov    %edx,0x4(%esp)
80108667:	8b 45 08             	mov    0x8(%ebp),%eax
8010866a:	89 04 24             	mov    %eax,(%esp)
8010866d:	e8 d8 fa ff ff       	call   8010814a <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108672:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010867f:	0f 82 67 ff ff ff    	jb     801085ec <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108685:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108688:	c9                   	leave  
80108689:	c3                   	ret    

8010868a <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010868a:	55                   	push   %ebp
8010868b:	89 e5                	mov    %esp,%ebp
8010868d:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108690:	8b 45 10             	mov    0x10(%ebp),%eax
80108693:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108696:	72 08                	jb     801086a0 <deallocuvm+0x16>
    return oldsz;
80108698:	8b 45 0c             	mov    0xc(%ebp),%eax
8010869b:	e9 a4 00 00 00       	jmp    80108744 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801086a0:	8b 45 10             	mov    0x10(%ebp),%eax
801086a3:	05 ff 0f 00 00       	add    $0xfff,%eax
801086a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801086b0:	e9 80 00 00 00       	jmp    80108735 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801086b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086bf:	00 
801086c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801086c4:	8b 45 08             	mov    0x8(%ebp),%eax
801086c7:	89 04 24             	mov    %eax,(%esp)
801086ca:	e8 d9 f9 ff ff       	call   801080a8 <walkpgdir>
801086cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801086d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086d6:	75 09                	jne    801086e1 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801086d8:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801086df:	eb 4d                	jmp    8010872e <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801086e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086e4:	8b 00                	mov    (%eax),%eax
801086e6:	83 e0 01             	and    $0x1,%eax
801086e9:	85 c0                	test   %eax,%eax
801086eb:	74 41                	je     8010872e <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801086ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086f0:	8b 00                	mov    (%eax),%eax
801086f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801086fa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086fe:	75 0c                	jne    8010870c <deallocuvm+0x82>
        panic("kfree");
80108700:	c7 04 24 41 91 10 80 	movl   $0x80109141,(%esp)
80108707:	e8 2e 7e ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
8010870c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010870f:	89 04 24             	mov    %eax,(%esp)
80108712:	e8 0e f5 ff ff       	call   80107c25 <p2v>
80108717:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010871a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010871d:	89 04 24             	mov    %eax,(%esp)
80108720:	e8 31 a3 ff ff       	call   80102a56 <kfree>
      *pte = 0;
80108725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108728:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010872e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108738:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010873b:	0f 82 74 ff ff ff    	jb     801086b5 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108741:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108744:	c9                   	leave  
80108745:	c3                   	ret    

80108746 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108746:	55                   	push   %ebp
80108747:	89 e5                	mov    %esp,%ebp
80108749:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010874c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108750:	75 0c                	jne    8010875e <freevm+0x18>
    panic("freevm: no pgdir");
80108752:	c7 04 24 47 91 10 80 	movl   $0x80109147,(%esp)
80108759:	e8 dc 7d ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010875e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108765:	00 
80108766:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010876d:	80 
8010876e:	8b 45 08             	mov    0x8(%ebp),%eax
80108771:	89 04 24             	mov    %eax,(%esp)
80108774:	e8 11 ff ff ff       	call   8010868a <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108779:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108780:	eb 48                	jmp    801087ca <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108785:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010878c:	8b 45 08             	mov    0x8(%ebp),%eax
8010878f:	01 d0                	add    %edx,%eax
80108791:	8b 00                	mov    (%eax),%eax
80108793:	83 e0 01             	and    $0x1,%eax
80108796:	85 c0                	test   %eax,%eax
80108798:	74 2c                	je     801087c6 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010879a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801087a4:	8b 45 08             	mov    0x8(%ebp),%eax
801087a7:	01 d0                	add    %edx,%eax
801087a9:	8b 00                	mov    (%eax),%eax
801087ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087b0:	89 04 24             	mov    %eax,(%esp)
801087b3:	e8 6d f4 ff ff       	call   80107c25 <p2v>
801087b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801087bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087be:	89 04 24             	mov    %eax,(%esp)
801087c1:	e8 90 a2 ff ff       	call   80102a56 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801087c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087ca:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801087d1:	76 af                	jbe    80108782 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801087d3:	8b 45 08             	mov    0x8(%ebp),%eax
801087d6:	89 04 24             	mov    %eax,(%esp)
801087d9:	e8 78 a2 ff ff       	call   80102a56 <kfree>
}
801087de:	c9                   	leave  
801087df:	c3                   	ret    

801087e0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801087e0:	55                   	push   %ebp
801087e1:	89 e5                	mov    %esp,%ebp
801087e3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087ed:	00 
801087ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801087f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801087f5:	8b 45 08             	mov    0x8(%ebp),%eax
801087f8:	89 04 24             	mov    %eax,(%esp)
801087fb:	e8 a8 f8 ff ff       	call   801080a8 <walkpgdir>
80108800:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108803:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108807:	75 0c                	jne    80108815 <clearpteu+0x35>
    panic("clearpteu");
80108809:	c7 04 24 58 91 10 80 	movl   $0x80109158,(%esp)
80108810:	e8 25 7d ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80108815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108818:	8b 00                	mov    (%eax),%eax
8010881a:	83 e0 fb             	and    $0xfffffffb,%eax
8010881d:	89 c2                	mov    %eax,%edx
8010881f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108822:	89 10                	mov    %edx,(%eax)
}
80108824:	c9                   	leave  
80108825:	c3                   	ret    

80108826 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108826:	55                   	push   %ebp
80108827:	89 e5                	mov    %esp,%ebp
80108829:	53                   	push   %ebx
8010882a:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010882d:	e8 b0 f9 ff ff       	call   801081e2 <setupkvm>
80108832:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108835:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108839:	75 0a                	jne    80108845 <copyuvm+0x1f>
    return 0;
8010883b:	b8 00 00 00 00       	mov    $0x0,%eax
80108840:	e9 fd 00 00 00       	jmp    80108942 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108845:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010884c:	e9 d0 00 00 00       	jmp    80108921 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108854:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010885b:	00 
8010885c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108860:	8b 45 08             	mov    0x8(%ebp),%eax
80108863:	89 04 24             	mov    %eax,(%esp)
80108866:	e8 3d f8 ff ff       	call   801080a8 <walkpgdir>
8010886b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010886e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108872:	75 0c                	jne    80108880 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108874:	c7 04 24 62 91 10 80 	movl   $0x80109162,(%esp)
8010887b:	e8 ba 7c ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108880:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108883:	8b 00                	mov    (%eax),%eax
80108885:	83 e0 01             	and    $0x1,%eax
80108888:	85 c0                	test   %eax,%eax
8010888a:	75 0c                	jne    80108898 <copyuvm+0x72>
      panic("copyuvm: page not present");
8010888c:	c7 04 24 7c 91 10 80 	movl   $0x8010917c,(%esp)
80108893:	e8 a2 7c ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108898:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010889b:	8b 00                	mov    (%eax),%eax
8010889d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801088a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088a8:	8b 00                	mov    (%eax),%eax
801088aa:	25 ff 0f 00 00       	and    $0xfff,%eax
801088af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801088b2:	e8 38 a2 ff ff       	call   80102aef <kalloc>
801088b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
801088ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801088be:	75 02                	jne    801088c2 <copyuvm+0x9c>
      goto bad;
801088c0:	eb 70                	jmp    80108932 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801088c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088c5:	89 04 24             	mov    %eax,(%esp)
801088c8:	e8 58 f3 ff ff       	call   80107c25 <p2v>
801088cd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801088d4:	00 
801088d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801088d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088dc:	89 04 24             	mov    %eax,(%esp)
801088df:	e8 1e ce ff ff       	call   80105702 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801088e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801088e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088ea:	89 04 24             	mov    %eax,(%esp)
801088ed:	e8 26 f3 ff ff       	call   80107c18 <v2p>
801088f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088f5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801088f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
801088fd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108904:	00 
80108905:	89 54 24 04          	mov    %edx,0x4(%esp)
80108909:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010890c:	89 04 24             	mov    %eax,(%esp)
8010890f:	e8 36 f8 ff ff       	call   8010814a <mappages>
80108914:	85 c0                	test   %eax,%eax
80108916:	79 02                	jns    8010891a <copyuvm+0xf4>
      goto bad;
80108918:	eb 18                	jmp    80108932 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010891a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108924:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108927:	0f 82 24 ff ff ff    	jb     80108851 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010892d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108930:	eb 10                	jmp    80108942 <copyuvm+0x11c>

bad:
  freevm(d);
80108932:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108935:	89 04 24             	mov    %eax,(%esp)
80108938:	e8 09 fe ff ff       	call   80108746 <freevm>
  return 0;
8010893d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108942:	83 c4 44             	add    $0x44,%esp
80108945:	5b                   	pop    %ebx
80108946:	5d                   	pop    %ebp
80108947:	c3                   	ret    

80108948 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108948:	55                   	push   %ebp
80108949:	89 e5                	mov    %esp,%ebp
8010894b:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010894e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108955:	00 
80108956:	8b 45 0c             	mov    0xc(%ebp),%eax
80108959:	89 44 24 04          	mov    %eax,0x4(%esp)
8010895d:	8b 45 08             	mov    0x8(%ebp),%eax
80108960:	89 04 24             	mov    %eax,(%esp)
80108963:	e8 40 f7 ff ff       	call   801080a8 <walkpgdir>
80108968:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010896b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896e:	8b 00                	mov    (%eax),%eax
80108970:	83 e0 01             	and    $0x1,%eax
80108973:	85 c0                	test   %eax,%eax
80108975:	75 07                	jne    8010897e <uva2ka+0x36>
    return 0;
80108977:	b8 00 00 00 00       	mov    $0x0,%eax
8010897c:	eb 25                	jmp    801089a3 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
8010897e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108981:	8b 00                	mov    (%eax),%eax
80108983:	83 e0 04             	and    $0x4,%eax
80108986:	85 c0                	test   %eax,%eax
80108988:	75 07                	jne    80108991 <uva2ka+0x49>
    return 0;
8010898a:	b8 00 00 00 00       	mov    $0x0,%eax
8010898f:	eb 12                	jmp    801089a3 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108994:	8b 00                	mov    (%eax),%eax
80108996:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010899b:	89 04 24             	mov    %eax,(%esp)
8010899e:	e8 82 f2 ff ff       	call   80107c25 <p2v>
}
801089a3:	c9                   	leave  
801089a4:	c3                   	ret    

801089a5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801089a5:	55                   	push   %ebp
801089a6:	89 e5                	mov    %esp,%ebp
801089a8:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801089ab:	8b 45 10             	mov    0x10(%ebp),%eax
801089ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801089b1:	e9 87 00 00 00       	jmp    80108a3d <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801089b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801089b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089be:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801089c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801089c8:	8b 45 08             	mov    0x8(%ebp),%eax
801089cb:	89 04 24             	mov    %eax,(%esp)
801089ce:	e8 75 ff ff ff       	call   80108948 <uva2ka>
801089d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801089d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801089da:	75 07                	jne    801089e3 <copyout+0x3e>
      return -1;
801089dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089e1:	eb 69                	jmp    80108a4c <copyout+0xa7>
    n = PGSIZE - (va - va0);
801089e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801089e9:	29 c2                	sub    %eax,%edx
801089eb:	89 d0                	mov    %edx,%eax
801089ed:	05 00 10 00 00       	add    $0x1000,%eax
801089f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801089f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089f8:	3b 45 14             	cmp    0x14(%ebp),%eax
801089fb:	76 06                	jbe    80108a03 <copyout+0x5e>
      n = len;
801089fd:	8b 45 14             	mov    0x14(%ebp),%eax
80108a00:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a06:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a09:	29 c2                	sub    %eax,%edx
80108a0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a0e:	01 c2                	add    %eax,%edx
80108a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a13:	89 44 24 08          	mov    %eax,0x8(%esp)
80108a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a1e:	89 14 24             	mov    %edx,(%esp)
80108a21:	e8 dc cc ff ff       	call   80105702 <memmove>
    len -= n;
80108a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a29:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a2f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108a32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a35:	05 00 10 00 00       	add    $0x1000,%eax
80108a3a:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108a3d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108a41:	0f 85 6f ff ff ff    	jne    801089b6 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a4c:	c9                   	leave  
80108a4d:	c3                   	ret    
