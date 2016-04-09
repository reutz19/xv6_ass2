
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
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
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
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

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
8010003a:	c7 44 24 04 00 87 10 	movl   $0x80108700,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 3e 50 00 00       	call   8010508c <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100055:	05 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
8010005f:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 05 11 80       	mov    0x80110574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 05 11 80       	mov    %eax,0x80110574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
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
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 eb 4f 00 00       	call   801050ad <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 05 11 80       	mov    0x80110574,%eax
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
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 06 50 00 00       	call   8010510f <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 2b 4b 00 00       	call   80104c4f <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 05 11 80       	mov    0x80110570,%eax
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
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 8e 4f 00 00       	call   8010510f <release>
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
8010018f:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 07 87 10 80 	movl   $0x80108707,(%esp)
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
801001ef:	c7 04 24 18 87 10 80 	movl   $0x80108718,(%esp)
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
80100229:	c7 04 24 1f 87 10 80 	movl   $0x8010871f,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 6c 4e 00 00       	call   801050ad <acquire>

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
8010025f:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 05 11 80       	mov    0x80110574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 05 11 80       	mov    %eax,0x80110574

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
8010029d:	e8 88 4a 00 00       	call   80104d2a <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 61 4e 00 00       	call   8010510f <release>
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
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
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
801003a6:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bb:	e8 ed 4c 00 00       	call   801050ad <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 26 87 10 80 	movl   $0x80108726,(%esp)
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
801004b0:	c7 45 ec 2f 87 10 80 	movl   $0x8010872f,-0x14(%ebp)
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
8010052c:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100533:	e8 d7 4b 00 00       	call   8010510f <release>
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
80100545:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 36 87 10 80 	movl   $0x80108736,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 45 87 10 80 	movl   $0x80108745,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 ca 4b 00 00       	call   8010515e <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 47 87 10 80 	movl   $0x80108747,(%esp)
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
801005be:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
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
8010066a:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
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
80100693:	a1 00 90 10 80       	mov    0x80109000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 19 4d 00 00       	call   801053d0 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006c6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 c8                	add    %ecx,%eax
801006d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 04 24             	mov    %eax,(%esp)
801006e1:	e8 1b 4c 00 00       	call   80105301 <memset>
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
8010073d:	a1 00 90 10 80       	mov    0x80109000,%eax
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
80100756:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
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
80100776:	e8 c5 65 00 00       	call   80106d40 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 b9 65 00 00       	call   80106d40 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 ad 65 00 00       	call   80106d40 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 a0 65 00 00       	call   80106d40 <uartputc>
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
801007b3:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
801007ba:	e8 ee 48 00 00       	call   801050ad <acquire>
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
801007ea:	e8 e1 45 00 00       	call   80104dd0 <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 3c 08 11 80       	mov    %eax,0x8011083c
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
80100810:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100816:	a1 38 08 11 80       	mov    0x80110838,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
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
8010083a:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100840:	a1 38 08 11 80       	mov    0x80110838,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 3c 08 11 80       	mov    %eax,0x8011083c
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
80100876:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
8010087c:	a1 34 08 11 80       	mov    0x80110834,%eax
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
8010089d:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 3c 08 11 80    	mov    %edx,0x8011083c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 b4 07 11 80    	mov    %al,-0x7feef84c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008d5:	8b 15 34 08 11 80    	mov    0x80110834,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008e7:	a3 38 08 11 80       	mov    %eax,0x80110838
          wakeup(&input.r);
801008ec:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
801008f3:	e8 32 44 00 00       	call   80104d2a <wakeup>
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
8010090d:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100914:	e8 f6 47 00 00       	call   8010510f <release>
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
80100932:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100939:	e8 6f 47 00 00       	call   801050ad <acquire>
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
80100952:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100959:	e8 b1 47 00 00       	call   8010510f <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 ff 0e 00 00       	call   80101868 <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 80 07 11 	movl   $0x80110780,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
80100982:	e8 c8 42 00 00       	call   80104c4f <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 34 08 11 80    	mov    0x80110834,%edx
8010098d:	a1 38 08 11 80       	mov    0x80110838,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 34 08 11 80       	mov    0x80110834,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 34 08 11 80    	mov    %edx,0x80110834
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
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
801009c2:	a1 34 08 11 80       	mov    0x80110834,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 34 08 11 80       	mov    %eax,0x80110834
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
801009f7:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
801009fe:	e8 0c 47 00 00       	call   8010510f <release>
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
80100a2b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a32:	e8 76 46 00 00       	call   801050ad <acquire>
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
80100a65:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a6c:	e8 9e 46 00 00       	call   8010510f <release>
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
80100a87:	c7 44 24 04 4b 87 10 	movl   $0x8010874b,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a96:	e8 f1 45 00 00       	call   8010508c <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 53 87 10 	movl   $0x80108753,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100aaa:	e8 dd 45 00 00       	call   8010508c <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 ec 11 11 80 1a 	movl   $0x80100a1a,0x801111ec
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 e8 11 11 80 1b 	movl   $0x8010091b,0x801111e8
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
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
#include "x86.h"
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
80100b73:	e8 19 73 00 00       	call   80107e91 <setupkvm>
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
80100c14:	e8 46 76 00 00       	call   8010825f <allocuvm>
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
80100c52:	e8 1d 75 00 00       	call   80108174 <loaduvm>
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
80100cc0:	e8 9a 75 00 00       	call   8010825f <allocuvm>
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
80100ce5:	e8 a5 77 00 00       	call   8010848f <clearpteu>
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
80100d1b:	e8 4b 48 00 00       	call   8010556b <strlen>
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
80100d44:	e8 22 48 00 00       	call   8010556b <strlen>
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
80100d74:	e8 db 78 00 00       	call   80108654 <copyout>
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
80100e1b:	e8 34 78 00 00       	call   80108654 <copyout>
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
80100e73:	e8 a9 46 00 00       	call   80105521 <safestrcpy>

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
80100ed2:	e8 ab 70 00 00       	call   80107f82 <switchuvm>
  freevm(oldpgdir);
80100ed7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eda:	89 04 24             	mov    %eax,(%esp)
80100edd:	e8 13 75 00 00       	call   801083f5 <freevm>
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
80100ef5:	e8 fb 74 00 00       	call   801083f5 <freevm>
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
80100f1d:	c7 44 24 04 59 87 10 	movl   $0x80108759,0x4(%esp)
80100f24:	80 
80100f25:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f2c:	e8 5b 41 00 00       	call   8010508c <initlock>
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
80100f39:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f40:	e8 68 41 00 00       	call   801050ad <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f45:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
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
80100f62:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f69:	e8 a1 41 00 00       	call   8010510f <release>
      return f;
80100f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f71:	eb 1e                	jmp    80100f91 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f73:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f77:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
80100f7e:	72 ce                	jb     80100f4e <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f80:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f87:	e8 83 41 00 00       	call   8010510f <release>
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
80100f99:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fa0:	e8 08 41 00 00       	call   801050ad <acquire>
  if(f->ref < 1)
80100fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa8:	8b 40 04             	mov    0x4(%eax),%eax
80100fab:	85 c0                	test   %eax,%eax
80100fad:	7f 0c                	jg     80100fbb <filedup+0x28>
    panic("filedup");
80100faf:	c7 04 24 60 87 10 80 	movl   $0x80108760,(%esp)
80100fb6:	e8 7f f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbe:	8b 40 04             	mov    0x4(%eax),%eax
80100fc1:	8d 50 01             	lea    0x1(%eax),%edx
80100fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc7:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fca:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fd1:	e8 39 41 00 00       	call   8010510f <release>
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
80100fe1:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fe8:	e8 c0 40 00 00       	call   801050ad <acquire>
  if(f->ref < 1)
80100fed:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff0:	8b 40 04             	mov    0x4(%eax),%eax
80100ff3:	85 c0                	test   %eax,%eax
80100ff5:	7f 0c                	jg     80101003 <fileclose+0x28>
    panic("fileclose");
80100ff7:	c7 04 24 68 87 10 80 	movl   $0x80108768,(%esp)
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
8010101c:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101023:	e8 e7 40 00 00       	call   8010510f <release>
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
80101066:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010106d:	e8 9d 40 00 00       	call   8010510f <release>
  
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
801011ae:	c7 04 24 72 87 10 80 	movl   $0x80108772,(%esp)
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
801012ba:	c7 04 24 7b 87 10 80 	movl   $0x8010877b,(%esp)
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
801012ec:	c7 04 24 8b 87 10 80 	movl   $0x8010878b,(%esp)
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
80101332:	e8 99 40 00 00       	call   801053d0 <memmove>
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
80101378:	e8 84 3f 00 00       	call   80105301 <memset>
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
801014d5:	c7 04 24 95 87 10 80 	movl   $0x80108795,(%esp)
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
80101567:	c7 04 24 ab 87 10 80 	movl   $0x801087ab,(%esp)
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
801015b7:	c7 44 24 04 be 87 10 	movl   $0x801087be,0x4(%esp)
801015be:	80 
801015bf:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801015c6:	e8 c1 3a 00 00       	call   8010508c <initlock>
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
80101648:	e8 b4 3c 00 00       	call   80105301 <memset>
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
8010169e:	c7 04 24 c5 87 10 80 	movl   $0x801087c5,(%esp)
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
80101747:	e8 84 3c 00 00       	call   801053d0 <memmove>
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
8010176a:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101771:	e8 37 39 00 00       	call   801050ad <acquire>

  // Is the inode already cached?
  empty = 0;
80101776:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010177d:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
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
801017b4:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801017bb:	e8 4f 39 00 00       	call   8010510f <release>
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
801017df:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
801017e6:	72 9e                	jb     80101786 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017ec:	75 0c                	jne    801017fa <iget+0x96>
    panic("iget: no inodes");
801017ee:	c7 04 24 d7 87 10 80 	movl   $0x801087d7,(%esp)
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
80101825:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010182c:	e8 de 38 00 00       	call   8010510f <release>

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
8010183c:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101843:	e8 65 38 00 00       	call   801050ad <acquire>
  ip->ref++;
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 08             	mov    0x8(%eax),%eax
8010184e:	8d 50 01             	lea    0x1(%eax),%edx
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101857:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010185e:	e8 ac 38 00 00       	call   8010510f <release>
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
8010187e:	c7 04 24 e7 87 10 80 	movl   $0x801087e7,(%esp)
80101885:	e8 b0 ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010188a:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101891:	e8 17 38 00 00       	call   801050ad <acquire>
  while(ip->flags & I_BUSY)
80101896:	eb 13                	jmp    801018ab <ilock+0x43>
    sleep(ip, &icache.lock);
80101898:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
8010189f:	80 
801018a0:	8b 45 08             	mov    0x8(%ebp),%eax
801018a3:	89 04 24             	mov    %eax,(%esp)
801018a6:	e8 a4 33 00 00       	call   80104c4f <sleep>

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
801018c9:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801018d0:	e8 3a 38 00 00       	call   8010510f <release>

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
8010197b:	e8 50 3a 00 00       	call   801053d0 <memmove>
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
801019a8:	c7 04 24 ed 87 10 80 	movl   $0x801087ed,(%esp)
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
801019d9:	c7 04 24 fc 87 10 80 	movl   $0x801087fc,(%esp)
801019e0:	e8 55 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019e5:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801019ec:	e8 bc 36 00 00       	call   801050ad <acquire>
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
80101a08:	e8 1d 33 00 00       	call   80104d2a <wakeup>
  release(&icache.lock);
80101a0d:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a14:	e8 f6 36 00 00       	call   8010510f <release>
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
80101a21:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a28:	e8 80 36 00 00       	call   801050ad <acquire>
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
80101a66:	c7 04 24 04 88 10 80 	movl   $0x80108804,(%esp)
80101a6d:	e8 c8 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	8b 40 0c             	mov    0xc(%eax),%eax
80101a78:	83 c8 01             	or     $0x1,%eax
80101a7b:	89 c2                	mov    %eax,%edx
80101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a80:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a83:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a8a:	e8 80 36 00 00       	call   8010510f <release>
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
80101aae:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101ab5:	e8 f3 35 00 00       	call   801050ad <acquire>
    ip->flags = 0;
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac7:	89 04 24             	mov    %eax,(%esp)
80101aca:	e8 5b 32 00 00       	call   80104d2a <wakeup>
  }
  ip->ref--;
80101acf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad2:	8b 40 08             	mov    0x8(%eax),%eax
80101ad5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ade:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101ae5:	e8 25 36 00 00       	call   8010510f <release>
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
80101c05:	c7 04 24 0e 88 10 80 	movl   $0x8010880e,(%esp)
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
80101da9:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101db0:	85 c0                	test   %eax,%eax
80101db2:	75 0a                	jne    80101dbe <readi+0x49>
      return -1;
80101db4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101db9:	e9 19 01 00 00       	jmp    80101ed7 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dc5:	98                   	cwtl   
80101dc6:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
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
80101ea6:	e8 25 35 00 00       	call   801053d0 <memmove>
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
80101f0d:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f14:	85 c0                	test   %eax,%eax
80101f16:	75 0a                	jne    80101f22 <writei+0x49>
      return -1;
80101f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1d:	e9 44 01 00 00       	jmp    80102066 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f22:	8b 45 08             	mov    0x8(%ebp),%eax
80101f25:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f29:	98                   	cwtl   
80101f2a:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
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
80102005:	e8 c6 33 00 00       	call   801053d0 <memmove>
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
80102083:	e8 eb 33 00 00       	call   80105473 <strncmp>
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
8010209d:	c7 04 24 21 88 10 80 	movl   $0x80108821,(%esp)
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
801020db:	c7 04 24 33 88 10 80 	movl   $0x80108833,(%esp)
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
801021c0:	c7 04 24 33 88 10 80 	movl   $0x80108833,(%esp)
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
80102205:	e8 bf 32 00 00       	call   801054c9 <strncpy>
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
80102237:	c7 04 24 40 88 10 80 	movl   $0x80108840,(%esp)
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
801022bc:	e8 0f 31 00 00       	call   801053d0 <memmove>
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
801022d7:	e8 f4 30 00 00       	call   801053d0 <memmove>
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
80102526:	c7 44 24 04 48 88 10 	movl   $0x80108848,0x4(%esp)
8010252d:	80 
8010252e:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102535:	e8 52 2b 00 00       	call   8010508c <initlock>
  picenable(IRQ_IDE);
8010253a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102541:	e8 7b 18 00 00       	call   80103dc1 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102546:	a1 40 29 11 80       	mov    0x80112940,%eax
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
80102597:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
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
801025d2:	c7 04 24 4c 88 10 80 	movl   $0x8010884c,(%esp)
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
801026f1:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801026f8:	e8 b0 29 00 00       	call   801050ad <acquire>
  if((b = idequeue) == 0){
801026fd:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102702:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102705:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102709:	75 11                	jne    8010271c <ideintr+0x31>
    release(&idelock);
8010270b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102712:	e8 f8 29 00 00       	call   8010510f <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102717:	e9 90 00 00 00       	jmp    801027ac <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010271c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271f:	8b 40 14             	mov    0x14(%eax),%eax
80102722:	a3 34 b6 10 80       	mov    %eax,0x8010b634

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
80102785:	e8 a0 25 00 00       	call   80104d2a <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010278a:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010278f:	85 c0                	test   %eax,%eax
80102791:	74 0d                	je     801027a0 <ideintr+0xb5>
    idestart(idequeue);
80102793:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102798:	89 04 24             	mov    %eax,(%esp)
8010279b:	e8 26 fe ff ff       	call   801025c6 <idestart>

  release(&idelock);
801027a0:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027a7:	e8 63 29 00 00       	call   8010510f <release>
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
801027c0:	c7 04 24 55 88 10 80 	movl   $0x80108855,(%esp)
801027c7:	e8 6e dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027cc:	8b 45 08             	mov    0x8(%ebp),%eax
801027cf:	8b 00                	mov    (%eax),%eax
801027d1:	83 e0 06             	and    $0x6,%eax
801027d4:	83 f8 02             	cmp    $0x2,%eax
801027d7:	75 0c                	jne    801027e5 <iderw+0x37>
    panic("iderw: nothing to do");
801027d9:	c7 04 24 69 88 10 80 	movl   $0x80108869,(%esp)
801027e0:	e8 55 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027e5:	8b 45 08             	mov    0x8(%ebp),%eax
801027e8:	8b 40 04             	mov    0x4(%eax),%eax
801027eb:	85 c0                	test   %eax,%eax
801027ed:	74 15                	je     80102804 <iderw+0x56>
801027ef:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801027f4:	85 c0                	test   %eax,%eax
801027f6:	75 0c                	jne    80102804 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027f8:	c7 04 24 7e 88 10 80 	movl   $0x8010887e,(%esp)
801027ff:	e8 36 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102804:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010280b:	e8 9d 28 00 00       	call   801050ad <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102810:	8b 45 08             	mov    0x8(%ebp),%eax
80102813:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010281a:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
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
8010283f:	a1 34 b6 10 80       	mov    0x8010b634,%eax
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
80102858:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
8010285f:	80 
80102860:	8b 45 08             	mov    0x8(%ebp),%eax
80102863:	89 04 24             	mov    %eax,(%esp)
80102866:	e8 e4 23 00 00       	call   80104c4f <sleep>
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
80102878:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010287f:	e8 8b 28 00 00       	call   8010510f <release>
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
80102889:	a1 14 22 11 80       	mov    0x80112214,%eax
8010288e:	8b 55 08             	mov    0x8(%ebp),%edx
80102891:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102893:	a1 14 22 11 80       	mov    0x80112214,%eax
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
801028a0:	a1 14 22 11 80       	mov    0x80112214,%eax
801028a5:	8b 55 08             	mov    0x8(%ebp),%edx
801028a8:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028aa:	a1 14 22 11 80       	mov    0x80112214,%eax
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
801028bd:	a1 44 23 11 80       	mov    0x80112344,%eax
801028c2:	85 c0                	test   %eax,%eax
801028c4:	75 05                	jne    801028cb <ioapicinit+0x14>
    return;
801028c6:	e9 9d 00 00 00       	jmp    80102968 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028cb:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
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
801028fe:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
80102905:	0f b6 c0             	movzbl %al,%eax
80102908:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010290b:	74 0c                	je     80102919 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010290d:	c7 04 24 9c 88 10 80 	movl   $0x8010889c,(%esp)
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
80102970:	a1 44 23 11 80       	mov    0x80112344,%eax
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
801029c7:	c7 44 24 04 ce 88 10 	movl   $0x801088ce,0x4(%esp)
801029ce:	80 
801029cf:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
801029d6:	e8 b1 26 00 00       	call   8010508c <initlock>
  kmem.use_lock = 0;
801029db:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
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
80102a11:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
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
80102a68:	81 7d 08 3c 85 11 80 	cmpl   $0x8011853c,0x8(%ebp)
80102a6f:	72 12                	jb     80102a83 <kfree+0x2d>
80102a71:	8b 45 08             	mov    0x8(%ebp),%eax
80102a74:	89 04 24             	mov    %eax,(%esp)
80102a77:	e8 38 ff ff ff       	call   801029b4 <v2p>
80102a7c:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a81:	76 0c                	jbe    80102a8f <kfree+0x39>
    panic("kfree");
80102a83:	c7 04 24 d3 88 10 80 	movl   $0x801088d3,(%esp)
80102a8a:	e8 ab da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a8f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a96:	00 
80102a97:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a9e:	00 
80102a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa2:	89 04 24             	mov    %eax,(%esp)
80102aa5:	e8 57 28 00 00       	call   80105301 <memset>

  if(kmem.use_lock)
80102aaa:	a1 54 22 11 80       	mov    0x80112254,%eax
80102aaf:	85 c0                	test   %eax,%eax
80102ab1:	74 0c                	je     80102abf <kfree+0x69>
    acquire(&kmem.lock);
80102ab3:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102aba:	e8 ee 25 00 00       	call   801050ad <acquire>
  r = (struct run*)v;
80102abf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ac5:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ace:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad3:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102ad8:	a1 54 22 11 80       	mov    0x80112254,%eax
80102add:	85 c0                	test   %eax,%eax
80102adf:	74 0c                	je     80102aed <kfree+0x97>
    release(&kmem.lock);
80102ae1:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102ae8:	e8 22 26 00 00       	call   8010510f <release>
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
80102af5:	a1 54 22 11 80       	mov    0x80112254,%eax
80102afa:	85 c0                	test   %eax,%eax
80102afc:	74 0c                	je     80102b0a <kalloc+0x1b>
    acquire(&kmem.lock);
80102afe:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b05:	e8 a3 25 00 00       	call   801050ad <acquire>
  r = kmem.freelist;
80102b0a:	a1 58 22 11 80       	mov    0x80112258,%eax
80102b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b16:	74 0a                	je     80102b22 <kalloc+0x33>
    kmem.freelist = r->next;
80102b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1b:	8b 00                	mov    (%eax),%eax
80102b1d:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102b22:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b27:	85 c0                	test   %eax,%eax
80102b29:	74 0c                	je     80102b37 <kalloc+0x48>
    release(&kmem.lock);
80102b2b:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b32:	e8 d8 25 00 00       	call   8010510f <release>
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
80102ba0:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ba5:	83 c8 40             	or     $0x40,%eax
80102ba8:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
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
80102bc3:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
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
80102be0:	05 20 90 10 80       	add    $0x80109020,%eax
80102be5:	0f b6 00             	movzbl (%eax),%eax
80102be8:	83 c8 40             	or     $0x40,%eax
80102beb:	0f b6 c0             	movzbl %al,%eax
80102bee:	f7 d0                	not    %eax
80102bf0:	89 c2                	mov    %eax,%edx
80102bf2:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bf7:	21 d0                	and    %edx,%eax
80102bf9:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102bfe:	b8 00 00 00 00       	mov    $0x0,%eax
80102c03:	e9 a2 00 00 00       	jmp    80102caa <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102c08:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c0d:	83 e0 40             	and    $0x40,%eax
80102c10:	85 c0                	test   %eax,%eax
80102c12:	74 14                	je     80102c28 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c14:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c1b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c20:	83 e0 bf             	and    $0xffffffbf,%eax
80102c23:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c2b:	05 20 90 10 80       	add    $0x80109020,%eax
80102c30:	0f b6 00             	movzbl (%eax),%eax
80102c33:	0f b6 d0             	movzbl %al,%edx
80102c36:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c3b:	09 d0                	or     %edx,%eax
80102c3d:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c45:	05 20 91 10 80       	add    $0x80109120,%eax
80102c4a:	0f b6 00             	movzbl (%eax),%eax
80102c4d:	0f b6 d0             	movzbl %al,%edx
80102c50:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c55:	31 d0                	xor    %edx,%eax
80102c57:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c5c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c61:	83 e0 03             	and    $0x3,%eax
80102c64:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102c6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6e:	01 d0                	add    %edx,%eax
80102c70:	0f b6 00             	movzbl (%eax),%eax
80102c73:	0f b6 c0             	movzbl %al,%eax
80102c76:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c79:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
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
80102d0e:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d13:	8b 55 08             	mov    0x8(%ebp),%edx
80102d16:	c1 e2 02             	shl    $0x2,%edx
80102d19:	01 c2                	add    %eax,%edx
80102d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d1e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d20:	a1 5c 22 11 80       	mov    0x8011225c,%eax
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
80102d32:	a1 5c 22 11 80       	mov    0x8011225c,%eax
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
80102db8:	a1 5c 22 11 80       	mov    0x8011225c,%eax
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
80102e5a:	a1 5c 22 11 80       	mov    0x8011225c,%eax
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
80102e99:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102e9e:	8d 50 01             	lea    0x1(%eax),%edx
80102ea1:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102ea7:	85 c0                	test   %eax,%eax
80102ea9:	75 13                	jne    80102ebe <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eab:	8b 45 04             	mov    0x4(%ebp),%eax
80102eae:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eb2:	c7 04 24 dc 88 10 80 	movl   $0x801088dc,(%esp)
80102eb9:	e8 e2 d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102ebe:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ec3:	85 c0                	test   %eax,%eax
80102ec5:	74 0f                	je     80102ed6 <cpunum+0x51>
    return lapic[ID]>>24;
80102ec7:	a1 5c 22 11 80       	mov    0x8011225c,%eax
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
80102ee3:	a1 5c 22 11 80       	mov    0x8011225c,%eax
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
80103115:	e8 5e 22 00 00       	call   80105378 <memcmp>
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
80103215:	c7 44 24 04 08 89 10 	movl   $0x80108908,0x4(%esp)
8010321c:	80 
8010321d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103224:	e8 63 1e 00 00       	call   8010508c <initlock>
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
80103246:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
8010324b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010324e:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = ROOTDEV;
80103253:	c7 05 a4 22 11 80 01 	movl   $0x1,0x801122a4
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
80103276:	8b 15 94 22 11 80    	mov    0x80112294,%edx
8010327c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010327f:	01 d0                	add    %edx,%eax
80103281:	83 c0 01             	add    $0x1,%eax
80103284:	89 c2                	mov    %eax,%edx
80103286:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010328b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010328f:	89 04 24             	mov    %eax,(%esp)
80103292:	e8 0f cf ff ff       	call   801001a6 <bread>
80103297:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010329a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010329d:	83 c0 10             	add    $0x10,%eax
801032a0:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801032a7:	89 c2                	mov    %eax,%edx
801032a9:	a1 a4 22 11 80       	mov    0x801122a4,%eax
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
801032d8:	e8 f3 20 00 00       	call   801053d0 <memmove>
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
80103302:	a1 a8 22 11 80       	mov    0x801122a8,%eax
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
80103318:	a1 94 22 11 80       	mov    0x80112294,%eax
8010331d:	89 c2                	mov    %eax,%edx
8010331f:	a1 a4 22 11 80       	mov    0x801122a4,%eax
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
80103341:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
80103346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010334d:	eb 1b                	jmp    8010336a <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010334f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103352:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103355:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103359:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010335c:	83 c2 10             	add    $0x10,%edx
8010335f:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103366:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010336a:	a1 a8 22 11 80       	mov    0x801122a8,%eax
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
80103387:	a1 94 22 11 80       	mov    0x80112294,%eax
8010338c:	89 c2                	mov    %eax,%edx
8010338e:	a1 a4 22 11 80       	mov    0x801122a4,%eax
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
801033ab:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
801033b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b4:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033bd:	eb 1b                	jmp    801033da <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c2:	83 c0 10             	add    $0x10,%eax
801033c5:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
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
801033da:	a1 a8 22 11 80       	mov    0x801122a8,%eax
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
8010340c:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
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
80103423:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010342a:	e8 7e 1c 00 00       	call   801050ad <acquire>
  while(1){
    if(log.committing){
8010342f:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103434:	85 c0                	test   %eax,%eax
80103436:	74 16                	je     8010344e <begin_op+0x31>
      sleep(&log, &log.lock);
80103438:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
8010343f:	80 
80103440:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103447:	e8 03 18 00 00       	call   80104c4f <sleep>
8010344c:	eb 4f                	jmp    8010349d <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010344e:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103454:	a1 9c 22 11 80       	mov    0x8011229c,%eax
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
8010346c:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103473:	80 
80103474:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010347b:	e8 cf 17 00 00       	call   80104c4f <sleep>
80103480:	eb 1b                	jmp    8010349d <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103482:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103487:	83 c0 01             	add    $0x1,%eax
8010348a:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
8010348f:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103496:	e8 74 1c 00 00       	call   8010510f <release>
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
801034ae:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034b5:	e8 f3 1b 00 00       	call   801050ad <acquire>
  log.outstanding -= 1;
801034ba:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034bf:	83 e8 01             	sub    $0x1,%eax
801034c2:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
801034c7:	a1 a0 22 11 80       	mov    0x801122a0,%eax
801034cc:	85 c0                	test   %eax,%eax
801034ce:	74 0c                	je     801034dc <end_op+0x3b>
    panic("log.committing");
801034d0:	c7 04 24 0c 89 10 80 	movl   $0x8010890c,(%esp)
801034d7:	e8 5e d0 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
801034dc:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034e1:	85 c0                	test   %eax,%eax
801034e3:	75 13                	jne    801034f8 <end_op+0x57>
    do_commit = 1;
801034e5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801034ec:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
801034f3:	00 00 00 
801034f6:	eb 0c                	jmp    80103504 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801034f8:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034ff:	e8 26 18 00 00       	call   80104d2a <wakeup>
  }
  release(&log.lock);
80103504:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010350b:	e8 ff 1b 00 00       	call   8010510f <release>

  if(do_commit){
80103510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103514:	74 33                	je     80103549 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103516:	e8 de 00 00 00       	call   801035f9 <commit>
    acquire(&log.lock);
8010351b:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103522:	e8 86 1b 00 00       	call   801050ad <acquire>
    log.committing = 0;
80103527:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
8010352e:	00 00 00 
    wakeup(&log);
80103531:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103538:	e8 ed 17 00 00       	call   80104d2a <wakeup>
    release(&log.lock);
8010353d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103544:	e8 c6 1b 00 00       	call   8010510f <release>
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
8010355d:	8b 15 94 22 11 80    	mov    0x80112294,%edx
80103563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103566:	01 d0                	add    %edx,%eax
80103568:	83 c0 01             	add    $0x1,%eax
8010356b:	89 c2                	mov    %eax,%edx
8010356d:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103572:	89 54 24 04          	mov    %edx,0x4(%esp)
80103576:	89 04 24             	mov    %eax,(%esp)
80103579:	e8 28 cc ff ff       	call   801001a6 <bread>
8010357e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103584:	83 c0 10             	add    $0x10,%eax
80103587:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
8010358e:	89 c2                	mov    %eax,%edx
80103590:	a1 a4 22 11 80       	mov    0x801122a4,%eax
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
801035bf:	e8 0c 1e 00 00       	call   801053d0 <memmove>
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
801035e9:	a1 a8 22 11 80       	mov    0x801122a8,%eax
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
801035ff:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103604:	85 c0                	test   %eax,%eax
80103606:	7e 1e                	jle    80103626 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103608:	e8 3e ff ff ff       	call   8010354b <write_log>
    write_head();    // Write header to disk -- the real commit
8010360d:	e8 6f fd ff ff       	call   80103381 <write_head>
    install_trans(); // Now install writes to home locations
80103612:	e8 4d fc ff ff       	call   80103264 <install_trans>
    log.lh.n = 0; 
80103617:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
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
8010362e:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103633:	83 f8 1d             	cmp    $0x1d,%eax
80103636:	7f 12                	jg     8010364a <log_write+0x22>
80103638:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010363d:	8b 15 98 22 11 80    	mov    0x80112298,%edx
80103643:	83 ea 01             	sub    $0x1,%edx
80103646:	39 d0                	cmp    %edx,%eax
80103648:	7c 0c                	jl     80103656 <log_write+0x2e>
    panic("too big a transaction");
8010364a:	c7 04 24 1b 89 10 80 	movl   $0x8010891b,(%esp)
80103651:	e8 e4 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103656:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010365b:	85 c0                	test   %eax,%eax
8010365d:	7f 0c                	jg     8010366b <log_write+0x43>
    panic("log_write outside of trans");
8010365f:	c7 04 24 31 89 10 80 	movl   $0x80108931,(%esp)
80103666:	e8 cf ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010366b:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103672:	e8 36 1a 00 00       	call   801050ad <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103677:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367e:	eb 1f                	jmp    8010369f <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103683:	83 c0 10             	add    $0x10,%eax
80103686:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
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
8010369f:	a1 a8 22 11 80       	mov    0x801122a8,%eax
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
801036b5:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
  if (i == log.lh.n)
801036bc:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036c1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036c4:	75 0d                	jne    801036d3 <log_write+0xab>
    log.lh.n++;
801036c6:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036cb:	83 c0 01             	add    $0x1,%eax
801036ce:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
801036d3:	8b 45 08             	mov    0x8(%ebp),%eax
801036d6:	8b 00                	mov    (%eax),%eax
801036d8:	83 c8 04             	or     $0x4,%eax
801036db:	89 c2                	mov    %eax,%edx
801036dd:	8b 45 08             	mov    0x8(%ebp),%eax
801036e0:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801036e2:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036e9:	e8 21 1a 00 00       	call   8010510f <release>
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
80103735:	c7 04 24 3c 85 11 80 	movl   $0x8011853c,(%esp)
8010373c:	e8 80 f2 ff ff       	call   801029c1 <kinit1>
  kvmalloc();      // kernel page table
80103741:	e8 08 48 00 00       	call   80107f4e <kvmalloc>
  mpinit();        // collect info about this machine
80103746:	e8 46 04 00 00       	call   80103b91 <mpinit>
  lapicinit();
8010374b:	e8 dc f5 ff ff       	call   80102d2c <lapicinit>
  seginit();       // set up segments
80103750:	e8 8c 41 00 00       	call   801078e1 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103755:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010375b:	0f b6 00             	movzbl (%eax),%eax
8010375e:	0f b6 c0             	movzbl %al,%eax
80103761:	89 44 24 04          	mov    %eax,0x4(%esp)
80103765:	c7 04 24 4c 89 10 80 	movl   $0x8010894c,(%esp)
8010376c:	e8 2f cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103771:	e8 79 06 00 00       	call   80103def <picinit>
  ioapicinit();    // another interrupt controller
80103776:	e8 3c f1 ff ff       	call   801028b7 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010377b:	e8 01 d3 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103780:	e8 ab 34 00 00       	call   80106c30 <uartinit>
  pinit();         // process table
80103785:	e8 a3 0b 00 00       	call   8010432d <pinit>
  tvinit();        // trap vectors
8010378a:	e8 53 30 00 00       	call   801067e2 <tvinit>
  binit();         // buffer cache
8010378f:	e8 a0 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103794:	e8 7e d7 ff ff       	call   80100f17 <fileinit>
  iinit();         // inode cache
80103799:	e8 13 de ff ff       	call   801015b1 <iinit>
  ideinit();       // disk
8010379e:	e8 7d ed ff ff       	call   80102520 <ideinit>
  if(!ismp)
801037a3:	a1 44 23 11 80       	mov    0x80112344,%eax
801037a8:	85 c0                	test   %eax,%eax
801037aa:	75 05                	jne    801037b1 <main+0x8d>
    timerinit();   // uniprocessor timer
801037ac:	e8 7c 2f 00 00       	call   8010672d <timerinit>
  startothers();   // start other processors
801037b1:	e8 7f 00 00 00       	call   80103835 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037b6:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037bd:	8e 
801037be:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037c5:	e8 2f f2 ff ff       	call   801029f9 <kinit2>
  userinit();      // first user process
801037ca:	e8 cd 0c 00 00       	call   8010449c <userinit>
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
801037da:	e8 86 47 00 00       	call   80107f65 <switchkvm>
  seginit();
801037df:	e8 fd 40 00 00       	call   801078e1 <seginit>
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
80103804:	c7 04 24 63 89 10 80 	movl   $0x80108963,(%esp)
8010380b:	e8 90 cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103810:	e8 41 31 00 00       	call   80106956 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103815:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010381b:	05 a8 00 00 00       	add    $0xa8,%eax
80103820:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103827:	00 
80103828:	89 04 24             	mov    %eax,(%esp)
8010382b:	e8 da fe ff ff       	call   8010370a <xchg>
  scheduler();     // start running processes
80103830:	e8 59 12 00 00       	call   80104a8e <scheduler>

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
80103854:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010385b:	80 
8010385c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010385f:	89 04 24             	mov    %eax,(%esp)
80103862:	e8 69 1b 00 00       	call   801053d0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103867:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
8010386e:	e9 85 00 00 00       	jmp    801038f8 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103873:	e8 0d f6 ff ff       	call   80102e85 <cpunum>
80103878:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010387e:	05 60 23 11 80       	add    $0x80112360,%eax
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
801038b5:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
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
801038f8:	a1 40 29 11 80       	mov    0x80112940,%eax
801038fd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103903:	05 60 23 11 80       	add    $0x80112360,%eax
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
80103962:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103967:	89 c2                	mov    %eax,%edx
80103969:	b8 60 23 11 80       	mov    $0x80112360,%eax
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
801039e4:	c7 44 24 04 74 89 10 	movl   $0x80108974,0x4(%esp)
801039eb:	80 
801039ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ef:	89 04 24             	mov    %eax,(%esp)
801039f2:	e8 81 19 00 00       	call   80105378 <memcmp>
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
80103b25:	c7 44 24 04 79 89 10 	movl   $0x80108979,0x4(%esp)
80103b2c:	80 
80103b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b30:	89 04 24             	mov    %eax,(%esp)
80103b33:	e8 40 18 00 00       	call   80105378 <memcmp>
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
80103b97:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103b9e:	23 11 80 
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
80103bba:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103bc1:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc7:	8b 40 24             	mov    0x24(%eax),%eax
80103bca:	a3 5c 22 11 80       	mov    %eax,0x8011225c
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
80103c01:	8b 04 85 bc 89 10 80 	mov    -0x7fef7644(,%eax,4),%eax
80103c08:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c13:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c17:	0f b6 d0             	movzbl %al,%edx
80103c1a:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c1f:	39 c2                	cmp    %eax,%edx
80103c21:	74 2d                	je     80103c50 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c26:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c2a:	0f b6 d0             	movzbl %al,%edx
80103c2d:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c32:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c36:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c3a:	c7 04 24 7e 89 10 80 	movl   $0x8010897e,(%esp)
80103c41:	e8 5a c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c46:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
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
80103c61:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c66:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c6c:	05 60 23 11 80       	add    $0x80112360,%eax
80103c71:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103c76:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103c7c:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c81:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103c87:	81 c2 60 23 11 80    	add    $0x80112360,%edx
80103c8d:	88 02                	mov    %al,(%edx)
      ncpu++;
80103c8f:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c94:	83 c0 01             	add    $0x1,%eax
80103c97:	a3 40 29 11 80       	mov    %eax,0x80112940
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
80103caf:	a2 40 23 11 80       	mov    %al,0x80112340
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
80103ccd:	c7 04 24 9c 89 10 80 	movl   $0x8010899c,(%esp)
80103cd4:	e8 c7 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103cd9:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
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
80103cef:	a1 44 23 11 80       	mov    0x80112344,%eax
80103cf4:	85 c0                	test   %eax,%eax
80103cf6:	75 1d                	jne    80103d15 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cf8:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103cff:	00 00 00 
    lapic = 0;
80103d02:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103d09:	00 00 00 
    ioapicid = 0;
80103d0c:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
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
80103d87:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
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
80103dd9:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
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
80103f0d:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f14:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f18:	74 12                	je     80103f2c <picinit+0x13d>
    picsetmask(irqmask);
80103f1a:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
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
80103fc6:	c7 44 24 04 d0 89 10 	movl   $0x801089d0,0x4(%esp)
80103fcd:	80 
80103fce:	89 04 24             	mov    %eax,(%esp)
80103fd1:	e8 b6 10 00 00       	call   8010508c <initlock>
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
8010407d:	e8 2b 10 00 00       	call   801050ad <acquire>
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
801040a0:	e8 85 0c 00 00       	call   80104d2a <wakeup>
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
801040bf:	e8 66 0c 00 00       	call   80104d2a <wakeup>
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
801040e4:	e8 26 10 00 00       	call   8010510f <release>
    kfree((char*)p);
801040e9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ec:	89 04 24             	mov    %eax,(%esp)
801040ef:	e8 62 e9 ff ff       	call   80102a56 <kfree>
801040f4:	eb 0b                	jmp    80104101 <pipeclose+0x90>
  } else
    release(&p->lock);
801040f6:	8b 45 08             	mov    0x8(%ebp),%eax
801040f9:	89 04 24             	mov    %eax,(%esp)
801040fc:	e8 0e 10 00 00       	call   8010510f <release>
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
8010410f:	e8 99 0f 00 00       	call   801050ad <acquire>
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
80104142:	e8 c8 0f 00 00       	call   8010510f <release>
        return -1;
80104147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010414c:	e9 9f 00 00 00       	jmp    801041f0 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104151:	8b 45 08             	mov    0x8(%ebp),%eax
80104154:	05 34 02 00 00       	add    $0x234,%eax
80104159:	89 04 24             	mov    %eax,(%esp)
8010415c:	e8 c9 0b 00 00       	call   80104d2a <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104161:	8b 45 08             	mov    0x8(%ebp),%eax
80104164:	8b 55 08             	mov    0x8(%ebp),%edx
80104167:	81 c2 38 02 00 00    	add    $0x238,%edx
8010416d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104171:	89 14 24             	mov    %edx,(%esp)
80104174:	e8 d6 0a 00 00       	call   80104c4f <sleep>
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
801041dd:	e8 48 0b 00 00       	call   80104d2a <wakeup>
  release(&p->lock);
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	89 04 24             	mov    %eax,(%esp)
801041e8:	e8 22 0f 00 00       	call   8010510f <release>
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
801041ff:	e8 a9 0e 00 00       	call   801050ad <acquire>
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
80104219:	e8 f1 0e 00 00       	call   8010510f <release>
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
8010423b:	e8 0f 0a 00 00       	call   80104c4f <sleep>
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
801042ca:	e8 5b 0a 00 00       	call   80104d2a <wakeup>
  release(&p->lock);
801042cf:	8b 45 08             	mov    0x8(%ebp),%eax
801042d2:	89 04 24             	mov    %eax,(%esp)
801042d5:	e8 35 0e 00 00       	call   8010510f <release>
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
        "movzx %%al, %1\n\t" 		// store result of comparison in 'result'
        : "+m" (*addr), "=r" (result)
        : "a" (expected), "b" (newval)
        : "cc");

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
80104333:	c7 44 24 04 d5 89 10 	movl   $0x801089d5,0x4(%esp)
8010433a:	80 
8010433b:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104342:	e8 45 0d 00 00       	call   8010508c <initlock>
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
8010434f:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104354:	89 45 fc             	mov    %eax,-0x4(%ebp)
  } while(!cas(&nextpid, pid, pid+1));
80104357:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010435a:	83 c0 01             	add    $0x1,%eax
8010435d:	89 44 24 08          	mov    %eax,0x8(%esp)
80104361:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104364:	89 44 24 04          	mov    %eax,0x4(%esp)
80104368:	c7 04 24 04 b0 10 80 	movl   $0x8010b004,(%esp)
8010436f:	e8 85 ff ff ff       	call   801042f9 <cas>
80104374:	85 c0                	test   %eax,%eax
80104376:	74 d7                	je     8010434f <allocpid+0x6>
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
80104386:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
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
801043d4:	81 45 f4 4c 01 00 00 	addl   $0x14c,-0xc(%ebp)
801043db:	81 7d f4 94 7c 11 80 	cmpl   $0x80117c94,-0xc(%ebp)
801043e2:	72 ab                	jb     8010438f <allocproc+0xf>
    //if(p->state == UNUSED)
    if(cas(&p->state, UNUSED, EMBRYO))
      goto found;
  //release(&ptable.lock);
  return 0;
801043e4:	b8 00 00 00 00       	mov    $0x0,%eax
801043e9:	e9 ac 00 00 00       	jmp    8010449a <allocproc+0x11a>

  p->pid = allocpid();

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043f8:	b8 00 00 00 00       	mov    $0x0,%eax
801043fd:	e9 98 00 00 00       	jmp    8010449a <allocproc+0x11a>
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

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104443:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010444d:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104450:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80104454:	ba 9d 67 10 80       	mov    $0x8010679d,%edx
80104459:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010445c:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010445e:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80104462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104465:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104468:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104471:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104478:	00 
80104479:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104480:	00 
80104481:	89 04 24             	mov    %eax,(%esp)
80104484:	e8 78 0e 00 00       	call   80105301 <memset>
  p->context->eip = (uint)forkret;
80104489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010448f:	ba 23 4c 10 80       	mov    $0x80104c23,%edx
80104494:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104497:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010449a:	c9                   	leave  
8010449b:	c3                   	ret    

8010449c <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010449c:	55                   	push   %ebp
8010449d:	89 e5                	mov    %esp,%ebp
8010449f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044a2:	e8 d9 fe ff ff       	call   80104380 <allocproc>
801044a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ad:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
801044b2:	e8 da 39 00 00       	call   80107e91 <setupkvm>
801044b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044ba:	89 42 04             	mov    %eax,0x4(%edx)
801044bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c0:	8b 40 04             	mov    0x4(%eax),%eax
801044c3:	85 c0                	test   %eax,%eax
801044c5:	75 0c                	jne    801044d3 <userinit+0x37>
    panic("userinit: out of memory?");
801044c7:	c7 04 24 dc 89 10 80 	movl   $0x801089dc,(%esp)
801044ce:	e8 67 c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044d3:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044db:	8b 40 04             	mov    0x4(%eax),%eax
801044de:	89 54 24 08          	mov    %edx,0x8(%esp)
801044e2:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044e9:	80 
801044ea:	89 04 24             	mov    %eax,(%esp)
801044ed:	e8 f7 3b 00 00       	call   801080e9 <inituvm>
  p->sz = PGSIZE;
801044f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fe:	8b 40 18             	mov    0x18(%eax),%eax
80104501:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104508:	00 
80104509:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104510:	00 
80104511:	89 04 24             	mov    %eax,(%esp)
80104514:	e8 e8 0d 00 00       	call   80105301 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451c:	8b 40 18             	mov    0x18(%eax),%eax
8010451f:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104528:	8b 40 18             	mov    0x18(%eax),%eax
8010452b:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104534:	8b 40 18             	mov    0x18(%eax),%eax
80104537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453a:	8b 52 18             	mov    0x18(%edx),%edx
8010453d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104541:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104548:	8b 40 18             	mov    0x18(%eax),%eax
8010454b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010454e:	8b 52 18             	mov    0x18(%edx),%edx
80104551:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104555:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455c:	8b 40 18             	mov    0x18(%eax),%eax
8010455f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104569:	8b 40 18             	mov    0x18(%eax),%eax
8010456c:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104576:	8b 40 18             	mov    0x18(%eax),%eax
80104579:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104583:	83 c0 6c             	add    $0x6c,%eax
80104586:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010458d:	00 
8010458e:	c7 44 24 04 f5 89 10 	movl   $0x801089f5,0x4(%esp)
80104595:	80 
80104596:	89 04 24             	mov    %eax,(%esp)
80104599:	e8 83 0f 00 00       	call   80105521 <safestrcpy>
  p->cwd = namei("/");
8010459e:	c7 04 24 fe 89 10 80 	movl   $0x801089fe,(%esp)
801045a5:	e8 69 de ff ff       	call   80102413 <namei>
801045aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ad:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801045b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045ba:	c9                   	leave  
801045bb:	c3                   	ret    

801045bc <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045bc:	55                   	push   %ebp
801045bd:	89 e5                	mov    %esp,%ebp
801045bf:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c8:	8b 00                	mov    (%eax),%eax
801045ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045d1:	7e 34                	jle    80104607 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045d3:	8b 55 08             	mov    0x8(%ebp),%edx
801045d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d9:	01 c2                	add    %eax,%edx
801045db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045e1:	8b 40 04             	mov    0x4(%eax),%eax
801045e4:	89 54 24 08          	mov    %edx,0x8(%esp)
801045e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801045ef:	89 04 24             	mov    %eax,(%esp)
801045f2:	e8 68 3c 00 00       	call   8010825f <allocuvm>
801045f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045fe:	75 41                	jne    80104641 <growproc+0x85>
      return -1;
80104600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104605:	eb 58                	jmp    8010465f <growproc+0xa3>
  } else if(n < 0){
80104607:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010460b:	79 34                	jns    80104641 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010460d:	8b 55 08             	mov    0x8(%ebp),%edx
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	01 c2                	add    %eax,%edx
80104615:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010461b:	8b 40 04             	mov    0x4(%eax),%eax
8010461e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104622:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104625:	89 54 24 04          	mov    %edx,0x4(%esp)
80104629:	89 04 24             	mov    %eax,(%esp)
8010462c:	e8 08 3d 00 00       	call   80108339 <deallocuvm>
80104631:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104634:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104638:	75 07                	jne    80104641 <growproc+0x85>
      return -1;
8010463a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010463f:	eb 1e                	jmp    8010465f <growproc+0xa3>
  }
  proc->sz = sz;
80104641:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104647:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464a:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010464c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104652:	89 04 24             	mov    %eax,(%esp)
80104655:	e8 28 39 00 00       	call   80107f82 <switchuvm>
  return 0;
8010465a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010465f:	c9                   	leave  
80104660:	c3                   	ret    

80104661 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104661:	55                   	push   %ebp
80104662:	89 e5                	mov    %esp,%ebp
80104664:	57                   	push   %edi
80104665:	56                   	push   %esi
80104666:	53                   	push   %ebx
80104667:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010466a:	e8 11 fd ff ff       	call   80104380 <allocproc>
8010466f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104672:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104676:	75 0a                	jne    80104682 <fork+0x21>
    return -1;
80104678:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010467d:	e9 61 01 00 00       	jmp    801047e3 <fork+0x182>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104682:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104688:	8b 10                	mov    (%eax),%edx
8010468a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104690:	8b 40 04             	mov    0x4(%eax),%eax
80104693:	89 54 24 04          	mov    %edx,0x4(%esp)
80104697:	89 04 24             	mov    %eax,(%esp)
8010469a:	e8 36 3e 00 00       	call   801084d5 <copyuvm>
8010469f:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046a2:	89 42 04             	mov    %eax,0x4(%edx)
801046a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a8:	8b 40 04             	mov    0x4(%eax),%eax
801046ab:	85 c0                	test   %eax,%eax
801046ad:	75 2c                	jne    801046db <fork+0x7a>
    kfree(np->kstack);
801046af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b2:	8b 40 08             	mov    0x8(%eax),%eax
801046b5:	89 04 24             	mov    %eax,(%esp)
801046b8:	e8 99 e3 ff ff       	call   80102a56 <kfree>
    np->kstack = 0;
801046bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ca:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d6:	e9 08 01 00 00       	jmp    801047e3 <fork+0x182>
  }
  np->sz = proc->sz;
801046db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e1:	8b 10                	mov    (%eax),%edx
801046e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e6:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046e8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f2:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f8:	8b 50 18             	mov    0x18(%eax),%edx
801046fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104701:	8b 40 18             	mov    0x18(%eax),%eax
80104704:	89 c3                	mov    %eax,%ebx
80104706:	b8 13 00 00 00       	mov    $0x13,%eax
8010470b:	89 d7                	mov    %edx,%edi
8010470d:	89 de                	mov    %ebx,%esi
8010470f:	89 c1                	mov    %eax,%ecx
80104711:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104713:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104716:	8b 40 18             	mov    0x18(%eax),%eax
80104719:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104720:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104727:	eb 3d                	jmp    80104766 <fork+0x105>
    if(proc->ofile[i])
80104729:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104732:	83 c2 08             	add    $0x8,%edx
80104735:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104739:	85 c0                	test   %eax,%eax
8010473b:	74 25                	je     80104762 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010473d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104743:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104746:	83 c2 08             	add    $0x8,%edx
80104749:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010474d:	89 04 24             	mov    %eax,(%esp)
80104750:	e8 3e c8 ff ff       	call   80100f93 <filedup>
80104755:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104758:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010475b:	83 c1 08             	add    $0x8,%ecx
8010475e:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104762:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104766:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010476a:	7e bd                	jle    80104729 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010476c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104772:	8b 40 68             	mov    0x68(%eax),%eax
80104775:	89 04 24             	mov    %eax,(%esp)
80104778:	e8 b9 d0 ff ff       	call   80101836 <idup>
8010477d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104780:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104783:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104789:	8d 50 6c             	lea    0x6c(%eax),%edx
8010478c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478f:	83 c0 6c             	add    $0x6c,%eax
80104792:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104799:	00 
8010479a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010479e:	89 04 24             	mov    %eax,(%esp)
801047a1:	e8 7b 0d 00 00       	call   80105521 <safestrcpy>
  np->sighandler = proc->sighandler; 
801047a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ac:	8b 50 7c             	mov    0x7c(%eax),%edx
801047af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b2:	89 50 7c             	mov    %edx,0x7c(%eax)
  //copy signal handler

  pid = np->pid;
801047b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b8:	8b 40 10             	mov    0x10(%eax),%eax
801047bb:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801047be:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047c5:	e8 e3 08 00 00       	call   801050ad <acquire>
  np->state = RUNNABLE;
801047ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047d4:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047db:	e8 2f 09 00 00       	call   8010510f <release>
  
  return pid;
801047e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047e3:	83 c4 2c             	add    $0x2c,%esp
801047e6:	5b                   	pop    %ebx
801047e7:	5e                   	pop    %esi
801047e8:	5f                   	pop    %edi
801047e9:	5d                   	pop    %ebp
801047ea:	c3                   	ret    

801047eb <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047eb:	55                   	push   %ebp
801047ec:	89 e5                	mov    %esp,%ebp
801047ee:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047f1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047f8:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047fd:	39 c2                	cmp    %eax,%edx
801047ff:	75 0c                	jne    8010480d <exit+0x22>
    panic("init exiting");
80104801:	c7 04 24 00 8a 10 80 	movl   $0x80108a00,(%esp)
80104808:	e8 2d bd ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010480d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104814:	eb 44                	jmp    8010485a <exit+0x6f>
    if(proc->ofile[fd]){
80104816:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010481f:	83 c2 08             	add    $0x8,%edx
80104822:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104826:	85 c0                	test   %eax,%eax
80104828:	74 2c                	je     80104856 <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010482a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104830:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104833:	83 c2 08             	add    $0x8,%edx
80104836:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010483a:	89 04 24             	mov    %eax,(%esp)
8010483d:	e8 99 c7 ff ff       	call   80100fdb <fileclose>
      proc->ofile[fd] = 0;
80104842:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104848:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010484b:	83 c2 08             	add    $0x8,%edx
8010484e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104855:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104856:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010485a:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010485e:	7e b6                	jle    80104816 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104860:	e8 b8 eb ff ff       	call   8010341d <begin_op>
  iput(proc->cwd);
80104865:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486b:	8b 40 68             	mov    0x68(%eax),%eax
8010486e:	89 04 24             	mov    %eax,(%esp)
80104871:	e8 a5 d1 ff ff       	call   80101a1b <iput>
  end_op();
80104876:	e8 26 ec ff ff       	call   801034a1 <end_op>
  proc->cwd = 0;
8010487b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104881:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104888:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
8010488f:	e8 19 08 00 00       	call   801050ad <acquire>

  proc->state = ZOMBIE;
80104894:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801048a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a7:	8b 40 14             	mov    0x14(%eax),%eax
801048aa:	89 04 24             	mov    %eax,(%esp)
801048ad:	e8 2b 04 00 00       	call   80104cdd <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048b2:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801048b9:	eb 3b                	jmp    801048f6 <exit+0x10b>
    if(p->parent == proc){
801048bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048be:	8b 50 14             	mov    0x14(%eax),%edx
801048c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c7:	39 c2                	cmp    %eax,%edx
801048c9:	75 24                	jne    801048ef <exit+0x104>
      p->parent = initproc;
801048cb:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801048d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048da:	8b 40 0c             	mov    0xc(%eax),%eax
801048dd:	83 f8 05             	cmp    $0x5,%eax
801048e0:	75 0d                	jne    801048ef <exit+0x104>
        wakeup1(initproc);
801048e2:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048e7:	89 04 24             	mov    %eax,(%esp)
801048ea:	e8 ee 03 00 00       	call   80104cdd <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048ef:	81 45 f4 4c 01 00 00 	addl   $0x14c,-0xc(%ebp)
801048f6:	81 7d f4 94 7c 11 80 	cmpl   $0x80117c94,-0xc(%ebp)
801048fd:	72 bc                	jb     801048bb <exit+0xd0>
    }
  }

  // Jump into the scheduler, never to return.
  
  sched();
801048ff:	e8 3b 02 00 00       	call   80104b3f <sched>
  panic("zombie exit");
80104904:	c7 04 24 0d 8a 10 80 	movl   $0x80108a0d,(%esp)
8010490b:	e8 2a bc ff ff       	call   8010053a <panic>

80104910 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104910:	55                   	push   %ebp
80104911:	89 e5                	mov    %esp,%ebp
80104913:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104916:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
8010491d:	e8 8b 07 00 00       	call   801050ad <acquire>
  for(;;){
    proc->chan = (int)proc;
80104922:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104928:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010492f:	89 50 20             	mov    %edx,0x20(%eax)
    proc->state = SLEEPING;    
80104932:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104938:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
    // Scan through table looking for zombie children.
    havekids = 0;
8010493f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104946:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
8010494d:	e9 84 00 00 00       	jmp    801049d6 <wait+0xc6>
      if(p->parent != proc)
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	8b 50 14             	mov    0x14(%eax),%edx
80104958:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010495e:	39 c2                	cmp    %eax,%edx
80104960:	74 02                	je     80104964 <wait+0x54>
        continue;
80104962:	eb 6b                	jmp    801049cf <wait+0xbf>
      havekids = 1;
80104964:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010496b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496e:	8b 40 0c             	mov    0xc(%eax),%eax
80104971:	83 f8 05             	cmp    $0x5,%eax
80104974:	75 59                	jne    801049cf <wait+0xbf>
        // Found one.
        pid = p->pid;
80104976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104979:	8b 40 10             	mov    0x10(%eax),%eax
8010497c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        p->state = UNUSED;
8010497f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104982:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104996:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010499d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a0:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)

        proc->chan = 0;
801049a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049aa:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
        proc->state = RUNNING;
801049b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b7:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        release(&ptable.lock);
801049be:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049c5:	e8 45 07 00 00       	call   8010510f <release>
        return pid;
801049ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049cd:	eb 5e                	jmp    80104a2d <wait+0x11d>
  for(;;){
    proc->chan = (int)proc;
    proc->state = SLEEPING;    
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049cf:	81 45 f4 4c 01 00 00 	addl   $0x14c,-0xc(%ebp)
801049d6:	81 7d f4 94 7c 11 80 	cmpl   $0x80117c94,-0xc(%ebp)
801049dd:	0f 82 6f ff ff ff    	jb     80104952 <wait+0x42>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049e7:	74 0d                	je     801049f6 <wait+0xe6>
801049e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ef:	8b 40 24             	mov    0x24(%eax),%eax
801049f2:	85 c0                	test   %eax,%eax
801049f4:	74 2d                	je     80104a23 <wait+0x113>
      proc->chan = 0;
801049f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fc:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      proc->state = RUNNING;      
80104a03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a09:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      release(&ptable.lock);
80104a10:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a17:	e8 f3 06 00 00       	call   8010510f <release>
      return -1;
80104a1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a21:	eb 0a                	jmp    80104a2d <wait+0x11d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sched();
80104a23:	e8 17 01 00 00       	call   80104b3f <sched>
  }
80104a28:	e9 f5 fe ff ff       	jmp    80104922 <wait+0x12>
}
80104a2d:	c9                   	leave  
80104a2e:	c3                   	ret    

80104a2f <freeproc>:

void 
freeproc(struct proc *p)
{
80104a2f:	55                   	push   %ebp
80104a30:	89 e5                	mov    %esp,%ebp
80104a32:	83 ec 18             	sub    $0x18,%esp
  if (!p || p->state != ZOMBIE)
80104a35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a39:	74 0b                	je     80104a46 <freeproc+0x17>
80104a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3e:	8b 40 0c             	mov    0xc(%eax),%eax
80104a41:	83 f8 05             	cmp    $0x5,%eax
80104a44:	74 0c                	je     80104a52 <freeproc+0x23>
    panic("freeproc not zombie");
80104a46:	c7 04 24 19 8a 10 80 	movl   $0x80108a19,(%esp)
80104a4d:	e8 e8 ba ff ff       	call   8010053a <panic>
  kfree(p->kstack);
80104a52:	8b 45 08             	mov    0x8(%ebp),%eax
80104a55:	8b 40 08             	mov    0x8(%eax),%eax
80104a58:	89 04 24             	mov    %eax,(%esp)
80104a5b:	e8 f6 df ff ff       	call   80102a56 <kfree>
  p->kstack = 0;
80104a60:	8b 45 08             	mov    0x8(%ebp),%eax
80104a63:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  freevm(p->pgdir);
80104a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a6d:	8b 40 04             	mov    0x4(%eax),%eax
80104a70:	89 04 24             	mov    %eax,(%esp)
80104a73:	e8 7d 39 00 00       	call   801083f5 <freevm>
  p->killed = 0;
80104a78:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7b:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
  p->chan = 0;
80104a82:	8b 45 08             	mov    0x8(%ebp),%eax
80104a85:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
}
80104a8c:	c9                   	leave  
80104a8d:	c3                   	ret    

80104a8e <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a8e:	55                   	push   %ebp
80104a8f:	89 e5                	mov    %esp,%ebp
80104a91:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a94:	e8 5a f8 ff ff       	call   801042f3 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a99:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104aa0:	e8 08 06 00 00       	call   801050ad <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aa5:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104aac:	eb 77                	jmp    80104b25 <scheduler+0x97>
      if(p->state != RUNNABLE)
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ab4:	83 f8 03             	cmp    $0x3,%eax
80104ab7:	74 02                	je     80104abb <scheduler+0x2d>
        continue;
80104ab9:	eb 63                	jmp    80104b1e <scheduler+0x90>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abe:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac7:	89 04 24             	mov    %eax,(%esp)
80104aca:	e8 b3 34 00 00       	call   80107f82 <switchuvm>
      p->state = RUNNING;
80104acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad2:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104ad9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104adf:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ae2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ae9:	83 c2 04             	add    $0x4,%edx
80104aec:	89 44 24 04          	mov    %eax,0x4(%esp)
80104af0:	89 14 24             	mov    %edx,(%esp)
80104af3:	e8 9a 0a 00 00       	call   80105592 <swtch>
      switchkvm();
80104af8:	e8 68 34 00 00       	call   80107f65 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104afd:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104b04:	00 00 00 00 
      if (p->state == ZOMBIE)
80104b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0b:	8b 40 0c             	mov    0xc(%eax),%eax
80104b0e:	83 f8 05             	cmp    $0x5,%eax
80104b11:	75 0b                	jne    80104b1e <scheduler+0x90>
        freeproc(p);
80104b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b16:	89 04 24             	mov    %eax,(%esp)
80104b19:	e8 11 ff ff ff       	call   80104a2f <freeproc>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b1e:	81 45 f4 4c 01 00 00 	addl   $0x14c,-0xc(%ebp)
80104b25:	81 7d f4 94 7c 11 80 	cmpl   $0x80117c94,-0xc(%ebp)
80104b2c:	72 80                	jb     80104aae <scheduler+0x20>
      // It should have changed its p->state before coming back.
      proc = 0;
      if (p->state == ZOMBIE)
        freeproc(p);
    }
    release(&ptable.lock);
80104b2e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b35:	e8 d5 05 00 00       	call   8010510f <release>

  }
80104b3a:	e9 55 ff ff ff       	jmp    80104a94 <scheduler+0x6>

80104b3f <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104b3f:	55                   	push   %ebp
80104b40:	89 e5                	mov    %esp,%ebp
80104b42:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104b45:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b4c:	e8 86 06 00 00       	call   801051d7 <holding>
80104b51:	85 c0                	test   %eax,%eax
80104b53:	75 0c                	jne    80104b61 <sched+0x22>
    panic("sched ptable.lock");
80104b55:	c7 04 24 2d 8a 10 80 	movl   $0x80108a2d,(%esp)
80104b5c:	e8 d9 b9 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104b61:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b67:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104b6d:	83 f8 01             	cmp    $0x1,%eax
80104b70:	74 0c                	je     80104b7e <sched+0x3f>
    panic("sched locks");
80104b72:	c7 04 24 3f 8a 10 80 	movl   $0x80108a3f,(%esp)
80104b79:	e8 bc b9 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104b7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b84:	8b 40 0c             	mov    0xc(%eax),%eax
80104b87:	83 f8 04             	cmp    $0x4,%eax
80104b8a:	75 0c                	jne    80104b98 <sched+0x59>
    panic("sched running");
80104b8c:	c7 04 24 4b 8a 10 80 	movl   $0x80108a4b,(%esp)
80104b93:	e8 a2 b9 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104b98:	e8 46 f7 ff ff       	call   801042e3 <readeflags>
80104b9d:	25 00 02 00 00       	and    $0x200,%eax
80104ba2:	85 c0                	test   %eax,%eax
80104ba4:	74 0c                	je     80104bb2 <sched+0x73>
    panic("sched interruptible");
80104ba6:	c7 04 24 59 8a 10 80 	movl   $0x80108a59,(%esp)
80104bad:	e8 88 b9 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104bb2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bb8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104bbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104bc1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bc7:	8b 40 04             	mov    0x4(%eax),%eax
80104bca:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bd1:	83 c2 1c             	add    $0x1c,%edx
80104bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bd8:	89 14 24             	mov    %edx,(%esp)
80104bdb:	e8 b2 09 00 00       	call   80105592 <swtch>
  cpu->intena = intena;
80104be0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104be9:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104bef:	c9                   	leave  
80104bf0:	c3                   	ret    

80104bf1 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104bf1:	55                   	push   %ebp
80104bf2:	89 e5                	mov    %esp,%ebp
80104bf4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104bf7:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104bfe:	e8 aa 04 00 00       	call   801050ad <acquire>
  proc->state = RUNNABLE;
80104c03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c09:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104c10:	e8 2a ff ff ff       	call   80104b3f <sched>
  release(&ptable.lock);
80104c15:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c1c:	e8 ee 04 00 00       	call   8010510f <release>
}
80104c21:	c9                   	leave  
80104c22:	c3                   	ret    

80104c23 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104c23:	55                   	push   %ebp
80104c24:	89 e5                	mov    %esp,%ebp
80104c26:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104c29:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c30:	e8 da 04 00 00       	call   8010510f <release>

  if (first) {
80104c35:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104c3a:	85 c0                	test   %eax,%eax
80104c3c:	74 0f                	je     80104c4d <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104c3e:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104c45:	00 00 00 
    initlog();
80104c48:	e8 c2 e5 ff ff       	call   8010320f <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104c4d:	c9                   	leave  
80104c4e:	c3                   	ret    

80104c4f <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c4f:	55                   	push   %ebp
80104c50:	89 e5                	mov    %esp,%ebp
80104c52:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104c55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c5b:	85 c0                	test   %eax,%eax
80104c5d:	75 0c                	jne    80104c6b <sleep+0x1c>
    panic("sleep");
80104c5f:	c7 04 24 6d 8a 10 80 	movl   $0x80108a6d,(%esp)
80104c66:	e8 cf b8 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104c6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c6f:	75 0c                	jne    80104c7d <sleep+0x2e>
    panic("sleep without lk");
80104c71:	c7 04 24 73 8a 10 80 	movl   $0x80108a73,(%esp)
80104c78:	e8 bd b8 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c7d:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104c84:	74 17                	je     80104c9d <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c86:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c8d:	e8 1b 04 00 00       	call   801050ad <acquire>
    release(lk);
80104c92:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c95:	89 04 24             	mov    %eax,(%esp)
80104c98:	e8 72 04 00 00       	call   8010510f <release>
  }

  // Go to sleep.
  proc->chan = (int)chan;
80104c9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ca3:	8b 55 08             	mov    0x8(%ebp),%edx
80104ca6:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104ca9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104caf:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)


  sched();
80104cb6:	e8 84 fe ff ff       	call   80104b3f <sched>

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104cbb:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104cc2:	74 17                	je     80104cdb <sleep+0x8c>
    release(&ptable.lock);
80104cc4:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ccb:	e8 3f 04 00 00       	call   8010510f <release>
    acquire(lk);
80104cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cd3:	89 04 24             	mov    %eax,(%esp)
80104cd6:	e8 d2 03 00 00       	call   801050ad <acquire>
  }
}
80104cdb:	c9                   	leave  
80104cdc:	c3                   	ret    

80104cdd <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cdd:	55                   	push   %ebp
80104cde:	89 e5                	mov    %esp,%ebp
80104ce0:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ce3:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104cea:	eb 33                	jmp    80104d1f <wakeup1+0x42>
    if(p->state == SLEEPING && p->chan == (int)chan){
80104cec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cef:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf2:	83 f8 02             	cmp    $0x2,%eax
80104cf5:	75 21                	jne    80104d18 <wakeup1+0x3b>
80104cf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cfa:	8b 50 20             	mov    0x20(%eax),%edx
80104cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80104d00:	39 c2                	cmp    %eax,%edx
80104d02:	75 14                	jne    80104d18 <wakeup1+0x3b>
      // Tidy up.
      p->chan = 0;
80104d04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d07:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      p->state = RUNNABLE;
80104d0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d11:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d18:	81 45 fc 4c 01 00 00 	addl   $0x14c,-0x4(%ebp)
80104d1f:	81 7d fc 94 7c 11 80 	cmpl   $0x80117c94,-0x4(%ebp)
80104d26:	72 c4                	jb     80104cec <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == (int)chan){
      // Tidy up.
      p->chan = 0;
      p->state = RUNNABLE;
    }
}
80104d28:	c9                   	leave  
80104d29:	c3                   	ret    

80104d2a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d2a:	55                   	push   %ebp
80104d2b:	89 e5                	mov    %esp,%ebp
80104d2d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104d30:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d37:	e8 71 03 00 00       	call   801050ad <acquire>
  wakeup1(chan);
80104d3c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3f:	89 04 24             	mov    %eax,(%esp)
80104d42:	e8 96 ff ff ff       	call   80104cdd <wakeup1>
  release(&ptable.lock);
80104d47:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d4e:	e8 bc 03 00 00       	call   8010510f <release>
}
80104d53:	c9                   	leave  
80104d54:	c3                   	ret    

80104d55 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d55:	55                   	push   %ebp
80104d56:	89 e5                	mov    %esp,%ebp
80104d58:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d5b:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d62:	e8 46 03 00 00       	call   801050ad <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d67:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104d6e:	eb 50                	jmp    80104dc0 <kill+0x6b>
    if(p->pid == pid){
80104d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d73:	8b 40 10             	mov    0x10(%eax),%eax
80104d76:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d79:	75 32                	jne    80104dad <kill+0x58>
      p->killed = 1;
80104d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d88:	8b 40 0c             	mov    0xc(%eax),%eax
80104d8b:	83 f8 02             	cmp    $0x2,%eax
80104d8e:	75 0a                	jne    80104d9a <kill+0x45>
        p->state = RUNNABLE;
80104d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d93:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      
      release(&ptable.lock);
80104d9a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104da1:	e8 69 03 00 00       	call   8010510f <release>
      return 0;
80104da6:	b8 00 00 00 00       	mov    $0x0,%eax
80104dab:	eb 21                	jmp    80104dce <kill+0x79>

      //int pid_test = p->pid;
      //cas(&pid_test, pid_test, 1);
      //cprintf("res = %d,    pid = %d", res, pid_test);
  
    release(&ptable.lock);
80104dad:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104db4:	e8 56 03 00 00       	call   8010510f <release>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104db9:	81 45 f4 4c 01 00 00 	addl   $0x14c,-0xc(%ebp)
80104dc0:	81 7d f4 94 7c 11 80 	cmpl   $0x80117c94,-0xc(%ebp)
80104dc7:	72 a7                	jb     80104d70 <kill+0x1b>
      //cprintf("res = %d,    pid = %d", res, pid_test);
  
    release(&ptable.lock);
  }

  return -1;
80104dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dce:	c9                   	leave  
80104dcf:	c3                   	ret    

80104dd0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104dd0:	55                   	push   %ebp
80104dd1:	89 e5                	mov    %esp,%ebp
80104dd3:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dd6:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104ddd:	e9 e3 00 00 00       	jmp    80104ec5 <procdump+0xf5>
    if(p->state == UNUSED)
80104de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104de5:	8b 40 0c             	mov    0xc(%eax),%eax
80104de8:	85 c0                	test   %eax,%eax
80104dea:	75 05                	jne    80104df1 <procdump+0x21>
      continue;
80104dec:	e9 cd 00 00 00       	jmp    80104ebe <procdump+0xee>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104df4:	8b 40 0c             	mov    0xc(%eax),%eax
80104df7:	85 c0                	test   %eax,%eax
80104df9:	78 2e                	js     80104e29 <procdump+0x59>
80104dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dfe:	8b 40 0c             	mov    0xc(%eax),%eax
80104e01:	83 f8 05             	cmp    $0x5,%eax
80104e04:	77 23                	ja     80104e29 <procdump+0x59>
80104e06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e09:	8b 40 0c             	mov    0xc(%eax),%eax
80104e0c:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104e13:	85 c0                	test   %eax,%eax
80104e15:	74 12                	je     80104e29 <procdump+0x59>
      state = states[p->state];
80104e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e1a:	8b 40 0c             	mov    0xc(%eax),%eax
80104e1d:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104e24:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e27:	eb 07                	jmp    80104e30 <procdump+0x60>
    else
      state = "???";
80104e29:	c7 45 ec 84 8a 10 80 	movl   $0x80108a84,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e33:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e39:	8b 40 10             	mov    0x10(%eax),%eax
80104e3c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104e40:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104e43:	89 54 24 08          	mov    %edx,0x8(%esp)
80104e47:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e4b:	c7 04 24 88 8a 10 80 	movl   $0x80108a88,(%esp)
80104e52:	e8 49 b5 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e5a:	8b 40 0c             	mov    0xc(%eax),%eax
80104e5d:	83 f8 02             	cmp    $0x2,%eax
80104e60:	75 50                	jne    80104eb2 <procdump+0xe2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e65:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e68:	8b 40 0c             	mov    0xc(%eax),%eax
80104e6b:	83 c0 08             	add    $0x8,%eax
80104e6e:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104e71:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e75:	89 04 24             	mov    %eax,(%esp)
80104e78:	e8 e1 02 00 00       	call   8010515e <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104e7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e84:	eb 1b                	jmp    80104ea1 <procdump+0xd1>
        cprintf(" %p", pc[i]);
80104e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e89:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e91:	c7 04 24 91 8a 10 80 	movl   $0x80108a91,(%esp)
80104e98:	e8 03 b5 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ea1:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ea5:	7f 0b                	jg     80104eb2 <procdump+0xe2>
80104ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eaa:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104eae:	85 c0                	test   %eax,%eax
80104eb0:	75 d4                	jne    80104e86 <procdump+0xb6>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104eb2:	c7 04 24 95 8a 10 80 	movl   $0x80108a95,(%esp)
80104eb9:	e8 e2 b4 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ebe:	81 45 f0 4c 01 00 00 	addl   $0x14c,-0x10(%ebp)
80104ec5:	81 7d f0 94 7c 11 80 	cmpl   $0x80117c94,-0x10(%ebp)
80104ecc:	0f 82 10 ff ff ff    	jb     80104de2 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104ed2:	c9                   	leave  
80104ed3:	c3                   	ret    

80104ed4 <sigset>:

void* 
sigset(void* new_handler)
{
80104ed4:	55                   	push   %ebp
80104ed5:	89 e5                	mov    %esp,%ebp
80104ed7:	83 ec 10             	sub    $0x10,%esp
  sig_handler oldhandler = proc->sighandler; 
80104eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee0:	8b 40 7c             	mov    0x7c(%eax),%eax
80104ee3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  proc->sighandler = new_handler;
80104ee6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eec:	8b 55 08             	mov    0x8(%ebp),%edx
80104eef:	89 50 7c             	mov    %edx,0x7c(%eax)
  return oldhandler;
80104ef2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ef5:	c9                   	leave  
80104ef6:	c3                   	ret    

80104ef7 <sigsend>:

int
sigsend(int dest_pid, int value)
{
80104ef7:	55                   	push   %ebp
80104ef8:	89 e5                	mov    %esp,%ebp
80104efa:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104efd:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104f04:	eb 50                	jmp    80104f56 <sigsend+0x5f>
    if (p->pid == dest_pid) {
80104f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f09:	8b 40 10             	mov    0x10(%eax),%eax
80104f0c:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f0f:	75 3e                	jne    80104f4f <sigsend+0x58>
      //found dest_pid process
  
      if (push(&p->pending_signals, proc->pid, dest_pid, value)) //if push succeed return 0 otherwise return -1
80104f11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f17:	8b 40 10             	mov    0x10(%eax),%eax
80104f1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f1d:	8d 8a 80 00 00 00    	lea    0x80(%edx),%ecx
80104f23:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f26:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f2a:	8b 55 08             	mov    0x8(%ebp),%edx
80104f2d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f31:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f35:	89 0c 24             	mov    %ecx,(%esp)
80104f38:	e8 29 00 00 00       	call   80104f66 <push>
80104f3d:	85 c0                	test   %eax,%eax
80104f3f:	74 07                	je     80104f48 <sigsend+0x51>
        return 0;
80104f41:	b8 00 00 00 00       	mov    $0x0,%eax
80104f46:	eb 1c                	jmp    80104f64 <sigsend+0x6d>
      else
        return -1;
80104f48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f4d:	eb 15                	jmp    80104f64 <sigsend+0x6d>
int
sigsend(int dest_pid, int value)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104f4f:	81 45 f4 4c 01 00 00 	addl   $0x14c,-0xc(%ebp)
80104f56:	81 7d f4 94 7c 11 80 	cmpl   $0x80117c94,-0xc(%ebp)
80104f5d:	72 a7                	jb     80104f06 <sigsend+0xf>
        return 0;
      else
        return -1;
    }
  }
  return -1;  
80104f5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f64:	c9                   	leave  
80104f65:	c3                   	ret    

80104f66 <push>:

// -------------- cstack implementation ------------
int 
push(struct cstack *cstack, int sender_pid, int recepient_pid, int value)
{
80104f66:	55                   	push   %ebp
80104f67:	89 e5                	mov    %esp,%ebp
80104f69:	83 ec 1c             	sub    $0x1c,%esp
  struct cstackframe *csf;
  for(csf = cstack->frames; csf < &cstack->frames[MAX_CSTACK_FRAMES]; csf++) {
80104f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f72:	eb 48                	jmp    80104fbc <push+0x56>
    if(cas(&csf->used, 0, 1)) 
80104f74:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f77:	83 c0 0c             	add    $0xc,%eax
80104f7a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80104f81:	00 
80104f82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104f89:	00 
80104f8a:	89 04 24             	mov    %eax,(%esp)
80104f8d:	e8 67 f3 ff ff       	call   801042f9 <cas>
80104f92:	85 c0                	test   %eax,%eax
80104f94:	74 1d                	je     80104fb3 <push+0x4d>
      goto found;
80104f96:	90                   	nop
  return 0;

  //found an unused signal
  found:
  // copy values
  csf->sender_pid = sender_pid;
80104f97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f9d:	89 10                	mov    %edx,(%eax)
  csf->recepient_pid = recepient_pid;
80104f9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fa2:	8b 55 10             	mov    0x10(%ebp),%edx
80104fa5:	89 50 04             	mov    %edx,0x4(%eax)
  csf->value = value;
80104fa8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fab:	8b 55 14             	mov    0x14(%ebp),%edx
80104fae:	89 50 08             	mov    %edx,0x8(%eax)
80104fb1:	eb 20                	jmp    80104fd3 <push+0x6d>
// -------------- cstack implementation ------------
int 
push(struct cstack *cstack, int sender_pid, int recepient_pid, int value)
{
  struct cstackframe *csf;
  for(csf = cstack->frames; csf < &cstack->frames[MAX_CSTACK_FRAMES]; csf++) {
80104fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb6:	83 c0 14             	add    $0x14,%eax
80104fb9:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbf:	8d 90 c8 00 00 00    	lea    0xc8(%eax),%edx
80104fc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fc8:	39 c2                	cmp    %eax,%edx
80104fca:	77 a8                	ja     80104f74 <push+0xe>
    if(cas(&csf->used, 0, 1)) 
      goto found;
  }

  //stack is full
  return 0;
80104fcc:	b8 00 00 00 00       	mov    $0x0,%eax
80104fd1:	eb 3a                	jmp    8010500d <push+0xa7>
  csf->sender_pid = sender_pid;
  csf->recepient_pid = recepient_pid;
  csf->value = value;
  
  do {
    csf->next = cstack->head;
80104fd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fd6:	8b 55 08             	mov    0x8(%ebp),%edx
80104fd9:	8b 92 c8 00 00 00    	mov    0xc8(%edx),%edx
80104fdf:	89 50 10             	mov    %edx,0x10(%eax)
  } while (!cas((int*)&(cstack->head), (int)csf->next, (int)&csf));
80104fe2:	8d 55 fc             	lea    -0x4(%ebp),%edx
80104fe5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fe8:	8b 40 10             	mov    0x10(%eax),%eax
80104feb:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fee:	81 c1 c8 00 00 00    	add    $0xc8,%ecx
80104ff4:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ffc:	89 0c 24             	mov    %ecx,(%esp)
80104fff:	e8 f5 f2 ff ff       	call   801042f9 <cas>
80105004:	85 c0                	test   %eax,%eax
80105006:	74 cb                	je     80104fd3 <push+0x6d>

  return 1;
80105008:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010500d:	c9                   	leave  
8010500e:	c3                   	ret    

8010500f <pop>:

struct cstackframe*
pop(struct cstack *cstack)
{
8010500f:	55                   	push   %ebp
80105010:	89 e5                	mov    %esp,%ebp
80105012:	83 ec 1c             	sub    $0x1c,%esp
  struct cstackframe *csf;
  struct cstackframe *next;
  
  do {
    csf = cstack->head;
80105015:	8b 45 08             	mov    0x8(%ebp),%eax
80105018:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
8010501e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (!csf)
80105021:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105025:	75 07                	jne    8010502e <pop+0x1f>
      return 0;
80105027:	b8 00 00 00 00       	mov    $0x0,%eax
8010502c:	eb 26                	jmp    80105054 <pop+0x45>
  } while (!cas((int*)&(cstack->head), (int)csf, (int)&next));
8010502e:	8d 55 f8             	lea    -0x8(%ebp),%edx
80105031:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105034:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105037:	81 c1 c8 00 00 00    	add    $0xc8,%ecx
8010503d:	89 54 24 08          	mov    %edx,0x8(%esp)
80105041:	89 44 24 04          	mov    %eax,0x4(%esp)
80105045:	89 0c 24             	mov    %ecx,(%esp)
80105048:	e8 ac f2 ff ff       	call   801042f9 <cas>
8010504d:	85 c0                	test   %eax,%eax
8010504f:	74 c4                	je     80105015 <pop+0x6>
  
  //csf->used = 0;
  return csf;
80105051:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105054:	c9                   	leave  
80105055:	c3                   	ret    

80105056 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105056:	55                   	push   %ebp
80105057:	89 e5                	mov    %esp,%ebp
80105059:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010505c:	9c                   	pushf  
8010505d:	58                   	pop    %eax
8010505e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105061:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105064:	c9                   	leave  
80105065:	c3                   	ret    

80105066 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105066:	55                   	push   %ebp
80105067:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105069:	fa                   	cli    
}
8010506a:	5d                   	pop    %ebp
8010506b:	c3                   	ret    

8010506c <sti>:

static inline void
sti(void)
{
8010506c:	55                   	push   %ebp
8010506d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010506f:	fb                   	sti    
}
80105070:	5d                   	pop    %ebp
80105071:	c3                   	ret    

80105072 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105072:	55                   	push   %ebp
80105073:	89 e5                	mov    %esp,%ebp
80105075:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105078:	8b 55 08             	mov    0x8(%ebp),%edx
8010507b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010507e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105081:	f0 87 02             	lock xchg %eax,(%edx)
80105084:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105087:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010508a:	c9                   	leave  
8010508b:	c3                   	ret    

8010508c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010508c:	55                   	push   %ebp
8010508d:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010508f:	8b 45 08             	mov    0x8(%ebp),%eax
80105092:	8b 55 0c             	mov    0xc(%ebp),%edx
80105095:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105098:	8b 45 08             	mov    0x8(%ebp),%eax
8010509b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050a1:	8b 45 08             	mov    0x8(%ebp),%eax
801050a4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050ab:	5d                   	pop    %ebp
801050ac:	c3                   	ret    

801050ad <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050ad:	55                   	push   %ebp
801050ae:	89 e5                	mov    %esp,%ebp
801050b0:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050b3:	e8 49 01 00 00       	call   80105201 <pushcli>
  if(holding(lk))
801050b8:	8b 45 08             	mov    0x8(%ebp),%eax
801050bb:	89 04 24             	mov    %eax,(%esp)
801050be:	e8 14 01 00 00       	call   801051d7 <holding>
801050c3:	85 c0                	test   %eax,%eax
801050c5:	74 0c                	je     801050d3 <acquire+0x26>
    panic("acquire");
801050c7:	c7 04 24 c1 8a 10 80 	movl   $0x80108ac1,(%esp)
801050ce:	e8 67 b4 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050d3:	90                   	nop
801050d4:	8b 45 08             	mov    0x8(%ebp),%eax
801050d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801050de:	00 
801050df:	89 04 24             	mov    %eax,(%esp)
801050e2:	e8 8b ff ff ff       	call   80105072 <xchg>
801050e7:	85 c0                	test   %eax,%eax
801050e9:	75 e9                	jne    801050d4 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050eb:	8b 45 08             	mov    0x8(%ebp),%eax
801050ee:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050f5:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801050f8:	8b 45 08             	mov    0x8(%ebp),%eax
801050fb:	83 c0 0c             	add    $0xc,%eax
801050fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105102:	8d 45 08             	lea    0x8(%ebp),%eax
80105105:	89 04 24             	mov    %eax,(%esp)
80105108:	e8 51 00 00 00       	call   8010515e <getcallerpcs>
}
8010510d:	c9                   	leave  
8010510e:	c3                   	ret    

8010510f <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010510f:	55                   	push   %ebp
80105110:	89 e5                	mov    %esp,%ebp
80105112:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105115:	8b 45 08             	mov    0x8(%ebp),%eax
80105118:	89 04 24             	mov    %eax,(%esp)
8010511b:	e8 b7 00 00 00       	call   801051d7 <holding>
80105120:	85 c0                	test   %eax,%eax
80105122:	75 0c                	jne    80105130 <release+0x21>
    panic("release");
80105124:	c7 04 24 c9 8a 10 80 	movl   $0x80108ac9,(%esp)
8010512b:	e8 0a b4 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80105130:	8b 45 08             	mov    0x8(%ebp),%eax
80105133:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010513a:	8b 45 08             	mov    0x8(%ebp),%eax
8010513d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105144:	8b 45 08             	mov    0x8(%ebp),%eax
80105147:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010514e:	00 
8010514f:	89 04 24             	mov    %eax,(%esp)
80105152:	e8 1b ff ff ff       	call   80105072 <xchg>

  popcli();
80105157:	e8 e9 00 00 00       	call   80105245 <popcli>
}
8010515c:	c9                   	leave  
8010515d:	c3                   	ret    

8010515e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010515e:	55                   	push   %ebp
8010515f:	89 e5                	mov    %esp,%ebp
80105161:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105164:	8b 45 08             	mov    0x8(%ebp),%eax
80105167:	83 e8 08             	sub    $0x8,%eax
8010516a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010516d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105174:	eb 38                	jmp    801051ae <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105176:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010517a:	74 38                	je     801051b4 <getcallerpcs+0x56>
8010517c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105183:	76 2f                	jbe    801051b4 <getcallerpcs+0x56>
80105185:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105189:	74 29                	je     801051b4 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010518b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010518e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105195:	8b 45 0c             	mov    0xc(%ebp),%eax
80105198:	01 c2                	add    %eax,%edx
8010519a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010519d:	8b 40 04             	mov    0x4(%eax),%eax
801051a0:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801051a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051a5:	8b 00                	mov    (%eax),%eax
801051a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801051aa:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051ae:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051b2:	7e c2                	jle    80105176 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051b4:	eb 19                	jmp    801051cf <getcallerpcs+0x71>
    pcs[i] = 0;
801051b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c3:	01 d0                	add    %edx,%eax
801051c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051cb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051cf:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051d3:	7e e1                	jle    801051b6 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801051d5:	c9                   	leave  
801051d6:	c3                   	ret    

801051d7 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051d7:	55                   	push   %ebp
801051d8:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051da:	8b 45 08             	mov    0x8(%ebp),%eax
801051dd:	8b 00                	mov    (%eax),%eax
801051df:	85 c0                	test   %eax,%eax
801051e1:	74 17                	je     801051fa <holding+0x23>
801051e3:	8b 45 08             	mov    0x8(%ebp),%eax
801051e6:	8b 50 08             	mov    0x8(%eax),%edx
801051e9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051ef:	39 c2                	cmp    %eax,%edx
801051f1:	75 07                	jne    801051fa <holding+0x23>
801051f3:	b8 01 00 00 00       	mov    $0x1,%eax
801051f8:	eb 05                	jmp    801051ff <holding+0x28>
801051fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051ff:	5d                   	pop    %ebp
80105200:	c3                   	ret    

80105201 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105201:	55                   	push   %ebp
80105202:	89 e5                	mov    %esp,%ebp
80105204:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105207:	e8 4a fe ff ff       	call   80105056 <readeflags>
8010520c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010520f:	e8 52 fe ff ff       	call   80105066 <cli>
  if(cpu->ncli++ == 0)
80105214:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010521b:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105221:	8d 48 01             	lea    0x1(%eax),%ecx
80105224:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010522a:	85 c0                	test   %eax,%eax
8010522c:	75 15                	jne    80105243 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010522e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105234:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105237:	81 e2 00 02 00 00    	and    $0x200,%edx
8010523d:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105243:	c9                   	leave  
80105244:	c3                   	ret    

80105245 <popcli>:

void
popcli(void)
{
80105245:	55                   	push   %ebp
80105246:	89 e5                	mov    %esp,%ebp
80105248:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010524b:	e8 06 fe ff ff       	call   80105056 <readeflags>
80105250:	25 00 02 00 00       	and    $0x200,%eax
80105255:	85 c0                	test   %eax,%eax
80105257:	74 0c                	je     80105265 <popcli+0x20>
    panic("popcli - interruptible");
80105259:	c7 04 24 d1 8a 10 80 	movl   $0x80108ad1,(%esp)
80105260:	e8 d5 b2 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105265:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010526b:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105271:	83 ea 01             	sub    $0x1,%edx
80105274:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010527a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105280:	85 c0                	test   %eax,%eax
80105282:	79 0c                	jns    80105290 <popcli+0x4b>
    panic("popcli");
80105284:	c7 04 24 e8 8a 10 80 	movl   $0x80108ae8,(%esp)
8010528b:	e8 aa b2 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105290:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105296:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010529c:	85 c0                	test   %eax,%eax
8010529e:	75 15                	jne    801052b5 <popcli+0x70>
801052a0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052a6:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052ac:	85 c0                	test   %eax,%eax
801052ae:	74 05                	je     801052b5 <popcli+0x70>
    sti();
801052b0:	e8 b7 fd ff ff       	call   8010506c <sti>
}
801052b5:	c9                   	leave  
801052b6:	c3                   	ret    

801052b7 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801052b7:	55                   	push   %ebp
801052b8:	89 e5                	mov    %esp,%ebp
801052ba:	57                   	push   %edi
801052bb:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052bf:	8b 55 10             	mov    0x10(%ebp),%edx
801052c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c5:	89 cb                	mov    %ecx,%ebx
801052c7:	89 df                	mov    %ebx,%edi
801052c9:	89 d1                	mov    %edx,%ecx
801052cb:	fc                   	cld    
801052cc:	f3 aa                	rep stos %al,%es:(%edi)
801052ce:	89 ca                	mov    %ecx,%edx
801052d0:	89 fb                	mov    %edi,%ebx
801052d2:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052d5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052d8:	5b                   	pop    %ebx
801052d9:	5f                   	pop    %edi
801052da:	5d                   	pop    %ebp
801052db:	c3                   	ret    

801052dc <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801052dc:	55                   	push   %ebp
801052dd:	89 e5                	mov    %esp,%ebp
801052df:	57                   	push   %edi
801052e0:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052e4:	8b 55 10             	mov    0x10(%ebp),%edx
801052e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ea:	89 cb                	mov    %ecx,%ebx
801052ec:	89 df                	mov    %ebx,%edi
801052ee:	89 d1                	mov    %edx,%ecx
801052f0:	fc                   	cld    
801052f1:	f3 ab                	rep stos %eax,%es:(%edi)
801052f3:	89 ca                	mov    %ecx,%edx
801052f5:	89 fb                	mov    %edi,%ebx
801052f7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052fa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052fd:	5b                   	pop    %ebx
801052fe:	5f                   	pop    %edi
801052ff:	5d                   	pop    %ebp
80105300:	c3                   	ret    

80105301 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105301:	55                   	push   %ebp
80105302:	89 e5                	mov    %esp,%ebp
80105304:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105307:	8b 45 08             	mov    0x8(%ebp),%eax
8010530a:	83 e0 03             	and    $0x3,%eax
8010530d:	85 c0                	test   %eax,%eax
8010530f:	75 49                	jne    8010535a <memset+0x59>
80105311:	8b 45 10             	mov    0x10(%ebp),%eax
80105314:	83 e0 03             	and    $0x3,%eax
80105317:	85 c0                	test   %eax,%eax
80105319:	75 3f                	jne    8010535a <memset+0x59>
    c &= 0xFF;
8010531b:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105322:	8b 45 10             	mov    0x10(%ebp),%eax
80105325:	c1 e8 02             	shr    $0x2,%eax
80105328:	89 c2                	mov    %eax,%edx
8010532a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532d:	c1 e0 18             	shl    $0x18,%eax
80105330:	89 c1                	mov    %eax,%ecx
80105332:	8b 45 0c             	mov    0xc(%ebp),%eax
80105335:	c1 e0 10             	shl    $0x10,%eax
80105338:	09 c1                	or     %eax,%ecx
8010533a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533d:	c1 e0 08             	shl    $0x8,%eax
80105340:	09 c8                	or     %ecx,%eax
80105342:	0b 45 0c             	or     0xc(%ebp),%eax
80105345:	89 54 24 08          	mov    %edx,0x8(%esp)
80105349:	89 44 24 04          	mov    %eax,0x4(%esp)
8010534d:	8b 45 08             	mov    0x8(%ebp),%eax
80105350:	89 04 24             	mov    %eax,(%esp)
80105353:	e8 84 ff ff ff       	call   801052dc <stosl>
80105358:	eb 19                	jmp    80105373 <memset+0x72>
  } else
    stosb(dst, c, n);
8010535a:	8b 45 10             	mov    0x10(%ebp),%eax
8010535d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105361:	8b 45 0c             	mov    0xc(%ebp),%eax
80105364:	89 44 24 04          	mov    %eax,0x4(%esp)
80105368:	8b 45 08             	mov    0x8(%ebp),%eax
8010536b:	89 04 24             	mov    %eax,(%esp)
8010536e:	e8 44 ff ff ff       	call   801052b7 <stosb>
  return dst;
80105373:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105376:	c9                   	leave  
80105377:	c3                   	ret    

80105378 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105378:	55                   	push   %ebp
80105379:	89 e5                	mov    %esp,%ebp
8010537b:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010537e:	8b 45 08             	mov    0x8(%ebp),%eax
80105381:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105384:	8b 45 0c             	mov    0xc(%ebp),%eax
80105387:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010538a:	eb 30                	jmp    801053bc <memcmp+0x44>
    if(*s1 != *s2)
8010538c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010538f:	0f b6 10             	movzbl (%eax),%edx
80105392:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105395:	0f b6 00             	movzbl (%eax),%eax
80105398:	38 c2                	cmp    %al,%dl
8010539a:	74 18                	je     801053b4 <memcmp+0x3c>
      return *s1 - *s2;
8010539c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539f:	0f b6 00             	movzbl (%eax),%eax
801053a2:	0f b6 d0             	movzbl %al,%edx
801053a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053a8:	0f b6 00             	movzbl (%eax),%eax
801053ab:	0f b6 c0             	movzbl %al,%eax
801053ae:	29 c2                	sub    %eax,%edx
801053b0:	89 d0                	mov    %edx,%eax
801053b2:	eb 1a                	jmp    801053ce <memcmp+0x56>
    s1++, s2++;
801053b4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053b8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801053bc:	8b 45 10             	mov    0x10(%ebp),%eax
801053bf:	8d 50 ff             	lea    -0x1(%eax),%edx
801053c2:	89 55 10             	mov    %edx,0x10(%ebp)
801053c5:	85 c0                	test   %eax,%eax
801053c7:	75 c3                	jne    8010538c <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801053c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053ce:	c9                   	leave  
801053cf:	c3                   	ret    

801053d0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053d0:	55                   	push   %ebp
801053d1:	89 e5                	mov    %esp,%ebp
801053d3:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053dc:	8b 45 08             	mov    0x8(%ebp),%eax
801053df:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053e8:	73 3d                	jae    80105427 <memmove+0x57>
801053ea:	8b 45 10             	mov    0x10(%ebp),%eax
801053ed:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053f0:	01 d0                	add    %edx,%eax
801053f2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053f5:	76 30                	jbe    80105427 <memmove+0x57>
    s += n;
801053f7:	8b 45 10             	mov    0x10(%ebp),%eax
801053fa:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053fd:	8b 45 10             	mov    0x10(%ebp),%eax
80105400:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105403:	eb 13                	jmp    80105418 <memmove+0x48>
      *--d = *--s;
80105405:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105409:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010540d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105410:	0f b6 10             	movzbl (%eax),%edx
80105413:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105416:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105418:	8b 45 10             	mov    0x10(%ebp),%eax
8010541b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010541e:	89 55 10             	mov    %edx,0x10(%ebp)
80105421:	85 c0                	test   %eax,%eax
80105423:	75 e0                	jne    80105405 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105425:	eb 26                	jmp    8010544d <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105427:	eb 17                	jmp    80105440 <memmove+0x70>
      *d++ = *s++;
80105429:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010542c:	8d 50 01             	lea    0x1(%eax),%edx
8010542f:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105432:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105435:	8d 4a 01             	lea    0x1(%edx),%ecx
80105438:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010543b:	0f b6 12             	movzbl (%edx),%edx
8010543e:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105440:	8b 45 10             	mov    0x10(%ebp),%eax
80105443:	8d 50 ff             	lea    -0x1(%eax),%edx
80105446:	89 55 10             	mov    %edx,0x10(%ebp)
80105449:	85 c0                	test   %eax,%eax
8010544b:	75 dc                	jne    80105429 <memmove+0x59>
      *d++ = *s++;

  return dst;
8010544d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105450:	c9                   	leave  
80105451:	c3                   	ret    

80105452 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105452:	55                   	push   %ebp
80105453:	89 e5                	mov    %esp,%ebp
80105455:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105458:	8b 45 10             	mov    0x10(%ebp),%eax
8010545b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010545f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105462:	89 44 24 04          	mov    %eax,0x4(%esp)
80105466:	8b 45 08             	mov    0x8(%ebp),%eax
80105469:	89 04 24             	mov    %eax,(%esp)
8010546c:	e8 5f ff ff ff       	call   801053d0 <memmove>
}
80105471:	c9                   	leave  
80105472:	c3                   	ret    

80105473 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105473:	55                   	push   %ebp
80105474:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105476:	eb 0c                	jmp    80105484 <strncmp+0x11>
    n--, p++, q++;
80105478:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010547c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105480:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105484:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105488:	74 1a                	je     801054a4 <strncmp+0x31>
8010548a:	8b 45 08             	mov    0x8(%ebp),%eax
8010548d:	0f b6 00             	movzbl (%eax),%eax
80105490:	84 c0                	test   %al,%al
80105492:	74 10                	je     801054a4 <strncmp+0x31>
80105494:	8b 45 08             	mov    0x8(%ebp),%eax
80105497:	0f b6 10             	movzbl (%eax),%edx
8010549a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010549d:	0f b6 00             	movzbl (%eax),%eax
801054a0:	38 c2                	cmp    %al,%dl
801054a2:	74 d4                	je     80105478 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801054a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054a8:	75 07                	jne    801054b1 <strncmp+0x3e>
    return 0;
801054aa:	b8 00 00 00 00       	mov    $0x0,%eax
801054af:	eb 16                	jmp    801054c7 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801054b1:	8b 45 08             	mov    0x8(%ebp),%eax
801054b4:	0f b6 00             	movzbl (%eax),%eax
801054b7:	0f b6 d0             	movzbl %al,%edx
801054ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801054bd:	0f b6 00             	movzbl (%eax),%eax
801054c0:	0f b6 c0             	movzbl %al,%eax
801054c3:	29 c2                	sub    %eax,%edx
801054c5:	89 d0                	mov    %edx,%eax
}
801054c7:	5d                   	pop    %ebp
801054c8:	c3                   	ret    

801054c9 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054c9:	55                   	push   %ebp
801054ca:	89 e5                	mov    %esp,%ebp
801054cc:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054cf:	8b 45 08             	mov    0x8(%ebp),%eax
801054d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054d5:	90                   	nop
801054d6:	8b 45 10             	mov    0x10(%ebp),%eax
801054d9:	8d 50 ff             	lea    -0x1(%eax),%edx
801054dc:	89 55 10             	mov    %edx,0x10(%ebp)
801054df:	85 c0                	test   %eax,%eax
801054e1:	7e 1e                	jle    80105501 <strncpy+0x38>
801054e3:	8b 45 08             	mov    0x8(%ebp),%eax
801054e6:	8d 50 01             	lea    0x1(%eax),%edx
801054e9:	89 55 08             	mov    %edx,0x8(%ebp)
801054ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801054ef:	8d 4a 01             	lea    0x1(%edx),%ecx
801054f2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801054f5:	0f b6 12             	movzbl (%edx),%edx
801054f8:	88 10                	mov    %dl,(%eax)
801054fa:	0f b6 00             	movzbl (%eax),%eax
801054fd:	84 c0                	test   %al,%al
801054ff:	75 d5                	jne    801054d6 <strncpy+0xd>
    ;
  while(n-- > 0)
80105501:	eb 0c                	jmp    8010550f <strncpy+0x46>
    *s++ = 0;
80105503:	8b 45 08             	mov    0x8(%ebp),%eax
80105506:	8d 50 01             	lea    0x1(%eax),%edx
80105509:	89 55 08             	mov    %edx,0x8(%ebp)
8010550c:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010550f:	8b 45 10             	mov    0x10(%ebp),%eax
80105512:	8d 50 ff             	lea    -0x1(%eax),%edx
80105515:	89 55 10             	mov    %edx,0x10(%ebp)
80105518:	85 c0                	test   %eax,%eax
8010551a:	7f e7                	jg     80105503 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010551c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010551f:	c9                   	leave  
80105520:	c3                   	ret    

80105521 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105521:	55                   	push   %ebp
80105522:	89 e5                	mov    %esp,%ebp
80105524:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105527:	8b 45 08             	mov    0x8(%ebp),%eax
8010552a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010552d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105531:	7f 05                	jg     80105538 <safestrcpy+0x17>
    return os;
80105533:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105536:	eb 31                	jmp    80105569 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105538:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010553c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105540:	7e 1e                	jle    80105560 <safestrcpy+0x3f>
80105542:	8b 45 08             	mov    0x8(%ebp),%eax
80105545:	8d 50 01             	lea    0x1(%eax),%edx
80105548:	89 55 08             	mov    %edx,0x8(%ebp)
8010554b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010554e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105551:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105554:	0f b6 12             	movzbl (%edx),%edx
80105557:	88 10                	mov    %dl,(%eax)
80105559:	0f b6 00             	movzbl (%eax),%eax
8010555c:	84 c0                	test   %al,%al
8010555e:	75 d8                	jne    80105538 <safestrcpy+0x17>
    ;
  *s = 0;
80105560:	8b 45 08             	mov    0x8(%ebp),%eax
80105563:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105566:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105569:	c9                   	leave  
8010556a:	c3                   	ret    

8010556b <strlen>:

int
strlen(const char *s)
{
8010556b:	55                   	push   %ebp
8010556c:	89 e5                	mov    %esp,%ebp
8010556e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105571:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105578:	eb 04                	jmp    8010557e <strlen+0x13>
8010557a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010557e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105581:	8b 45 08             	mov    0x8(%ebp),%eax
80105584:	01 d0                	add    %edx,%eax
80105586:	0f b6 00             	movzbl (%eax),%eax
80105589:	84 c0                	test   %al,%al
8010558b:	75 ed                	jne    8010557a <strlen+0xf>
    ;
  return n;
8010558d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105590:	c9                   	leave  
80105591:	c3                   	ret    

80105592 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105592:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105596:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010559a:	55                   	push   %ebp
  pushl %ebx
8010559b:	53                   	push   %ebx
  pushl %esi
8010559c:	56                   	push   %esi
  pushl %edi
8010559d:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010559e:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055a0:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055a2:	5f                   	pop    %edi
  popl %esi
801055a3:	5e                   	pop    %esi
  popl %ebx
801055a4:	5b                   	pop    %ebx
  popl %ebp
801055a5:	5d                   	pop    %ebp
  ret
801055a6:	c3                   	ret    

801055a7 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055a7:	55                   	push   %ebp
801055a8:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801055aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b0:	8b 00                	mov    (%eax),%eax
801055b2:	3b 45 08             	cmp    0x8(%ebp),%eax
801055b5:	76 12                	jbe    801055c9 <fetchint+0x22>
801055b7:	8b 45 08             	mov    0x8(%ebp),%eax
801055ba:	8d 50 04             	lea    0x4(%eax),%edx
801055bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055c3:	8b 00                	mov    (%eax),%eax
801055c5:	39 c2                	cmp    %eax,%edx
801055c7:	76 07                	jbe    801055d0 <fetchint+0x29>
    return -1;
801055c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ce:	eb 0f                	jmp    801055df <fetchint+0x38>
  *ip = *(int*)(addr);
801055d0:	8b 45 08             	mov    0x8(%ebp),%eax
801055d3:	8b 10                	mov    (%eax),%edx
801055d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d8:	89 10                	mov    %edx,(%eax)
  return 0;
801055da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055df:	5d                   	pop    %ebp
801055e0:	c3                   	ret    

801055e1 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055e1:	55                   	push   %ebp
801055e2:	89 e5                	mov    %esp,%ebp
801055e4:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801055e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055ed:	8b 00                	mov    (%eax),%eax
801055ef:	3b 45 08             	cmp    0x8(%ebp),%eax
801055f2:	77 07                	ja     801055fb <fetchstr+0x1a>
    return -1;
801055f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f9:	eb 46                	jmp    80105641 <fetchstr+0x60>
  *pp = (char*)addr;
801055fb:	8b 55 08             	mov    0x8(%ebp),%edx
801055fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105601:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105603:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105609:	8b 00                	mov    (%eax),%eax
8010560b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010560e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105611:	8b 00                	mov    (%eax),%eax
80105613:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105616:	eb 1c                	jmp    80105634 <fetchstr+0x53>
    if(*s == 0)
80105618:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010561b:	0f b6 00             	movzbl (%eax),%eax
8010561e:	84 c0                	test   %al,%al
80105620:	75 0e                	jne    80105630 <fetchstr+0x4f>
      return s - *pp;
80105622:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105625:	8b 45 0c             	mov    0xc(%ebp),%eax
80105628:	8b 00                	mov    (%eax),%eax
8010562a:	29 c2                	sub    %eax,%edx
8010562c:	89 d0                	mov    %edx,%eax
8010562e:	eb 11                	jmp    80105641 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105630:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105634:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105637:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010563a:	72 dc                	jb     80105618 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010563c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105641:	c9                   	leave  
80105642:	c3                   	ret    

80105643 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105643:	55                   	push   %ebp
80105644:	89 e5                	mov    %esp,%ebp
80105646:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105649:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010564f:	8b 40 18             	mov    0x18(%eax),%eax
80105652:	8b 50 44             	mov    0x44(%eax),%edx
80105655:	8b 45 08             	mov    0x8(%ebp),%eax
80105658:	c1 e0 02             	shl    $0x2,%eax
8010565b:	01 d0                	add    %edx,%eax
8010565d:	8d 50 04             	lea    0x4(%eax),%edx
80105660:	8b 45 0c             	mov    0xc(%ebp),%eax
80105663:	89 44 24 04          	mov    %eax,0x4(%esp)
80105667:	89 14 24             	mov    %edx,(%esp)
8010566a:	e8 38 ff ff ff       	call   801055a7 <fetchint>
}
8010566f:	c9                   	leave  
80105670:	c3                   	ret    

80105671 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105671:	55                   	push   %ebp
80105672:	89 e5                	mov    %esp,%ebp
80105674:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105677:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010567a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010567e:	8b 45 08             	mov    0x8(%ebp),%eax
80105681:	89 04 24             	mov    %eax,(%esp)
80105684:	e8 ba ff ff ff       	call   80105643 <argint>
80105689:	85 c0                	test   %eax,%eax
8010568b:	79 07                	jns    80105694 <argptr+0x23>
    return -1;
8010568d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105692:	eb 3d                	jmp    801056d1 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105694:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105697:	89 c2                	mov    %eax,%edx
80105699:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010569f:	8b 00                	mov    (%eax),%eax
801056a1:	39 c2                	cmp    %eax,%edx
801056a3:	73 16                	jae    801056bb <argptr+0x4a>
801056a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a8:	89 c2                	mov    %eax,%edx
801056aa:	8b 45 10             	mov    0x10(%ebp),%eax
801056ad:	01 c2                	add    %eax,%edx
801056af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056b5:	8b 00                	mov    (%eax),%eax
801056b7:	39 c2                	cmp    %eax,%edx
801056b9:	76 07                	jbe    801056c2 <argptr+0x51>
    return -1;
801056bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c0:	eb 0f                	jmp    801056d1 <argptr+0x60>
  *pp = (char*)i;
801056c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c5:	89 c2                	mov    %eax,%edx
801056c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ca:	89 10                	mov    %edx,(%eax)
  return 0;
801056cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056d1:	c9                   	leave  
801056d2:	c3                   	ret    

801056d3 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801056d3:	55                   	push   %ebp
801056d4:	89 e5                	mov    %esp,%ebp
801056d6:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801056d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
801056dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801056e0:	8b 45 08             	mov    0x8(%ebp),%eax
801056e3:	89 04 24             	mov    %eax,(%esp)
801056e6:	e8 58 ff ff ff       	call   80105643 <argint>
801056eb:	85 c0                	test   %eax,%eax
801056ed:	79 07                	jns    801056f6 <argstr+0x23>
    return -1;
801056ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f4:	eb 12                	jmp    80105708 <argstr+0x35>
  return fetchstr(addr, pp);
801056f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801056fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80105700:	89 04 24             	mov    %eax,(%esp)
80105703:	e8 d9 fe ff ff       	call   801055e1 <fetchstr>
}
80105708:	c9                   	leave  
80105709:	c3                   	ret    

8010570a <syscall>:
[SYS_sigsend]  sys_sigsend,
};

void
syscall(void)
{
8010570a:	55                   	push   %ebp
8010570b:	89 e5                	mov    %esp,%ebp
8010570d:	53                   	push   %ebx
8010570e:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105711:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105717:	8b 40 18             	mov    0x18(%eax),%eax
8010571a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010571d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105720:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105724:	7e 30                	jle    80105756 <syscall+0x4c>
80105726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105729:	83 f8 17             	cmp    $0x17,%eax
8010572c:	77 28                	ja     80105756 <syscall+0x4c>
8010572e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105731:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105738:	85 c0                	test   %eax,%eax
8010573a:	74 1a                	je     80105756 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010573c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105742:	8b 58 18             	mov    0x18(%eax),%ebx
80105745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105748:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010574f:	ff d0                	call   *%eax
80105751:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105754:	eb 3d                	jmp    80105793 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105756:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010575c:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010575f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105765:	8b 40 10             	mov    0x10(%eax),%eax
80105768:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010576b:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010576f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105773:	89 44 24 04          	mov    %eax,0x4(%esp)
80105777:	c7 04 24 ef 8a 10 80 	movl   $0x80108aef,(%esp)
8010577e:	e8 1d ac ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105783:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105789:	8b 40 18             	mov    0x18(%eax),%eax
8010578c:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105793:	83 c4 24             	add    $0x24,%esp
80105796:	5b                   	pop    %ebx
80105797:	5d                   	pop    %ebp
80105798:	c3                   	ret    

80105799 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105799:	55                   	push   %ebp
8010579a:	89 e5                	mov    %esp,%ebp
8010579c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010579f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801057a6:	8b 45 08             	mov    0x8(%ebp),%eax
801057a9:	89 04 24             	mov    %eax,(%esp)
801057ac:	e8 92 fe ff ff       	call   80105643 <argint>
801057b1:	85 c0                	test   %eax,%eax
801057b3:	79 07                	jns    801057bc <argfd+0x23>
    return -1;
801057b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ba:	eb 50                	jmp    8010580c <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801057bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057bf:	85 c0                	test   %eax,%eax
801057c1:	78 21                	js     801057e4 <argfd+0x4b>
801057c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c6:	83 f8 0f             	cmp    $0xf,%eax
801057c9:	7f 19                	jg     801057e4 <argfd+0x4b>
801057cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057d4:	83 c2 08             	add    $0x8,%edx
801057d7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057e2:	75 07                	jne    801057eb <argfd+0x52>
    return -1;
801057e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e9:	eb 21                	jmp    8010580c <argfd+0x73>
  if(pfd)
801057eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801057ef:	74 08                	je     801057f9 <argfd+0x60>
    *pfd = fd;
801057f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801057f7:	89 10                	mov    %edx,(%eax)
  if(pf)
801057f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057fd:	74 08                	je     80105807 <argfd+0x6e>
    *pf = f;
801057ff:	8b 45 10             	mov    0x10(%ebp),%eax
80105802:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105805:	89 10                	mov    %edx,(%eax)
  return 0;
80105807:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010580c:	c9                   	leave  
8010580d:	c3                   	ret    

8010580e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010580e:	55                   	push   %ebp
8010580f:	89 e5                	mov    %esp,%ebp
80105811:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105814:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010581b:	eb 30                	jmp    8010584d <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010581d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105823:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105826:	83 c2 08             	add    $0x8,%edx
80105829:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010582d:	85 c0                	test   %eax,%eax
8010582f:	75 18                	jne    80105849 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105831:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105837:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010583a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010583d:	8b 55 08             	mov    0x8(%ebp),%edx
80105840:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105844:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105847:	eb 0f                	jmp    80105858 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105849:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010584d:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105851:	7e ca                	jle    8010581d <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105853:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105858:	c9                   	leave  
80105859:	c3                   	ret    

8010585a <sys_dup>:

int
sys_dup(void)
{
8010585a:	55                   	push   %ebp
8010585b:	89 e5                	mov    %esp,%ebp
8010585d:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105860:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105863:	89 44 24 08          	mov    %eax,0x8(%esp)
80105867:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010586e:	00 
8010586f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105876:	e8 1e ff ff ff       	call   80105799 <argfd>
8010587b:	85 c0                	test   %eax,%eax
8010587d:	79 07                	jns    80105886 <sys_dup+0x2c>
    return -1;
8010587f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105884:	eb 29                	jmp    801058af <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105889:	89 04 24             	mov    %eax,(%esp)
8010588c:	e8 7d ff ff ff       	call   8010580e <fdalloc>
80105891:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105894:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105898:	79 07                	jns    801058a1 <sys_dup+0x47>
    return -1;
8010589a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010589f:	eb 0e                	jmp    801058af <sys_dup+0x55>
  filedup(f);
801058a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a4:	89 04 24             	mov    %eax,(%esp)
801058a7:	e8 e7 b6 ff ff       	call   80100f93 <filedup>
  return fd;
801058ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058af:	c9                   	leave  
801058b0:	c3                   	ret    

801058b1 <sys_read>:

int
sys_read(void)
{
801058b1:	55                   	push   %ebp
801058b2:	89 e5                	mov    %esp,%ebp
801058b4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058ba:	89 44 24 08          	mov    %eax,0x8(%esp)
801058be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058c5:	00 
801058c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058cd:	e8 c7 fe ff ff       	call   80105799 <argfd>
801058d2:	85 c0                	test   %eax,%eax
801058d4:	78 35                	js     8010590b <sys_read+0x5a>
801058d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801058dd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801058e4:	e8 5a fd ff ff       	call   80105643 <argint>
801058e9:	85 c0                	test   %eax,%eax
801058eb:	78 1e                	js     8010590b <sys_read+0x5a>
801058ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f0:	89 44 24 08          	mov    %eax,0x8(%esp)
801058f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801058fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105902:	e8 6a fd ff ff       	call   80105671 <argptr>
80105907:	85 c0                	test   %eax,%eax
80105909:	79 07                	jns    80105912 <sys_read+0x61>
    return -1;
8010590b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105910:	eb 19                	jmp    8010592b <sys_read+0x7a>
  return fileread(f, p, n);
80105912:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105915:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010591f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105923:	89 04 24             	mov    %eax,(%esp)
80105926:	e8 d5 b7 ff ff       	call   80101100 <fileread>
}
8010592b:	c9                   	leave  
8010592c:	c3                   	ret    

8010592d <sys_write>:

int
sys_write(void)
{
8010592d:	55                   	push   %ebp
8010592e:	89 e5                	mov    %esp,%ebp
80105930:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105933:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105936:	89 44 24 08          	mov    %eax,0x8(%esp)
8010593a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105941:	00 
80105942:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105949:	e8 4b fe ff ff       	call   80105799 <argfd>
8010594e:	85 c0                	test   %eax,%eax
80105950:	78 35                	js     80105987 <sys_write+0x5a>
80105952:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105955:	89 44 24 04          	mov    %eax,0x4(%esp)
80105959:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105960:	e8 de fc ff ff       	call   80105643 <argint>
80105965:	85 c0                	test   %eax,%eax
80105967:	78 1e                	js     80105987 <sys_write+0x5a>
80105969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105970:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105973:	89 44 24 04          	mov    %eax,0x4(%esp)
80105977:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010597e:	e8 ee fc ff ff       	call   80105671 <argptr>
80105983:	85 c0                	test   %eax,%eax
80105985:	79 07                	jns    8010598e <sys_write+0x61>
    return -1;
80105987:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010598c:	eb 19                	jmp    801059a7 <sys_write+0x7a>
  return filewrite(f, p, n);
8010598e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105991:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105997:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010599b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010599f:	89 04 24             	mov    %eax,(%esp)
801059a2:	e8 15 b8 ff ff       	call   801011bc <filewrite>
}
801059a7:	c9                   	leave  
801059a8:	c3                   	ret    

801059a9 <sys_close>:

int
sys_close(void)
{
801059a9:	55                   	push   %ebp
801059aa:	89 e5                	mov    %esp,%ebp
801059ac:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801059af:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059b2:	89 44 24 08          	mov    %eax,0x8(%esp)
801059b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801059bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059c4:	e8 d0 fd ff ff       	call   80105799 <argfd>
801059c9:	85 c0                	test   %eax,%eax
801059cb:	79 07                	jns    801059d4 <sys_close+0x2b>
    return -1;
801059cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d2:	eb 24                	jmp    801059f8 <sys_close+0x4f>
  proc->ofile[fd] = 0;
801059d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059dd:	83 c2 08             	add    $0x8,%edx
801059e0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801059e7:	00 
  fileclose(f);
801059e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059eb:	89 04 24             	mov    %eax,(%esp)
801059ee:	e8 e8 b5 ff ff       	call   80100fdb <fileclose>
  return 0;
801059f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059f8:	c9                   	leave  
801059f9:	c3                   	ret    

801059fa <sys_fstat>:

int
sys_fstat(void)
{
801059fa:	55                   	push   %ebp
801059fb:	89 e5                	mov    %esp,%ebp
801059fd:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a00:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a03:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a0e:	00 
80105a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a16:	e8 7e fd ff ff       	call   80105799 <argfd>
80105a1b:	85 c0                	test   %eax,%eax
80105a1d:	78 1f                	js     80105a3e <sys_fstat+0x44>
80105a1f:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105a26:	00 
80105a27:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a35:	e8 37 fc ff ff       	call   80105671 <argptr>
80105a3a:	85 c0                	test   %eax,%eax
80105a3c:	79 07                	jns    80105a45 <sys_fstat+0x4b>
    return -1;
80105a3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a43:	eb 12                	jmp    80105a57 <sys_fstat+0x5d>
  return filestat(f, st);
80105a45:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4b:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a4f:	89 04 24             	mov    %eax,(%esp)
80105a52:	e8 5a b6 ff ff       	call   801010b1 <filestat>
}
80105a57:	c9                   	leave  
80105a58:	c3                   	ret    

80105a59 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105a59:	55                   	push   %ebp
80105a5a:	89 e5                	mov    %esp,%ebp
80105a5c:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a5f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a62:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a6d:	e8 61 fc ff ff       	call   801056d3 <argstr>
80105a72:	85 c0                	test   %eax,%eax
80105a74:	78 17                	js     80105a8d <sys_link+0x34>
80105a76:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a79:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a84:	e8 4a fc ff ff       	call   801056d3 <argstr>
80105a89:	85 c0                	test   %eax,%eax
80105a8b:	79 0a                	jns    80105a97 <sys_link+0x3e>
    return -1;
80105a8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a92:	e9 42 01 00 00       	jmp    80105bd9 <sys_link+0x180>

  begin_op();
80105a97:	e8 81 d9 ff ff       	call   8010341d <begin_op>
  if((ip = namei(old)) == 0){
80105a9c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a9f:	89 04 24             	mov    %eax,(%esp)
80105aa2:	e8 6c c9 ff ff       	call   80102413 <namei>
80105aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aaa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aae:	75 0f                	jne    80105abf <sys_link+0x66>
    end_op();
80105ab0:	e8 ec d9 ff ff       	call   801034a1 <end_op>
    return -1;
80105ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aba:	e9 1a 01 00 00       	jmp    80105bd9 <sys_link+0x180>
  }

  ilock(ip);
80105abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac2:	89 04 24             	mov    %eax,(%esp)
80105ac5:	e8 9e bd ff ff       	call   80101868 <ilock>
  if(ip->type == T_DIR){
80105aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105acd:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ad1:	66 83 f8 01          	cmp    $0x1,%ax
80105ad5:	75 1a                	jne    80105af1 <sys_link+0x98>
    iunlockput(ip);
80105ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ada:	89 04 24             	mov    %eax,(%esp)
80105add:	e8 0a c0 ff ff       	call   80101aec <iunlockput>
    end_op();
80105ae2:	e8 ba d9 ff ff       	call   801034a1 <end_op>
    return -1;
80105ae7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aec:	e9 e8 00 00 00       	jmp    80105bd9 <sys_link+0x180>
  }

  ip->nlink++;
80105af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105af8:	8d 50 01             	lea    0x1(%eax),%edx
80105afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afe:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b05:	89 04 24             	mov    %eax,(%esp)
80105b08:	e8 9f bb ff ff       	call   801016ac <iupdate>
  iunlock(ip);
80105b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b10:	89 04 24             	mov    %eax,(%esp)
80105b13:	e8 9e be ff ff       	call   801019b6 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105b18:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b1b:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b1e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b22:	89 04 24             	mov    %eax,(%esp)
80105b25:	e8 0b c9 ff ff       	call   80102435 <nameiparent>
80105b2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b31:	75 02                	jne    80105b35 <sys_link+0xdc>
    goto bad;
80105b33:	eb 68                	jmp    80105b9d <sys_link+0x144>
  ilock(dp);
80105b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b38:	89 04 24             	mov    %eax,(%esp)
80105b3b:	e8 28 bd ff ff       	call   80101868 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b43:	8b 10                	mov    (%eax),%edx
80105b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b48:	8b 00                	mov    (%eax),%eax
80105b4a:	39 c2                	cmp    %eax,%edx
80105b4c:	75 20                	jne    80105b6e <sys_link+0x115>
80105b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b51:	8b 40 04             	mov    0x4(%eax),%eax
80105b54:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b58:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b62:	89 04 24             	mov    %eax,(%esp)
80105b65:	e8 e9 c5 ff ff       	call   80102153 <dirlink>
80105b6a:	85 c0                	test   %eax,%eax
80105b6c:	79 0d                	jns    80105b7b <sys_link+0x122>
    iunlockput(dp);
80105b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b71:	89 04 24             	mov    %eax,(%esp)
80105b74:	e8 73 bf ff ff       	call   80101aec <iunlockput>
    goto bad;
80105b79:	eb 22                	jmp    80105b9d <sys_link+0x144>
  }
  iunlockput(dp);
80105b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7e:	89 04 24             	mov    %eax,(%esp)
80105b81:	e8 66 bf ff ff       	call   80101aec <iunlockput>
  iput(ip);
80105b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b89:	89 04 24             	mov    %eax,(%esp)
80105b8c:	e8 8a be ff ff       	call   80101a1b <iput>

  end_op();
80105b91:	e8 0b d9 ff ff       	call   801034a1 <end_op>

  return 0;
80105b96:	b8 00 00 00 00       	mov    $0x0,%eax
80105b9b:	eb 3c                	jmp    80105bd9 <sys_link+0x180>

bad:
  ilock(ip);
80105b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba0:	89 04 24             	mov    %eax,(%esp)
80105ba3:	e8 c0 bc ff ff       	call   80101868 <ilock>
  ip->nlink--;
80105ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bab:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105baf:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb5:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbc:	89 04 24             	mov    %eax,(%esp)
80105bbf:	e8 e8 ba ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
80105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc7:	89 04 24             	mov    %eax,(%esp)
80105bca:	e8 1d bf ff ff       	call   80101aec <iunlockput>
  end_op();
80105bcf:	e8 cd d8 ff ff       	call   801034a1 <end_op>
  return -1;
80105bd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bd9:	c9                   	leave  
80105bda:	c3                   	ret    

80105bdb <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105bdb:	55                   	push   %ebp
80105bdc:	89 e5                	mov    %esp,%ebp
80105bde:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105be1:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105be8:	eb 4b                	jmp    80105c35 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bed:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105bf4:	00 
80105bf5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bf9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c00:	8b 45 08             	mov    0x8(%ebp),%eax
80105c03:	89 04 24             	mov    %eax,(%esp)
80105c06:	e8 6a c1 ff ff       	call   80101d75 <readi>
80105c0b:	83 f8 10             	cmp    $0x10,%eax
80105c0e:	74 0c                	je     80105c1c <isdirempty+0x41>
      panic("isdirempty: readi");
80105c10:	c7 04 24 0b 8b 10 80 	movl   $0x80108b0b,(%esp)
80105c17:	e8 1e a9 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105c1c:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c20:	66 85 c0             	test   %ax,%ax
80105c23:	74 07                	je     80105c2c <isdirempty+0x51>
      return 0;
80105c25:	b8 00 00 00 00       	mov    $0x0,%eax
80105c2a:	eb 1b                	jmp    80105c47 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2f:	83 c0 10             	add    $0x10,%eax
80105c32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c38:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3b:	8b 40 18             	mov    0x18(%eax),%eax
80105c3e:	39 c2                	cmp    %eax,%edx
80105c40:	72 a8                	jb     80105bea <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105c42:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c47:	c9                   	leave  
80105c48:	c3                   	ret    

80105c49 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c49:	55                   	push   %ebp
80105c4a:	89 e5                	mov    %esp,%ebp
80105c4c:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c4f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c52:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c5d:	e8 71 fa ff ff       	call   801056d3 <argstr>
80105c62:	85 c0                	test   %eax,%eax
80105c64:	79 0a                	jns    80105c70 <sys_unlink+0x27>
    return -1;
80105c66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c6b:	e9 af 01 00 00       	jmp    80105e1f <sys_unlink+0x1d6>

  begin_op();
80105c70:	e8 a8 d7 ff ff       	call   8010341d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c75:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c78:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c7b:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c7f:	89 04 24             	mov    %eax,(%esp)
80105c82:	e8 ae c7 ff ff       	call   80102435 <nameiparent>
80105c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c8e:	75 0f                	jne    80105c9f <sys_unlink+0x56>
    end_op();
80105c90:	e8 0c d8 ff ff       	call   801034a1 <end_op>
    return -1;
80105c95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9a:	e9 80 01 00 00       	jmp    80105e1f <sys_unlink+0x1d6>
  }

  ilock(dp);
80105c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca2:	89 04 24             	mov    %eax,(%esp)
80105ca5:	e8 be bb ff ff       	call   80101868 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105caa:	c7 44 24 04 1d 8b 10 	movl   $0x80108b1d,0x4(%esp)
80105cb1:	80 
80105cb2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cb5:	89 04 24             	mov    %eax,(%esp)
80105cb8:	e8 ab c3 ff ff       	call   80102068 <namecmp>
80105cbd:	85 c0                	test   %eax,%eax
80105cbf:	0f 84 45 01 00 00    	je     80105e0a <sys_unlink+0x1c1>
80105cc5:	c7 44 24 04 1f 8b 10 	movl   $0x80108b1f,0x4(%esp)
80105ccc:	80 
80105ccd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cd0:	89 04 24             	mov    %eax,(%esp)
80105cd3:	e8 90 c3 ff ff       	call   80102068 <namecmp>
80105cd8:	85 c0                	test   %eax,%eax
80105cda:	0f 84 2a 01 00 00    	je     80105e0a <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ce0:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cea:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf1:	89 04 24             	mov    %eax,(%esp)
80105cf4:	e8 91 c3 ff ff       	call   8010208a <dirlookup>
80105cf9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cfc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d00:	75 05                	jne    80105d07 <sys_unlink+0xbe>
    goto bad;
80105d02:	e9 03 01 00 00       	jmp    80105e0a <sys_unlink+0x1c1>
  ilock(ip);
80105d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0a:	89 04 24             	mov    %eax,(%esp)
80105d0d:	e8 56 bb ff ff       	call   80101868 <ilock>

  if(ip->nlink < 1)
80105d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d15:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d19:	66 85 c0             	test   %ax,%ax
80105d1c:	7f 0c                	jg     80105d2a <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105d1e:	c7 04 24 22 8b 10 80 	movl   $0x80108b22,(%esp)
80105d25:	e8 10 a8 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d31:	66 83 f8 01          	cmp    $0x1,%ax
80105d35:	75 1f                	jne    80105d56 <sys_unlink+0x10d>
80105d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3a:	89 04 24             	mov    %eax,(%esp)
80105d3d:	e8 99 fe ff ff       	call   80105bdb <isdirempty>
80105d42:	85 c0                	test   %eax,%eax
80105d44:	75 10                	jne    80105d56 <sys_unlink+0x10d>
    iunlockput(ip);
80105d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d49:	89 04 24             	mov    %eax,(%esp)
80105d4c:	e8 9b bd ff ff       	call   80101aec <iunlockput>
    goto bad;
80105d51:	e9 b4 00 00 00       	jmp    80105e0a <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105d56:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105d5d:	00 
80105d5e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d65:	00 
80105d66:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d69:	89 04 24             	mov    %eax,(%esp)
80105d6c:	e8 90 f5 ff ff       	call   80105301 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d71:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d74:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d7b:	00 
80105d7c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d80:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d83:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8a:	89 04 24             	mov    %eax,(%esp)
80105d8d:	e8 47 c1 ff ff       	call   80101ed9 <writei>
80105d92:	83 f8 10             	cmp    $0x10,%eax
80105d95:	74 0c                	je     80105da3 <sys_unlink+0x15a>
    panic("unlink: writei");
80105d97:	c7 04 24 34 8b 10 80 	movl   $0x80108b34,(%esp)
80105d9e:	e8 97 a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105daa:	66 83 f8 01          	cmp    $0x1,%ax
80105dae:	75 1c                	jne    80105dcc <sys_unlink+0x183>
    dp->nlink--;
80105db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105db7:	8d 50 ff             	lea    -0x1(%eax),%edx
80105dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbd:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc4:	89 04 24             	mov    %eax,(%esp)
80105dc7:	e8 e0 b8 ff ff       	call   801016ac <iupdate>
  }
  iunlockput(dp);
80105dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dcf:	89 04 24             	mov    %eax,(%esp)
80105dd2:	e8 15 bd ff ff       	call   80101aec <iunlockput>

  ip->nlink--;
80105dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dda:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105dde:	8d 50 ff             	lea    -0x1(%eax),%edx
80105de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de4:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105deb:	89 04 24             	mov    %eax,(%esp)
80105dee:	e8 b9 b8 ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
80105df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df6:	89 04 24             	mov    %eax,(%esp)
80105df9:	e8 ee bc ff ff       	call   80101aec <iunlockput>

  end_op();
80105dfe:	e8 9e d6 ff ff       	call   801034a1 <end_op>

  return 0;
80105e03:	b8 00 00 00 00       	mov    $0x0,%eax
80105e08:	eb 15                	jmp    80105e1f <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0d:	89 04 24             	mov    %eax,(%esp)
80105e10:	e8 d7 bc ff ff       	call   80101aec <iunlockput>
  end_op();
80105e15:	e8 87 d6 ff ff       	call   801034a1 <end_op>
  return -1;
80105e1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e1f:	c9                   	leave  
80105e20:	c3                   	ret    

80105e21 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e21:	55                   	push   %ebp
80105e22:	89 e5                	mov    %esp,%ebp
80105e24:	83 ec 48             	sub    $0x48,%esp
80105e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e2a:	8b 55 10             	mov    0x10(%ebp),%edx
80105e2d:	8b 45 14             	mov    0x14(%ebp),%eax
80105e30:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e34:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e38:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e3c:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e43:	8b 45 08             	mov    0x8(%ebp),%eax
80105e46:	89 04 24             	mov    %eax,(%esp)
80105e49:	e8 e7 c5 ff ff       	call   80102435 <nameiparent>
80105e4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e55:	75 0a                	jne    80105e61 <create+0x40>
    return 0;
80105e57:	b8 00 00 00 00       	mov    $0x0,%eax
80105e5c:	e9 7e 01 00 00       	jmp    80105fdf <create+0x1be>
  ilock(dp);
80105e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e64:	89 04 24             	mov    %eax,(%esp)
80105e67:	e8 fc b9 ff ff       	call   80101868 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e6c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e73:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e76:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7d:	89 04 24             	mov    %eax,(%esp)
80105e80:	e8 05 c2 ff ff       	call   8010208a <dirlookup>
80105e85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e8c:	74 47                	je     80105ed5 <create+0xb4>
    iunlockput(dp);
80105e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e91:	89 04 24             	mov    %eax,(%esp)
80105e94:	e8 53 bc ff ff       	call   80101aec <iunlockput>
    ilock(ip);
80105e99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9c:	89 04 24             	mov    %eax,(%esp)
80105e9f:	e8 c4 b9 ff ff       	call   80101868 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105ea4:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ea9:	75 15                	jne    80105ec0 <create+0x9f>
80105eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105eb2:	66 83 f8 02          	cmp    $0x2,%ax
80105eb6:	75 08                	jne    80105ec0 <create+0x9f>
      return ip;
80105eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ebb:	e9 1f 01 00 00       	jmp    80105fdf <create+0x1be>
    iunlockput(ip);
80105ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec3:	89 04 24             	mov    %eax,(%esp)
80105ec6:	e8 21 bc ff ff       	call   80101aec <iunlockput>
    return 0;
80105ecb:	b8 00 00 00 00       	mov    $0x0,%eax
80105ed0:	e9 0a 01 00 00       	jmp    80105fdf <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105ed5:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edc:	8b 00                	mov    (%eax),%eax
80105ede:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ee2:	89 04 24             	mov    %eax,(%esp)
80105ee5:	e8 e3 b6 ff ff       	call   801015cd <ialloc>
80105eea:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105eed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ef1:	75 0c                	jne    80105eff <create+0xde>
    panic("create: ialloc");
80105ef3:	c7 04 24 43 8b 10 80 	movl   $0x80108b43,(%esp)
80105efa:	e8 3b a6 ff ff       	call   8010053a <panic>

  ilock(ip);
80105eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f02:	89 04 24             	mov    %eax,(%esp)
80105f05:	e8 5e b9 ff ff       	call   80101868 <ilock>
  ip->major = major;
80105f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f11:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f18:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f1c:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f23:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2c:	89 04 24             	mov    %eax,(%esp)
80105f2f:	e8 78 b7 ff ff       	call   801016ac <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105f34:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f39:	75 6a                	jne    80105fa5 <create+0x184>
    dp->nlink++;  // for ".."
80105f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f42:	8d 50 01             	lea    0x1(%eax),%edx
80105f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f48:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4f:	89 04 24             	mov    %eax,(%esp)
80105f52:	e8 55 b7 ff ff       	call   801016ac <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5a:	8b 40 04             	mov    0x4(%eax),%eax
80105f5d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f61:	c7 44 24 04 1d 8b 10 	movl   $0x80108b1d,0x4(%esp)
80105f68:	80 
80105f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6c:	89 04 24             	mov    %eax,(%esp)
80105f6f:	e8 df c1 ff ff       	call   80102153 <dirlink>
80105f74:	85 c0                	test   %eax,%eax
80105f76:	78 21                	js     80105f99 <create+0x178>
80105f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7b:	8b 40 04             	mov    0x4(%eax),%eax
80105f7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f82:	c7 44 24 04 1f 8b 10 	movl   $0x80108b1f,0x4(%esp)
80105f89:	80 
80105f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8d:	89 04 24             	mov    %eax,(%esp)
80105f90:	e8 be c1 ff ff       	call   80102153 <dirlink>
80105f95:	85 c0                	test   %eax,%eax
80105f97:	79 0c                	jns    80105fa5 <create+0x184>
      panic("create dots");
80105f99:	c7 04 24 52 8b 10 80 	movl   $0x80108b52,(%esp)
80105fa0:	e8 95 a5 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa8:	8b 40 04             	mov    0x4(%eax),%eax
80105fab:	89 44 24 08          	mov    %eax,0x8(%esp)
80105faf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb9:	89 04 24             	mov    %eax,(%esp)
80105fbc:	e8 92 c1 ff ff       	call   80102153 <dirlink>
80105fc1:	85 c0                	test   %eax,%eax
80105fc3:	79 0c                	jns    80105fd1 <create+0x1b0>
    panic("create: dirlink");
80105fc5:	c7 04 24 5e 8b 10 80 	movl   $0x80108b5e,(%esp)
80105fcc:	e8 69 a5 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80105fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd4:	89 04 24             	mov    %eax,(%esp)
80105fd7:	e8 10 bb ff ff       	call   80101aec <iunlockput>

  return ip;
80105fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105fdf:	c9                   	leave  
80105fe0:	c3                   	ret    

80105fe1 <sys_open>:

int
sys_open(void)
{
80105fe1:	55                   	push   %ebp
80105fe2:	89 e5                	mov    %esp,%ebp
80105fe4:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105fe7:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fea:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ff5:	e8 d9 f6 ff ff       	call   801056d3 <argstr>
80105ffa:	85 c0                	test   %eax,%eax
80105ffc:	78 17                	js     80106015 <sys_open+0x34>
80105ffe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106001:	89 44 24 04          	mov    %eax,0x4(%esp)
80106005:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010600c:	e8 32 f6 ff ff       	call   80105643 <argint>
80106011:	85 c0                	test   %eax,%eax
80106013:	79 0a                	jns    8010601f <sys_open+0x3e>
    return -1;
80106015:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601a:	e9 5c 01 00 00       	jmp    8010617b <sys_open+0x19a>

  begin_op();
8010601f:	e8 f9 d3 ff ff       	call   8010341d <begin_op>

  if(omode & O_CREATE){
80106024:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106027:	25 00 02 00 00       	and    $0x200,%eax
8010602c:	85 c0                	test   %eax,%eax
8010602e:	74 3b                	je     8010606b <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106030:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106033:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010603a:	00 
8010603b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106042:	00 
80106043:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010604a:	00 
8010604b:	89 04 24             	mov    %eax,(%esp)
8010604e:	e8 ce fd ff ff       	call   80105e21 <create>
80106053:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106056:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010605a:	75 6b                	jne    801060c7 <sys_open+0xe6>
      end_op();
8010605c:	e8 40 d4 ff ff       	call   801034a1 <end_op>
      return -1;
80106061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106066:	e9 10 01 00 00       	jmp    8010617b <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
8010606b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010606e:	89 04 24             	mov    %eax,(%esp)
80106071:	e8 9d c3 ff ff       	call   80102413 <namei>
80106076:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106079:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010607d:	75 0f                	jne    8010608e <sys_open+0xad>
      end_op();
8010607f:	e8 1d d4 ff ff       	call   801034a1 <end_op>
      return -1;
80106084:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106089:	e9 ed 00 00 00       	jmp    8010617b <sys_open+0x19a>
    }
    ilock(ip);
8010608e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106091:	89 04 24             	mov    %eax,(%esp)
80106094:	e8 cf b7 ff ff       	call   80101868 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060a0:	66 83 f8 01          	cmp    $0x1,%ax
801060a4:	75 21                	jne    801060c7 <sys_open+0xe6>
801060a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060a9:	85 c0                	test   %eax,%eax
801060ab:	74 1a                	je     801060c7 <sys_open+0xe6>
      iunlockput(ip);
801060ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b0:	89 04 24             	mov    %eax,(%esp)
801060b3:	e8 34 ba ff ff       	call   80101aec <iunlockput>
      end_op();
801060b8:	e8 e4 d3 ff ff       	call   801034a1 <end_op>
      return -1;
801060bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c2:	e9 b4 00 00 00       	jmp    8010617b <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801060c7:	e8 67 ae ff ff       	call   80100f33 <filealloc>
801060cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060d3:	74 14                	je     801060e9 <sys_open+0x108>
801060d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d8:	89 04 24             	mov    %eax,(%esp)
801060db:	e8 2e f7 ff ff       	call   8010580e <fdalloc>
801060e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801060e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801060e7:	79 28                	jns    80106111 <sys_open+0x130>
    if(f)
801060e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060ed:	74 0b                	je     801060fa <sys_open+0x119>
      fileclose(f);
801060ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f2:	89 04 24             	mov    %eax,(%esp)
801060f5:	e8 e1 ae ff ff       	call   80100fdb <fileclose>
    iunlockput(ip);
801060fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fd:	89 04 24             	mov    %eax,(%esp)
80106100:	e8 e7 b9 ff ff       	call   80101aec <iunlockput>
    end_op();
80106105:	e8 97 d3 ff ff       	call   801034a1 <end_op>
    return -1;
8010610a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610f:	eb 6a                	jmp    8010617b <sys_open+0x19a>
  }
  iunlock(ip);
80106111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106114:	89 04 24             	mov    %eax,(%esp)
80106117:	e8 9a b8 ff ff       	call   801019b6 <iunlock>
  end_op();
8010611c:	e8 80 d3 ff ff       	call   801034a1 <end_op>

  f->type = FD_INODE;
80106121:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106124:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010612a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010612d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106130:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106133:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106136:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010613d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106140:	83 e0 01             	and    $0x1,%eax
80106143:	85 c0                	test   %eax,%eax
80106145:	0f 94 c0             	sete   %al
80106148:	89 c2                	mov    %eax,%edx
8010614a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010614d:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106150:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106153:	83 e0 01             	and    $0x1,%eax
80106156:	85 c0                	test   %eax,%eax
80106158:	75 0a                	jne    80106164 <sys_open+0x183>
8010615a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010615d:	83 e0 02             	and    $0x2,%eax
80106160:	85 c0                	test   %eax,%eax
80106162:	74 07                	je     8010616b <sys_open+0x18a>
80106164:	b8 01 00 00 00       	mov    $0x1,%eax
80106169:	eb 05                	jmp    80106170 <sys_open+0x18f>
8010616b:	b8 00 00 00 00       	mov    $0x0,%eax
80106170:	89 c2                	mov    %eax,%edx
80106172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106175:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106178:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010617b:	c9                   	leave  
8010617c:	c3                   	ret    

8010617d <sys_mkdir>:

int
sys_mkdir(void)
{
8010617d:	55                   	push   %ebp
8010617e:	89 e5                	mov    %esp,%ebp
80106180:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106183:	e8 95 d2 ff ff       	call   8010341d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106188:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010618b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010618f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106196:	e8 38 f5 ff ff       	call   801056d3 <argstr>
8010619b:	85 c0                	test   %eax,%eax
8010619d:	78 2c                	js     801061cb <sys_mkdir+0x4e>
8010619f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061a9:	00 
801061aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801061b1:	00 
801061b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801061b9:	00 
801061ba:	89 04 24             	mov    %eax,(%esp)
801061bd:	e8 5f fc ff ff       	call   80105e21 <create>
801061c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061c9:	75 0c                	jne    801061d7 <sys_mkdir+0x5a>
    end_op();
801061cb:	e8 d1 d2 ff ff       	call   801034a1 <end_op>
    return -1;
801061d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d5:	eb 15                	jmp    801061ec <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801061d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061da:	89 04 24             	mov    %eax,(%esp)
801061dd:	e8 0a b9 ff ff       	call   80101aec <iunlockput>
  end_op();
801061e2:	e8 ba d2 ff ff       	call   801034a1 <end_op>
  return 0;
801061e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061ec:	c9                   	leave  
801061ed:	c3                   	ret    

801061ee <sys_mknod>:

int
sys_mknod(void)
{
801061ee:	55                   	push   %ebp
801061ef:	89 e5                	mov    %esp,%ebp
801061f1:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801061f4:	e8 24 d2 ff ff       	call   8010341d <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801061f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106200:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106207:	e8 c7 f4 ff ff       	call   801056d3 <argstr>
8010620c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010620f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106213:	78 5e                	js     80106273 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106215:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106218:	89 44 24 04          	mov    %eax,0x4(%esp)
8010621c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106223:	e8 1b f4 ff ff       	call   80105643 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106228:	85 c0                	test   %eax,%eax
8010622a:	78 47                	js     80106273 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010622c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010622f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106233:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010623a:	e8 04 f4 ff ff       	call   80105643 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010623f:	85 c0                	test   %eax,%eax
80106241:	78 30                	js     80106273 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106246:	0f bf c8             	movswl %ax,%ecx
80106249:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010624c:	0f bf d0             	movswl %ax,%edx
8010624f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106252:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106256:	89 54 24 08          	mov    %edx,0x8(%esp)
8010625a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106261:	00 
80106262:	89 04 24             	mov    %eax,(%esp)
80106265:	e8 b7 fb ff ff       	call   80105e21 <create>
8010626a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010626d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106271:	75 0c                	jne    8010627f <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106273:	e8 29 d2 ff ff       	call   801034a1 <end_op>
    return -1;
80106278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627d:	eb 15                	jmp    80106294 <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010627f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106282:	89 04 24             	mov    %eax,(%esp)
80106285:	e8 62 b8 ff ff       	call   80101aec <iunlockput>
  end_op();
8010628a:	e8 12 d2 ff ff       	call   801034a1 <end_op>
  return 0;
8010628f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106294:	c9                   	leave  
80106295:	c3                   	ret    

80106296 <sys_chdir>:

int
sys_chdir(void)
{
80106296:	55                   	push   %ebp
80106297:	89 e5                	mov    %esp,%ebp
80106299:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010629c:	e8 7c d1 ff ff       	call   8010341d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801062a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062af:	e8 1f f4 ff ff       	call   801056d3 <argstr>
801062b4:	85 c0                	test   %eax,%eax
801062b6:	78 14                	js     801062cc <sys_chdir+0x36>
801062b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bb:	89 04 24             	mov    %eax,(%esp)
801062be:	e8 50 c1 ff ff       	call   80102413 <namei>
801062c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062ca:	75 0c                	jne    801062d8 <sys_chdir+0x42>
    end_op();
801062cc:	e8 d0 d1 ff ff       	call   801034a1 <end_op>
    return -1;
801062d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d6:	eb 61                	jmp    80106339 <sys_chdir+0xa3>
  }
  ilock(ip);
801062d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062db:	89 04 24             	mov    %eax,(%esp)
801062de:	e8 85 b5 ff ff       	call   80101868 <ilock>
  if(ip->type != T_DIR){
801062e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801062ea:	66 83 f8 01          	cmp    $0x1,%ax
801062ee:	74 17                	je     80106307 <sys_chdir+0x71>
    iunlockput(ip);
801062f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f3:	89 04 24             	mov    %eax,(%esp)
801062f6:	e8 f1 b7 ff ff       	call   80101aec <iunlockput>
    end_op();
801062fb:	e8 a1 d1 ff ff       	call   801034a1 <end_op>
    return -1;
80106300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106305:	eb 32                	jmp    80106339 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630a:	89 04 24             	mov    %eax,(%esp)
8010630d:	e8 a4 b6 ff ff       	call   801019b6 <iunlock>
  iput(proc->cwd);
80106312:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106318:	8b 40 68             	mov    0x68(%eax),%eax
8010631b:	89 04 24             	mov    %eax,(%esp)
8010631e:	e8 f8 b6 ff ff       	call   80101a1b <iput>
  end_op();
80106323:	e8 79 d1 ff ff       	call   801034a1 <end_op>
  proc->cwd = ip;
80106328:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010632e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106331:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106334:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106339:	c9                   	leave  
8010633a:	c3                   	ret    

8010633b <sys_exec>:

int
sys_exec(void)
{
8010633b:	55                   	push   %ebp
8010633c:	89 e5                	mov    %esp,%ebp
8010633e:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106344:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106347:	89 44 24 04          	mov    %eax,0x4(%esp)
8010634b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106352:	e8 7c f3 ff ff       	call   801056d3 <argstr>
80106357:	85 c0                	test   %eax,%eax
80106359:	78 1a                	js     80106375 <sys_exec+0x3a>
8010635b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106361:	89 44 24 04          	mov    %eax,0x4(%esp)
80106365:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010636c:	e8 d2 f2 ff ff       	call   80105643 <argint>
80106371:	85 c0                	test   %eax,%eax
80106373:	79 0a                	jns    8010637f <sys_exec+0x44>
    return -1;
80106375:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637a:	e9 c8 00 00 00       	jmp    80106447 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
8010637f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106386:	00 
80106387:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010638e:	00 
8010638f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106395:	89 04 24             	mov    %eax,(%esp)
80106398:	e8 64 ef ff ff       	call   80105301 <memset>
  for(i=0;; i++){
8010639d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a7:	83 f8 1f             	cmp    $0x1f,%eax
801063aa:	76 0a                	jbe    801063b6 <sys_exec+0x7b>
      return -1;
801063ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b1:	e9 91 00 00 00       	jmp    80106447 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801063b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b9:	c1 e0 02             	shl    $0x2,%eax
801063bc:	89 c2                	mov    %eax,%edx
801063be:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063c4:	01 c2                	add    %eax,%edx
801063c6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801063cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801063d0:	89 14 24             	mov    %edx,(%esp)
801063d3:	e8 cf f1 ff ff       	call   801055a7 <fetchint>
801063d8:	85 c0                	test   %eax,%eax
801063da:	79 07                	jns    801063e3 <sys_exec+0xa8>
      return -1;
801063dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e1:	eb 64                	jmp    80106447 <sys_exec+0x10c>
    if(uarg == 0){
801063e3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063e9:	85 c0                	test   %eax,%eax
801063eb:	75 26                	jne    80106413 <sys_exec+0xd8>
      argv[i] = 0;
801063ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f0:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801063f7:	00 00 00 00 
      break;
801063fb:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801063fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ff:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106405:	89 54 24 04          	mov    %edx,0x4(%esp)
80106409:	89 04 24             	mov    %eax,(%esp)
8010640c:	e8 de a6 ff ff       	call   80100aef <exec>
80106411:	eb 34                	jmp    80106447 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106413:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106419:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010641c:	c1 e2 02             	shl    $0x2,%edx
8010641f:	01 c2                	add    %eax,%edx
80106421:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106427:	89 54 24 04          	mov    %edx,0x4(%esp)
8010642b:	89 04 24             	mov    %eax,(%esp)
8010642e:	e8 ae f1 ff ff       	call   801055e1 <fetchstr>
80106433:	85 c0                	test   %eax,%eax
80106435:	79 07                	jns    8010643e <sys_exec+0x103>
      return -1;
80106437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643c:	eb 09                	jmp    80106447 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010643e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106442:	e9 5d ff ff ff       	jmp    801063a4 <sys_exec+0x69>
  return exec(path, argv);
}
80106447:	c9                   	leave  
80106448:	c3                   	ret    

80106449 <sys_pipe>:

int
sys_pipe(void)
{
80106449:	55                   	push   %ebp
8010644a:	89 e5                	mov    %esp,%ebp
8010644c:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010644f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106456:	00 
80106457:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010645a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010645e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106465:	e8 07 f2 ff ff       	call   80105671 <argptr>
8010646a:	85 c0                	test   %eax,%eax
8010646c:	79 0a                	jns    80106478 <sys_pipe+0x2f>
    return -1;
8010646e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106473:	e9 9b 00 00 00       	jmp    80106513 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106478:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010647b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010647f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106482:	89 04 24             	mov    %eax,(%esp)
80106485:	e8 a4 da ff ff       	call   80103f2e <pipealloc>
8010648a:	85 c0                	test   %eax,%eax
8010648c:	79 07                	jns    80106495 <sys_pipe+0x4c>
    return -1;
8010648e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106493:	eb 7e                	jmp    80106513 <sys_pipe+0xca>
  fd0 = -1;
80106495:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010649c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010649f:	89 04 24             	mov    %eax,(%esp)
801064a2:	e8 67 f3 ff ff       	call   8010580e <fdalloc>
801064a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064ae:	78 14                	js     801064c4 <sys_pipe+0x7b>
801064b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064b3:	89 04 24             	mov    %eax,(%esp)
801064b6:	e8 53 f3 ff ff       	call   8010580e <fdalloc>
801064bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064c2:	79 37                	jns    801064fb <sys_pipe+0xb2>
    if(fd0 >= 0)
801064c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064c8:	78 14                	js     801064de <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801064ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064d3:	83 c2 08             	add    $0x8,%edx
801064d6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064dd:	00 
    fileclose(rf);
801064de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064e1:	89 04 24             	mov    %eax,(%esp)
801064e4:	e8 f2 aa ff ff       	call   80100fdb <fileclose>
    fileclose(wf);
801064e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ec:	89 04 24             	mov    %eax,(%esp)
801064ef:	e8 e7 aa ff ff       	call   80100fdb <fileclose>
    return -1;
801064f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f9:	eb 18                	jmp    80106513 <sys_pipe+0xca>
  }
  fd[0] = fd0;
801064fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106501:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106503:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106506:	8d 50 04             	lea    0x4(%eax),%edx
80106509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650c:	89 02                	mov    %eax,(%edx)
  return 0;
8010650e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106513:	c9                   	leave  
80106514:	c3                   	ret    

80106515 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106515:	55                   	push   %ebp
80106516:	89 e5                	mov    %esp,%ebp
80106518:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010651b:	e8 41 e1 ff ff       	call   80104661 <fork>
}
80106520:	c9                   	leave  
80106521:	c3                   	ret    

80106522 <sys_exit>:

int
sys_exit(void)
{
80106522:	55                   	push   %ebp
80106523:	89 e5                	mov    %esp,%ebp
80106525:	83 ec 08             	sub    $0x8,%esp
  exit();
80106528:	e8 be e2 ff ff       	call   801047eb <exit>
  return 0;  // not reached
8010652d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106532:	c9                   	leave  
80106533:	c3                   	ret    

80106534 <sys_wait>:

int
sys_wait(void)
{
80106534:	55                   	push   %ebp
80106535:	89 e5                	mov    %esp,%ebp
80106537:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010653a:	e8 d1 e3 ff ff       	call   80104910 <wait>
}
8010653f:	c9                   	leave  
80106540:	c3                   	ret    

80106541 <sys_kill>:

int
sys_kill(void)
{
80106541:	55                   	push   %ebp
80106542:	89 e5                	mov    %esp,%ebp
80106544:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106547:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010654a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010654e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106555:	e8 e9 f0 ff ff       	call   80105643 <argint>
8010655a:	85 c0                	test   %eax,%eax
8010655c:	79 07                	jns    80106565 <sys_kill+0x24>
    return -1;
8010655e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106563:	eb 0b                	jmp    80106570 <sys_kill+0x2f>
  return kill(pid);
80106565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106568:	89 04 24             	mov    %eax,(%esp)
8010656b:	e8 e5 e7 ff ff       	call   80104d55 <kill>
}
80106570:	c9                   	leave  
80106571:	c3                   	ret    

80106572 <sys_getpid>:

int
sys_getpid(void)
{
80106572:	55                   	push   %ebp
80106573:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106575:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010657b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010657e:	5d                   	pop    %ebp
8010657f:	c3                   	ret    

80106580 <sys_sbrk>:

int
sys_sbrk(void)
{
80106580:	55                   	push   %ebp
80106581:	89 e5                	mov    %esp,%ebp
80106583:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106586:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106589:	89 44 24 04          	mov    %eax,0x4(%esp)
8010658d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106594:	e8 aa f0 ff ff       	call   80105643 <argint>
80106599:	85 c0                	test   %eax,%eax
8010659b:	79 07                	jns    801065a4 <sys_sbrk+0x24>
    return -1;
8010659d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a2:	eb 24                	jmp    801065c8 <sys_sbrk+0x48>
  addr = proc->sz;
801065a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065aa:	8b 00                	mov    (%eax),%eax
801065ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b2:	89 04 24             	mov    %eax,(%esp)
801065b5:	e8 02 e0 ff ff       	call   801045bc <growproc>
801065ba:	85 c0                	test   %eax,%eax
801065bc:	79 07                	jns    801065c5 <sys_sbrk+0x45>
    return -1;
801065be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c3:	eb 03                	jmp    801065c8 <sys_sbrk+0x48>
  return addr;
801065c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065c8:	c9                   	leave  
801065c9:	c3                   	ret    

801065ca <sys_sleep>:

int
sys_sleep(void)
{
801065ca:	55                   	push   %ebp
801065cb:	89 e5                	mov    %esp,%ebp
801065cd:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801065d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065de:	e8 60 f0 ff ff       	call   80105643 <argint>
801065e3:	85 c0                	test   %eax,%eax
801065e5:	79 07                	jns    801065ee <sys_sleep+0x24>
    return -1;
801065e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ec:	eb 6c                	jmp    8010665a <sys_sleep+0x90>
  acquire(&tickslock);
801065ee:	c7 04 24 a0 7c 11 80 	movl   $0x80117ca0,(%esp)
801065f5:	e8 b3 ea ff ff       	call   801050ad <acquire>
  ticks0 = ticks;
801065fa:	a1 e0 84 11 80       	mov    0x801184e0,%eax
801065ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106602:	eb 34                	jmp    80106638 <sys_sleep+0x6e>
    if(proc->killed){
80106604:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010660a:	8b 40 24             	mov    0x24(%eax),%eax
8010660d:	85 c0                	test   %eax,%eax
8010660f:	74 13                	je     80106624 <sys_sleep+0x5a>
      release(&tickslock);
80106611:	c7 04 24 a0 7c 11 80 	movl   $0x80117ca0,(%esp)
80106618:	e8 f2 ea ff ff       	call   8010510f <release>
      return -1;
8010661d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106622:	eb 36                	jmp    8010665a <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106624:	c7 44 24 04 a0 7c 11 	movl   $0x80117ca0,0x4(%esp)
8010662b:	80 
8010662c:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
80106633:	e8 17 e6 ff ff       	call   80104c4f <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106638:	a1 e0 84 11 80       	mov    0x801184e0,%eax
8010663d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106640:	89 c2                	mov    %eax,%edx
80106642:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106645:	39 c2                	cmp    %eax,%edx
80106647:	72 bb                	jb     80106604 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106649:	c7 04 24 a0 7c 11 80 	movl   $0x80117ca0,(%esp)
80106650:	e8 ba ea ff ff       	call   8010510f <release>
  return 0;
80106655:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010665a:	c9                   	leave  
8010665b:	c3                   	ret    

8010665c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010665c:	55                   	push   %ebp
8010665d:	89 e5                	mov    %esp,%ebp
8010665f:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106662:	c7 04 24 a0 7c 11 80 	movl   $0x80117ca0,(%esp)
80106669:	e8 3f ea ff ff       	call   801050ad <acquire>
  xticks = ticks;
8010666e:	a1 e0 84 11 80       	mov    0x801184e0,%eax
80106673:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106676:	c7 04 24 a0 7c 11 80 	movl   $0x80117ca0,(%esp)
8010667d:	e8 8d ea ff ff       	call   8010510f <release>
  return xticks;
80106682:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106685:	c9                   	leave  
80106686:	c3                   	ret    

80106687 <sys_sigset>:

int
sys_sigset(void)
{
80106687:	55                   	push   %ebp
80106688:	89 e5                	mov    %esp,%ebp
8010668a:	83 ec 28             	sub    $0x28,%esp
  sig_handler new_handler;

  if(argptr(0, (char**)&new_handler, sizeof(sig_handler)) < 0)
8010668d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106694:	00 
80106695:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106698:	89 44 24 04          	mov    %eax,0x4(%esp)
8010669c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066a3:	e8 c9 ef ff ff       	call   80105671 <argptr>
801066a8:	85 c0                	test   %eax,%eax
801066aa:	79 07                	jns    801066b3 <sys_sigset+0x2c>
    return -1;
801066ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b1:	eb 0b                	jmp    801066be <sys_sigset+0x37>
  return (int) sigset(new_handler);
801066b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b6:	89 04 24             	mov    %eax,(%esp)
801066b9:	e8 16 e8 ff ff       	call   80104ed4 <sigset>
}
801066be:	c9                   	leave  
801066bf:	c3                   	ret    

801066c0 <sys_sigsend>:

int
sys_sigsend(void)
{
801066c0:	55                   	push   %ebp
801066c1:	89 e5                	mov    %esp,%ebp
801066c3:	83 ec 28             	sub    $0x28,%esp
  int dest_pid;
  int value;

  if(argint(0, &dest_pid) < 0 || argint(0, &value) < 0)
801066c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801066cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066d4:	e8 6a ef ff ff       	call   80105643 <argint>
801066d9:	85 c0                	test   %eax,%eax
801066db:	78 17                	js     801066f4 <sys_sigsend+0x34>
801066dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066eb:	e8 53 ef ff ff       	call   80105643 <argint>
801066f0:	85 c0                	test   %eax,%eax
801066f2:	79 07                	jns    801066fb <sys_sigsend+0x3b>
    return -1;
801066f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f9:	eb 12                	jmp    8010670d <sys_sigsend+0x4d>

  return sigsend(dest_pid, value);
801066fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801066fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106701:	89 54 24 04          	mov    %edx,0x4(%esp)
80106705:	89 04 24             	mov    %eax,(%esp)
80106708:	e8 ea e7 ff ff       	call   80104ef7 <sigsend>
8010670d:	c9                   	leave  
8010670e:	c3                   	ret    

8010670f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010670f:	55                   	push   %ebp
80106710:	89 e5                	mov    %esp,%ebp
80106712:	83 ec 08             	sub    $0x8,%esp
80106715:	8b 55 08             	mov    0x8(%ebp),%edx
80106718:	8b 45 0c             	mov    0xc(%ebp),%eax
8010671b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010671f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106722:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106726:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010672a:	ee                   	out    %al,(%dx)
}
8010672b:	c9                   	leave  
8010672c:	c3                   	ret    

8010672d <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010672d:	55                   	push   %ebp
8010672e:	89 e5                	mov    %esp,%ebp
80106730:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106733:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010673a:	00 
8010673b:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106742:	e8 c8 ff ff ff       	call   8010670f <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106747:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010674e:	00 
8010674f:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106756:	e8 b4 ff ff ff       	call   8010670f <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010675b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106762:	00 
80106763:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010676a:	e8 a0 ff ff ff       	call   8010670f <outb>
  picenable(IRQ_TIMER);
8010676f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106776:	e8 46 d6 ff ff       	call   80103dc1 <picenable>
}
8010677b:	c9                   	leave  
8010677c:	c3                   	ret    

8010677d <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010677d:	1e                   	push   %ds
  pushl %es
8010677e:	06                   	push   %es
  pushl %fs
8010677f:	0f a0                	push   %fs
  pushl %gs
80106781:	0f a8                	push   %gs
  pushal
80106783:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106784:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106788:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010678a:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010678c:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106790:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106792:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106794:	54                   	push   %esp
  call trap
80106795:	e8 d8 01 00 00       	call   80106972 <trap>
  addl $4, %esp
8010679a:	83 c4 04             	add    $0x4,%esp

8010679d <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010679d:	61                   	popa   
  popl %gs
8010679e:	0f a9                	pop    %gs
  popl %fs
801067a0:	0f a1                	pop    %fs
  popl %es
801067a2:	07                   	pop    %es
  popl %ds
801067a3:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801067a4:	83 c4 08             	add    $0x8,%esp
  iret
801067a7:	cf                   	iret   

801067a8 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801067a8:	55                   	push   %ebp
801067a9:	89 e5                	mov    %esp,%ebp
801067ab:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801067ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801067b1:	83 e8 01             	sub    $0x1,%eax
801067b4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801067b8:	8b 45 08             	mov    0x8(%ebp),%eax
801067bb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801067bf:	8b 45 08             	mov    0x8(%ebp),%eax
801067c2:	c1 e8 10             	shr    $0x10,%eax
801067c5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801067c9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067cc:	0f 01 18             	lidtl  (%eax)
}
801067cf:	c9                   	leave  
801067d0:	c3                   	ret    

801067d1 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801067d1:	55                   	push   %ebp
801067d2:	89 e5                	mov    %esp,%ebp
801067d4:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067d7:	0f 20 d0             	mov    %cr2,%eax
801067da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801067dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801067e0:	c9                   	leave  
801067e1:	c3                   	ret    

801067e2 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067e2:	55                   	push   %ebp
801067e3:	89 e5                	mov    %esp,%ebp
801067e5:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801067e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067ef:	e9 c3 00 00 00       	jmp    801068b7 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f7:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801067fe:	89 c2                	mov    %eax,%edx
80106800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106803:	66 89 14 c5 e0 7c 11 	mov    %dx,-0x7fee8320(,%eax,8)
8010680a:	80 
8010680b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680e:	66 c7 04 c5 e2 7c 11 	movw   $0x8,-0x7fee831e(,%eax,8)
80106815:	80 08 00 
80106818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681b:	0f b6 14 c5 e4 7c 11 	movzbl -0x7fee831c(,%eax,8),%edx
80106822:	80 
80106823:	83 e2 e0             	and    $0xffffffe0,%edx
80106826:	88 14 c5 e4 7c 11 80 	mov    %dl,-0x7fee831c(,%eax,8)
8010682d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106830:	0f b6 14 c5 e4 7c 11 	movzbl -0x7fee831c(,%eax,8),%edx
80106837:	80 
80106838:	83 e2 1f             	and    $0x1f,%edx
8010683b:	88 14 c5 e4 7c 11 80 	mov    %dl,-0x7fee831c(,%eax,8)
80106842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106845:	0f b6 14 c5 e5 7c 11 	movzbl -0x7fee831b(,%eax,8),%edx
8010684c:	80 
8010684d:	83 e2 f0             	and    $0xfffffff0,%edx
80106850:	83 ca 0e             	or     $0xe,%edx
80106853:	88 14 c5 e5 7c 11 80 	mov    %dl,-0x7fee831b(,%eax,8)
8010685a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685d:	0f b6 14 c5 e5 7c 11 	movzbl -0x7fee831b(,%eax,8),%edx
80106864:	80 
80106865:	83 e2 ef             	and    $0xffffffef,%edx
80106868:	88 14 c5 e5 7c 11 80 	mov    %dl,-0x7fee831b(,%eax,8)
8010686f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106872:	0f b6 14 c5 e5 7c 11 	movzbl -0x7fee831b(,%eax,8),%edx
80106879:	80 
8010687a:	83 e2 9f             	and    $0xffffff9f,%edx
8010687d:	88 14 c5 e5 7c 11 80 	mov    %dl,-0x7fee831b(,%eax,8)
80106884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106887:	0f b6 14 c5 e5 7c 11 	movzbl -0x7fee831b(,%eax,8),%edx
8010688e:	80 
8010688f:	83 ca 80             	or     $0xffffff80,%edx
80106892:	88 14 c5 e5 7c 11 80 	mov    %dl,-0x7fee831b(,%eax,8)
80106899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689c:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801068a3:	c1 e8 10             	shr    $0x10,%eax
801068a6:	89 c2                	mov    %eax,%edx
801068a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ab:	66 89 14 c5 e6 7c 11 	mov    %dx,-0x7fee831a(,%eax,8)
801068b2:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801068b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801068b7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801068be:	0f 8e 30 ff ff ff    	jle    801067f4 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801068c4:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
801068c9:	66 a3 e0 7e 11 80    	mov    %ax,0x80117ee0
801068cf:	66 c7 05 e2 7e 11 80 	movw   $0x8,0x80117ee2
801068d6:	08 00 
801068d8:	0f b6 05 e4 7e 11 80 	movzbl 0x80117ee4,%eax
801068df:	83 e0 e0             	and    $0xffffffe0,%eax
801068e2:	a2 e4 7e 11 80       	mov    %al,0x80117ee4
801068e7:	0f b6 05 e4 7e 11 80 	movzbl 0x80117ee4,%eax
801068ee:	83 e0 1f             	and    $0x1f,%eax
801068f1:	a2 e4 7e 11 80       	mov    %al,0x80117ee4
801068f6:	0f b6 05 e5 7e 11 80 	movzbl 0x80117ee5,%eax
801068fd:	83 c8 0f             	or     $0xf,%eax
80106900:	a2 e5 7e 11 80       	mov    %al,0x80117ee5
80106905:	0f b6 05 e5 7e 11 80 	movzbl 0x80117ee5,%eax
8010690c:	83 e0 ef             	and    $0xffffffef,%eax
8010690f:	a2 e5 7e 11 80       	mov    %al,0x80117ee5
80106914:	0f b6 05 e5 7e 11 80 	movzbl 0x80117ee5,%eax
8010691b:	83 c8 60             	or     $0x60,%eax
8010691e:	a2 e5 7e 11 80       	mov    %al,0x80117ee5
80106923:	0f b6 05 e5 7e 11 80 	movzbl 0x80117ee5,%eax
8010692a:	83 c8 80             	or     $0xffffff80,%eax
8010692d:	a2 e5 7e 11 80       	mov    %al,0x80117ee5
80106932:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106937:	c1 e8 10             	shr    $0x10,%eax
8010693a:	66 a3 e6 7e 11 80    	mov    %ax,0x80117ee6
  
  initlock(&tickslock, "time");
80106940:	c7 44 24 04 70 8b 10 	movl   $0x80108b70,0x4(%esp)
80106947:	80 
80106948:	c7 04 24 a0 7c 11 80 	movl   $0x80117ca0,(%esp)
8010694f:	e8 38 e7 ff ff       	call   8010508c <initlock>
}
80106954:	c9                   	leave  
80106955:	c3                   	ret    

80106956 <idtinit>:

void
idtinit(void)
{
80106956:	55                   	push   %ebp
80106957:	89 e5                	mov    %esp,%ebp
80106959:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010695c:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106963:	00 
80106964:	c7 04 24 e0 7c 11 80 	movl   $0x80117ce0,(%esp)
8010696b:	e8 38 fe ff ff       	call   801067a8 <lidt>
}
80106970:	c9                   	leave  
80106971:	c3                   	ret    

80106972 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106972:	55                   	push   %ebp
80106973:	89 e5                	mov    %esp,%ebp
80106975:	57                   	push   %edi
80106976:	56                   	push   %esi
80106977:	53                   	push   %ebx
80106978:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010697b:	8b 45 08             	mov    0x8(%ebp),%eax
8010697e:	8b 40 30             	mov    0x30(%eax),%eax
80106981:	83 f8 40             	cmp    $0x40,%eax
80106984:	75 3f                	jne    801069c5 <trap+0x53>
    if(proc->killed)
80106986:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010698c:	8b 40 24             	mov    0x24(%eax),%eax
8010698f:	85 c0                	test   %eax,%eax
80106991:	74 05                	je     80106998 <trap+0x26>
      exit();
80106993:	e8 53 de ff ff       	call   801047eb <exit>
    proc->tf = tf;
80106998:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010699e:	8b 55 08             	mov    0x8(%ebp),%edx
801069a1:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801069a4:	e8 61 ed ff ff       	call   8010570a <syscall>
    if(proc->killed)
801069a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069af:	8b 40 24             	mov    0x24(%eax),%eax
801069b2:	85 c0                	test   %eax,%eax
801069b4:	74 0a                	je     801069c0 <trap+0x4e>
      exit();
801069b6:	e8 30 de ff ff       	call   801047eb <exit>
    return;
801069bb:	e9 2d 02 00 00       	jmp    80106bed <trap+0x27b>
801069c0:	e9 28 02 00 00       	jmp    80106bed <trap+0x27b>
  }

  switch(tf->trapno){
801069c5:	8b 45 08             	mov    0x8(%ebp),%eax
801069c8:	8b 40 30             	mov    0x30(%eax),%eax
801069cb:	83 e8 20             	sub    $0x20,%eax
801069ce:	83 f8 1f             	cmp    $0x1f,%eax
801069d1:	0f 87 bc 00 00 00    	ja     80106a93 <trap+0x121>
801069d7:	8b 04 85 18 8c 10 80 	mov    -0x7fef73e8(,%eax,4),%eax
801069de:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801069e0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069e6:	0f b6 00             	movzbl (%eax),%eax
801069e9:	84 c0                	test   %al,%al
801069eb:	75 31                	jne    80106a1e <trap+0xac>
      acquire(&tickslock);
801069ed:	c7 04 24 a0 7c 11 80 	movl   $0x80117ca0,(%esp)
801069f4:	e8 b4 e6 ff ff       	call   801050ad <acquire>
      ticks++;
801069f9:	a1 e0 84 11 80       	mov    0x801184e0,%eax
801069fe:	83 c0 01             	add    $0x1,%eax
80106a01:	a3 e0 84 11 80       	mov    %eax,0x801184e0
      wakeup(&ticks);
80106a06:	c7 04 24 e0 84 11 80 	movl   $0x801184e0,(%esp)
80106a0d:	e8 18 e3 ff ff       	call   80104d2a <wakeup>
      release(&tickslock);
80106a12:	c7 04 24 a0 7c 11 80 	movl   $0x80117ca0,(%esp)
80106a19:	e8 f1 e6 ff ff       	call   8010510f <release>
    }
    lapiceoi();
80106a1e:	e8 ba c4 ff ff       	call   80102edd <lapiceoi>
    break;
80106a23:	e9 41 01 00 00       	jmp    80106b69 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a28:	e8 be bc ff ff       	call   801026eb <ideintr>
    lapiceoi();
80106a2d:	e8 ab c4 ff ff       	call   80102edd <lapiceoi>
    break;
80106a32:	e9 32 01 00 00       	jmp    80106b69 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a37:	e8 70 c2 ff ff       	call   80102cac <kbdintr>
    lapiceoi();
80106a3c:	e8 9c c4 ff ff       	call   80102edd <lapiceoi>
    break;
80106a41:	e9 23 01 00 00       	jmp    80106b69 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a46:	e8 97 03 00 00       	call   80106de2 <uartintr>
    lapiceoi();
80106a4b:	e8 8d c4 ff ff       	call   80102edd <lapiceoi>
    break;
80106a50:	e9 14 01 00 00       	jmp    80106b69 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a55:	8b 45 08             	mov    0x8(%ebp),%eax
80106a58:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a5e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a62:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106a65:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a6b:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a6e:	0f b6 c0             	movzbl %al,%eax
80106a71:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a75:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a79:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a7d:	c7 04 24 78 8b 10 80 	movl   $0x80108b78,(%esp)
80106a84:	e8 17 99 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106a89:	e8 4f c4 ff ff       	call   80102edd <lapiceoi>
    break;
80106a8e:	e9 d6 00 00 00       	jmp    80106b69 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a99:	85 c0                	test   %eax,%eax
80106a9b:	74 11                	je     80106aae <trap+0x13c>
80106a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106aa4:	0f b7 c0             	movzwl %ax,%eax
80106aa7:	83 e0 03             	and    $0x3,%eax
80106aaa:	85 c0                	test   %eax,%eax
80106aac:	75 46                	jne    80106af4 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106aae:	e8 1e fd ff ff       	call   801067d1 <rcr2>
80106ab3:	8b 55 08             	mov    0x8(%ebp),%edx
80106ab6:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106ab9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106ac0:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ac3:	0f b6 ca             	movzbl %dl,%ecx
80106ac6:	8b 55 08             	mov    0x8(%ebp),%edx
80106ac9:	8b 52 30             	mov    0x30(%edx),%edx
80106acc:	89 44 24 10          	mov    %eax,0x10(%esp)
80106ad0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106ad4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106ad8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106adc:	c7 04 24 9c 8b 10 80 	movl   $0x80108b9c,(%esp)
80106ae3:	e8 b8 98 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106ae8:	c7 04 24 ce 8b 10 80 	movl   $0x80108bce,(%esp)
80106aef:	e8 46 9a ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106af4:	e8 d8 fc ff ff       	call   801067d1 <rcr2>
80106af9:	89 c2                	mov    %eax,%edx
80106afb:	8b 45 08             	mov    0x8(%ebp),%eax
80106afe:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b01:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b07:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b0a:	0f b6 f0             	movzbl %al,%esi
80106b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b10:	8b 58 34             	mov    0x34(%eax),%ebx
80106b13:	8b 45 08             	mov    0x8(%ebp),%eax
80106b16:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b1f:	83 c0 6c             	add    $0x6c,%eax
80106b22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b25:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b2b:	8b 40 10             	mov    0x10(%eax),%eax
80106b2e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106b32:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106b36:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b3a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b3e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b42:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106b45:	89 74 24 08          	mov    %esi,0x8(%esp)
80106b49:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b4d:	c7 04 24 d4 8b 10 80 	movl   $0x80108bd4,(%esp)
80106b54:	e8 47 98 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106b59:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b5f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b66:	eb 01                	jmp    80106b69 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106b68:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b6f:	85 c0                	test   %eax,%eax
80106b71:	74 24                	je     80106b97 <trap+0x225>
80106b73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b79:	8b 40 24             	mov    0x24(%eax),%eax
80106b7c:	85 c0                	test   %eax,%eax
80106b7e:	74 17                	je     80106b97 <trap+0x225>
80106b80:	8b 45 08             	mov    0x8(%ebp),%eax
80106b83:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b87:	0f b7 c0             	movzwl %ax,%eax
80106b8a:	83 e0 03             	and    $0x3,%eax
80106b8d:	83 f8 03             	cmp    $0x3,%eax
80106b90:	75 05                	jne    80106b97 <trap+0x225>
    exit();
80106b92:	e8 54 dc ff ff       	call   801047eb <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106b97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b9d:	85 c0                	test   %eax,%eax
80106b9f:	74 1e                	je     80106bbf <trap+0x24d>
80106ba1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ba7:	8b 40 0c             	mov    0xc(%eax),%eax
80106baa:	83 f8 04             	cmp    $0x4,%eax
80106bad:	75 10                	jne    80106bbf <trap+0x24d>
80106baf:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb2:	8b 40 30             	mov    0x30(%eax),%eax
80106bb5:	83 f8 20             	cmp    $0x20,%eax
80106bb8:	75 05                	jne    80106bbf <trap+0x24d>
    yield();
80106bba:	e8 32 e0 ff ff       	call   80104bf1 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106bbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc5:	85 c0                	test   %eax,%eax
80106bc7:	74 24                	je     80106bed <trap+0x27b>
80106bc9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bcf:	8b 40 24             	mov    0x24(%eax),%eax
80106bd2:	85 c0                	test   %eax,%eax
80106bd4:	74 17                	je     80106bed <trap+0x27b>
80106bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bdd:	0f b7 c0             	movzwl %ax,%eax
80106be0:	83 e0 03             	and    $0x3,%eax
80106be3:	83 f8 03             	cmp    $0x3,%eax
80106be6:	75 05                	jne    80106bed <trap+0x27b>
    exit();
80106be8:	e8 fe db ff ff       	call   801047eb <exit>
}
80106bed:	83 c4 3c             	add    $0x3c,%esp
80106bf0:	5b                   	pop    %ebx
80106bf1:	5e                   	pop    %esi
80106bf2:	5f                   	pop    %edi
80106bf3:	5d                   	pop    %ebp
80106bf4:	c3                   	ret    

80106bf5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106bf5:	55                   	push   %ebp
80106bf6:	89 e5                	mov    %esp,%ebp
80106bf8:	83 ec 14             	sub    $0x14,%esp
80106bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80106bfe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c02:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106c06:	89 c2                	mov    %eax,%edx
80106c08:	ec                   	in     (%dx),%al
80106c09:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106c0c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106c10:	c9                   	leave  
80106c11:	c3                   	ret    

80106c12 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c12:	55                   	push   %ebp
80106c13:	89 e5                	mov    %esp,%ebp
80106c15:	83 ec 08             	sub    $0x8,%esp
80106c18:	8b 55 08             	mov    0x8(%ebp),%edx
80106c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c1e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c22:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c25:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c29:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c2d:	ee                   	out    %al,(%dx)
}
80106c2e:	c9                   	leave  
80106c2f:	c3                   	ret    

80106c30 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c30:	55                   	push   %ebp
80106c31:	89 e5                	mov    %esp,%ebp
80106c33:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c3d:	00 
80106c3e:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c45:	e8 c8 ff ff ff       	call   80106c12 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c4a:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106c51:	00 
80106c52:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c59:	e8 b4 ff ff ff       	call   80106c12 <outb>
  outb(COM1+0, 115200/9600);
80106c5e:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106c65:	00 
80106c66:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c6d:	e8 a0 ff ff ff       	call   80106c12 <outb>
  outb(COM1+1, 0);
80106c72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c79:	00 
80106c7a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c81:	e8 8c ff ff ff       	call   80106c12 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c86:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c8d:	00 
80106c8e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c95:	e8 78 ff ff ff       	call   80106c12 <outb>
  outb(COM1+4, 0);
80106c9a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ca1:	00 
80106ca2:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106ca9:	e8 64 ff ff ff       	call   80106c12 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106cae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106cb5:	00 
80106cb6:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106cbd:	e8 50 ff ff ff       	call   80106c12 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106cc2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106cc9:	e8 27 ff ff ff       	call   80106bf5 <inb>
80106cce:	3c ff                	cmp    $0xff,%al
80106cd0:	75 02                	jne    80106cd4 <uartinit+0xa4>
    return;
80106cd2:	eb 6a                	jmp    80106d3e <uartinit+0x10e>
  uart = 1;
80106cd4:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106cdb:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106cde:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106ce5:	e8 0b ff ff ff       	call   80106bf5 <inb>
  inb(COM1+0);
80106cea:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cf1:	e8 ff fe ff ff       	call   80106bf5 <inb>
  picenable(IRQ_COM1);
80106cf6:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106cfd:	e8 bf d0 ff ff       	call   80103dc1 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106d02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d09:	00 
80106d0a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d11:	e8 54 bc ff ff       	call   8010296a <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d16:	c7 45 f4 98 8c 10 80 	movl   $0x80108c98,-0xc(%ebp)
80106d1d:	eb 15                	jmp    80106d34 <uartinit+0x104>
    uartputc(*p);
80106d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d22:	0f b6 00             	movzbl (%eax),%eax
80106d25:	0f be c0             	movsbl %al,%eax
80106d28:	89 04 24             	mov    %eax,(%esp)
80106d2b:	e8 10 00 00 00       	call   80106d40 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d30:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d37:	0f b6 00             	movzbl (%eax),%eax
80106d3a:	84 c0                	test   %al,%al
80106d3c:	75 e1                	jne    80106d1f <uartinit+0xef>
    uartputc(*p);
}
80106d3e:	c9                   	leave  
80106d3f:	c3                   	ret    

80106d40 <uartputc>:

void
uartputc(int c)
{
80106d40:	55                   	push   %ebp
80106d41:	89 e5                	mov    %esp,%ebp
80106d43:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106d46:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106d4b:	85 c0                	test   %eax,%eax
80106d4d:	75 02                	jne    80106d51 <uartputc+0x11>
    return;
80106d4f:	eb 4b                	jmp    80106d9c <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d58:	eb 10                	jmp    80106d6a <uartputc+0x2a>
    microdelay(10);
80106d5a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106d61:	e8 9c c1 ff ff       	call   80102f02 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d6a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d6e:	7f 16                	jg     80106d86 <uartputc+0x46>
80106d70:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d77:	e8 79 fe ff ff       	call   80106bf5 <inb>
80106d7c:	0f b6 c0             	movzbl %al,%eax
80106d7f:	83 e0 20             	and    $0x20,%eax
80106d82:	85 c0                	test   %eax,%eax
80106d84:	74 d4                	je     80106d5a <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106d86:	8b 45 08             	mov    0x8(%ebp),%eax
80106d89:	0f b6 c0             	movzbl %al,%eax
80106d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d90:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d97:	e8 76 fe ff ff       	call   80106c12 <outb>
}
80106d9c:	c9                   	leave  
80106d9d:	c3                   	ret    

80106d9e <uartgetc>:

static int
uartgetc(void)
{
80106d9e:	55                   	push   %ebp
80106d9f:	89 e5                	mov    %esp,%ebp
80106da1:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106da4:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106da9:	85 c0                	test   %eax,%eax
80106dab:	75 07                	jne    80106db4 <uartgetc+0x16>
    return -1;
80106dad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106db2:	eb 2c                	jmp    80106de0 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106db4:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dbb:	e8 35 fe ff ff       	call   80106bf5 <inb>
80106dc0:	0f b6 c0             	movzbl %al,%eax
80106dc3:	83 e0 01             	and    $0x1,%eax
80106dc6:	85 c0                	test   %eax,%eax
80106dc8:	75 07                	jne    80106dd1 <uartgetc+0x33>
    return -1;
80106dca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dcf:	eb 0f                	jmp    80106de0 <uartgetc+0x42>
  return inb(COM1+0);
80106dd1:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106dd8:	e8 18 fe ff ff       	call   80106bf5 <inb>
80106ddd:	0f b6 c0             	movzbl %al,%eax
}
80106de0:	c9                   	leave  
80106de1:	c3                   	ret    

80106de2 <uartintr>:

void
uartintr(void)
{
80106de2:	55                   	push   %ebp
80106de3:	89 e5                	mov    %esp,%ebp
80106de5:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106de8:	c7 04 24 9e 6d 10 80 	movl   $0x80106d9e,(%esp)
80106def:	e8 b9 99 ff ff       	call   801007ad <consoleintr>
}
80106df4:	c9                   	leave  
80106df5:	c3                   	ret    

80106df6 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106df6:	6a 00                	push   $0x0
  pushl $0
80106df8:	6a 00                	push   $0x0
  jmp alltraps
80106dfa:	e9 7e f9 ff ff       	jmp    8010677d <alltraps>

80106dff <vector1>:
.globl vector1
vector1:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $1
80106e01:	6a 01                	push   $0x1
  jmp alltraps
80106e03:	e9 75 f9 ff ff       	jmp    8010677d <alltraps>

80106e08 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e08:	6a 00                	push   $0x0
  pushl $2
80106e0a:	6a 02                	push   $0x2
  jmp alltraps
80106e0c:	e9 6c f9 ff ff       	jmp    8010677d <alltraps>

80106e11 <vector3>:
.globl vector3
vector3:
  pushl $0
80106e11:	6a 00                	push   $0x0
  pushl $3
80106e13:	6a 03                	push   $0x3
  jmp alltraps
80106e15:	e9 63 f9 ff ff       	jmp    8010677d <alltraps>

80106e1a <vector4>:
.globl vector4
vector4:
  pushl $0
80106e1a:	6a 00                	push   $0x0
  pushl $4
80106e1c:	6a 04                	push   $0x4
  jmp alltraps
80106e1e:	e9 5a f9 ff ff       	jmp    8010677d <alltraps>

80106e23 <vector5>:
.globl vector5
vector5:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $5
80106e25:	6a 05                	push   $0x5
  jmp alltraps
80106e27:	e9 51 f9 ff ff       	jmp    8010677d <alltraps>

80106e2c <vector6>:
.globl vector6
vector6:
  pushl $0
80106e2c:	6a 00                	push   $0x0
  pushl $6
80106e2e:	6a 06                	push   $0x6
  jmp alltraps
80106e30:	e9 48 f9 ff ff       	jmp    8010677d <alltraps>

80106e35 <vector7>:
.globl vector7
vector7:
  pushl $0
80106e35:	6a 00                	push   $0x0
  pushl $7
80106e37:	6a 07                	push   $0x7
  jmp alltraps
80106e39:	e9 3f f9 ff ff       	jmp    8010677d <alltraps>

80106e3e <vector8>:
.globl vector8
vector8:
  pushl $8
80106e3e:	6a 08                	push   $0x8
  jmp alltraps
80106e40:	e9 38 f9 ff ff       	jmp    8010677d <alltraps>

80106e45 <vector9>:
.globl vector9
vector9:
  pushl $0
80106e45:	6a 00                	push   $0x0
  pushl $9
80106e47:	6a 09                	push   $0x9
  jmp alltraps
80106e49:	e9 2f f9 ff ff       	jmp    8010677d <alltraps>

80106e4e <vector10>:
.globl vector10
vector10:
  pushl $10
80106e4e:	6a 0a                	push   $0xa
  jmp alltraps
80106e50:	e9 28 f9 ff ff       	jmp    8010677d <alltraps>

80106e55 <vector11>:
.globl vector11
vector11:
  pushl $11
80106e55:	6a 0b                	push   $0xb
  jmp alltraps
80106e57:	e9 21 f9 ff ff       	jmp    8010677d <alltraps>

80106e5c <vector12>:
.globl vector12
vector12:
  pushl $12
80106e5c:	6a 0c                	push   $0xc
  jmp alltraps
80106e5e:	e9 1a f9 ff ff       	jmp    8010677d <alltraps>

80106e63 <vector13>:
.globl vector13
vector13:
  pushl $13
80106e63:	6a 0d                	push   $0xd
  jmp alltraps
80106e65:	e9 13 f9 ff ff       	jmp    8010677d <alltraps>

80106e6a <vector14>:
.globl vector14
vector14:
  pushl $14
80106e6a:	6a 0e                	push   $0xe
  jmp alltraps
80106e6c:	e9 0c f9 ff ff       	jmp    8010677d <alltraps>

80106e71 <vector15>:
.globl vector15
vector15:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $15
80106e73:	6a 0f                	push   $0xf
  jmp alltraps
80106e75:	e9 03 f9 ff ff       	jmp    8010677d <alltraps>

80106e7a <vector16>:
.globl vector16
vector16:
  pushl $0
80106e7a:	6a 00                	push   $0x0
  pushl $16
80106e7c:	6a 10                	push   $0x10
  jmp alltraps
80106e7e:	e9 fa f8 ff ff       	jmp    8010677d <alltraps>

80106e83 <vector17>:
.globl vector17
vector17:
  pushl $17
80106e83:	6a 11                	push   $0x11
  jmp alltraps
80106e85:	e9 f3 f8 ff ff       	jmp    8010677d <alltraps>

80106e8a <vector18>:
.globl vector18
vector18:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $18
80106e8c:	6a 12                	push   $0x12
  jmp alltraps
80106e8e:	e9 ea f8 ff ff       	jmp    8010677d <alltraps>

80106e93 <vector19>:
.globl vector19
vector19:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $19
80106e95:	6a 13                	push   $0x13
  jmp alltraps
80106e97:	e9 e1 f8 ff ff       	jmp    8010677d <alltraps>

80106e9c <vector20>:
.globl vector20
vector20:
  pushl $0
80106e9c:	6a 00                	push   $0x0
  pushl $20
80106e9e:	6a 14                	push   $0x14
  jmp alltraps
80106ea0:	e9 d8 f8 ff ff       	jmp    8010677d <alltraps>

80106ea5 <vector21>:
.globl vector21
vector21:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $21
80106ea7:	6a 15                	push   $0x15
  jmp alltraps
80106ea9:	e9 cf f8 ff ff       	jmp    8010677d <alltraps>

80106eae <vector22>:
.globl vector22
vector22:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $22
80106eb0:	6a 16                	push   $0x16
  jmp alltraps
80106eb2:	e9 c6 f8 ff ff       	jmp    8010677d <alltraps>

80106eb7 <vector23>:
.globl vector23
vector23:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $23
80106eb9:	6a 17                	push   $0x17
  jmp alltraps
80106ebb:	e9 bd f8 ff ff       	jmp    8010677d <alltraps>

80106ec0 <vector24>:
.globl vector24
vector24:
  pushl $0
80106ec0:	6a 00                	push   $0x0
  pushl $24
80106ec2:	6a 18                	push   $0x18
  jmp alltraps
80106ec4:	e9 b4 f8 ff ff       	jmp    8010677d <alltraps>

80106ec9 <vector25>:
.globl vector25
vector25:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $25
80106ecb:	6a 19                	push   $0x19
  jmp alltraps
80106ecd:	e9 ab f8 ff ff       	jmp    8010677d <alltraps>

80106ed2 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $26
80106ed4:	6a 1a                	push   $0x1a
  jmp alltraps
80106ed6:	e9 a2 f8 ff ff       	jmp    8010677d <alltraps>

80106edb <vector27>:
.globl vector27
vector27:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $27
80106edd:	6a 1b                	push   $0x1b
  jmp alltraps
80106edf:	e9 99 f8 ff ff       	jmp    8010677d <alltraps>

80106ee4 <vector28>:
.globl vector28
vector28:
  pushl $0
80106ee4:	6a 00                	push   $0x0
  pushl $28
80106ee6:	6a 1c                	push   $0x1c
  jmp alltraps
80106ee8:	e9 90 f8 ff ff       	jmp    8010677d <alltraps>

80106eed <vector29>:
.globl vector29
vector29:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $29
80106eef:	6a 1d                	push   $0x1d
  jmp alltraps
80106ef1:	e9 87 f8 ff ff       	jmp    8010677d <alltraps>

80106ef6 <vector30>:
.globl vector30
vector30:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $30
80106ef8:	6a 1e                	push   $0x1e
  jmp alltraps
80106efa:	e9 7e f8 ff ff       	jmp    8010677d <alltraps>

80106eff <vector31>:
.globl vector31
vector31:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $31
80106f01:	6a 1f                	push   $0x1f
  jmp alltraps
80106f03:	e9 75 f8 ff ff       	jmp    8010677d <alltraps>

80106f08 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f08:	6a 00                	push   $0x0
  pushl $32
80106f0a:	6a 20                	push   $0x20
  jmp alltraps
80106f0c:	e9 6c f8 ff ff       	jmp    8010677d <alltraps>

80106f11 <vector33>:
.globl vector33
vector33:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $33
80106f13:	6a 21                	push   $0x21
  jmp alltraps
80106f15:	e9 63 f8 ff ff       	jmp    8010677d <alltraps>

80106f1a <vector34>:
.globl vector34
vector34:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $34
80106f1c:	6a 22                	push   $0x22
  jmp alltraps
80106f1e:	e9 5a f8 ff ff       	jmp    8010677d <alltraps>

80106f23 <vector35>:
.globl vector35
vector35:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $35
80106f25:	6a 23                	push   $0x23
  jmp alltraps
80106f27:	e9 51 f8 ff ff       	jmp    8010677d <alltraps>

80106f2c <vector36>:
.globl vector36
vector36:
  pushl $0
80106f2c:	6a 00                	push   $0x0
  pushl $36
80106f2e:	6a 24                	push   $0x24
  jmp alltraps
80106f30:	e9 48 f8 ff ff       	jmp    8010677d <alltraps>

80106f35 <vector37>:
.globl vector37
vector37:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $37
80106f37:	6a 25                	push   $0x25
  jmp alltraps
80106f39:	e9 3f f8 ff ff       	jmp    8010677d <alltraps>

80106f3e <vector38>:
.globl vector38
vector38:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $38
80106f40:	6a 26                	push   $0x26
  jmp alltraps
80106f42:	e9 36 f8 ff ff       	jmp    8010677d <alltraps>

80106f47 <vector39>:
.globl vector39
vector39:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $39
80106f49:	6a 27                	push   $0x27
  jmp alltraps
80106f4b:	e9 2d f8 ff ff       	jmp    8010677d <alltraps>

80106f50 <vector40>:
.globl vector40
vector40:
  pushl $0
80106f50:	6a 00                	push   $0x0
  pushl $40
80106f52:	6a 28                	push   $0x28
  jmp alltraps
80106f54:	e9 24 f8 ff ff       	jmp    8010677d <alltraps>

80106f59 <vector41>:
.globl vector41
vector41:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $41
80106f5b:	6a 29                	push   $0x29
  jmp alltraps
80106f5d:	e9 1b f8 ff ff       	jmp    8010677d <alltraps>

80106f62 <vector42>:
.globl vector42
vector42:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $42
80106f64:	6a 2a                	push   $0x2a
  jmp alltraps
80106f66:	e9 12 f8 ff ff       	jmp    8010677d <alltraps>

80106f6b <vector43>:
.globl vector43
vector43:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $43
80106f6d:	6a 2b                	push   $0x2b
  jmp alltraps
80106f6f:	e9 09 f8 ff ff       	jmp    8010677d <alltraps>

80106f74 <vector44>:
.globl vector44
vector44:
  pushl $0
80106f74:	6a 00                	push   $0x0
  pushl $44
80106f76:	6a 2c                	push   $0x2c
  jmp alltraps
80106f78:	e9 00 f8 ff ff       	jmp    8010677d <alltraps>

80106f7d <vector45>:
.globl vector45
vector45:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $45
80106f7f:	6a 2d                	push   $0x2d
  jmp alltraps
80106f81:	e9 f7 f7 ff ff       	jmp    8010677d <alltraps>

80106f86 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f86:	6a 00                	push   $0x0
  pushl $46
80106f88:	6a 2e                	push   $0x2e
  jmp alltraps
80106f8a:	e9 ee f7 ff ff       	jmp    8010677d <alltraps>

80106f8f <vector47>:
.globl vector47
vector47:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $47
80106f91:	6a 2f                	push   $0x2f
  jmp alltraps
80106f93:	e9 e5 f7 ff ff       	jmp    8010677d <alltraps>

80106f98 <vector48>:
.globl vector48
vector48:
  pushl $0
80106f98:	6a 00                	push   $0x0
  pushl $48
80106f9a:	6a 30                	push   $0x30
  jmp alltraps
80106f9c:	e9 dc f7 ff ff       	jmp    8010677d <alltraps>

80106fa1 <vector49>:
.globl vector49
vector49:
  pushl $0
80106fa1:	6a 00                	push   $0x0
  pushl $49
80106fa3:	6a 31                	push   $0x31
  jmp alltraps
80106fa5:	e9 d3 f7 ff ff       	jmp    8010677d <alltraps>

80106faa <vector50>:
.globl vector50
vector50:
  pushl $0
80106faa:	6a 00                	push   $0x0
  pushl $50
80106fac:	6a 32                	push   $0x32
  jmp alltraps
80106fae:	e9 ca f7 ff ff       	jmp    8010677d <alltraps>

80106fb3 <vector51>:
.globl vector51
vector51:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $51
80106fb5:	6a 33                	push   $0x33
  jmp alltraps
80106fb7:	e9 c1 f7 ff ff       	jmp    8010677d <alltraps>

80106fbc <vector52>:
.globl vector52
vector52:
  pushl $0
80106fbc:	6a 00                	push   $0x0
  pushl $52
80106fbe:	6a 34                	push   $0x34
  jmp alltraps
80106fc0:	e9 b8 f7 ff ff       	jmp    8010677d <alltraps>

80106fc5 <vector53>:
.globl vector53
vector53:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $53
80106fc7:	6a 35                	push   $0x35
  jmp alltraps
80106fc9:	e9 af f7 ff ff       	jmp    8010677d <alltraps>

80106fce <vector54>:
.globl vector54
vector54:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $54
80106fd0:	6a 36                	push   $0x36
  jmp alltraps
80106fd2:	e9 a6 f7 ff ff       	jmp    8010677d <alltraps>

80106fd7 <vector55>:
.globl vector55
vector55:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $55
80106fd9:	6a 37                	push   $0x37
  jmp alltraps
80106fdb:	e9 9d f7 ff ff       	jmp    8010677d <alltraps>

80106fe0 <vector56>:
.globl vector56
vector56:
  pushl $0
80106fe0:	6a 00                	push   $0x0
  pushl $56
80106fe2:	6a 38                	push   $0x38
  jmp alltraps
80106fe4:	e9 94 f7 ff ff       	jmp    8010677d <alltraps>

80106fe9 <vector57>:
.globl vector57
vector57:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $57
80106feb:	6a 39                	push   $0x39
  jmp alltraps
80106fed:	e9 8b f7 ff ff       	jmp    8010677d <alltraps>

80106ff2 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $58
80106ff4:	6a 3a                	push   $0x3a
  jmp alltraps
80106ff6:	e9 82 f7 ff ff       	jmp    8010677d <alltraps>

80106ffb <vector59>:
.globl vector59
vector59:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $59
80106ffd:	6a 3b                	push   $0x3b
  jmp alltraps
80106fff:	e9 79 f7 ff ff       	jmp    8010677d <alltraps>

80107004 <vector60>:
.globl vector60
vector60:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $60
80107006:	6a 3c                	push   $0x3c
  jmp alltraps
80107008:	e9 70 f7 ff ff       	jmp    8010677d <alltraps>

8010700d <vector61>:
.globl vector61
vector61:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $61
8010700f:	6a 3d                	push   $0x3d
  jmp alltraps
80107011:	e9 67 f7 ff ff       	jmp    8010677d <alltraps>

80107016 <vector62>:
.globl vector62
vector62:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $62
80107018:	6a 3e                	push   $0x3e
  jmp alltraps
8010701a:	e9 5e f7 ff ff       	jmp    8010677d <alltraps>

8010701f <vector63>:
.globl vector63
vector63:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $63
80107021:	6a 3f                	push   $0x3f
  jmp alltraps
80107023:	e9 55 f7 ff ff       	jmp    8010677d <alltraps>

80107028 <vector64>:
.globl vector64
vector64:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $64
8010702a:	6a 40                	push   $0x40
  jmp alltraps
8010702c:	e9 4c f7 ff ff       	jmp    8010677d <alltraps>

80107031 <vector65>:
.globl vector65
vector65:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $65
80107033:	6a 41                	push   $0x41
  jmp alltraps
80107035:	e9 43 f7 ff ff       	jmp    8010677d <alltraps>

8010703a <vector66>:
.globl vector66
vector66:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $66
8010703c:	6a 42                	push   $0x42
  jmp alltraps
8010703e:	e9 3a f7 ff ff       	jmp    8010677d <alltraps>

80107043 <vector67>:
.globl vector67
vector67:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $67
80107045:	6a 43                	push   $0x43
  jmp alltraps
80107047:	e9 31 f7 ff ff       	jmp    8010677d <alltraps>

8010704c <vector68>:
.globl vector68
vector68:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $68
8010704e:	6a 44                	push   $0x44
  jmp alltraps
80107050:	e9 28 f7 ff ff       	jmp    8010677d <alltraps>

80107055 <vector69>:
.globl vector69
vector69:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $69
80107057:	6a 45                	push   $0x45
  jmp alltraps
80107059:	e9 1f f7 ff ff       	jmp    8010677d <alltraps>

8010705e <vector70>:
.globl vector70
vector70:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $70
80107060:	6a 46                	push   $0x46
  jmp alltraps
80107062:	e9 16 f7 ff ff       	jmp    8010677d <alltraps>

80107067 <vector71>:
.globl vector71
vector71:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $71
80107069:	6a 47                	push   $0x47
  jmp alltraps
8010706b:	e9 0d f7 ff ff       	jmp    8010677d <alltraps>

80107070 <vector72>:
.globl vector72
vector72:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $72
80107072:	6a 48                	push   $0x48
  jmp alltraps
80107074:	e9 04 f7 ff ff       	jmp    8010677d <alltraps>

80107079 <vector73>:
.globl vector73
vector73:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $73
8010707b:	6a 49                	push   $0x49
  jmp alltraps
8010707d:	e9 fb f6 ff ff       	jmp    8010677d <alltraps>

80107082 <vector74>:
.globl vector74
vector74:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $74
80107084:	6a 4a                	push   $0x4a
  jmp alltraps
80107086:	e9 f2 f6 ff ff       	jmp    8010677d <alltraps>

8010708b <vector75>:
.globl vector75
vector75:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $75
8010708d:	6a 4b                	push   $0x4b
  jmp alltraps
8010708f:	e9 e9 f6 ff ff       	jmp    8010677d <alltraps>

80107094 <vector76>:
.globl vector76
vector76:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $76
80107096:	6a 4c                	push   $0x4c
  jmp alltraps
80107098:	e9 e0 f6 ff ff       	jmp    8010677d <alltraps>

8010709d <vector77>:
.globl vector77
vector77:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $77
8010709f:	6a 4d                	push   $0x4d
  jmp alltraps
801070a1:	e9 d7 f6 ff ff       	jmp    8010677d <alltraps>

801070a6 <vector78>:
.globl vector78
vector78:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $78
801070a8:	6a 4e                	push   $0x4e
  jmp alltraps
801070aa:	e9 ce f6 ff ff       	jmp    8010677d <alltraps>

801070af <vector79>:
.globl vector79
vector79:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $79
801070b1:	6a 4f                	push   $0x4f
  jmp alltraps
801070b3:	e9 c5 f6 ff ff       	jmp    8010677d <alltraps>

801070b8 <vector80>:
.globl vector80
vector80:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $80
801070ba:	6a 50                	push   $0x50
  jmp alltraps
801070bc:	e9 bc f6 ff ff       	jmp    8010677d <alltraps>

801070c1 <vector81>:
.globl vector81
vector81:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $81
801070c3:	6a 51                	push   $0x51
  jmp alltraps
801070c5:	e9 b3 f6 ff ff       	jmp    8010677d <alltraps>

801070ca <vector82>:
.globl vector82
vector82:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $82
801070cc:	6a 52                	push   $0x52
  jmp alltraps
801070ce:	e9 aa f6 ff ff       	jmp    8010677d <alltraps>

801070d3 <vector83>:
.globl vector83
vector83:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $83
801070d5:	6a 53                	push   $0x53
  jmp alltraps
801070d7:	e9 a1 f6 ff ff       	jmp    8010677d <alltraps>

801070dc <vector84>:
.globl vector84
vector84:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $84
801070de:	6a 54                	push   $0x54
  jmp alltraps
801070e0:	e9 98 f6 ff ff       	jmp    8010677d <alltraps>

801070e5 <vector85>:
.globl vector85
vector85:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $85
801070e7:	6a 55                	push   $0x55
  jmp alltraps
801070e9:	e9 8f f6 ff ff       	jmp    8010677d <alltraps>

801070ee <vector86>:
.globl vector86
vector86:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $86
801070f0:	6a 56                	push   $0x56
  jmp alltraps
801070f2:	e9 86 f6 ff ff       	jmp    8010677d <alltraps>

801070f7 <vector87>:
.globl vector87
vector87:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $87
801070f9:	6a 57                	push   $0x57
  jmp alltraps
801070fb:	e9 7d f6 ff ff       	jmp    8010677d <alltraps>

80107100 <vector88>:
.globl vector88
vector88:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $88
80107102:	6a 58                	push   $0x58
  jmp alltraps
80107104:	e9 74 f6 ff ff       	jmp    8010677d <alltraps>

80107109 <vector89>:
.globl vector89
vector89:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $89
8010710b:	6a 59                	push   $0x59
  jmp alltraps
8010710d:	e9 6b f6 ff ff       	jmp    8010677d <alltraps>

80107112 <vector90>:
.globl vector90
vector90:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $90
80107114:	6a 5a                	push   $0x5a
  jmp alltraps
80107116:	e9 62 f6 ff ff       	jmp    8010677d <alltraps>

8010711b <vector91>:
.globl vector91
vector91:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $91
8010711d:	6a 5b                	push   $0x5b
  jmp alltraps
8010711f:	e9 59 f6 ff ff       	jmp    8010677d <alltraps>

80107124 <vector92>:
.globl vector92
vector92:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $92
80107126:	6a 5c                	push   $0x5c
  jmp alltraps
80107128:	e9 50 f6 ff ff       	jmp    8010677d <alltraps>

8010712d <vector93>:
.globl vector93
vector93:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $93
8010712f:	6a 5d                	push   $0x5d
  jmp alltraps
80107131:	e9 47 f6 ff ff       	jmp    8010677d <alltraps>

80107136 <vector94>:
.globl vector94
vector94:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $94
80107138:	6a 5e                	push   $0x5e
  jmp alltraps
8010713a:	e9 3e f6 ff ff       	jmp    8010677d <alltraps>

8010713f <vector95>:
.globl vector95
vector95:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $95
80107141:	6a 5f                	push   $0x5f
  jmp alltraps
80107143:	e9 35 f6 ff ff       	jmp    8010677d <alltraps>

80107148 <vector96>:
.globl vector96
vector96:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $96
8010714a:	6a 60                	push   $0x60
  jmp alltraps
8010714c:	e9 2c f6 ff ff       	jmp    8010677d <alltraps>

80107151 <vector97>:
.globl vector97
vector97:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $97
80107153:	6a 61                	push   $0x61
  jmp alltraps
80107155:	e9 23 f6 ff ff       	jmp    8010677d <alltraps>

8010715a <vector98>:
.globl vector98
vector98:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $98
8010715c:	6a 62                	push   $0x62
  jmp alltraps
8010715e:	e9 1a f6 ff ff       	jmp    8010677d <alltraps>

80107163 <vector99>:
.globl vector99
vector99:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $99
80107165:	6a 63                	push   $0x63
  jmp alltraps
80107167:	e9 11 f6 ff ff       	jmp    8010677d <alltraps>

8010716c <vector100>:
.globl vector100
vector100:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $100
8010716e:	6a 64                	push   $0x64
  jmp alltraps
80107170:	e9 08 f6 ff ff       	jmp    8010677d <alltraps>

80107175 <vector101>:
.globl vector101
vector101:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $101
80107177:	6a 65                	push   $0x65
  jmp alltraps
80107179:	e9 ff f5 ff ff       	jmp    8010677d <alltraps>

8010717e <vector102>:
.globl vector102
vector102:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $102
80107180:	6a 66                	push   $0x66
  jmp alltraps
80107182:	e9 f6 f5 ff ff       	jmp    8010677d <alltraps>

80107187 <vector103>:
.globl vector103
vector103:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $103
80107189:	6a 67                	push   $0x67
  jmp alltraps
8010718b:	e9 ed f5 ff ff       	jmp    8010677d <alltraps>

80107190 <vector104>:
.globl vector104
vector104:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $104
80107192:	6a 68                	push   $0x68
  jmp alltraps
80107194:	e9 e4 f5 ff ff       	jmp    8010677d <alltraps>

80107199 <vector105>:
.globl vector105
vector105:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $105
8010719b:	6a 69                	push   $0x69
  jmp alltraps
8010719d:	e9 db f5 ff ff       	jmp    8010677d <alltraps>

801071a2 <vector106>:
.globl vector106
vector106:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $106
801071a4:	6a 6a                	push   $0x6a
  jmp alltraps
801071a6:	e9 d2 f5 ff ff       	jmp    8010677d <alltraps>

801071ab <vector107>:
.globl vector107
vector107:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $107
801071ad:	6a 6b                	push   $0x6b
  jmp alltraps
801071af:	e9 c9 f5 ff ff       	jmp    8010677d <alltraps>

801071b4 <vector108>:
.globl vector108
vector108:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $108
801071b6:	6a 6c                	push   $0x6c
  jmp alltraps
801071b8:	e9 c0 f5 ff ff       	jmp    8010677d <alltraps>

801071bd <vector109>:
.globl vector109
vector109:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $109
801071bf:	6a 6d                	push   $0x6d
  jmp alltraps
801071c1:	e9 b7 f5 ff ff       	jmp    8010677d <alltraps>

801071c6 <vector110>:
.globl vector110
vector110:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $110
801071c8:	6a 6e                	push   $0x6e
  jmp alltraps
801071ca:	e9 ae f5 ff ff       	jmp    8010677d <alltraps>

801071cf <vector111>:
.globl vector111
vector111:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $111
801071d1:	6a 6f                	push   $0x6f
  jmp alltraps
801071d3:	e9 a5 f5 ff ff       	jmp    8010677d <alltraps>

801071d8 <vector112>:
.globl vector112
vector112:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $112
801071da:	6a 70                	push   $0x70
  jmp alltraps
801071dc:	e9 9c f5 ff ff       	jmp    8010677d <alltraps>

801071e1 <vector113>:
.globl vector113
vector113:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $113
801071e3:	6a 71                	push   $0x71
  jmp alltraps
801071e5:	e9 93 f5 ff ff       	jmp    8010677d <alltraps>

801071ea <vector114>:
.globl vector114
vector114:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $114
801071ec:	6a 72                	push   $0x72
  jmp alltraps
801071ee:	e9 8a f5 ff ff       	jmp    8010677d <alltraps>

801071f3 <vector115>:
.globl vector115
vector115:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $115
801071f5:	6a 73                	push   $0x73
  jmp alltraps
801071f7:	e9 81 f5 ff ff       	jmp    8010677d <alltraps>

801071fc <vector116>:
.globl vector116
vector116:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $116
801071fe:	6a 74                	push   $0x74
  jmp alltraps
80107200:	e9 78 f5 ff ff       	jmp    8010677d <alltraps>

80107205 <vector117>:
.globl vector117
vector117:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $117
80107207:	6a 75                	push   $0x75
  jmp alltraps
80107209:	e9 6f f5 ff ff       	jmp    8010677d <alltraps>

8010720e <vector118>:
.globl vector118
vector118:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $118
80107210:	6a 76                	push   $0x76
  jmp alltraps
80107212:	e9 66 f5 ff ff       	jmp    8010677d <alltraps>

80107217 <vector119>:
.globl vector119
vector119:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $119
80107219:	6a 77                	push   $0x77
  jmp alltraps
8010721b:	e9 5d f5 ff ff       	jmp    8010677d <alltraps>

80107220 <vector120>:
.globl vector120
vector120:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $120
80107222:	6a 78                	push   $0x78
  jmp alltraps
80107224:	e9 54 f5 ff ff       	jmp    8010677d <alltraps>

80107229 <vector121>:
.globl vector121
vector121:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $121
8010722b:	6a 79                	push   $0x79
  jmp alltraps
8010722d:	e9 4b f5 ff ff       	jmp    8010677d <alltraps>

80107232 <vector122>:
.globl vector122
vector122:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $122
80107234:	6a 7a                	push   $0x7a
  jmp alltraps
80107236:	e9 42 f5 ff ff       	jmp    8010677d <alltraps>

8010723b <vector123>:
.globl vector123
vector123:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $123
8010723d:	6a 7b                	push   $0x7b
  jmp alltraps
8010723f:	e9 39 f5 ff ff       	jmp    8010677d <alltraps>

80107244 <vector124>:
.globl vector124
vector124:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $124
80107246:	6a 7c                	push   $0x7c
  jmp alltraps
80107248:	e9 30 f5 ff ff       	jmp    8010677d <alltraps>

8010724d <vector125>:
.globl vector125
vector125:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $125
8010724f:	6a 7d                	push   $0x7d
  jmp alltraps
80107251:	e9 27 f5 ff ff       	jmp    8010677d <alltraps>

80107256 <vector126>:
.globl vector126
vector126:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $126
80107258:	6a 7e                	push   $0x7e
  jmp alltraps
8010725a:	e9 1e f5 ff ff       	jmp    8010677d <alltraps>

8010725f <vector127>:
.globl vector127
vector127:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $127
80107261:	6a 7f                	push   $0x7f
  jmp alltraps
80107263:	e9 15 f5 ff ff       	jmp    8010677d <alltraps>

80107268 <vector128>:
.globl vector128
vector128:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $128
8010726a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010726f:	e9 09 f5 ff ff       	jmp    8010677d <alltraps>

80107274 <vector129>:
.globl vector129
vector129:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $129
80107276:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010727b:	e9 fd f4 ff ff       	jmp    8010677d <alltraps>

80107280 <vector130>:
.globl vector130
vector130:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $130
80107282:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107287:	e9 f1 f4 ff ff       	jmp    8010677d <alltraps>

8010728c <vector131>:
.globl vector131
vector131:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $131
8010728e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107293:	e9 e5 f4 ff ff       	jmp    8010677d <alltraps>

80107298 <vector132>:
.globl vector132
vector132:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $132
8010729a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010729f:	e9 d9 f4 ff ff       	jmp    8010677d <alltraps>

801072a4 <vector133>:
.globl vector133
vector133:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $133
801072a6:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801072ab:	e9 cd f4 ff ff       	jmp    8010677d <alltraps>

801072b0 <vector134>:
.globl vector134
vector134:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $134
801072b2:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801072b7:	e9 c1 f4 ff ff       	jmp    8010677d <alltraps>

801072bc <vector135>:
.globl vector135
vector135:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $135
801072be:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801072c3:	e9 b5 f4 ff ff       	jmp    8010677d <alltraps>

801072c8 <vector136>:
.globl vector136
vector136:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $136
801072ca:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801072cf:	e9 a9 f4 ff ff       	jmp    8010677d <alltraps>

801072d4 <vector137>:
.globl vector137
vector137:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $137
801072d6:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072db:	e9 9d f4 ff ff       	jmp    8010677d <alltraps>

801072e0 <vector138>:
.globl vector138
vector138:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $138
801072e2:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801072e7:	e9 91 f4 ff ff       	jmp    8010677d <alltraps>

801072ec <vector139>:
.globl vector139
vector139:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $139
801072ee:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072f3:	e9 85 f4 ff ff       	jmp    8010677d <alltraps>

801072f8 <vector140>:
.globl vector140
vector140:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $140
801072fa:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801072ff:	e9 79 f4 ff ff       	jmp    8010677d <alltraps>

80107304 <vector141>:
.globl vector141
vector141:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $141
80107306:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010730b:	e9 6d f4 ff ff       	jmp    8010677d <alltraps>

80107310 <vector142>:
.globl vector142
vector142:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $142
80107312:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107317:	e9 61 f4 ff ff       	jmp    8010677d <alltraps>

8010731c <vector143>:
.globl vector143
vector143:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $143
8010731e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107323:	e9 55 f4 ff ff       	jmp    8010677d <alltraps>

80107328 <vector144>:
.globl vector144
vector144:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $144
8010732a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010732f:	e9 49 f4 ff ff       	jmp    8010677d <alltraps>

80107334 <vector145>:
.globl vector145
vector145:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $145
80107336:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010733b:	e9 3d f4 ff ff       	jmp    8010677d <alltraps>

80107340 <vector146>:
.globl vector146
vector146:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $146
80107342:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107347:	e9 31 f4 ff ff       	jmp    8010677d <alltraps>

8010734c <vector147>:
.globl vector147
vector147:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $147
8010734e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107353:	e9 25 f4 ff ff       	jmp    8010677d <alltraps>

80107358 <vector148>:
.globl vector148
vector148:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $148
8010735a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010735f:	e9 19 f4 ff ff       	jmp    8010677d <alltraps>

80107364 <vector149>:
.globl vector149
vector149:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $149
80107366:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010736b:	e9 0d f4 ff ff       	jmp    8010677d <alltraps>

80107370 <vector150>:
.globl vector150
vector150:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $150
80107372:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107377:	e9 01 f4 ff ff       	jmp    8010677d <alltraps>

8010737c <vector151>:
.globl vector151
vector151:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $151
8010737e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107383:	e9 f5 f3 ff ff       	jmp    8010677d <alltraps>

80107388 <vector152>:
.globl vector152
vector152:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $152
8010738a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010738f:	e9 e9 f3 ff ff       	jmp    8010677d <alltraps>

80107394 <vector153>:
.globl vector153
vector153:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $153
80107396:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010739b:	e9 dd f3 ff ff       	jmp    8010677d <alltraps>

801073a0 <vector154>:
.globl vector154
vector154:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $154
801073a2:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801073a7:	e9 d1 f3 ff ff       	jmp    8010677d <alltraps>

801073ac <vector155>:
.globl vector155
vector155:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $155
801073ae:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801073b3:	e9 c5 f3 ff ff       	jmp    8010677d <alltraps>

801073b8 <vector156>:
.globl vector156
vector156:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $156
801073ba:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801073bf:	e9 b9 f3 ff ff       	jmp    8010677d <alltraps>

801073c4 <vector157>:
.globl vector157
vector157:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $157
801073c6:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801073cb:	e9 ad f3 ff ff       	jmp    8010677d <alltraps>

801073d0 <vector158>:
.globl vector158
vector158:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $158
801073d2:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801073d7:	e9 a1 f3 ff ff       	jmp    8010677d <alltraps>

801073dc <vector159>:
.globl vector159
vector159:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $159
801073de:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801073e3:	e9 95 f3 ff ff       	jmp    8010677d <alltraps>

801073e8 <vector160>:
.globl vector160
vector160:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $160
801073ea:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073ef:	e9 89 f3 ff ff       	jmp    8010677d <alltraps>

801073f4 <vector161>:
.globl vector161
vector161:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $161
801073f6:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801073fb:	e9 7d f3 ff ff       	jmp    8010677d <alltraps>

80107400 <vector162>:
.globl vector162
vector162:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $162
80107402:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107407:	e9 71 f3 ff ff       	jmp    8010677d <alltraps>

8010740c <vector163>:
.globl vector163
vector163:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $163
8010740e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107413:	e9 65 f3 ff ff       	jmp    8010677d <alltraps>

80107418 <vector164>:
.globl vector164
vector164:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $164
8010741a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010741f:	e9 59 f3 ff ff       	jmp    8010677d <alltraps>

80107424 <vector165>:
.globl vector165
vector165:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $165
80107426:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010742b:	e9 4d f3 ff ff       	jmp    8010677d <alltraps>

80107430 <vector166>:
.globl vector166
vector166:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $166
80107432:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107437:	e9 41 f3 ff ff       	jmp    8010677d <alltraps>

8010743c <vector167>:
.globl vector167
vector167:
  pushl $0
8010743c:	6a 00                	push   $0x0
  pushl $167
8010743e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107443:	e9 35 f3 ff ff       	jmp    8010677d <alltraps>

80107448 <vector168>:
.globl vector168
vector168:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $168
8010744a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010744f:	e9 29 f3 ff ff       	jmp    8010677d <alltraps>

80107454 <vector169>:
.globl vector169
vector169:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $169
80107456:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010745b:	e9 1d f3 ff ff       	jmp    8010677d <alltraps>

80107460 <vector170>:
.globl vector170
vector170:
  pushl $0
80107460:	6a 00                	push   $0x0
  pushl $170
80107462:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107467:	e9 11 f3 ff ff       	jmp    8010677d <alltraps>

8010746c <vector171>:
.globl vector171
vector171:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $171
8010746e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107473:	e9 05 f3 ff ff       	jmp    8010677d <alltraps>

80107478 <vector172>:
.globl vector172
vector172:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $172
8010747a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010747f:	e9 f9 f2 ff ff       	jmp    8010677d <alltraps>

80107484 <vector173>:
.globl vector173
vector173:
  pushl $0
80107484:	6a 00                	push   $0x0
  pushl $173
80107486:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010748b:	e9 ed f2 ff ff       	jmp    8010677d <alltraps>

80107490 <vector174>:
.globl vector174
vector174:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $174
80107492:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107497:	e9 e1 f2 ff ff       	jmp    8010677d <alltraps>

8010749c <vector175>:
.globl vector175
vector175:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $175
8010749e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801074a3:	e9 d5 f2 ff ff       	jmp    8010677d <alltraps>

801074a8 <vector176>:
.globl vector176
vector176:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $176
801074aa:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801074af:	e9 c9 f2 ff ff       	jmp    8010677d <alltraps>

801074b4 <vector177>:
.globl vector177
vector177:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $177
801074b6:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801074bb:	e9 bd f2 ff ff       	jmp    8010677d <alltraps>

801074c0 <vector178>:
.globl vector178
vector178:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $178
801074c2:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801074c7:	e9 b1 f2 ff ff       	jmp    8010677d <alltraps>

801074cc <vector179>:
.globl vector179
vector179:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $179
801074ce:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801074d3:	e9 a5 f2 ff ff       	jmp    8010677d <alltraps>

801074d8 <vector180>:
.globl vector180
vector180:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $180
801074da:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074df:	e9 99 f2 ff ff       	jmp    8010677d <alltraps>

801074e4 <vector181>:
.globl vector181
vector181:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $181
801074e6:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801074eb:	e9 8d f2 ff ff       	jmp    8010677d <alltraps>

801074f0 <vector182>:
.globl vector182
vector182:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $182
801074f2:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801074f7:	e9 81 f2 ff ff       	jmp    8010677d <alltraps>

801074fc <vector183>:
.globl vector183
vector183:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $183
801074fe:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107503:	e9 75 f2 ff ff       	jmp    8010677d <alltraps>

80107508 <vector184>:
.globl vector184
vector184:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $184
8010750a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010750f:	e9 69 f2 ff ff       	jmp    8010677d <alltraps>

80107514 <vector185>:
.globl vector185
vector185:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $185
80107516:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010751b:	e9 5d f2 ff ff       	jmp    8010677d <alltraps>

80107520 <vector186>:
.globl vector186
vector186:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $186
80107522:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107527:	e9 51 f2 ff ff       	jmp    8010677d <alltraps>

8010752c <vector187>:
.globl vector187
vector187:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $187
8010752e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107533:	e9 45 f2 ff ff       	jmp    8010677d <alltraps>

80107538 <vector188>:
.globl vector188
vector188:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $188
8010753a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010753f:	e9 39 f2 ff ff       	jmp    8010677d <alltraps>

80107544 <vector189>:
.globl vector189
vector189:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $189
80107546:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010754b:	e9 2d f2 ff ff       	jmp    8010677d <alltraps>

80107550 <vector190>:
.globl vector190
vector190:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $190
80107552:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107557:	e9 21 f2 ff ff       	jmp    8010677d <alltraps>

8010755c <vector191>:
.globl vector191
vector191:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $191
8010755e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107563:	e9 15 f2 ff ff       	jmp    8010677d <alltraps>

80107568 <vector192>:
.globl vector192
vector192:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $192
8010756a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010756f:	e9 09 f2 ff ff       	jmp    8010677d <alltraps>

80107574 <vector193>:
.globl vector193
vector193:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $193
80107576:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010757b:	e9 fd f1 ff ff       	jmp    8010677d <alltraps>

80107580 <vector194>:
.globl vector194
vector194:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $194
80107582:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107587:	e9 f1 f1 ff ff       	jmp    8010677d <alltraps>

8010758c <vector195>:
.globl vector195
vector195:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $195
8010758e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107593:	e9 e5 f1 ff ff       	jmp    8010677d <alltraps>

80107598 <vector196>:
.globl vector196
vector196:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $196
8010759a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010759f:	e9 d9 f1 ff ff       	jmp    8010677d <alltraps>

801075a4 <vector197>:
.globl vector197
vector197:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $197
801075a6:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801075ab:	e9 cd f1 ff ff       	jmp    8010677d <alltraps>

801075b0 <vector198>:
.globl vector198
vector198:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $198
801075b2:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801075b7:	e9 c1 f1 ff ff       	jmp    8010677d <alltraps>

801075bc <vector199>:
.globl vector199
vector199:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $199
801075be:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801075c3:	e9 b5 f1 ff ff       	jmp    8010677d <alltraps>

801075c8 <vector200>:
.globl vector200
vector200:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $200
801075ca:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801075cf:	e9 a9 f1 ff ff       	jmp    8010677d <alltraps>

801075d4 <vector201>:
.globl vector201
vector201:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $201
801075d6:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075db:	e9 9d f1 ff ff       	jmp    8010677d <alltraps>

801075e0 <vector202>:
.globl vector202
vector202:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $202
801075e2:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801075e7:	e9 91 f1 ff ff       	jmp    8010677d <alltraps>

801075ec <vector203>:
.globl vector203
vector203:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $203
801075ee:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075f3:	e9 85 f1 ff ff       	jmp    8010677d <alltraps>

801075f8 <vector204>:
.globl vector204
vector204:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $204
801075fa:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801075ff:	e9 79 f1 ff ff       	jmp    8010677d <alltraps>

80107604 <vector205>:
.globl vector205
vector205:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $205
80107606:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010760b:	e9 6d f1 ff ff       	jmp    8010677d <alltraps>

80107610 <vector206>:
.globl vector206
vector206:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $206
80107612:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107617:	e9 61 f1 ff ff       	jmp    8010677d <alltraps>

8010761c <vector207>:
.globl vector207
vector207:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $207
8010761e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107623:	e9 55 f1 ff ff       	jmp    8010677d <alltraps>

80107628 <vector208>:
.globl vector208
vector208:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $208
8010762a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010762f:	e9 49 f1 ff ff       	jmp    8010677d <alltraps>

80107634 <vector209>:
.globl vector209
vector209:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $209
80107636:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010763b:	e9 3d f1 ff ff       	jmp    8010677d <alltraps>

80107640 <vector210>:
.globl vector210
vector210:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $210
80107642:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107647:	e9 31 f1 ff ff       	jmp    8010677d <alltraps>

8010764c <vector211>:
.globl vector211
vector211:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $211
8010764e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107653:	e9 25 f1 ff ff       	jmp    8010677d <alltraps>

80107658 <vector212>:
.globl vector212
vector212:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $212
8010765a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010765f:	e9 19 f1 ff ff       	jmp    8010677d <alltraps>

80107664 <vector213>:
.globl vector213
vector213:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $213
80107666:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010766b:	e9 0d f1 ff ff       	jmp    8010677d <alltraps>

80107670 <vector214>:
.globl vector214
vector214:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $214
80107672:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107677:	e9 01 f1 ff ff       	jmp    8010677d <alltraps>

8010767c <vector215>:
.globl vector215
vector215:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $215
8010767e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107683:	e9 f5 f0 ff ff       	jmp    8010677d <alltraps>

80107688 <vector216>:
.globl vector216
vector216:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $216
8010768a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010768f:	e9 e9 f0 ff ff       	jmp    8010677d <alltraps>

80107694 <vector217>:
.globl vector217
vector217:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $217
80107696:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010769b:	e9 dd f0 ff ff       	jmp    8010677d <alltraps>

801076a0 <vector218>:
.globl vector218
vector218:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $218
801076a2:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801076a7:	e9 d1 f0 ff ff       	jmp    8010677d <alltraps>

801076ac <vector219>:
.globl vector219
vector219:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $219
801076ae:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801076b3:	e9 c5 f0 ff ff       	jmp    8010677d <alltraps>

801076b8 <vector220>:
.globl vector220
vector220:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $220
801076ba:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801076bf:	e9 b9 f0 ff ff       	jmp    8010677d <alltraps>

801076c4 <vector221>:
.globl vector221
vector221:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $221
801076c6:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801076cb:	e9 ad f0 ff ff       	jmp    8010677d <alltraps>

801076d0 <vector222>:
.globl vector222
vector222:
  pushl $0
801076d0:	6a 00                	push   $0x0
  pushl $222
801076d2:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801076d7:	e9 a1 f0 ff ff       	jmp    8010677d <alltraps>

801076dc <vector223>:
.globl vector223
vector223:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $223
801076de:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801076e3:	e9 95 f0 ff ff       	jmp    8010677d <alltraps>

801076e8 <vector224>:
.globl vector224
vector224:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $224
801076ea:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076ef:	e9 89 f0 ff ff       	jmp    8010677d <alltraps>

801076f4 <vector225>:
.globl vector225
vector225:
  pushl $0
801076f4:	6a 00                	push   $0x0
  pushl $225
801076f6:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801076fb:	e9 7d f0 ff ff       	jmp    8010677d <alltraps>

80107700 <vector226>:
.globl vector226
vector226:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $226
80107702:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107707:	e9 71 f0 ff ff       	jmp    8010677d <alltraps>

8010770c <vector227>:
.globl vector227
vector227:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $227
8010770e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107713:	e9 65 f0 ff ff       	jmp    8010677d <alltraps>

80107718 <vector228>:
.globl vector228
vector228:
  pushl $0
80107718:	6a 00                	push   $0x0
  pushl $228
8010771a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010771f:	e9 59 f0 ff ff       	jmp    8010677d <alltraps>

80107724 <vector229>:
.globl vector229
vector229:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $229
80107726:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010772b:	e9 4d f0 ff ff       	jmp    8010677d <alltraps>

80107730 <vector230>:
.globl vector230
vector230:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $230
80107732:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107737:	e9 41 f0 ff ff       	jmp    8010677d <alltraps>

8010773c <vector231>:
.globl vector231
vector231:
  pushl $0
8010773c:	6a 00                	push   $0x0
  pushl $231
8010773e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107743:	e9 35 f0 ff ff       	jmp    8010677d <alltraps>

80107748 <vector232>:
.globl vector232
vector232:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $232
8010774a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010774f:	e9 29 f0 ff ff       	jmp    8010677d <alltraps>

80107754 <vector233>:
.globl vector233
vector233:
  pushl $0
80107754:	6a 00                	push   $0x0
  pushl $233
80107756:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010775b:	e9 1d f0 ff ff       	jmp    8010677d <alltraps>

80107760 <vector234>:
.globl vector234
vector234:
  pushl $0
80107760:	6a 00                	push   $0x0
  pushl $234
80107762:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107767:	e9 11 f0 ff ff       	jmp    8010677d <alltraps>

8010776c <vector235>:
.globl vector235
vector235:
  pushl $0
8010776c:	6a 00                	push   $0x0
  pushl $235
8010776e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107773:	e9 05 f0 ff ff       	jmp    8010677d <alltraps>

80107778 <vector236>:
.globl vector236
vector236:
  pushl $0
80107778:	6a 00                	push   $0x0
  pushl $236
8010777a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010777f:	e9 f9 ef ff ff       	jmp    8010677d <alltraps>

80107784 <vector237>:
.globl vector237
vector237:
  pushl $0
80107784:	6a 00                	push   $0x0
  pushl $237
80107786:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010778b:	e9 ed ef ff ff       	jmp    8010677d <alltraps>

80107790 <vector238>:
.globl vector238
vector238:
  pushl $0
80107790:	6a 00                	push   $0x0
  pushl $238
80107792:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107797:	e9 e1 ef ff ff       	jmp    8010677d <alltraps>

8010779c <vector239>:
.globl vector239
vector239:
  pushl $0
8010779c:	6a 00                	push   $0x0
  pushl $239
8010779e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801077a3:	e9 d5 ef ff ff       	jmp    8010677d <alltraps>

801077a8 <vector240>:
.globl vector240
vector240:
  pushl $0
801077a8:	6a 00                	push   $0x0
  pushl $240
801077aa:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801077af:	e9 c9 ef ff ff       	jmp    8010677d <alltraps>

801077b4 <vector241>:
.globl vector241
vector241:
  pushl $0
801077b4:	6a 00                	push   $0x0
  pushl $241
801077b6:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801077bb:	e9 bd ef ff ff       	jmp    8010677d <alltraps>

801077c0 <vector242>:
.globl vector242
vector242:
  pushl $0
801077c0:	6a 00                	push   $0x0
  pushl $242
801077c2:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801077c7:	e9 b1 ef ff ff       	jmp    8010677d <alltraps>

801077cc <vector243>:
.globl vector243
vector243:
  pushl $0
801077cc:	6a 00                	push   $0x0
  pushl $243
801077ce:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801077d3:	e9 a5 ef ff ff       	jmp    8010677d <alltraps>

801077d8 <vector244>:
.globl vector244
vector244:
  pushl $0
801077d8:	6a 00                	push   $0x0
  pushl $244
801077da:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077df:	e9 99 ef ff ff       	jmp    8010677d <alltraps>

801077e4 <vector245>:
.globl vector245
vector245:
  pushl $0
801077e4:	6a 00                	push   $0x0
  pushl $245
801077e6:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801077eb:	e9 8d ef ff ff       	jmp    8010677d <alltraps>

801077f0 <vector246>:
.globl vector246
vector246:
  pushl $0
801077f0:	6a 00                	push   $0x0
  pushl $246
801077f2:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801077f7:	e9 81 ef ff ff       	jmp    8010677d <alltraps>

801077fc <vector247>:
.globl vector247
vector247:
  pushl $0
801077fc:	6a 00                	push   $0x0
  pushl $247
801077fe:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107803:	e9 75 ef ff ff       	jmp    8010677d <alltraps>

80107808 <vector248>:
.globl vector248
vector248:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $248
8010780a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010780f:	e9 69 ef ff ff       	jmp    8010677d <alltraps>

80107814 <vector249>:
.globl vector249
vector249:
  pushl $0
80107814:	6a 00                	push   $0x0
  pushl $249
80107816:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010781b:	e9 5d ef ff ff       	jmp    8010677d <alltraps>

80107820 <vector250>:
.globl vector250
vector250:
  pushl $0
80107820:	6a 00                	push   $0x0
  pushl $250
80107822:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107827:	e9 51 ef ff ff       	jmp    8010677d <alltraps>

8010782c <vector251>:
.globl vector251
vector251:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $251
8010782e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107833:	e9 45 ef ff ff       	jmp    8010677d <alltraps>

80107838 <vector252>:
.globl vector252
vector252:
  pushl $0
80107838:	6a 00                	push   $0x0
  pushl $252
8010783a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010783f:	e9 39 ef ff ff       	jmp    8010677d <alltraps>

80107844 <vector253>:
.globl vector253
vector253:
  pushl $0
80107844:	6a 00                	push   $0x0
  pushl $253
80107846:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010784b:	e9 2d ef ff ff       	jmp    8010677d <alltraps>

80107850 <vector254>:
.globl vector254
vector254:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $254
80107852:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107857:	e9 21 ef ff ff       	jmp    8010677d <alltraps>

8010785c <vector255>:
.globl vector255
vector255:
  pushl $0
8010785c:	6a 00                	push   $0x0
  pushl $255
8010785e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107863:	e9 15 ef ff ff       	jmp    8010677d <alltraps>

80107868 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107868:	55                   	push   %ebp
80107869:	89 e5                	mov    %esp,%ebp
8010786b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010786e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107871:	83 e8 01             	sub    $0x1,%eax
80107874:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107878:	8b 45 08             	mov    0x8(%ebp),%eax
8010787b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010787f:	8b 45 08             	mov    0x8(%ebp),%eax
80107882:	c1 e8 10             	shr    $0x10,%eax
80107885:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107889:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010788c:	0f 01 10             	lgdtl  (%eax)
}
8010788f:	c9                   	leave  
80107890:	c3                   	ret    

80107891 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107891:	55                   	push   %ebp
80107892:	89 e5                	mov    %esp,%ebp
80107894:	83 ec 04             	sub    $0x4,%esp
80107897:	8b 45 08             	mov    0x8(%ebp),%eax
8010789a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010789e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078a2:	0f 00 d8             	ltr    %ax
}
801078a5:	c9                   	leave  
801078a6:	c3                   	ret    

801078a7 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801078a7:	55                   	push   %ebp
801078a8:	89 e5                	mov    %esp,%ebp
801078aa:	83 ec 04             	sub    $0x4,%esp
801078ad:	8b 45 08             	mov    0x8(%ebp),%eax
801078b0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801078b4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078b8:	8e e8                	mov    %eax,%gs
}
801078ba:	c9                   	leave  
801078bb:	c3                   	ret    

801078bc <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801078bc:	55                   	push   %ebp
801078bd:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801078bf:	8b 45 08             	mov    0x8(%ebp),%eax
801078c2:	0f 22 d8             	mov    %eax,%cr3
}
801078c5:	5d                   	pop    %ebp
801078c6:	c3                   	ret    

801078c7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801078c7:	55                   	push   %ebp
801078c8:	89 e5                	mov    %esp,%ebp
801078ca:	8b 45 08             	mov    0x8(%ebp),%eax
801078cd:	05 00 00 00 80       	add    $0x80000000,%eax
801078d2:	5d                   	pop    %ebp
801078d3:	c3                   	ret    

801078d4 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801078d4:	55                   	push   %ebp
801078d5:	89 e5                	mov    %esp,%ebp
801078d7:	8b 45 08             	mov    0x8(%ebp),%eax
801078da:	05 00 00 00 80       	add    $0x80000000,%eax
801078df:	5d                   	pop    %ebp
801078e0:	c3                   	ret    

801078e1 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801078e1:	55                   	push   %ebp
801078e2:	89 e5                	mov    %esp,%ebp
801078e4:	53                   	push   %ebx
801078e5:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801078e8:	e8 98 b5 ff ff       	call   80102e85 <cpunum>
801078ed:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801078f3:	05 60 23 11 80       	add    $0x80112360,%eax
801078f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801078fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fe:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107907:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010790d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107910:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107917:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010791b:	83 e2 f0             	and    $0xfffffff0,%edx
8010791e:	83 ca 0a             	or     $0xa,%edx
80107921:	88 50 7d             	mov    %dl,0x7d(%eax)
80107924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107927:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010792b:	83 ca 10             	or     $0x10,%edx
8010792e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107934:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107938:	83 e2 9f             	and    $0xffffff9f,%edx
8010793b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010793e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107941:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107945:	83 ca 80             	or     $0xffffff80,%edx
80107948:	88 50 7d             	mov    %dl,0x7d(%eax)
8010794b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107952:	83 ca 0f             	or     $0xf,%edx
80107955:	88 50 7e             	mov    %dl,0x7e(%eax)
80107958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010795f:	83 e2 ef             	and    $0xffffffef,%edx
80107962:	88 50 7e             	mov    %dl,0x7e(%eax)
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010796c:	83 e2 df             	and    $0xffffffdf,%edx
8010796f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107975:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107979:	83 ca 40             	or     $0x40,%edx
8010797c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010797f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107982:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107986:	83 ca 80             	or     $0xffffff80,%edx
80107989:	88 50 7e             	mov    %dl,0x7e(%eax)
8010798c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107996:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010799d:	ff ff 
8010799f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a2:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801079a9:	00 00 
801079ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ae:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801079b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079bf:	83 e2 f0             	and    $0xfffffff0,%edx
801079c2:	83 ca 02             	or     $0x2,%edx
801079c5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ce:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079d5:	83 ca 10             	or     $0x10,%edx
801079d8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079e8:	83 e2 9f             	and    $0xffffff9f,%edx
801079eb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079fb:	83 ca 80             	or     $0xffffff80,%edx
801079fe:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a07:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a0e:	83 ca 0f             	or     $0xf,%edx
80107a11:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a21:	83 e2 ef             	and    $0xffffffef,%edx
80107a24:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a34:	83 e2 df             	and    $0xffffffdf,%edx
80107a37:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a40:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a47:	83 ca 40             	or     $0x40,%edx
80107a4a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a53:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a5a:	83 ca 80             	or     $0xffffff80,%edx
80107a5d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a66:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a70:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a77:	ff ff 
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a83:	00 00 
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a92:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a99:	83 e2 f0             	and    $0xfffffff0,%edx
80107a9c:	83 ca 0a             	or     $0xa,%edx
80107a9f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107aaf:	83 ca 10             	or     $0x10,%edx
80107ab2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abb:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ac2:	83 ca 60             	or     $0x60,%edx
80107ac5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ace:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ad5:	83 ca 80             	or     $0xffffff80,%edx
80107ad8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ae8:	83 ca 0f             	or     $0xf,%edx
80107aeb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107afb:	83 e2 ef             	and    $0xffffffef,%edx
80107afe:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b07:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b0e:	83 e2 df             	and    $0xffffffdf,%edx
80107b11:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b21:	83 ca 40             	or     $0x40,%edx
80107b24:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b34:	83 ca 80             	or     $0xffffff80,%edx
80107b37:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b40:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107b51:	ff ff 
80107b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b56:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107b5d:	00 00 
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b73:	83 e2 f0             	and    $0xfffffff0,%edx
80107b76:	83 ca 02             	or     $0x2,%edx
80107b79:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b82:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b89:	83 ca 10             	or     $0x10,%edx
80107b8c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b95:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b9c:	83 ca 60             	or     $0x60,%edx
80107b9f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107baf:	83 ca 80             	or     $0xffffff80,%edx
80107bb2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bc2:	83 ca 0f             	or     $0xf,%edx
80107bc5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bce:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bd5:	83 e2 ef             	and    $0xffffffef,%edx
80107bd8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107be8:	83 e2 df             	and    $0xffffffdf,%edx
80107beb:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bfb:	83 ca 40             	or     $0x40,%edx
80107bfe:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c07:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c0e:	83 ca 80             	or     $0xffffff80,%edx
80107c11:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c24:	05 b4 00 00 00       	add    $0xb4,%eax
80107c29:	89 c3                	mov    %eax,%ebx
80107c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2e:	05 b4 00 00 00       	add    $0xb4,%eax
80107c33:	c1 e8 10             	shr    $0x10,%eax
80107c36:	89 c1                	mov    %eax,%ecx
80107c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3b:	05 b4 00 00 00       	add    $0xb4,%eax
80107c40:	c1 e8 18             	shr    $0x18,%eax
80107c43:	89 c2                	mov    %eax,%edx
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107c4f:	00 00 
80107c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c54:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5e:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c67:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c6e:	83 e1 f0             	and    $0xfffffff0,%ecx
80107c71:	83 c9 02             	or     $0x2,%ecx
80107c74:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7d:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c84:	83 c9 10             	or     $0x10,%ecx
80107c87:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c90:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c97:	83 e1 9f             	and    $0xffffff9f,%ecx
80107c9a:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107caa:	83 c9 80             	or     $0xffffff80,%ecx
80107cad:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cbd:	83 e1 f0             	and    $0xfffffff0,%ecx
80107cc0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc9:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cd0:	83 e1 ef             	and    $0xffffffef,%ecx
80107cd3:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdc:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ce3:	83 e1 df             	and    $0xffffffdf,%ecx
80107ce6:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cf6:	83 c9 40             	or     $0x40,%ecx
80107cf9:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d02:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d09:	83 c9 80             	or     $0xffffff80,%ecx
80107d0c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d15:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1e:	83 c0 70             	add    $0x70,%eax
80107d21:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107d28:	00 
80107d29:	89 04 24             	mov    %eax,(%esp)
80107d2c:	e8 37 fb ff ff       	call   80107868 <lgdt>
  loadgs(SEG_KCPU << 3);
80107d31:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107d38:	e8 6a fb ff ff       	call   801078a7 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d40:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107d46:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107d4d:	00 00 00 00 
}
80107d51:	83 c4 24             	add    $0x24,%esp
80107d54:	5b                   	pop    %ebx
80107d55:	5d                   	pop    %ebp
80107d56:	c3                   	ret    

80107d57 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107d57:	55                   	push   %ebp
80107d58:	89 e5                	mov    %esp,%ebp
80107d5a:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d60:	c1 e8 16             	shr    $0x16,%eax
80107d63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80107d6d:	01 d0                	add    %edx,%eax
80107d6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d75:	8b 00                	mov    (%eax),%eax
80107d77:	83 e0 01             	and    $0x1,%eax
80107d7a:	85 c0                	test   %eax,%eax
80107d7c:	74 17                	je     80107d95 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d81:	8b 00                	mov    (%eax),%eax
80107d83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d88:	89 04 24             	mov    %eax,(%esp)
80107d8b:	e8 44 fb ff ff       	call   801078d4 <p2v>
80107d90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d93:	eb 4b                	jmp    80107de0 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107d95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107d99:	74 0e                	je     80107da9 <walkpgdir+0x52>
80107d9b:	e8 4f ad ff ff       	call   80102aef <kalloc>
80107da0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107da3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107da7:	75 07                	jne    80107db0 <walkpgdir+0x59>
      return 0;
80107da9:	b8 00 00 00 00       	mov    $0x0,%eax
80107dae:	eb 47                	jmp    80107df7 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107db0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107db7:	00 
80107db8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107dbf:	00 
80107dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc3:	89 04 24             	mov    %eax,(%esp)
80107dc6:	e8 36 d5 ff ff       	call   80105301 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dce:	89 04 24             	mov    %eax,(%esp)
80107dd1:	e8 f1 fa ff ff       	call   801078c7 <v2p>
80107dd6:	83 c8 07             	or     $0x7,%eax
80107dd9:	89 c2                	mov    %eax,%edx
80107ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dde:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107de0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de3:	c1 e8 0c             	shr    $0xc,%eax
80107de6:	25 ff 03 00 00       	and    $0x3ff,%eax
80107deb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df5:	01 d0                	add    %edx,%eax
}
80107df7:	c9                   	leave  
80107df8:	c3                   	ret    

80107df9 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107df9:	55                   	push   %ebp
80107dfa:	89 e5                	mov    %esp,%ebp
80107dfc:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107dff:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e0a:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e0d:	8b 45 10             	mov    0x10(%ebp),%eax
80107e10:	01 d0                	add    %edx,%eax
80107e12:	83 e8 01             	sub    $0x1,%eax
80107e15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e1d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107e24:	00 
80107e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e28:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e2f:	89 04 24             	mov    %eax,(%esp)
80107e32:	e8 20 ff ff ff       	call   80107d57 <walkpgdir>
80107e37:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e3a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e3e:	75 07                	jne    80107e47 <mappages+0x4e>
      return -1;
80107e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e45:	eb 48                	jmp    80107e8f <mappages+0x96>
    if(*pte & PTE_P)
80107e47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e4a:	8b 00                	mov    (%eax),%eax
80107e4c:	83 e0 01             	and    $0x1,%eax
80107e4f:	85 c0                	test   %eax,%eax
80107e51:	74 0c                	je     80107e5f <mappages+0x66>
      panic("remap");
80107e53:	c7 04 24 a0 8c 10 80 	movl   $0x80108ca0,(%esp)
80107e5a:	e8 db 86 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107e5f:	8b 45 18             	mov    0x18(%ebp),%eax
80107e62:	0b 45 14             	or     0x14(%ebp),%eax
80107e65:	83 c8 01             	or     $0x1,%eax
80107e68:	89 c2                	mov    %eax,%edx
80107e6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e6d:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e72:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107e75:	75 08                	jne    80107e7f <mappages+0x86>
      break;
80107e77:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107e78:	b8 00 00 00 00       	mov    $0x0,%eax
80107e7d:	eb 10                	jmp    80107e8f <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107e7f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107e86:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107e8d:	eb 8e                	jmp    80107e1d <mappages+0x24>
  return 0;
}
80107e8f:	c9                   	leave  
80107e90:	c3                   	ret    

80107e91 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107e91:	55                   	push   %ebp
80107e92:	89 e5                	mov    %esp,%ebp
80107e94:	53                   	push   %ebx
80107e95:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107e98:	e8 52 ac ff ff       	call   80102aef <kalloc>
80107e9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ea0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ea4:	75 0a                	jne    80107eb0 <setupkvm+0x1f>
    return 0;
80107ea6:	b8 00 00 00 00       	mov    $0x0,%eax
80107eab:	e9 98 00 00 00       	jmp    80107f48 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107eb0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107eb7:	00 
80107eb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ebf:	00 
80107ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ec3:	89 04 24             	mov    %eax,(%esp)
80107ec6:	e8 36 d4 ff ff       	call   80105301 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107ecb:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107ed2:	e8 fd f9 ff ff       	call   801078d4 <p2v>
80107ed7:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107edc:	76 0c                	jbe    80107eea <setupkvm+0x59>
    panic("PHYSTOP too high");
80107ede:	c7 04 24 a6 8c 10 80 	movl   $0x80108ca6,(%esp)
80107ee5:	e8 50 86 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107eea:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107ef1:	eb 49                	jmp    80107f3c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef6:	8b 48 0c             	mov    0xc(%eax),%ecx
80107ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efc:	8b 50 04             	mov    0x4(%eax),%edx
80107eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f02:	8b 58 08             	mov    0x8(%eax),%ebx
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	8b 40 04             	mov    0x4(%eax),%eax
80107f0b:	29 c3                	sub    %eax,%ebx
80107f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f10:	8b 00                	mov    (%eax),%eax
80107f12:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107f16:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f1a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f25:	89 04 24             	mov    %eax,(%esp)
80107f28:	e8 cc fe ff ff       	call   80107df9 <mappages>
80107f2d:	85 c0                	test   %eax,%eax
80107f2f:	79 07                	jns    80107f38 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107f31:	b8 00 00 00 00       	mov    $0x0,%eax
80107f36:	eb 10                	jmp    80107f48 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f38:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f3c:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107f43:	72 ae                	jb     80107ef3 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f48:	83 c4 34             	add    $0x34,%esp
80107f4b:	5b                   	pop    %ebx
80107f4c:	5d                   	pop    %ebp
80107f4d:	c3                   	ret    

80107f4e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f4e:	55                   	push   %ebp
80107f4f:	89 e5                	mov    %esp,%ebp
80107f51:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107f54:	e8 38 ff ff ff       	call   80107e91 <setupkvm>
80107f59:	a3 38 85 11 80       	mov    %eax,0x80118538
  switchkvm();
80107f5e:	e8 02 00 00 00       	call   80107f65 <switchkvm>
}
80107f63:	c9                   	leave  
80107f64:	c3                   	ret    

80107f65 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107f65:	55                   	push   %ebp
80107f66:	89 e5                	mov    %esp,%ebp
80107f68:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107f6b:	a1 38 85 11 80       	mov    0x80118538,%eax
80107f70:	89 04 24             	mov    %eax,(%esp)
80107f73:	e8 4f f9 ff ff       	call   801078c7 <v2p>
80107f78:	89 04 24             	mov    %eax,(%esp)
80107f7b:	e8 3c f9 ff ff       	call   801078bc <lcr3>
}
80107f80:	c9                   	leave  
80107f81:	c3                   	ret    

80107f82 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107f82:	55                   	push   %ebp
80107f83:	89 e5                	mov    %esp,%ebp
80107f85:	53                   	push   %ebx
80107f86:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107f89:	e8 73 d2 ff ff       	call   80105201 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107f8e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f94:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107f9b:	83 c2 08             	add    $0x8,%edx
80107f9e:	89 d3                	mov    %edx,%ebx
80107fa0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fa7:	83 c2 08             	add    $0x8,%edx
80107faa:	c1 ea 10             	shr    $0x10,%edx
80107fad:	89 d1                	mov    %edx,%ecx
80107faf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fb6:	83 c2 08             	add    $0x8,%edx
80107fb9:	c1 ea 18             	shr    $0x18,%edx
80107fbc:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107fc3:	67 00 
80107fc5:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107fcc:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107fd2:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107fd9:	83 e1 f0             	and    $0xfffffff0,%ecx
80107fdc:	83 c9 09             	or     $0x9,%ecx
80107fdf:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107fe5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107fec:	83 c9 10             	or     $0x10,%ecx
80107fef:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ff5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ffc:	83 e1 9f             	and    $0xffffff9f,%ecx
80107fff:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108005:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010800c:	83 c9 80             	or     $0xffffff80,%ecx
8010800f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108015:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010801c:	83 e1 f0             	and    $0xfffffff0,%ecx
8010801f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108025:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010802c:	83 e1 ef             	and    $0xffffffef,%ecx
8010802f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108035:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010803c:	83 e1 df             	and    $0xffffffdf,%ecx
8010803f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108045:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010804c:	83 c9 40             	or     $0x40,%ecx
8010804f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108055:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010805c:	83 e1 7f             	and    $0x7f,%ecx
8010805f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108065:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010806b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108071:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108078:	83 e2 ef             	and    $0xffffffef,%edx
8010807b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108081:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108087:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010808d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108093:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010809a:	8b 52 08             	mov    0x8(%edx),%edx
8010809d:	81 c2 00 10 00 00    	add    $0x1000,%edx
801080a3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801080a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801080ad:	e8 df f7 ff ff       	call   80107891 <ltr>
  if(p->pgdir == 0)
801080b2:	8b 45 08             	mov    0x8(%ebp),%eax
801080b5:	8b 40 04             	mov    0x4(%eax),%eax
801080b8:	85 c0                	test   %eax,%eax
801080ba:	75 0c                	jne    801080c8 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801080bc:	c7 04 24 b7 8c 10 80 	movl   $0x80108cb7,(%esp)
801080c3:	e8 72 84 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801080c8:	8b 45 08             	mov    0x8(%ebp),%eax
801080cb:	8b 40 04             	mov    0x4(%eax),%eax
801080ce:	89 04 24             	mov    %eax,(%esp)
801080d1:	e8 f1 f7 ff ff       	call   801078c7 <v2p>
801080d6:	89 04 24             	mov    %eax,(%esp)
801080d9:	e8 de f7 ff ff       	call   801078bc <lcr3>
  popcli();
801080de:	e8 62 d1 ff ff       	call   80105245 <popcli>
}
801080e3:	83 c4 14             	add    $0x14,%esp
801080e6:	5b                   	pop    %ebx
801080e7:	5d                   	pop    %ebp
801080e8:	c3                   	ret    

801080e9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801080e9:	55                   	push   %ebp
801080ea:	89 e5                	mov    %esp,%ebp
801080ec:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801080ef:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801080f6:	76 0c                	jbe    80108104 <inituvm+0x1b>
    panic("inituvm: more than a page");
801080f8:	c7 04 24 cb 8c 10 80 	movl   $0x80108ccb,(%esp)
801080ff:	e8 36 84 ff ff       	call   8010053a <panic>
  mem = kalloc();
80108104:	e8 e6 a9 ff ff       	call   80102aef <kalloc>
80108109:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010810c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108113:	00 
80108114:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010811b:	00 
8010811c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811f:	89 04 24             	mov    %eax,(%esp)
80108122:	e8 da d1 ff ff       	call   80105301 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812a:	89 04 24             	mov    %eax,(%esp)
8010812d:	e8 95 f7 ff ff       	call   801078c7 <v2p>
80108132:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108139:	00 
8010813a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010813e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108145:	00 
80108146:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010814d:	00 
8010814e:	8b 45 08             	mov    0x8(%ebp),%eax
80108151:	89 04 24             	mov    %eax,(%esp)
80108154:	e8 a0 fc ff ff       	call   80107df9 <mappages>
  memmove(mem, init, sz);
80108159:	8b 45 10             	mov    0x10(%ebp),%eax
8010815c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108160:	8b 45 0c             	mov    0xc(%ebp),%eax
80108163:	89 44 24 04          	mov    %eax,0x4(%esp)
80108167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816a:	89 04 24             	mov    %eax,(%esp)
8010816d:	e8 5e d2 ff ff       	call   801053d0 <memmove>
}
80108172:	c9                   	leave  
80108173:	c3                   	ret    

80108174 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108174:	55                   	push   %ebp
80108175:	89 e5                	mov    %esp,%ebp
80108177:	53                   	push   %ebx
80108178:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010817b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010817e:	25 ff 0f 00 00       	and    $0xfff,%eax
80108183:	85 c0                	test   %eax,%eax
80108185:	74 0c                	je     80108193 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108187:	c7 04 24 e8 8c 10 80 	movl   $0x80108ce8,(%esp)
8010818e:	e8 a7 83 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010819a:	e9 a9 00 00 00       	jmp    80108248 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010819f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801081a5:	01 d0                	add    %edx,%eax
801081a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081ae:	00 
801081af:	89 44 24 04          	mov    %eax,0x4(%esp)
801081b3:	8b 45 08             	mov    0x8(%ebp),%eax
801081b6:	89 04 24             	mov    %eax,(%esp)
801081b9:	e8 99 fb ff ff       	call   80107d57 <walkpgdir>
801081be:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081c5:	75 0c                	jne    801081d3 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801081c7:	c7 04 24 0b 8d 10 80 	movl   $0x80108d0b,(%esp)
801081ce:	e8 67 83 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801081d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d6:	8b 00                	mov    (%eax),%eax
801081d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801081e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e3:	8b 55 18             	mov    0x18(%ebp),%edx
801081e6:	29 c2                	sub    %eax,%edx
801081e8:	89 d0                	mov    %edx,%eax
801081ea:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801081ef:	77 0f                	ja     80108200 <loaduvm+0x8c>
      n = sz - i;
801081f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f4:	8b 55 18             	mov    0x18(%ebp),%edx
801081f7:	29 c2                	sub    %eax,%edx
801081f9:	89 d0                	mov    %edx,%eax
801081fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081fe:	eb 07                	jmp    80108207 <loaduvm+0x93>
    else
      n = PGSIZE;
80108200:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108207:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820a:	8b 55 14             	mov    0x14(%ebp),%edx
8010820d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108210:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108213:	89 04 24             	mov    %eax,(%esp)
80108216:	e8 b9 f6 ff ff       	call   801078d4 <p2v>
8010821b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010821e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108222:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108226:	89 44 24 04          	mov    %eax,0x4(%esp)
8010822a:	8b 45 10             	mov    0x10(%ebp),%eax
8010822d:	89 04 24             	mov    %eax,(%esp)
80108230:	e8 40 9b ff ff       	call   80101d75 <readi>
80108235:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108238:	74 07                	je     80108241 <loaduvm+0xcd>
      return -1;
8010823a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010823f:	eb 18                	jmp    80108259 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108241:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824b:	3b 45 18             	cmp    0x18(%ebp),%eax
8010824e:	0f 82 4b ff ff ff    	jb     8010819f <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108254:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108259:	83 c4 24             	add    $0x24,%esp
8010825c:	5b                   	pop    %ebx
8010825d:	5d                   	pop    %ebp
8010825e:	c3                   	ret    

8010825f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010825f:	55                   	push   %ebp
80108260:	89 e5                	mov    %esp,%ebp
80108262:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108265:	8b 45 10             	mov    0x10(%ebp),%eax
80108268:	85 c0                	test   %eax,%eax
8010826a:	79 0a                	jns    80108276 <allocuvm+0x17>
    return 0;
8010826c:	b8 00 00 00 00       	mov    $0x0,%eax
80108271:	e9 c1 00 00 00       	jmp    80108337 <allocuvm+0xd8>
  if(newsz < oldsz)
80108276:	8b 45 10             	mov    0x10(%ebp),%eax
80108279:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010827c:	73 08                	jae    80108286 <allocuvm+0x27>
    return oldsz;
8010827e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108281:	e9 b1 00 00 00       	jmp    80108337 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108286:	8b 45 0c             	mov    0xc(%ebp),%eax
80108289:	05 ff 0f 00 00       	add    $0xfff,%eax
8010828e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108293:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108296:	e9 8d 00 00 00       	jmp    80108328 <allocuvm+0xc9>
    mem = kalloc();
8010829b:	e8 4f a8 ff ff       	call   80102aef <kalloc>
801082a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082a7:	75 2c                	jne    801082d5 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801082a9:	c7 04 24 29 8d 10 80 	movl   $0x80108d29,(%esp)
801082b0:	e8 eb 80 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801082b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801082b8:	89 44 24 08          	mov    %eax,0x8(%esp)
801082bc:	8b 45 10             	mov    0x10(%ebp),%eax
801082bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801082c3:	8b 45 08             	mov    0x8(%ebp),%eax
801082c6:	89 04 24             	mov    %eax,(%esp)
801082c9:	e8 6b 00 00 00       	call   80108339 <deallocuvm>
      return 0;
801082ce:	b8 00 00 00 00       	mov    $0x0,%eax
801082d3:	eb 62                	jmp    80108337 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801082d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082dc:	00 
801082dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082e4:	00 
801082e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082e8:	89 04 24             	mov    %eax,(%esp)
801082eb:	e8 11 d0 ff ff       	call   80105301 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f3:	89 04 24             	mov    %eax,(%esp)
801082f6:	e8 cc f5 ff ff       	call   801078c7 <v2p>
801082fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801082fe:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108305:	00 
80108306:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010830a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108311:	00 
80108312:	89 54 24 04          	mov    %edx,0x4(%esp)
80108316:	8b 45 08             	mov    0x8(%ebp),%eax
80108319:	89 04 24             	mov    %eax,(%esp)
8010831c:	e8 d8 fa ff ff       	call   80107df9 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108321:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010832e:	0f 82 67 ff ff ff    	jb     8010829b <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108334:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108337:	c9                   	leave  
80108338:	c3                   	ret    

80108339 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108339:	55                   	push   %ebp
8010833a:	89 e5                	mov    %esp,%ebp
8010833c:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010833f:	8b 45 10             	mov    0x10(%ebp),%eax
80108342:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108345:	72 08                	jb     8010834f <deallocuvm+0x16>
    return oldsz;
80108347:	8b 45 0c             	mov    0xc(%ebp),%eax
8010834a:	e9 a4 00 00 00       	jmp    801083f3 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010834f:	8b 45 10             	mov    0x10(%ebp),%eax
80108352:	05 ff 0f 00 00       	add    $0xfff,%eax
80108357:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010835c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010835f:	e9 80 00 00 00       	jmp    801083e4 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108367:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010836e:	00 
8010836f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108373:	8b 45 08             	mov    0x8(%ebp),%eax
80108376:	89 04 24             	mov    %eax,(%esp)
80108379:	e8 d9 f9 ff ff       	call   80107d57 <walkpgdir>
8010837e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108381:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108385:	75 09                	jne    80108390 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108387:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010838e:	eb 4d                	jmp    801083dd <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108393:	8b 00                	mov    (%eax),%eax
80108395:	83 e0 01             	and    $0x1,%eax
80108398:	85 c0                	test   %eax,%eax
8010839a:	74 41                	je     801083dd <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
8010839c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010839f:	8b 00                	mov    (%eax),%eax
801083a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801083a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083ad:	75 0c                	jne    801083bb <deallocuvm+0x82>
        panic("kfree");
801083af:	c7 04 24 41 8d 10 80 	movl   $0x80108d41,(%esp)
801083b6:	e8 7f 81 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
801083bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083be:	89 04 24             	mov    %eax,(%esp)
801083c1:	e8 0e f5 ff ff       	call   801078d4 <p2v>
801083c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801083c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083cc:	89 04 24             	mov    %eax,(%esp)
801083cf:	e8 82 a6 ff ff       	call   80102a56 <kfree>
      *pte = 0;
801083d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801083dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083ea:	0f 82 74 ff ff ff    	jb     80108364 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801083f0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083f3:	c9                   	leave  
801083f4:	c3                   	ret    

801083f5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801083f5:	55                   	push   %ebp
801083f6:	89 e5                	mov    %esp,%ebp
801083f8:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801083fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801083ff:	75 0c                	jne    8010840d <freevm+0x18>
    panic("freevm: no pgdir");
80108401:	c7 04 24 47 8d 10 80 	movl   $0x80108d47,(%esp)
80108408:	e8 2d 81 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010840d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108414:	00 
80108415:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010841c:	80 
8010841d:	8b 45 08             	mov    0x8(%ebp),%eax
80108420:	89 04 24             	mov    %eax,(%esp)
80108423:	e8 11 ff ff ff       	call   80108339 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108428:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010842f:	eb 48                	jmp    80108479 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108434:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010843b:	8b 45 08             	mov    0x8(%ebp),%eax
8010843e:	01 d0                	add    %edx,%eax
80108440:	8b 00                	mov    (%eax),%eax
80108442:	83 e0 01             	and    $0x1,%eax
80108445:	85 c0                	test   %eax,%eax
80108447:	74 2c                	je     80108475 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108453:	8b 45 08             	mov    0x8(%ebp),%eax
80108456:	01 d0                	add    %edx,%eax
80108458:	8b 00                	mov    (%eax),%eax
8010845a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010845f:	89 04 24             	mov    %eax,(%esp)
80108462:	e8 6d f4 ff ff       	call   801078d4 <p2v>
80108467:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010846a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010846d:	89 04 24             	mov    %eax,(%esp)
80108470:	e8 e1 a5 ff ff       	call   80102a56 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108475:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108479:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108480:	76 af                	jbe    80108431 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108482:	8b 45 08             	mov    0x8(%ebp),%eax
80108485:	89 04 24             	mov    %eax,(%esp)
80108488:	e8 c9 a5 ff ff       	call   80102a56 <kfree>
}
8010848d:	c9                   	leave  
8010848e:	c3                   	ret    

8010848f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010848f:	55                   	push   %ebp
80108490:	89 e5                	mov    %esp,%ebp
80108492:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108495:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010849c:	00 
8010849d:	8b 45 0c             	mov    0xc(%ebp),%eax
801084a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801084a4:	8b 45 08             	mov    0x8(%ebp),%eax
801084a7:	89 04 24             	mov    %eax,(%esp)
801084aa:	e8 a8 f8 ff ff       	call   80107d57 <walkpgdir>
801084af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801084b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801084b6:	75 0c                	jne    801084c4 <clearpteu+0x35>
    panic("clearpteu");
801084b8:	c7 04 24 58 8d 10 80 	movl   $0x80108d58,(%esp)
801084bf:	e8 76 80 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
801084c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c7:	8b 00                	mov    (%eax),%eax
801084c9:	83 e0 fb             	and    $0xfffffffb,%eax
801084cc:	89 c2                	mov    %eax,%edx
801084ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d1:	89 10                	mov    %edx,(%eax)
}
801084d3:	c9                   	leave  
801084d4:	c3                   	ret    

801084d5 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801084d5:	55                   	push   %ebp
801084d6:	89 e5                	mov    %esp,%ebp
801084d8:	53                   	push   %ebx
801084d9:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801084dc:	e8 b0 f9 ff ff       	call   80107e91 <setupkvm>
801084e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084e8:	75 0a                	jne    801084f4 <copyuvm+0x1f>
    return 0;
801084ea:	b8 00 00 00 00       	mov    $0x0,%eax
801084ef:	e9 fd 00 00 00       	jmp    801085f1 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801084f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084fb:	e9 d0 00 00 00       	jmp    801085d0 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108503:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010850a:	00 
8010850b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010850f:	8b 45 08             	mov    0x8(%ebp),%eax
80108512:	89 04 24             	mov    %eax,(%esp)
80108515:	e8 3d f8 ff ff       	call   80107d57 <walkpgdir>
8010851a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010851d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108521:	75 0c                	jne    8010852f <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108523:	c7 04 24 62 8d 10 80 	movl   $0x80108d62,(%esp)
8010852a:	e8 0b 80 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
8010852f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108532:	8b 00                	mov    (%eax),%eax
80108534:	83 e0 01             	and    $0x1,%eax
80108537:	85 c0                	test   %eax,%eax
80108539:	75 0c                	jne    80108547 <copyuvm+0x72>
      panic("copyuvm: page not present");
8010853b:	c7 04 24 7c 8d 10 80 	movl   $0x80108d7c,(%esp)
80108542:	e8 f3 7f ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108547:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010854a:	8b 00                	mov    (%eax),%eax
8010854c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108551:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108554:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108557:	8b 00                	mov    (%eax),%eax
80108559:	25 ff 0f 00 00       	and    $0xfff,%eax
8010855e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108561:	e8 89 a5 ff ff       	call   80102aef <kalloc>
80108566:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108569:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010856d:	75 02                	jne    80108571 <copyuvm+0x9c>
      goto bad;
8010856f:	eb 70                	jmp    801085e1 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108571:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108574:	89 04 24             	mov    %eax,(%esp)
80108577:	e8 58 f3 ff ff       	call   801078d4 <p2v>
8010857c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108583:	00 
80108584:	89 44 24 04          	mov    %eax,0x4(%esp)
80108588:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010858b:	89 04 24             	mov    %eax,(%esp)
8010858e:	e8 3d ce ff ff       	call   801053d0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108593:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108596:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108599:	89 04 24             	mov    %eax,(%esp)
8010859c:	e8 26 f3 ff ff       	call   801078c7 <v2p>
801085a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085a4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801085a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
801085ac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085b3:	00 
801085b4:	89 54 24 04          	mov    %edx,0x4(%esp)
801085b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085bb:	89 04 24             	mov    %eax,(%esp)
801085be:	e8 36 f8 ff ff       	call   80107df9 <mappages>
801085c3:	85 c0                	test   %eax,%eax
801085c5:	79 02                	jns    801085c9 <copyuvm+0xf4>
      goto bad;
801085c7:	eb 18                	jmp    801085e1 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801085c9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085d6:	0f 82 24 ff ff ff    	jb     80108500 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801085dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085df:	eb 10                	jmp    801085f1 <copyuvm+0x11c>

bad:
  freevm(d);
801085e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e4:	89 04 24             	mov    %eax,(%esp)
801085e7:	e8 09 fe ff ff       	call   801083f5 <freevm>
  return 0;
801085ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085f1:	83 c4 44             	add    $0x44,%esp
801085f4:	5b                   	pop    %ebx
801085f5:	5d                   	pop    %ebp
801085f6:	c3                   	ret    

801085f7 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801085f7:	55                   	push   %ebp
801085f8:	89 e5                	mov    %esp,%ebp
801085fa:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108604:	00 
80108605:	8b 45 0c             	mov    0xc(%ebp),%eax
80108608:	89 44 24 04          	mov    %eax,0x4(%esp)
8010860c:	8b 45 08             	mov    0x8(%ebp),%eax
8010860f:	89 04 24             	mov    %eax,(%esp)
80108612:	e8 40 f7 ff ff       	call   80107d57 <walkpgdir>
80108617:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010861a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861d:	8b 00                	mov    (%eax),%eax
8010861f:	83 e0 01             	and    $0x1,%eax
80108622:	85 c0                	test   %eax,%eax
80108624:	75 07                	jne    8010862d <uva2ka+0x36>
    return 0;
80108626:	b8 00 00 00 00       	mov    $0x0,%eax
8010862b:	eb 25                	jmp    80108652 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
8010862d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108630:	8b 00                	mov    (%eax),%eax
80108632:	83 e0 04             	and    $0x4,%eax
80108635:	85 c0                	test   %eax,%eax
80108637:	75 07                	jne    80108640 <uva2ka+0x49>
    return 0;
80108639:	b8 00 00 00 00       	mov    $0x0,%eax
8010863e:	eb 12                	jmp    80108652 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108643:	8b 00                	mov    (%eax),%eax
80108645:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010864a:	89 04 24             	mov    %eax,(%esp)
8010864d:	e8 82 f2 ff ff       	call   801078d4 <p2v>
}
80108652:	c9                   	leave  
80108653:	c3                   	ret    

80108654 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108654:	55                   	push   %ebp
80108655:	89 e5                	mov    %esp,%ebp
80108657:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010865a:	8b 45 10             	mov    0x10(%ebp),%eax
8010865d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108660:	e9 87 00 00 00       	jmp    801086ec <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108665:	8b 45 0c             	mov    0xc(%ebp),%eax
80108668:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010866d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108670:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108673:	89 44 24 04          	mov    %eax,0x4(%esp)
80108677:	8b 45 08             	mov    0x8(%ebp),%eax
8010867a:	89 04 24             	mov    %eax,(%esp)
8010867d:	e8 75 ff ff ff       	call   801085f7 <uva2ka>
80108682:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108685:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108689:	75 07                	jne    80108692 <copyout+0x3e>
      return -1;
8010868b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108690:	eb 69                	jmp    801086fb <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108692:	8b 45 0c             	mov    0xc(%ebp),%eax
80108695:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108698:	29 c2                	sub    %eax,%edx
8010869a:	89 d0                	mov    %edx,%eax
8010869c:	05 00 10 00 00       	add    $0x1000,%eax
801086a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801086a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a7:	3b 45 14             	cmp    0x14(%ebp),%eax
801086aa:	76 06                	jbe    801086b2 <copyout+0x5e>
      n = len;
801086ac:	8b 45 14             	mov    0x14(%ebp),%eax
801086af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801086b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086b5:	8b 55 0c             	mov    0xc(%ebp),%edx
801086b8:	29 c2                	sub    %eax,%edx
801086ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086bd:	01 c2                	add    %eax,%edx
801086bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801086c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801086cd:	89 14 24             	mov    %edx,(%esp)
801086d0:	e8 fb cc ff ff       	call   801053d0 <memmove>
    len -= n;
801086d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d8:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801086db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086de:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801086e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086e4:	05 00 10 00 00       	add    $0x1000,%eax
801086e9:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801086ec:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801086f0:	0f 85 6f ff ff ff    	jne    80108665 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801086f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086fb:	c9                   	leave  
801086fc:	c3                   	ret    
