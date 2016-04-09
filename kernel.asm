
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
8010002d:	b8 27 37 10 80       	mov    $0x80103727,%eax
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
8010003a:	c7 44 24 04 0c 87 10 	movl   $0x8010870c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 4a 50 00 00       	call   80105098 <initlock>

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
801000bd:	e8 f7 4f 00 00       	call   801050b9 <acquire>

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
80100104:	e8 12 50 00 00       	call   8010511b <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 34 4b 00 00       	call   80104c58 <sleep>
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
8010017c:	e8 9a 4f 00 00       	call   8010511b <release>
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
80100198:	c7 04 24 13 87 10 80 	movl   $0x80108713,(%esp)
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
801001d3:	e8 d9 25 00 00       	call   801027b1 <iderw>
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
801001ef:	c7 04 24 24 87 10 80 	movl   $0x80108724,(%esp)
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
80100210:	e8 9c 25 00 00       	call   801027b1 <iderw>
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
80100229:	c7 04 24 2b 87 10 80 	movl   $0x8010872b,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 78 4e 00 00       	call   801050b9 <acquire>

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
8010029d:	e8 91 4a 00 00       	call   80104d33 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 6d 4e 00 00       	call   8010511b <release>
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
801003bb:	e8 f9 4c 00 00       	call   801050b9 <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 32 87 10 80 	movl   $0x80108732,(%esp)
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
801004b0:	c7 45 ec 3b 87 10 80 	movl   $0x8010873b,-0x14(%ebp)
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
80100533:	e8 e3 4b 00 00       	call   8010511b <release>
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
8010055f:	c7 04 24 42 87 10 80 	movl   $0x80108742,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 51 87 10 80 	movl   $0x80108751,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 d6 4b 00 00       	call   8010516a <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 53 87 10 80 	movl   $0x80108753,(%esp)
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
801006b2:	e8 25 4d 00 00       	call   801053dc <memmove>
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
801006e1:	e8 27 4c 00 00       	call   8010530d <memset>
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
80100776:	e8 d1 65 00 00       	call   80106d4c <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 c5 65 00 00       	call   80106d4c <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 b9 65 00 00       	call   80106d4c <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 ac 65 00 00       	call   80106d4c <uartputc>
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
801007ba:	e8 fa 48 00 00       	call   801050b9 <acquire>
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
801007ea:	e8 ea 45 00 00       	call   80104dd9 <procdump>
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
801008f3:	e8 3b 44 00 00       	call   80104d33 <wakeup>
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
80100914:	e8 02 48 00 00       	call   8010511b <release>
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
80100927:	e8 8d 10 00 00       	call   801019b9 <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100939:	e8 7b 47 00 00       	call   801050b9 <acquire>
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
80100959:	e8 bd 47 00 00       	call   8010511b <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 02 0f 00 00       	call   8010186b <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 80 07 11 	movl   $0x80110780,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
80100982:	e8 d1 42 00 00       	call   80104c58 <sleep>

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
801009fe:	e8 18 47 00 00       	call   8010511b <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 5d 0e 00 00       	call   8010186b <ilock>

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
80100a26:	e8 8e 0f 00 00       	call   801019b9 <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a32:	e8 82 46 00 00       	call   801050b9 <acquire>
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
80100a6c:	e8 aa 46 00 00       	call   8010511b <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 ef 0d 00 00       	call   8010186b <ilock>

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
80100a87:	c7 44 24 04 57 87 10 	movl   $0x80108757,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a96:	e8 fd 45 00 00       	call   80105098 <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 5f 87 10 	movl   $0x8010875f,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100aaa:	e8 e9 45 00 00       	call   80105098 <initlock>

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
80100ad4:	e8 eb 32 00 00       	call   80103dc4 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 80 1e 00 00       	call   8010296d <ioapicenable>
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
80100af8:	e8 23 29 00 00       	call   80103420 <begin_op>
  if((ip = namei(path)) == 0){
80100afd:	8b 45 08             	mov    0x8(%ebp),%eax
80100b00:	89 04 24             	mov    %eax,(%esp)
80100b03:	e8 0e 19 00 00       	call   80102416 <namei>
80100b08:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b0b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b0f:	75 0f                	jne    80100b20 <exec+0x31>
    end_op();
80100b11:	e8 8e 29 00 00       	call   801034a4 <end_op>
    return -1;
80100b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1b:	e9 f8 03 00 00       	jmp    80100f18 <exec+0x429>
  }
  ilock(ip);
80100b20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b23:	89 04 24             	mov    %eax,(%esp)
80100b26:	e8 40 0d 00 00       	call   8010186b <ilock>
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
80100b52:	e8 21 12 00 00       	call   80101d78 <readi>
80100b57:	83 f8 33             	cmp    $0x33,%eax
80100b5a:	77 05                	ja     80100b61 <exec+0x72>
    goto bad;
80100b5c:	e9 8b 03 00 00       	jmp    80100eec <exec+0x3fd>
  if(elf.magic != ELF_MAGIC)
80100b61:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b67:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b6c:	74 05                	je     80100b73 <exec+0x84>
    goto bad;
80100b6e:	e9 79 03 00 00       	jmp    80100eec <exec+0x3fd>

  if((pgdir = setupkvm()) == 0)
80100b73:	e8 25 73 00 00       	call   80107e9d <setupkvm>
80100b78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b7b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b7f:	75 05                	jne    80100b86 <exec+0x97>
    goto bad;
80100b81:	e9 66 03 00 00       	jmp    80100eec <exec+0x3fd>

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
80100bc1:	e8 b2 11 00 00       	call   80101d78 <readi>
80100bc6:	83 f8 20             	cmp    $0x20,%eax
80100bc9:	74 05                	je     80100bd0 <exec+0xe1>
      goto bad;
80100bcb:	e9 1c 03 00 00       	jmp    80100eec <exec+0x3fd>
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
80100bf0:	e9 f7 02 00 00       	jmp    80100eec <exec+0x3fd>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf5:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfb:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c01:	01 d0                	add    %edx,%eax
80100c03:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c11:	89 04 24             	mov    %eax,(%esp)
80100c14:	e8 52 76 00 00       	call   8010826b <allocuvm>
80100c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c20:	75 05                	jne    80100c27 <exec+0x138>
      goto bad;
80100c22:	e9 c5 02 00 00       	jmp    80100eec <exec+0x3fd>
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
80100c52:	e8 29 75 00 00       	call   80108180 <loaduvm>
80100c57:	85 c0                	test   %eax,%eax
80100c59:	79 05                	jns    80100c60 <exec+0x171>
      goto bad;
80100c5b:	e9 8c 02 00 00       	jmp    80100eec <exec+0x3fd>
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
80100c86:	e8 64 0e 00 00       	call   80101aef <iunlockput>
  end_op();
80100c8b:	e8 14 28 00 00       	call   801034a4 <end_op>
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
80100cc0:	e8 a6 75 00 00       	call   8010826b <allocuvm>
80100cc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ccc:	75 05                	jne    80100cd3 <exec+0x1e4>
    goto bad;
80100cce:	e9 19 02 00 00       	jmp    80100eec <exec+0x3fd>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce2:	89 04 24             	mov    %eax,(%esp)
80100ce5:	e8 b1 77 00 00       	call   8010849b <clearpteu>
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
80100d02:	e9 e5 01 00 00       	jmp    80100eec <exec+0x3fd>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d14:	01 d0                	add    %edx,%eax
80100d16:	8b 00                	mov    (%eax),%eax
80100d18:	89 04 24             	mov    %eax,(%esp)
80100d1b:	e8 57 48 00 00       	call   80105577 <strlen>
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
80100d44:	e8 2e 48 00 00       	call   80105577 <strlen>
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
80100d74:	e8 e7 78 00 00       	call   80108660 <copyout>
80100d79:	85 c0                	test   %eax,%eax
80100d7b:	79 05                	jns    80100d82 <exec+0x293>
      goto bad;
80100d7d:	e9 6a 01 00 00       	jmp    80100eec <exec+0x3fd>
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
80100e1b:	e8 40 78 00 00       	call   80108660 <copyout>
80100e20:	85 c0                	test   %eax,%eax
80100e22:	79 05                	jns    80100e29 <exec+0x33a>
    goto bad;
80100e24:	e9 c3 00 00 00       	jmp    80100eec <exec+0x3fd>

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
80100e73:	e8 b5 46 00 00       	call   8010552d <safestrcpy>

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
80100ec2:	c7 80 5c 01 00 00 ff 	movl   $0xffffffff,0x15c(%eax)
80100ec9:	ff ff ff 
  switchuvm(proc);
80100ecc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed2:	89 04 24             	mov    %eax,(%esp)
80100ed5:	e8 b4 70 00 00       	call   80107f8e <switchuvm>
  freevm(oldpgdir);
80100eda:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100edd:	89 04 24             	mov    %eax,(%esp)
80100ee0:	e8 1c 75 00 00       	call   80108401 <freevm>
  return 0;
80100ee5:	b8 00 00 00 00       	mov    $0x0,%eax
80100eea:	eb 2c                	jmp    80100f18 <exec+0x429>

 bad:
  if(pgdir)
80100eec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ef0:	74 0b                	je     80100efd <exec+0x40e>
    freevm(pgdir);
80100ef2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ef5:	89 04 24             	mov    %eax,(%esp)
80100ef8:	e8 04 75 00 00       	call   80108401 <freevm>
  if(ip){
80100efd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f01:	74 10                	je     80100f13 <exec+0x424>
    iunlockput(ip);
80100f03:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f06:	89 04 24             	mov    %eax,(%esp)
80100f09:	e8 e1 0b 00 00       	call   80101aef <iunlockput>
    end_op();
80100f0e:	e8 91 25 00 00       	call   801034a4 <end_op>
  }
  return -1;
80100f13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f18:	c9                   	leave  
80100f19:	c3                   	ret    

80100f1a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f1a:	55                   	push   %ebp
80100f1b:	89 e5                	mov    %esp,%ebp
80100f1d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f20:	c7 44 24 04 65 87 10 	movl   $0x80108765,0x4(%esp)
80100f27:	80 
80100f28:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f2f:	e8 64 41 00 00       	call   80105098 <initlock>
}
80100f34:	c9                   	leave  
80100f35:	c3                   	ret    

80100f36 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f36:	55                   	push   %ebp
80100f37:	89 e5                	mov    %esp,%ebp
80100f39:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f3c:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f43:	e8 71 41 00 00       	call   801050b9 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f48:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f4f:	eb 29                	jmp    80100f7a <filealloc+0x44>
    if(f->ref == 0){
80100f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f54:	8b 40 04             	mov    0x4(%eax),%eax
80100f57:	85 c0                	test   %eax,%eax
80100f59:	75 1b                	jne    80100f76 <filealloc+0x40>
      f->ref = 1;
80100f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f65:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f6c:	e8 aa 41 00 00       	call   8010511b <release>
      return f;
80100f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f74:	eb 1e                	jmp    80100f94 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f76:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f7a:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
80100f81:	72 ce                	jb     80100f51 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f83:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f8a:	e8 8c 41 00 00       	call   8010511b <release>
  return 0;
80100f8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f94:	c9                   	leave  
80100f95:	c3                   	ret    

80100f96 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f96:	55                   	push   %ebp
80100f97:	89 e5                	mov    %esp,%ebp
80100f99:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f9c:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fa3:	e8 11 41 00 00       	call   801050b9 <acquire>
  if(f->ref < 1)
80100fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80100fab:	8b 40 04             	mov    0x4(%eax),%eax
80100fae:	85 c0                	test   %eax,%eax
80100fb0:	7f 0c                	jg     80100fbe <filedup+0x28>
    panic("filedup");
80100fb2:	c7 04 24 6c 87 10 80 	movl   $0x8010876c,(%esp)
80100fb9:	e8 7c f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc1:	8b 40 04             	mov    0x4(%eax),%eax
80100fc4:	8d 50 01             	lea    0x1(%eax),%edx
80100fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fca:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fcd:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fd4:	e8 42 41 00 00       	call   8010511b <release>
  return f;
80100fd9:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fdc:	c9                   	leave  
80100fdd:	c3                   	ret    

80100fde <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fde:	55                   	push   %ebp
80100fdf:	89 e5                	mov    %esp,%ebp
80100fe1:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fe4:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100feb:	e8 c9 40 00 00       	call   801050b9 <acquire>
  if(f->ref < 1)
80100ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff3:	8b 40 04             	mov    0x4(%eax),%eax
80100ff6:	85 c0                	test   %eax,%eax
80100ff8:	7f 0c                	jg     80101006 <fileclose+0x28>
    panic("fileclose");
80100ffa:	c7 04 24 74 87 10 80 	movl   $0x80108774,(%esp)
80101001:	e8 34 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101006:	8b 45 08             	mov    0x8(%ebp),%eax
80101009:	8b 40 04             	mov    0x4(%eax),%eax
8010100c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010100f:	8b 45 08             	mov    0x8(%ebp),%eax
80101012:	89 50 04             	mov    %edx,0x4(%eax)
80101015:	8b 45 08             	mov    0x8(%ebp),%eax
80101018:	8b 40 04             	mov    0x4(%eax),%eax
8010101b:	85 c0                	test   %eax,%eax
8010101d:	7e 11                	jle    80101030 <fileclose+0x52>
    release(&ftable.lock);
8010101f:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101026:	e8 f0 40 00 00       	call   8010511b <release>
8010102b:	e9 82 00 00 00       	jmp    801010b2 <fileclose+0xd4>
    return;
  }
  ff = *f;
80101030:	8b 45 08             	mov    0x8(%ebp),%eax
80101033:	8b 10                	mov    (%eax),%edx
80101035:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101038:	8b 50 04             	mov    0x4(%eax),%edx
8010103b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010103e:	8b 50 08             	mov    0x8(%eax),%edx
80101041:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101044:	8b 50 0c             	mov    0xc(%eax),%edx
80101047:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010104a:	8b 50 10             	mov    0x10(%eax),%edx
8010104d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101050:	8b 40 14             	mov    0x14(%eax),%eax
80101053:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101056:	8b 45 08             	mov    0x8(%ebp),%eax
80101059:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101069:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101070:	e8 a6 40 00 00       	call   8010511b <release>
  
  if(ff.type == FD_PIPE)
80101075:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101078:	83 f8 01             	cmp    $0x1,%eax
8010107b:	75 18                	jne    80101095 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010107d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101081:	0f be d0             	movsbl %al,%edx
80101084:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101087:	89 54 24 04          	mov    %edx,0x4(%esp)
8010108b:	89 04 24             	mov    %eax,(%esp)
8010108e:	e8 e1 2f 00 00       	call   80104074 <pipeclose>
80101093:	eb 1d                	jmp    801010b2 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101095:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101098:	83 f8 02             	cmp    $0x2,%eax
8010109b:	75 15                	jne    801010b2 <fileclose+0xd4>
    begin_op();
8010109d:	e8 7e 23 00 00       	call   80103420 <begin_op>
    iput(ff.ip);
801010a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010a5:	89 04 24             	mov    %eax,(%esp)
801010a8:	e8 71 09 00 00       	call   80101a1e <iput>
    end_op();
801010ad:	e8 f2 23 00 00       	call   801034a4 <end_op>
  }
}
801010b2:	c9                   	leave  
801010b3:	c3                   	ret    

801010b4 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010b4:	55                   	push   %ebp
801010b5:	89 e5                	mov    %esp,%ebp
801010b7:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010ba:	8b 45 08             	mov    0x8(%ebp),%eax
801010bd:	8b 00                	mov    (%eax),%eax
801010bf:	83 f8 02             	cmp    $0x2,%eax
801010c2:	75 38                	jne    801010fc <filestat+0x48>
    ilock(f->ip);
801010c4:	8b 45 08             	mov    0x8(%ebp),%eax
801010c7:	8b 40 10             	mov    0x10(%eax),%eax
801010ca:	89 04 24             	mov    %eax,(%esp)
801010cd:	e8 99 07 00 00       	call   8010186b <ilock>
    stati(f->ip, st);
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	8b 40 10             	mov    0x10(%eax),%eax
801010d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801010db:	89 54 24 04          	mov    %edx,0x4(%esp)
801010df:	89 04 24             	mov    %eax,(%esp)
801010e2:	e8 4c 0c 00 00       	call   80101d33 <stati>
    iunlock(f->ip);
801010e7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ea:	8b 40 10             	mov    0x10(%eax),%eax
801010ed:	89 04 24             	mov    %eax,(%esp)
801010f0:	e8 c4 08 00 00       	call   801019b9 <iunlock>
    return 0;
801010f5:	b8 00 00 00 00       	mov    $0x0,%eax
801010fa:	eb 05                	jmp    80101101 <filestat+0x4d>
  }
  return -1;
801010fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101101:	c9                   	leave  
80101102:	c3                   	ret    

80101103 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101103:	55                   	push   %ebp
80101104:	89 e5                	mov    %esp,%ebp
80101106:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101109:	8b 45 08             	mov    0x8(%ebp),%eax
8010110c:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101110:	84 c0                	test   %al,%al
80101112:	75 0a                	jne    8010111e <fileread+0x1b>
    return -1;
80101114:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101119:	e9 9f 00 00 00       	jmp    801011bd <fileread+0xba>
  if(f->type == FD_PIPE)
8010111e:	8b 45 08             	mov    0x8(%ebp),%eax
80101121:	8b 00                	mov    (%eax),%eax
80101123:	83 f8 01             	cmp    $0x1,%eax
80101126:	75 1e                	jne    80101146 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101128:	8b 45 08             	mov    0x8(%ebp),%eax
8010112b:	8b 40 0c             	mov    0xc(%eax),%eax
8010112e:	8b 55 10             	mov    0x10(%ebp),%edx
80101131:	89 54 24 08          	mov    %edx,0x8(%esp)
80101135:	8b 55 0c             	mov    0xc(%ebp),%edx
80101138:	89 54 24 04          	mov    %edx,0x4(%esp)
8010113c:	89 04 24             	mov    %eax,(%esp)
8010113f:	e8 b1 30 00 00       	call   801041f5 <piperead>
80101144:	eb 77                	jmp    801011bd <fileread+0xba>
  if(f->type == FD_INODE){
80101146:	8b 45 08             	mov    0x8(%ebp),%eax
80101149:	8b 00                	mov    (%eax),%eax
8010114b:	83 f8 02             	cmp    $0x2,%eax
8010114e:	75 61                	jne    801011b1 <fileread+0xae>
    ilock(f->ip);
80101150:	8b 45 08             	mov    0x8(%ebp),%eax
80101153:	8b 40 10             	mov    0x10(%eax),%eax
80101156:	89 04 24             	mov    %eax,(%esp)
80101159:	e8 0d 07 00 00       	call   8010186b <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010115e:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101161:	8b 45 08             	mov    0x8(%ebp),%eax
80101164:	8b 50 14             	mov    0x14(%eax),%edx
80101167:	8b 45 08             	mov    0x8(%ebp),%eax
8010116a:	8b 40 10             	mov    0x10(%eax),%eax
8010116d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101171:	89 54 24 08          	mov    %edx,0x8(%esp)
80101175:	8b 55 0c             	mov    0xc(%ebp),%edx
80101178:	89 54 24 04          	mov    %edx,0x4(%esp)
8010117c:	89 04 24             	mov    %eax,(%esp)
8010117f:	e8 f4 0b 00 00       	call   80101d78 <readi>
80101184:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101187:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010118b:	7e 11                	jle    8010119e <fileread+0x9b>
      f->off += r;
8010118d:	8b 45 08             	mov    0x8(%ebp),%eax
80101190:	8b 50 14             	mov    0x14(%eax),%edx
80101193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101196:	01 c2                	add    %eax,%edx
80101198:	8b 45 08             	mov    0x8(%ebp),%eax
8010119b:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010119e:	8b 45 08             	mov    0x8(%ebp),%eax
801011a1:	8b 40 10             	mov    0x10(%eax),%eax
801011a4:	89 04 24             	mov    %eax,(%esp)
801011a7:	e8 0d 08 00 00       	call   801019b9 <iunlock>
    return r;
801011ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011af:	eb 0c                	jmp    801011bd <fileread+0xba>
  }
  panic("fileread");
801011b1:	c7 04 24 7e 87 10 80 	movl   $0x8010877e,(%esp)
801011b8:	e8 7d f3 ff ff       	call   8010053a <panic>
}
801011bd:	c9                   	leave  
801011be:	c3                   	ret    

801011bf <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011bf:	55                   	push   %ebp
801011c0:	89 e5                	mov    %esp,%ebp
801011c2:	53                   	push   %ebx
801011c3:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011c6:	8b 45 08             	mov    0x8(%ebp),%eax
801011c9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011cd:	84 c0                	test   %al,%al
801011cf:	75 0a                	jne    801011db <filewrite+0x1c>
    return -1;
801011d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d6:	e9 20 01 00 00       	jmp    801012fb <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	8b 00                	mov    (%eax),%eax
801011e0:	83 f8 01             	cmp    $0x1,%eax
801011e3:	75 21                	jne    80101206 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011e5:	8b 45 08             	mov    0x8(%ebp),%eax
801011e8:	8b 40 0c             	mov    0xc(%eax),%eax
801011eb:	8b 55 10             	mov    0x10(%ebp),%edx
801011ee:	89 54 24 08          	mov    %edx,0x8(%esp)
801011f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801011f5:	89 54 24 04          	mov    %edx,0x4(%esp)
801011f9:	89 04 24             	mov    %eax,(%esp)
801011fc:	e8 05 2f 00 00       	call   80104106 <pipewrite>
80101201:	e9 f5 00 00 00       	jmp    801012fb <filewrite+0x13c>
  if(f->type == FD_INODE){
80101206:	8b 45 08             	mov    0x8(%ebp),%eax
80101209:	8b 00                	mov    (%eax),%eax
8010120b:	83 f8 02             	cmp    $0x2,%eax
8010120e:	0f 85 db 00 00 00    	jne    801012ef <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101214:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010121b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101222:	e9 a8 00 00 00       	jmp    801012cf <filewrite+0x110>
      int n1 = n - i;
80101227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010122a:	8b 55 10             	mov    0x10(%ebp),%edx
8010122d:	29 c2                	sub    %eax,%edx
8010122f:	89 d0                	mov    %edx,%eax
80101231:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101234:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101237:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010123a:	7e 06                	jle    80101242 <filewrite+0x83>
        n1 = max;
8010123c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010123f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101242:	e8 d9 21 00 00       	call   80103420 <begin_op>
      ilock(f->ip);
80101247:	8b 45 08             	mov    0x8(%ebp),%eax
8010124a:	8b 40 10             	mov    0x10(%eax),%eax
8010124d:	89 04 24             	mov    %eax,(%esp)
80101250:	e8 16 06 00 00       	call   8010186b <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101255:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101258:	8b 45 08             	mov    0x8(%ebp),%eax
8010125b:	8b 50 14             	mov    0x14(%eax),%edx
8010125e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101261:	8b 45 0c             	mov    0xc(%ebp),%eax
80101264:	01 c3                	add    %eax,%ebx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	8b 40 10             	mov    0x10(%eax),%eax
8010126c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101270:	89 54 24 08          	mov    %edx,0x8(%esp)
80101274:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101278:	89 04 24             	mov    %eax,(%esp)
8010127b:	e8 5c 0c 00 00       	call   80101edc <writei>
80101280:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101283:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101287:	7e 11                	jle    8010129a <filewrite+0xdb>
        f->off += r;
80101289:	8b 45 08             	mov    0x8(%ebp),%eax
8010128c:	8b 50 14             	mov    0x14(%eax),%edx
8010128f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101292:	01 c2                	add    %eax,%edx
80101294:	8b 45 08             	mov    0x8(%ebp),%eax
80101297:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010129a:	8b 45 08             	mov    0x8(%ebp),%eax
8010129d:	8b 40 10             	mov    0x10(%eax),%eax
801012a0:	89 04 24             	mov    %eax,(%esp)
801012a3:	e8 11 07 00 00       	call   801019b9 <iunlock>
      end_op();
801012a8:	e8 f7 21 00 00       	call   801034a4 <end_op>

      if(r < 0)
801012ad:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012b1:	79 02                	jns    801012b5 <filewrite+0xf6>
        break;
801012b3:	eb 26                	jmp    801012db <filewrite+0x11c>
      if(r != n1)
801012b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012b8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012bb:	74 0c                	je     801012c9 <filewrite+0x10a>
        panic("short filewrite");
801012bd:	c7 04 24 87 87 10 80 	movl   $0x80108787,(%esp)
801012c4:	e8 71 f2 ff ff       	call   8010053a <panic>
      i += r;
801012c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012cc:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d2:	3b 45 10             	cmp    0x10(%ebp),%eax
801012d5:	0f 8c 4c ff ff ff    	jl     80101227 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012de:	3b 45 10             	cmp    0x10(%ebp),%eax
801012e1:	75 05                	jne    801012e8 <filewrite+0x129>
801012e3:	8b 45 10             	mov    0x10(%ebp),%eax
801012e6:	eb 05                	jmp    801012ed <filewrite+0x12e>
801012e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012ed:	eb 0c                	jmp    801012fb <filewrite+0x13c>
  }
  panic("filewrite");
801012ef:	c7 04 24 97 87 10 80 	movl   $0x80108797,(%esp)
801012f6:	e8 3f f2 ff ff       	call   8010053a <panic>
}
801012fb:	83 c4 24             	add    $0x24,%esp
801012fe:	5b                   	pop    %ebx
801012ff:	5d                   	pop    %ebp
80101300:	c3                   	ret    

80101301 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101301:	55                   	push   %ebp
80101302:	89 e5                	mov    %esp,%ebp
80101304:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101307:	8b 45 08             	mov    0x8(%ebp),%eax
8010130a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101311:	00 
80101312:	89 04 24             	mov    %eax,(%esp)
80101315:	e8 8c ee ff ff       	call   801001a6 <bread>
8010131a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010131d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101320:	83 c0 18             	add    $0x18,%eax
80101323:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010132a:	00 
8010132b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010132f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101332:	89 04 24             	mov    %eax,(%esp)
80101335:	e8 a2 40 00 00       	call   801053dc <memmove>
  brelse(bp);
8010133a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010133d:	89 04 24             	mov    %eax,(%esp)
80101340:	e8 d2 ee ff ff       	call   80100217 <brelse>
}
80101345:	c9                   	leave  
80101346:	c3                   	ret    

80101347 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101347:	55                   	push   %ebp
80101348:	89 e5                	mov    %esp,%ebp
8010134a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010134d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	89 54 24 04          	mov    %edx,0x4(%esp)
80101357:	89 04 24             	mov    %eax,(%esp)
8010135a:	e8 47 ee ff ff       	call   801001a6 <bread>
8010135f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101365:	83 c0 18             	add    $0x18,%eax
80101368:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010136f:	00 
80101370:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101377:	00 
80101378:	89 04 24             	mov    %eax,(%esp)
8010137b:	e8 8d 3f 00 00       	call   8010530d <memset>
  log_write(bp);
80101380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101383:	89 04 24             	mov    %eax,(%esp)
80101386:	e8 a0 22 00 00       	call   8010362b <log_write>
  brelse(bp);
8010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138e:	89 04 24             	mov    %eax,(%esp)
80101391:	e8 81 ee ff ff       	call   80100217 <brelse>
}
80101396:	c9                   	leave  
80101397:	c3                   	ret    

80101398 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101398:	55                   	push   %ebp
80101399:	89 e5                	mov    %esp,%ebp
8010139b:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010139e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013a5:	8b 45 08             	mov    0x8(%ebp),%eax
801013a8:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801013af:	89 04 24             	mov    %eax,(%esp)
801013b2:	e8 4a ff ff ff       	call   80101301 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013be:	e9 07 01 00 00       	jmp    801014ca <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013cc:	85 c0                	test   %eax,%eax
801013ce:	0f 48 c2             	cmovs  %edx,%eax
801013d1:	c1 f8 0c             	sar    $0xc,%eax
801013d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013d7:	c1 ea 03             	shr    $0x3,%edx
801013da:	01 d0                	add    %edx,%eax
801013dc:	83 c0 03             	add    $0x3,%eax
801013df:	89 44 24 04          	mov    %eax,0x4(%esp)
801013e3:	8b 45 08             	mov    0x8(%ebp),%eax
801013e6:	89 04 24             	mov    %eax,(%esp)
801013e9:	e8 b8 ed ff ff       	call   801001a6 <bread>
801013ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013f8:	e9 9d 00 00 00       	jmp    8010149a <balloc+0x102>
      m = 1 << (bi % 8);
801013fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101400:	99                   	cltd   
80101401:	c1 ea 1d             	shr    $0x1d,%edx
80101404:	01 d0                	add    %edx,%eax
80101406:	83 e0 07             	and    $0x7,%eax
80101409:	29 d0                	sub    %edx,%eax
8010140b:	ba 01 00 00 00       	mov    $0x1,%edx
80101410:	89 c1                	mov    %eax,%ecx
80101412:	d3 e2                	shl    %cl,%edx
80101414:	89 d0                	mov    %edx,%eax
80101416:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101419:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010141c:	8d 50 07             	lea    0x7(%eax),%edx
8010141f:	85 c0                	test   %eax,%eax
80101421:	0f 48 c2             	cmovs  %edx,%eax
80101424:	c1 f8 03             	sar    $0x3,%eax
80101427:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010142a:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010142f:	0f b6 c0             	movzbl %al,%eax
80101432:	23 45 e8             	and    -0x18(%ebp),%eax
80101435:	85 c0                	test   %eax,%eax
80101437:	75 5d                	jne    80101496 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101439:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010143c:	8d 50 07             	lea    0x7(%eax),%edx
8010143f:	85 c0                	test   %eax,%eax
80101441:	0f 48 c2             	cmovs  %edx,%eax
80101444:	c1 f8 03             	sar    $0x3,%eax
80101447:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010144a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010144f:	89 d1                	mov    %edx,%ecx
80101451:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101454:	09 ca                	or     %ecx,%edx
80101456:	89 d1                	mov    %edx,%ecx
80101458:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010145b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010145f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101462:	89 04 24             	mov    %eax,(%esp)
80101465:	e8 c1 21 00 00       	call   8010362b <log_write>
        brelse(bp);
8010146a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010146d:	89 04 24             	mov    %eax,(%esp)
80101470:	e8 a2 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101478:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010147b:	01 c2                	add    %eax,%edx
8010147d:	8b 45 08             	mov    0x8(%ebp),%eax
80101480:	89 54 24 04          	mov    %edx,0x4(%esp)
80101484:	89 04 24             	mov    %eax,(%esp)
80101487:	e8 bb fe ff ff       	call   80101347 <bzero>
        return b + bi;
8010148c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101492:	01 d0                	add    %edx,%eax
80101494:	eb 4e                	jmp    801014e4 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101496:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010149a:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014a1:	7f 15                	jg     801014b8 <balloc+0x120>
801014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a9:	01 d0                	add    %edx,%eax
801014ab:	89 c2                	mov    %eax,%edx
801014ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014b0:	39 c2                	cmp    %eax,%edx
801014b2:	0f 82 45 ff ff ff    	jb     801013fd <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014bb:	89 04 24             	mov    %eax,(%esp)
801014be:	e8 54 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014c3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014d0:	39 c2                	cmp    %eax,%edx
801014d2:	0f 82 eb fe ff ff    	jb     801013c3 <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014d8:	c7 04 24 a1 87 10 80 	movl   $0x801087a1,(%esp)
801014df:	e8 56 f0 ff ff       	call   8010053a <panic>
}
801014e4:	c9                   	leave  
801014e5:	c3                   	ret    

801014e6 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014e6:	55                   	push   %ebp
801014e7:	89 e5                	mov    %esp,%ebp
801014e9:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801014f3:	8b 45 08             	mov    0x8(%ebp),%eax
801014f6:	89 04 24             	mov    %eax,(%esp)
801014f9:	e8 03 fe ff ff       	call   80101301 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80101501:	c1 e8 0c             	shr    $0xc,%eax
80101504:	89 c2                	mov    %eax,%edx
80101506:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101509:	c1 e8 03             	shr    $0x3,%eax
8010150c:	01 d0                	add    %edx,%eax
8010150e:	8d 50 03             	lea    0x3(%eax),%edx
80101511:	8b 45 08             	mov    0x8(%ebp),%eax
80101514:	89 54 24 04          	mov    %edx,0x4(%esp)
80101518:	89 04 24             	mov    %eax,(%esp)
8010151b:	e8 86 ec ff ff       	call   801001a6 <bread>
80101520:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101523:	8b 45 0c             	mov    0xc(%ebp),%eax
80101526:	25 ff 0f 00 00       	and    $0xfff,%eax
8010152b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010152e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101531:	99                   	cltd   
80101532:	c1 ea 1d             	shr    $0x1d,%edx
80101535:	01 d0                	add    %edx,%eax
80101537:	83 e0 07             	and    $0x7,%eax
8010153a:	29 d0                	sub    %edx,%eax
8010153c:	ba 01 00 00 00       	mov    $0x1,%edx
80101541:	89 c1                	mov    %eax,%ecx
80101543:	d3 e2                	shl    %cl,%edx
80101545:	89 d0                	mov    %edx,%eax
80101547:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154d:	8d 50 07             	lea    0x7(%eax),%edx
80101550:	85 c0                	test   %eax,%eax
80101552:	0f 48 c2             	cmovs  %edx,%eax
80101555:	c1 f8 03             	sar    $0x3,%eax
80101558:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155b:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101560:	0f b6 c0             	movzbl %al,%eax
80101563:	23 45 ec             	and    -0x14(%ebp),%eax
80101566:	85 c0                	test   %eax,%eax
80101568:	75 0c                	jne    80101576 <bfree+0x90>
    panic("freeing free block");
8010156a:	c7 04 24 b7 87 10 80 	movl   $0x801087b7,(%esp)
80101571:	e8 c4 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101576:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101579:	8d 50 07             	lea    0x7(%eax),%edx
8010157c:	85 c0                	test   %eax,%eax
8010157e:	0f 48 c2             	cmovs  %edx,%eax
80101581:	c1 f8 03             	sar    $0x3,%eax
80101584:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101587:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010158c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010158f:	f7 d1                	not    %ecx
80101591:	21 ca                	and    %ecx,%edx
80101593:	89 d1                	mov    %edx,%ecx
80101595:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101598:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010159c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159f:	89 04 24             	mov    %eax,(%esp)
801015a2:	e8 84 20 00 00       	call   8010362b <log_write>
  brelse(bp);
801015a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015aa:	89 04 24             	mov    %eax,(%esp)
801015ad:	e8 65 ec ff ff       	call   80100217 <brelse>
}
801015b2:	c9                   	leave  
801015b3:	c3                   	ret    

801015b4 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015b4:	55                   	push   %ebp
801015b5:	89 e5                	mov    %esp,%ebp
801015b7:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015ba:	c7 44 24 04 ca 87 10 	movl   $0x801087ca,0x4(%esp)
801015c1:	80 
801015c2:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801015c9:	e8 ca 3a 00 00       	call   80105098 <initlock>
}
801015ce:	c9                   	leave  
801015cf:	c3                   	ret    

801015d0 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015d0:	55                   	push   %ebp
801015d1:	89 e5                	mov    %esp,%ebp
801015d3:	83 ec 38             	sub    $0x38,%esp
801015d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d9:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015dd:	8b 45 08             	mov    0x8(%ebp),%eax
801015e0:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015e3:	89 54 24 04          	mov    %edx,0x4(%esp)
801015e7:	89 04 24             	mov    %eax,(%esp)
801015ea:	e8 12 fd ff ff       	call   80101301 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015ef:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015f6:	e9 98 00 00 00       	jmp    80101693 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fe:	c1 e8 03             	shr    $0x3,%eax
80101601:	83 c0 02             	add    $0x2,%eax
80101604:	89 44 24 04          	mov    %eax,0x4(%esp)
80101608:	8b 45 08             	mov    0x8(%ebp),%eax
8010160b:	89 04 24             	mov    %eax,(%esp)
8010160e:	e8 93 eb ff ff       	call   801001a6 <bread>
80101613:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101619:	8d 50 18             	lea    0x18(%eax),%edx
8010161c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161f:	83 e0 07             	and    $0x7,%eax
80101622:	c1 e0 06             	shl    $0x6,%eax
80101625:	01 d0                	add    %edx,%eax
80101627:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010162a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010162d:	0f b7 00             	movzwl (%eax),%eax
80101630:	66 85 c0             	test   %ax,%ax
80101633:	75 4f                	jne    80101684 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101635:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010163c:	00 
8010163d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101644:	00 
80101645:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101648:	89 04 24             	mov    %eax,(%esp)
8010164b:	e8 bd 3c 00 00       	call   8010530d <memset>
      dip->type = type;
80101650:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101653:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101657:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010165a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165d:	89 04 24             	mov    %eax,(%esp)
80101660:	e8 c6 1f 00 00       	call   8010362b <log_write>
      brelse(bp);
80101665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101668:	89 04 24             	mov    %eax,(%esp)
8010166b:	e8 a7 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101673:	89 44 24 04          	mov    %eax,0x4(%esp)
80101677:	8b 45 08             	mov    0x8(%ebp),%eax
8010167a:	89 04 24             	mov    %eax,(%esp)
8010167d:	e8 e5 00 00 00       	call   80101767 <iget>
80101682:	eb 29                	jmp    801016ad <ialloc+0xdd>
    }
    brelse(bp);
80101684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101687:	89 04 24             	mov    %eax,(%esp)
8010168a:	e8 88 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010168f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101693:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101696:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101699:	39 c2                	cmp    %eax,%edx
8010169b:	0f 82 5a ff ff ff    	jb     801015fb <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016a1:	c7 04 24 d1 87 10 80 	movl   $0x801087d1,(%esp)
801016a8:	e8 8d ee ff ff       	call   8010053a <panic>
}
801016ad:	c9                   	leave  
801016ae:	c3                   	ret    

801016af <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016af:	55                   	push   %ebp
801016b0:	89 e5                	mov    %esp,%ebp
801016b2:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016b5:	8b 45 08             	mov    0x8(%ebp),%eax
801016b8:	8b 40 04             	mov    0x4(%eax),%eax
801016bb:	c1 e8 03             	shr    $0x3,%eax
801016be:	8d 50 02             	lea    0x2(%eax),%edx
801016c1:	8b 45 08             	mov    0x8(%ebp),%eax
801016c4:	8b 00                	mov    (%eax),%eax
801016c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ca:	89 04 24             	mov    %eax,(%esp)
801016cd:	e8 d4 ea ff ff       	call   801001a6 <bread>
801016d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d8:	8d 50 18             	lea    0x18(%eax),%edx
801016db:	8b 45 08             	mov    0x8(%ebp),%eax
801016de:	8b 40 04             	mov    0x4(%eax),%eax
801016e1:	83 e0 07             	and    $0x7,%eax
801016e4:	c1 e0 06             	shl    $0x6,%eax
801016e7:	01 d0                	add    %edx,%eax
801016e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016ec:	8b 45 08             	mov    0x8(%ebp),%eax
801016ef:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f6:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016f9:	8b 45 08             	mov    0x8(%ebp),%eax
801016fc:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101703:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101707:	8b 45 08             	mov    0x8(%ebp),%eax
8010170a:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010170e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101711:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101715:	8b 45 08             	mov    0x8(%ebp),%eax
80101718:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010171c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171f:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101723:	8b 45 08             	mov    0x8(%ebp),%eax
80101726:	8b 50 18             	mov    0x18(%eax),%edx
80101729:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010172c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010172f:	8b 45 08             	mov    0x8(%ebp),%eax
80101732:	8d 50 1c             	lea    0x1c(%eax),%edx
80101735:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101738:	83 c0 0c             	add    $0xc,%eax
8010173b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101742:	00 
80101743:	89 54 24 04          	mov    %edx,0x4(%esp)
80101747:	89 04 24             	mov    %eax,(%esp)
8010174a:	e8 8d 3c 00 00       	call   801053dc <memmove>
  log_write(bp);
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	89 04 24             	mov    %eax,(%esp)
80101755:	e8 d1 1e 00 00       	call   8010362b <log_write>
  brelse(bp);
8010175a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175d:	89 04 24             	mov    %eax,(%esp)
80101760:	e8 b2 ea ff ff       	call   80100217 <brelse>
}
80101765:	c9                   	leave  
80101766:	c3                   	ret    

80101767 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101767:	55                   	push   %ebp
80101768:	89 e5                	mov    %esp,%ebp
8010176a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010176d:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101774:	e8 40 39 00 00       	call   801050b9 <acquire>

  // Is the inode already cached?
  empty = 0;
80101779:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101780:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
80101787:	eb 59                	jmp    801017e2 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010178c:	8b 40 08             	mov    0x8(%eax),%eax
8010178f:	85 c0                	test   %eax,%eax
80101791:	7e 35                	jle    801017c8 <iget+0x61>
80101793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101796:	8b 00                	mov    (%eax),%eax
80101798:	3b 45 08             	cmp    0x8(%ebp),%eax
8010179b:	75 2b                	jne    801017c8 <iget+0x61>
8010179d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a0:	8b 40 04             	mov    0x4(%eax),%eax
801017a3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017a6:	75 20                	jne    801017c8 <iget+0x61>
      ip->ref++;
801017a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ab:	8b 40 08             	mov    0x8(%eax),%eax
801017ae:	8d 50 01             	lea    0x1(%eax),%edx
801017b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b4:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017b7:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801017be:	e8 58 39 00 00       	call   8010511b <release>
      return ip;
801017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c6:	eb 6f                	jmp    80101837 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017cc:	75 10                	jne    801017de <iget+0x77>
801017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d1:	8b 40 08             	mov    0x8(%eax),%eax
801017d4:	85 c0                	test   %eax,%eax
801017d6:	75 06                	jne    801017de <iget+0x77>
      empty = ip;
801017d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017db:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017de:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017e2:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
801017e9:	72 9e                	jb     80101789 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017ef:	75 0c                	jne    801017fd <iget+0x96>
    panic("iget: no inodes");
801017f1:	c7 04 24 e3 87 10 80 	movl   $0x801087e3,(%esp)
801017f8:	e8 3d ed ff ff       	call   8010053a <panic>

  ip = empty;
801017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101800:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101806:	8b 55 08             	mov    0x8(%ebp),%edx
80101809:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010180b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101811:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101817:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010181e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101821:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101828:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010182f:	e8 e7 38 00 00       	call   8010511b <release>

  return ip;
80101834:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101837:	c9                   	leave  
80101838:	c3                   	ret    

80101839 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101839:	55                   	push   %ebp
8010183a:	89 e5                	mov    %esp,%ebp
8010183c:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010183f:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101846:	e8 6e 38 00 00       	call   801050b9 <acquire>
  ip->ref++;
8010184b:	8b 45 08             	mov    0x8(%ebp),%eax
8010184e:	8b 40 08             	mov    0x8(%eax),%eax
80101851:	8d 50 01             	lea    0x1(%eax),%edx
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010185a:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101861:	e8 b5 38 00 00       	call   8010511b <release>
  return ip;
80101866:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101869:	c9                   	leave  
8010186a:	c3                   	ret    

8010186b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010186b:	55                   	push   %ebp
8010186c:	89 e5                	mov    %esp,%ebp
8010186e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101871:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101875:	74 0a                	je     80101881 <ilock+0x16>
80101877:	8b 45 08             	mov    0x8(%ebp),%eax
8010187a:	8b 40 08             	mov    0x8(%eax),%eax
8010187d:	85 c0                	test   %eax,%eax
8010187f:	7f 0c                	jg     8010188d <ilock+0x22>
    panic("ilock");
80101881:	c7 04 24 f3 87 10 80 	movl   $0x801087f3,(%esp)
80101888:	e8 ad ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010188d:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101894:	e8 20 38 00 00       	call   801050b9 <acquire>
  while(ip->flags & I_BUSY)
80101899:	eb 13                	jmp    801018ae <ilock+0x43>
    sleep(ip, &icache.lock);
8010189b:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801018a2:	80 
801018a3:	8b 45 08             	mov    0x8(%ebp),%eax
801018a6:	89 04 24             	mov    %eax,(%esp)
801018a9:	e8 aa 33 00 00       	call   80104c58 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018ae:	8b 45 08             	mov    0x8(%ebp),%eax
801018b1:	8b 40 0c             	mov    0xc(%eax),%eax
801018b4:	83 e0 01             	and    $0x1,%eax
801018b7:	85 c0                	test   %eax,%eax
801018b9:	75 e0                	jne    8010189b <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018bb:	8b 45 08             	mov    0x8(%ebp),%eax
801018be:	8b 40 0c             	mov    0xc(%eax),%eax
801018c1:	83 c8 01             	or     $0x1,%eax
801018c4:	89 c2                	mov    %eax,%edx
801018c6:	8b 45 08             	mov    0x8(%ebp),%eax
801018c9:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018cc:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801018d3:	e8 43 38 00 00       	call   8010511b <release>

  if(!(ip->flags & I_VALID)){
801018d8:	8b 45 08             	mov    0x8(%ebp),%eax
801018db:	8b 40 0c             	mov    0xc(%eax),%eax
801018de:	83 e0 02             	and    $0x2,%eax
801018e1:	85 c0                	test   %eax,%eax
801018e3:	0f 85 ce 00 00 00    	jne    801019b7 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018e9:	8b 45 08             	mov    0x8(%ebp),%eax
801018ec:	8b 40 04             	mov    0x4(%eax),%eax
801018ef:	c1 e8 03             	shr    $0x3,%eax
801018f2:	8d 50 02             	lea    0x2(%eax),%edx
801018f5:	8b 45 08             	mov    0x8(%ebp),%eax
801018f8:	8b 00                	mov    (%eax),%eax
801018fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801018fe:	89 04 24             	mov    %eax,(%esp)
80101901:	e8 a0 e8 ff ff       	call   801001a6 <bread>
80101906:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190c:	8d 50 18             	lea    0x18(%eax),%edx
8010190f:	8b 45 08             	mov    0x8(%ebp),%eax
80101912:	8b 40 04             	mov    0x4(%eax),%eax
80101915:	83 e0 07             	and    $0x7,%eax
80101918:	c1 e0 06             	shl    $0x6,%eax
8010191b:	01 d0                	add    %edx,%eax
8010191d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101920:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101923:	0f b7 10             	movzwl (%eax),%edx
80101926:	8b 45 08             	mov    0x8(%ebp),%eax
80101929:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010192d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101930:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101934:	8b 45 08             	mov    0x8(%ebp),%eax
80101937:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010193b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193e:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101942:	8b 45 08             	mov    0x8(%ebp),%eax
80101945:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101950:	8b 45 08             	mov    0x8(%ebp),%eax
80101953:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195a:	8b 50 08             	mov    0x8(%eax),%edx
8010195d:	8b 45 08             	mov    0x8(%ebp),%eax
80101960:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101966:	8d 50 0c             	lea    0xc(%eax),%edx
80101969:	8b 45 08             	mov    0x8(%ebp),%eax
8010196c:	83 c0 1c             	add    $0x1c,%eax
8010196f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101976:	00 
80101977:	89 54 24 04          	mov    %edx,0x4(%esp)
8010197b:	89 04 24             	mov    %eax,(%esp)
8010197e:	e8 59 3a 00 00       	call   801053dc <memmove>
    brelse(bp);
80101983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101986:	89 04 24             	mov    %eax,(%esp)
80101989:	e8 89 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010198e:	8b 45 08             	mov    0x8(%ebp),%eax
80101991:	8b 40 0c             	mov    0xc(%eax),%eax
80101994:	83 c8 02             	or     $0x2,%eax
80101997:	89 c2                	mov    %eax,%edx
80101999:	8b 45 08             	mov    0x8(%ebp),%eax
8010199c:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010199f:	8b 45 08             	mov    0x8(%ebp),%eax
801019a2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019a6:	66 85 c0             	test   %ax,%ax
801019a9:	75 0c                	jne    801019b7 <ilock+0x14c>
      panic("ilock: no type");
801019ab:	c7 04 24 f9 87 10 80 	movl   $0x801087f9,(%esp)
801019b2:	e8 83 eb ff ff       	call   8010053a <panic>
  }
}
801019b7:	c9                   	leave  
801019b8:	c3                   	ret    

801019b9 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019b9:	55                   	push   %ebp
801019ba:	89 e5                	mov    %esp,%ebp
801019bc:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019c3:	74 17                	je     801019dc <iunlock+0x23>
801019c5:	8b 45 08             	mov    0x8(%ebp),%eax
801019c8:	8b 40 0c             	mov    0xc(%eax),%eax
801019cb:	83 e0 01             	and    $0x1,%eax
801019ce:	85 c0                	test   %eax,%eax
801019d0:	74 0a                	je     801019dc <iunlock+0x23>
801019d2:	8b 45 08             	mov    0x8(%ebp),%eax
801019d5:	8b 40 08             	mov    0x8(%eax),%eax
801019d8:	85 c0                	test   %eax,%eax
801019da:	7f 0c                	jg     801019e8 <iunlock+0x2f>
    panic("iunlock");
801019dc:	c7 04 24 08 88 10 80 	movl   $0x80108808,(%esp)
801019e3:	e8 52 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019e8:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801019ef:	e8 c5 36 00 00       	call   801050b9 <acquire>
  ip->flags &= ~I_BUSY;
801019f4:	8b 45 08             	mov    0x8(%ebp),%eax
801019f7:	8b 40 0c             	mov    0xc(%eax),%eax
801019fa:	83 e0 fe             	and    $0xfffffffe,%eax
801019fd:	89 c2                	mov    %eax,%edx
801019ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101a02:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a05:	8b 45 08             	mov    0x8(%ebp),%eax
80101a08:	89 04 24             	mov    %eax,(%esp)
80101a0b:	e8 23 33 00 00       	call   80104d33 <wakeup>
  release(&icache.lock);
80101a10:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a17:	e8 ff 36 00 00       	call   8010511b <release>
}
80101a1c:	c9                   	leave  
80101a1d:	c3                   	ret    

80101a1e <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a1e:	55                   	push   %ebp
80101a1f:	89 e5                	mov    %esp,%ebp
80101a21:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a24:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a2b:	e8 89 36 00 00       	call   801050b9 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a30:	8b 45 08             	mov    0x8(%ebp),%eax
80101a33:	8b 40 08             	mov    0x8(%eax),%eax
80101a36:	83 f8 01             	cmp    $0x1,%eax
80101a39:	0f 85 93 00 00 00    	jne    80101ad2 <iput+0xb4>
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 40 0c             	mov    0xc(%eax),%eax
80101a45:	83 e0 02             	and    $0x2,%eax
80101a48:	85 c0                	test   %eax,%eax
80101a4a:	0f 84 82 00 00 00    	je     80101ad2 <iput+0xb4>
80101a50:	8b 45 08             	mov    0x8(%ebp),%eax
80101a53:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a57:	66 85 c0             	test   %ax,%ax
80101a5a:	75 76                	jne    80101ad2 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a62:	83 e0 01             	and    $0x1,%eax
80101a65:	85 c0                	test   %eax,%eax
80101a67:	74 0c                	je     80101a75 <iput+0x57>
      panic("iput busy");
80101a69:	c7 04 24 10 88 10 80 	movl   $0x80108810,(%esp)
80101a70:	e8 c5 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	8b 40 0c             	mov    0xc(%eax),%eax
80101a7b:	83 c8 01             	or     $0x1,%eax
80101a7e:	89 c2                	mov    %eax,%edx
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a86:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a8d:	e8 89 36 00 00       	call   8010511b <release>
    itrunc(ip);
80101a92:	8b 45 08             	mov    0x8(%ebp),%eax
80101a95:	89 04 24             	mov    %eax,(%esp)
80101a98:	e8 7d 01 00 00       	call   80101c1a <itrunc>
    ip->type = 0;
80101a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa0:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa9:	89 04 24             	mov    %eax,(%esp)
80101aac:	e8 fe fb ff ff       	call   801016af <iupdate>
    acquire(&icache.lock);
80101ab1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101ab8:	e8 fc 35 00 00       	call   801050b9 <acquire>
    ip->flags = 0;
80101abd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aca:	89 04 24             	mov    %eax,(%esp)
80101acd:	e8 61 32 00 00       	call   80104d33 <wakeup>
  }
  ip->ref--;
80101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad5:	8b 40 08             	mov    0x8(%eax),%eax
80101ad8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101adb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ade:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ae1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101ae8:	e8 2e 36 00 00       	call   8010511b <release>
}
80101aed:	c9                   	leave  
80101aee:	c3                   	ret    

80101aef <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101aef:	55                   	push   %ebp
80101af0:	89 e5                	mov    %esp,%ebp
80101af2:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101af5:	8b 45 08             	mov    0x8(%ebp),%eax
80101af8:	89 04 24             	mov    %eax,(%esp)
80101afb:	e8 b9 fe ff ff       	call   801019b9 <iunlock>
  iput(ip);
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	89 04 24             	mov    %eax,(%esp)
80101b06:	e8 13 ff ff ff       	call   80101a1e <iput>
}
80101b0b:	c9                   	leave  
80101b0c:	c3                   	ret    

80101b0d <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b0d:	55                   	push   %ebp
80101b0e:	89 e5                	mov    %esp,%ebp
80101b10:	53                   	push   %ebx
80101b11:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b14:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b18:	77 3e                	ja     80101b58 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b20:	83 c2 04             	add    $0x4,%edx
80101b23:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b2e:	75 20                	jne    80101b50 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	8b 00                	mov    (%eax),%eax
80101b35:	89 04 24             	mov    %eax,(%esp)
80101b38:	e8 5b f8 ff ff       	call   80101398 <balloc>
80101b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b40:	8b 45 08             	mov    0x8(%ebp),%eax
80101b43:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b46:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b4c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b53:	e9 bc 00 00 00       	jmp    80101c14 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b58:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b5c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b60:	0f 87 a2 00 00 00    	ja     80101c08 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b66:	8b 45 08             	mov    0x8(%ebp),%eax
80101b69:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b73:	75 19                	jne    80101b8e <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	8b 00                	mov    (%eax),%eax
80101b7a:	89 04 24             	mov    %eax,(%esp)
80101b7d:	e8 16 f8 ff ff       	call   80101398 <balloc>
80101b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b85:	8b 45 08             	mov    0x8(%ebp),%eax
80101b88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b8b:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b91:	8b 00                	mov    (%eax),%eax
80101b93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b96:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b9a:	89 04 24             	mov    %eax,(%esp)
80101b9d:	e8 04 e6 ff ff       	call   801001a6 <bread>
80101ba2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba8:	83 c0 18             	add    $0x18,%eax
80101bab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bb1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bbb:	01 d0                	add    %edx,%eax
80101bbd:	8b 00                	mov    (%eax),%eax
80101bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bc6:	75 30                	jne    80101bf8 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bcb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bd5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdb:	8b 00                	mov    (%eax),%eax
80101bdd:	89 04 24             	mov    %eax,(%esp)
80101be0:	e8 b3 f7 ff ff       	call   80101398 <balloc>
80101be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101beb:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf0:	89 04 24             	mov    %eax,(%esp)
80101bf3:	e8 33 1a 00 00       	call   8010362b <log_write>
    }
    brelse(bp);
80101bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bfb:	89 04 24             	mov    %eax,(%esp)
80101bfe:	e8 14 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c06:	eb 0c                	jmp    80101c14 <bmap+0x107>
  }

  panic("bmap: out of range");
80101c08:	c7 04 24 1a 88 10 80 	movl   $0x8010881a,(%esp)
80101c0f:	e8 26 e9 ff ff       	call   8010053a <panic>
}
80101c14:	83 c4 24             	add    $0x24,%esp
80101c17:	5b                   	pop    %ebx
80101c18:	5d                   	pop    %ebp
80101c19:	c3                   	ret    

80101c1a <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c1a:	55                   	push   %ebp
80101c1b:	89 e5                	mov    %esp,%ebp
80101c1d:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c27:	eb 44                	jmp    80101c6d <itrunc+0x53>
    if(ip->addrs[i]){
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c2f:	83 c2 04             	add    $0x4,%edx
80101c32:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c36:	85 c0                	test   %eax,%eax
80101c38:	74 2f                	je     80101c69 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c40:	83 c2 04             	add    $0x4,%edx
80101c43:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	8b 00                	mov    (%eax),%eax
80101c4c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c50:	89 04 24             	mov    %eax,(%esp)
80101c53:	e8 8e f8 ff ff       	call   801014e6 <bfree>
      ip->addrs[i] = 0;
80101c58:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c5e:	83 c2 04             	add    $0x4,%edx
80101c61:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c68:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c6d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c71:	7e b6                	jle    80101c29 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c73:	8b 45 08             	mov    0x8(%ebp),%eax
80101c76:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c79:	85 c0                	test   %eax,%eax
80101c7b:	0f 84 9b 00 00 00    	je     80101d1c <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c81:	8b 45 08             	mov    0x8(%ebp),%eax
80101c84:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c87:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8a:	8b 00                	mov    (%eax),%eax
80101c8c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c90:	89 04 24             	mov    %eax,(%esp)
80101c93:	e8 0e e5 ff ff       	call   801001a6 <bread>
80101c98:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c9e:	83 c0 18             	add    $0x18,%eax
80101ca1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ca4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101cab:	eb 3b                	jmp    80101ce8 <itrunc+0xce>
      if(a[j])
80101cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cba:	01 d0                	add    %edx,%eax
80101cbc:	8b 00                	mov    (%eax),%eax
80101cbe:	85 c0                	test   %eax,%eax
80101cc0:	74 22                	je     80101ce4 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ccc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ccf:	01 d0                	add    %edx,%eax
80101cd1:	8b 10                	mov    (%eax),%edx
80101cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd6:	8b 00                	mov    (%eax),%eax
80101cd8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cdc:	89 04 24             	mov    %eax,(%esp)
80101cdf:	e8 02 f8 ff ff       	call   801014e6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ce4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ceb:	83 f8 7f             	cmp    $0x7f,%eax
80101cee:	76 bd                	jbe    80101cad <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101cf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cf3:	89 04 24             	mov    %eax,(%esp)
80101cf6:	e8 1c e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfe:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	8b 00                	mov    (%eax),%eax
80101d06:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d0a:	89 04 24             	mov    %eax,(%esp)
80101d0d:	e8 d4 f7 ff ff       	call   801014e6 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d12:	8b 45 08             	mov    0x8(%ebp),%eax
80101d15:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	89 04 24             	mov    %eax,(%esp)
80101d2c:	e8 7e f9 ff ff       	call   801016af <iupdate>
}
80101d31:	c9                   	leave  
80101d32:	c3                   	ret    

80101d33 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d33:	55                   	push   %ebp
80101d34:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d36:	8b 45 08             	mov    0x8(%ebp),%eax
80101d39:	8b 00                	mov    (%eax),%eax
80101d3b:	89 c2                	mov    %eax,%edx
80101d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d40:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d43:	8b 45 08             	mov    0x8(%ebp),%eax
80101d46:	8b 50 04             	mov    0x4(%eax),%edx
80101d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4c:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d52:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d56:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d59:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d66:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	8b 50 18             	mov    0x18(%eax),%edx
80101d70:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d73:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d76:	5d                   	pop    %ebp
80101d77:	c3                   	ret    

80101d78 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d78:	55                   	push   %ebp
80101d79:	89 e5                	mov    %esp,%ebp
80101d7b:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d81:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d85:	66 83 f8 03          	cmp    $0x3,%ax
80101d89:	75 60                	jne    80101deb <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d92:	66 85 c0             	test   %ax,%ax
80101d95:	78 20                	js     80101db7 <readi+0x3f>
80101d97:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d9e:	66 83 f8 09          	cmp    $0x9,%ax
80101da2:	7f 13                	jg     80101db7 <readi+0x3f>
80101da4:	8b 45 08             	mov    0x8(%ebp),%eax
80101da7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dab:	98                   	cwtl   
80101dac:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101db3:	85 c0                	test   %eax,%eax
80101db5:	75 0a                	jne    80101dc1 <readi+0x49>
      return -1;
80101db7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dbc:	e9 19 01 00 00       	jmp    80101eda <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dc8:	98                   	cwtl   
80101dc9:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101dd0:	8b 55 14             	mov    0x14(%ebp),%edx
80101dd3:	89 54 24 08          	mov    %edx,0x8(%esp)
80101dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dda:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dde:	8b 55 08             	mov    0x8(%ebp),%edx
80101de1:	89 14 24             	mov    %edx,(%esp)
80101de4:	ff d0                	call   *%eax
80101de6:	e9 ef 00 00 00       	jmp    80101eda <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101deb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dee:	8b 40 18             	mov    0x18(%eax),%eax
80101df1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df4:	72 0d                	jb     80101e03 <readi+0x8b>
80101df6:	8b 45 14             	mov    0x14(%ebp),%eax
80101df9:	8b 55 10             	mov    0x10(%ebp),%edx
80101dfc:	01 d0                	add    %edx,%eax
80101dfe:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e01:	73 0a                	jae    80101e0d <readi+0x95>
    return -1;
80101e03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e08:	e9 cd 00 00 00       	jmp    80101eda <readi+0x162>
  if(off + n > ip->size)
80101e0d:	8b 45 14             	mov    0x14(%ebp),%eax
80101e10:	8b 55 10             	mov    0x10(%ebp),%edx
80101e13:	01 c2                	add    %eax,%edx
80101e15:	8b 45 08             	mov    0x8(%ebp),%eax
80101e18:	8b 40 18             	mov    0x18(%eax),%eax
80101e1b:	39 c2                	cmp    %eax,%edx
80101e1d:	76 0c                	jbe    80101e2b <readi+0xb3>
    n = ip->size - off;
80101e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e22:	8b 40 18             	mov    0x18(%eax),%eax
80101e25:	2b 45 10             	sub    0x10(%ebp),%eax
80101e28:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e32:	e9 94 00 00 00       	jmp    80101ecb <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e37:	8b 45 10             	mov    0x10(%ebp),%eax
80101e3a:	c1 e8 09             	shr    $0x9,%eax
80101e3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e41:	8b 45 08             	mov    0x8(%ebp),%eax
80101e44:	89 04 24             	mov    %eax,(%esp)
80101e47:	e8 c1 fc ff ff       	call   80101b0d <bmap>
80101e4c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e4f:	8b 12                	mov    (%edx),%edx
80101e51:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e55:	89 14 24             	mov    %edx,(%esp)
80101e58:	e8 49 e3 ff ff       	call   801001a6 <bread>
80101e5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e60:	8b 45 10             	mov    0x10(%ebp),%eax
80101e63:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e68:	89 c2                	mov    %eax,%edx
80101e6a:	b8 00 02 00 00       	mov    $0x200,%eax
80101e6f:	29 d0                	sub    %edx,%eax
80101e71:	89 c2                	mov    %eax,%edx
80101e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e76:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e79:	29 c1                	sub    %eax,%ecx
80101e7b:	89 c8                	mov    %ecx,%eax
80101e7d:	39 c2                	cmp    %eax,%edx
80101e7f:	0f 46 c2             	cmovbe %edx,%eax
80101e82:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e85:	8b 45 10             	mov    0x10(%ebp),%eax
80101e88:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e8d:	8d 50 10             	lea    0x10(%eax),%edx
80101e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e93:	01 d0                	add    %edx,%eax
80101e95:	8d 50 08             	lea    0x8(%eax),%edx
80101e98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e9b:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e9f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea6:	89 04 24             	mov    %eax,(%esp)
80101ea9:	e8 2e 35 00 00       	call   801053dc <memmove>
    brelse(bp);
80101eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb1:	89 04 24             	mov    %eax,(%esp)
80101eb4:	e8 5e e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101eb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ebc:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ebf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec2:	01 45 10             	add    %eax,0x10(%ebp)
80101ec5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec8:	01 45 0c             	add    %eax,0xc(%ebp)
80101ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ece:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ed1:	0f 82 60 ff ff ff    	jb     80101e37 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ed7:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101eda:	c9                   	leave  
80101edb:	c3                   	ret    

80101edc <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101edc:	55                   	push   %ebp
80101edd:	89 e5                	mov    %esp,%ebp
80101edf:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee9:	66 83 f8 03          	cmp    $0x3,%ax
80101eed:	75 60                	jne    80101f4f <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101eef:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef6:	66 85 c0             	test   %ax,%ax
80101ef9:	78 20                	js     80101f1b <writei+0x3f>
80101efb:	8b 45 08             	mov    0x8(%ebp),%eax
80101efe:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f02:	66 83 f8 09          	cmp    $0x9,%ax
80101f06:	7f 13                	jg     80101f1b <writei+0x3f>
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0f:	98                   	cwtl   
80101f10:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f17:	85 c0                	test   %eax,%eax
80101f19:	75 0a                	jne    80101f25 <writei+0x49>
      return -1;
80101f1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f20:	e9 44 01 00 00       	jmp    80102069 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f25:	8b 45 08             	mov    0x8(%ebp),%eax
80101f28:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f2c:	98                   	cwtl   
80101f2d:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f34:	8b 55 14             	mov    0x14(%ebp),%edx
80101f37:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f3e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f42:	8b 55 08             	mov    0x8(%ebp),%edx
80101f45:	89 14 24             	mov    %edx,(%esp)
80101f48:	ff d0                	call   *%eax
80101f4a:	e9 1a 01 00 00       	jmp    80102069 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	8b 40 18             	mov    0x18(%eax),%eax
80101f55:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f58:	72 0d                	jb     80101f67 <writei+0x8b>
80101f5a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f60:	01 d0                	add    %edx,%eax
80101f62:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f65:	73 0a                	jae    80101f71 <writei+0x95>
    return -1;
80101f67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6c:	e9 f8 00 00 00       	jmp    80102069 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f71:	8b 45 14             	mov    0x14(%ebp),%eax
80101f74:	8b 55 10             	mov    0x10(%ebp),%edx
80101f77:	01 d0                	add    %edx,%eax
80101f79:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f7e:	76 0a                	jbe    80101f8a <writei+0xae>
    return -1;
80101f80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f85:	e9 df 00 00 00       	jmp    80102069 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f91:	e9 9f 00 00 00       	jmp    80102035 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f96:	8b 45 10             	mov    0x10(%ebp),%eax
80101f99:	c1 e8 09             	shr    $0x9,%eax
80101f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa3:	89 04 24             	mov    %eax,(%esp)
80101fa6:	e8 62 fb ff ff       	call   80101b0d <bmap>
80101fab:	8b 55 08             	mov    0x8(%ebp),%edx
80101fae:	8b 12                	mov    (%edx),%edx
80101fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fb4:	89 14 24             	mov    %edx,(%esp)
80101fb7:	e8 ea e1 ff ff       	call   801001a6 <bread>
80101fbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc7:	89 c2                	mov    %eax,%edx
80101fc9:	b8 00 02 00 00       	mov    $0x200,%eax
80101fce:	29 d0                	sub    %edx,%eax
80101fd0:	89 c2                	mov    %eax,%edx
80101fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fd5:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fd8:	29 c1                	sub    %eax,%ecx
80101fda:	89 c8                	mov    %ecx,%eax
80101fdc:	39 c2                	cmp    %eax,%edx
80101fde:	0f 46 c2             	cmovbe %edx,%eax
80101fe1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fe4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fec:	8d 50 10             	lea    0x10(%eax),%edx
80101fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff2:	01 d0                	add    %edx,%eax
80101ff4:	8d 50 08             	lea    0x8(%eax),%edx
80101ff7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ffa:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
80102001:	89 44 24 04          	mov    %eax,0x4(%esp)
80102005:	89 14 24             	mov    %edx,(%esp)
80102008:	e8 cf 33 00 00       	call   801053dc <memmove>
    log_write(bp);
8010200d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102010:	89 04 24             	mov    %eax,(%esp)
80102013:	e8 13 16 00 00       	call   8010362b <log_write>
    brelse(bp);
80102018:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010201b:	89 04 24             	mov    %eax,(%esp)
8010201e:	e8 f4 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102023:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102026:	01 45 f4             	add    %eax,-0xc(%ebp)
80102029:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202c:	01 45 10             	add    %eax,0x10(%ebp)
8010202f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102032:	01 45 0c             	add    %eax,0xc(%ebp)
80102035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102038:	3b 45 14             	cmp    0x14(%ebp),%eax
8010203b:	0f 82 55 ff ff ff    	jb     80101f96 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102041:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102045:	74 1f                	je     80102066 <writei+0x18a>
80102047:	8b 45 08             	mov    0x8(%ebp),%eax
8010204a:	8b 40 18             	mov    0x18(%eax),%eax
8010204d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102050:	73 14                	jae    80102066 <writei+0x18a>
    ip->size = off;
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	8b 55 10             	mov    0x10(%ebp),%edx
80102058:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010205b:	8b 45 08             	mov    0x8(%ebp),%eax
8010205e:	89 04 24             	mov    %eax,(%esp)
80102061:	e8 49 f6 ff ff       	call   801016af <iupdate>
  }
  return n;
80102066:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102069:	c9                   	leave  
8010206a:	c3                   	ret    

8010206b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010206b:	55                   	push   %ebp
8010206c:	89 e5                	mov    %esp,%ebp
8010206e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102071:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102078:	00 
80102079:	8b 45 0c             	mov    0xc(%ebp),%eax
8010207c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102080:	8b 45 08             	mov    0x8(%ebp),%eax
80102083:	89 04 24             	mov    %eax,(%esp)
80102086:	e8 f4 33 00 00       	call   8010547f <strncmp>
}
8010208b:	c9                   	leave  
8010208c:	c3                   	ret    

8010208d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010208d:	55                   	push   %ebp
8010208e:	89 e5                	mov    %esp,%ebp
80102090:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102093:	8b 45 08             	mov    0x8(%ebp),%eax
80102096:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010209a:	66 83 f8 01          	cmp    $0x1,%ax
8010209e:	74 0c                	je     801020ac <dirlookup+0x1f>
    panic("dirlookup not DIR");
801020a0:	c7 04 24 2d 88 10 80 	movl   $0x8010882d,(%esp)
801020a7:	e8 8e e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020b3:	e9 88 00 00 00       	jmp    80102140 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020b8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020bf:	00 
801020c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020c3:	89 44 24 08          	mov    %eax,0x8(%esp)
801020c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ce:	8b 45 08             	mov    0x8(%ebp),%eax
801020d1:	89 04 24             	mov    %eax,(%esp)
801020d4:	e8 9f fc ff ff       	call   80101d78 <readi>
801020d9:	83 f8 10             	cmp    $0x10,%eax
801020dc:	74 0c                	je     801020ea <dirlookup+0x5d>
      panic("dirlink read");
801020de:	c7 04 24 3f 88 10 80 	movl   $0x8010883f,(%esp)
801020e5:	e8 50 e4 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801020ea:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020ee:	66 85 c0             	test   %ax,%ax
801020f1:	75 02                	jne    801020f5 <dirlookup+0x68>
      continue;
801020f3:	eb 47                	jmp    8010213c <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
801020f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020f8:	83 c0 02             	add    $0x2,%eax
801020fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80102102:	89 04 24             	mov    %eax,(%esp)
80102105:	e8 61 ff ff ff       	call   8010206b <namecmp>
8010210a:	85 c0                	test   %eax,%eax
8010210c:	75 2e                	jne    8010213c <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010210e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102112:	74 08                	je     8010211c <dirlookup+0x8f>
        *poff = off;
80102114:	8b 45 10             	mov    0x10(%ebp),%eax
80102117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010211a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010211c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102120:	0f b7 c0             	movzwl %ax,%eax
80102123:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102126:	8b 45 08             	mov    0x8(%ebp),%eax
80102129:	8b 00                	mov    (%eax),%eax
8010212b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010212e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102132:	89 04 24             	mov    %eax,(%esp)
80102135:	e8 2d f6 ff ff       	call   80101767 <iget>
8010213a:	eb 18                	jmp    80102154 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010213c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102140:	8b 45 08             	mov    0x8(%ebp),%eax
80102143:	8b 40 18             	mov    0x18(%eax),%eax
80102146:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102149:	0f 87 69 ff ff ff    	ja     801020b8 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010214f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102154:	c9                   	leave  
80102155:	c3                   	ret    

80102156 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102156:	55                   	push   %ebp
80102157:	89 e5                	mov    %esp,%ebp
80102159:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010215c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102163:	00 
80102164:	8b 45 0c             	mov    0xc(%ebp),%eax
80102167:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216b:	8b 45 08             	mov    0x8(%ebp),%eax
8010216e:	89 04 24             	mov    %eax,(%esp)
80102171:	e8 17 ff ff ff       	call   8010208d <dirlookup>
80102176:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102179:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010217d:	74 15                	je     80102194 <dirlink+0x3e>
    iput(ip);
8010217f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102182:	89 04 24             	mov    %eax,(%esp)
80102185:	e8 94 f8 ff ff       	call   80101a1e <iput>
    return -1;
8010218a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010218f:	e9 b7 00 00 00       	jmp    8010224b <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102194:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010219b:	eb 46                	jmp    801021e3 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010219d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021a0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021a7:	00 
801021a8:	89 44 24 08          	mov    %eax,0x8(%esp)
801021ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021af:	89 44 24 04          	mov    %eax,0x4(%esp)
801021b3:	8b 45 08             	mov    0x8(%ebp),%eax
801021b6:	89 04 24             	mov    %eax,(%esp)
801021b9:	e8 ba fb ff ff       	call   80101d78 <readi>
801021be:	83 f8 10             	cmp    $0x10,%eax
801021c1:	74 0c                	je     801021cf <dirlink+0x79>
      panic("dirlink read");
801021c3:	c7 04 24 3f 88 10 80 	movl   $0x8010883f,(%esp)
801021ca:	e8 6b e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801021cf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021d3:	66 85 c0             	test   %ax,%ax
801021d6:	75 02                	jne    801021da <dirlink+0x84>
      break;
801021d8:	eb 16                	jmp    801021f0 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021dd:	83 c0 10             	add    $0x10,%eax
801021e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021e6:	8b 45 08             	mov    0x8(%ebp),%eax
801021e9:	8b 40 18             	mov    0x18(%eax),%eax
801021ec:	39 c2                	cmp    %eax,%edx
801021ee:	72 ad                	jb     8010219d <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801021f0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021f7:	00 
801021f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801021fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102202:	83 c0 02             	add    $0x2,%eax
80102205:	89 04 24             	mov    %eax,(%esp)
80102208:	e8 c8 32 00 00       	call   801054d5 <strncpy>
  de.inum = inum;
8010220d:	8b 45 10             	mov    0x10(%ebp),%eax
80102210:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102217:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010221e:	00 
8010221f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102223:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102226:	89 44 24 04          	mov    %eax,0x4(%esp)
8010222a:	8b 45 08             	mov    0x8(%ebp),%eax
8010222d:	89 04 24             	mov    %eax,(%esp)
80102230:	e8 a7 fc ff ff       	call   80101edc <writei>
80102235:	83 f8 10             	cmp    $0x10,%eax
80102238:	74 0c                	je     80102246 <dirlink+0xf0>
    panic("dirlink");
8010223a:	c7 04 24 4c 88 10 80 	movl   $0x8010884c,(%esp)
80102241:	e8 f4 e2 ff ff       	call   8010053a <panic>
  
  return 0;
80102246:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010224b:	c9                   	leave  
8010224c:	c3                   	ret    

8010224d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010224d:	55                   	push   %ebp
8010224e:	89 e5                	mov    %esp,%ebp
80102250:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102253:	eb 04                	jmp    80102259 <skipelem+0xc>
    path++;
80102255:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102259:	8b 45 08             	mov    0x8(%ebp),%eax
8010225c:	0f b6 00             	movzbl (%eax),%eax
8010225f:	3c 2f                	cmp    $0x2f,%al
80102261:	74 f2                	je     80102255 <skipelem+0x8>
    path++;
  if(*path == 0)
80102263:	8b 45 08             	mov    0x8(%ebp),%eax
80102266:	0f b6 00             	movzbl (%eax),%eax
80102269:	84 c0                	test   %al,%al
8010226b:	75 0a                	jne    80102277 <skipelem+0x2a>
    return 0;
8010226d:	b8 00 00 00 00       	mov    $0x0,%eax
80102272:	e9 86 00 00 00       	jmp    801022fd <skipelem+0xb0>
  s = path;
80102277:	8b 45 08             	mov    0x8(%ebp),%eax
8010227a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010227d:	eb 04                	jmp    80102283 <skipelem+0x36>
    path++;
8010227f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102283:	8b 45 08             	mov    0x8(%ebp),%eax
80102286:	0f b6 00             	movzbl (%eax),%eax
80102289:	3c 2f                	cmp    $0x2f,%al
8010228b:	74 0a                	je     80102297 <skipelem+0x4a>
8010228d:	8b 45 08             	mov    0x8(%ebp),%eax
80102290:	0f b6 00             	movzbl (%eax),%eax
80102293:	84 c0                	test   %al,%al
80102295:	75 e8                	jne    8010227f <skipelem+0x32>
    path++;
  len = path - s;
80102297:	8b 55 08             	mov    0x8(%ebp),%edx
8010229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229d:	29 c2                	sub    %eax,%edx
8010229f:	89 d0                	mov    %edx,%eax
801022a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022a4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022a8:	7e 1c                	jle    801022c6 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
801022aa:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022b1:	00 
801022b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801022bc:	89 04 24             	mov    %eax,(%esp)
801022bf:	e8 18 31 00 00       	call   801053dc <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022c4:	eb 2a                	jmp    801022f0 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022c9:	89 44 24 08          	mov    %eax,0x8(%esp)
801022cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d7:	89 04 24             	mov    %eax,(%esp)
801022da:	e8 fd 30 00 00       	call   801053dc <memmove>
    name[len] = 0;
801022df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801022e5:	01 d0                	add    %edx,%eax
801022e7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022ea:	eb 04                	jmp    801022f0 <skipelem+0xa3>
    path++;
801022ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022f0:	8b 45 08             	mov    0x8(%ebp),%eax
801022f3:	0f b6 00             	movzbl (%eax),%eax
801022f6:	3c 2f                	cmp    $0x2f,%al
801022f8:	74 f2                	je     801022ec <skipelem+0x9f>
    path++;
  return path;
801022fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022fd:	c9                   	leave  
801022fe:	c3                   	ret    

801022ff <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022ff:	55                   	push   %ebp
80102300:	89 e5                	mov    %esp,%ebp
80102302:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102305:	8b 45 08             	mov    0x8(%ebp),%eax
80102308:	0f b6 00             	movzbl (%eax),%eax
8010230b:	3c 2f                	cmp    $0x2f,%al
8010230d:	75 1c                	jne    8010232b <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010230f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102316:	00 
80102317:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010231e:	e8 44 f4 ff ff       	call   80101767 <iget>
80102323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102326:	e9 af 00 00 00       	jmp    801023da <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010232b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102331:	8b 40 68             	mov    0x68(%eax),%eax
80102334:	89 04 24             	mov    %eax,(%esp)
80102337:	e8 fd f4 ff ff       	call   80101839 <idup>
8010233c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010233f:	e9 96 00 00 00       	jmp    801023da <namex+0xdb>
    ilock(ip);
80102344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102347:	89 04 24             	mov    %eax,(%esp)
8010234a:	e8 1c f5 ff ff       	call   8010186b <ilock>
    if(ip->type != T_DIR){
8010234f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102352:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102356:	66 83 f8 01          	cmp    $0x1,%ax
8010235a:	74 15                	je     80102371 <namex+0x72>
      iunlockput(ip);
8010235c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235f:	89 04 24             	mov    %eax,(%esp)
80102362:	e8 88 f7 ff ff       	call   80101aef <iunlockput>
      return 0;
80102367:	b8 00 00 00 00       	mov    $0x0,%eax
8010236c:	e9 a3 00 00 00       	jmp    80102414 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102371:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102375:	74 1d                	je     80102394 <namex+0x95>
80102377:	8b 45 08             	mov    0x8(%ebp),%eax
8010237a:	0f b6 00             	movzbl (%eax),%eax
8010237d:	84 c0                	test   %al,%al
8010237f:	75 13                	jne    80102394 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102384:	89 04 24             	mov    %eax,(%esp)
80102387:	e8 2d f6 ff ff       	call   801019b9 <iunlock>
      return ip;
8010238c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238f:	e9 80 00 00 00       	jmp    80102414 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102394:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010239b:	00 
8010239c:	8b 45 10             	mov    0x10(%ebp),%eax
8010239f:	89 44 24 04          	mov    %eax,0x4(%esp)
801023a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a6:	89 04 24             	mov    %eax,(%esp)
801023a9:	e8 df fc ff ff       	call   8010208d <dirlookup>
801023ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023b5:	75 12                	jne    801023c9 <namex+0xca>
      iunlockput(ip);
801023b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ba:	89 04 24             	mov    %eax,(%esp)
801023bd:	e8 2d f7 ff ff       	call   80101aef <iunlockput>
      return 0;
801023c2:	b8 00 00 00 00       	mov    $0x0,%eax
801023c7:	eb 4b                	jmp    80102414 <namex+0x115>
    }
    iunlockput(ip);
801023c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cc:	89 04 24             	mov    %eax,(%esp)
801023cf:	e8 1b f7 ff ff       	call   80101aef <iunlockput>
    ip = next;
801023d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023da:	8b 45 10             	mov    0x10(%ebp),%eax
801023dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801023e1:	8b 45 08             	mov    0x8(%ebp),%eax
801023e4:	89 04 24             	mov    %eax,(%esp)
801023e7:	e8 61 fe ff ff       	call   8010224d <skipelem>
801023ec:	89 45 08             	mov    %eax,0x8(%ebp)
801023ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023f3:	0f 85 4b ff ff ff    	jne    80102344 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023fd:	74 12                	je     80102411 <namex+0x112>
    iput(ip);
801023ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102402:	89 04 24             	mov    %eax,(%esp)
80102405:	e8 14 f6 ff ff       	call   80101a1e <iput>
    return 0;
8010240a:	b8 00 00 00 00       	mov    $0x0,%eax
8010240f:	eb 03                	jmp    80102414 <namex+0x115>
  }
  return ip;
80102411:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102414:	c9                   	leave  
80102415:	c3                   	ret    

80102416 <namei>:

struct inode*
namei(char *path)
{
80102416:	55                   	push   %ebp
80102417:	89 e5                	mov    %esp,%ebp
80102419:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010241c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010241f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102423:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010242a:	00 
8010242b:	8b 45 08             	mov    0x8(%ebp),%eax
8010242e:	89 04 24             	mov    %eax,(%esp)
80102431:	e8 c9 fe ff ff       	call   801022ff <namex>
}
80102436:	c9                   	leave  
80102437:	c3                   	ret    

80102438 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102438:	55                   	push   %ebp
80102439:	89 e5                	mov    %esp,%ebp
8010243b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010243e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102441:	89 44 24 08          	mov    %eax,0x8(%esp)
80102445:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010244c:	00 
8010244d:	8b 45 08             	mov    0x8(%ebp),%eax
80102450:	89 04 24             	mov    %eax,(%esp)
80102453:	e8 a7 fe ff ff       	call   801022ff <namex>
}
80102458:	c9                   	leave  
80102459:	c3                   	ret    

8010245a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010245a:	55                   	push   %ebp
8010245b:	89 e5                	mov    %esp,%ebp
8010245d:	83 ec 14             	sub    $0x14,%esp
80102460:	8b 45 08             	mov    0x8(%ebp),%eax
80102463:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102467:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010246b:	89 c2                	mov    %eax,%edx
8010246d:	ec                   	in     (%dx),%al
8010246e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102471:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102475:	c9                   	leave  
80102476:	c3                   	ret    

80102477 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102477:	55                   	push   %ebp
80102478:	89 e5                	mov    %esp,%ebp
8010247a:	57                   	push   %edi
8010247b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010247c:	8b 55 08             	mov    0x8(%ebp),%edx
8010247f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102482:	8b 45 10             	mov    0x10(%ebp),%eax
80102485:	89 cb                	mov    %ecx,%ebx
80102487:	89 df                	mov    %ebx,%edi
80102489:	89 c1                	mov    %eax,%ecx
8010248b:	fc                   	cld    
8010248c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010248e:	89 c8                	mov    %ecx,%eax
80102490:	89 fb                	mov    %edi,%ebx
80102492:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102495:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102498:	5b                   	pop    %ebx
80102499:	5f                   	pop    %edi
8010249a:	5d                   	pop    %ebp
8010249b:	c3                   	ret    

8010249c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010249c:	55                   	push   %ebp
8010249d:	89 e5                	mov    %esp,%ebp
8010249f:	83 ec 08             	sub    $0x8,%esp
801024a2:	8b 55 08             	mov    0x8(%ebp),%edx
801024a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801024a8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024ac:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024af:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024b3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024b7:	ee                   	out    %al,(%dx)
}
801024b8:	c9                   	leave  
801024b9:	c3                   	ret    

801024ba <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024ba:	55                   	push   %ebp
801024bb:	89 e5                	mov    %esp,%ebp
801024bd:	56                   	push   %esi
801024be:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024bf:	8b 55 08             	mov    0x8(%ebp),%edx
801024c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024c5:	8b 45 10             	mov    0x10(%ebp),%eax
801024c8:	89 cb                	mov    %ecx,%ebx
801024ca:	89 de                	mov    %ebx,%esi
801024cc:	89 c1                	mov    %eax,%ecx
801024ce:	fc                   	cld    
801024cf:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024d1:	89 c8                	mov    %ecx,%eax
801024d3:	89 f3                	mov    %esi,%ebx
801024d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024d8:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024db:	5b                   	pop    %ebx
801024dc:	5e                   	pop    %esi
801024dd:	5d                   	pop    %ebp
801024de:	c3                   	ret    

801024df <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024df:	55                   	push   %ebp
801024e0:	89 e5                	mov    %esp,%ebp
801024e2:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024e5:	90                   	nop
801024e6:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024ed:	e8 68 ff ff ff       	call   8010245a <inb>
801024f2:	0f b6 c0             	movzbl %al,%eax
801024f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024fb:	25 c0 00 00 00       	and    $0xc0,%eax
80102500:	83 f8 40             	cmp    $0x40,%eax
80102503:	75 e1                	jne    801024e6 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102505:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102509:	74 11                	je     8010251c <idewait+0x3d>
8010250b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010250e:	83 e0 21             	and    $0x21,%eax
80102511:	85 c0                	test   %eax,%eax
80102513:	74 07                	je     8010251c <idewait+0x3d>
    return -1;
80102515:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010251a:	eb 05                	jmp    80102521 <idewait+0x42>
  return 0;
8010251c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102521:	c9                   	leave  
80102522:	c3                   	ret    

80102523 <ideinit>:

void
ideinit(void)
{
80102523:	55                   	push   %ebp
80102524:	89 e5                	mov    %esp,%ebp
80102526:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102529:	c7 44 24 04 54 88 10 	movl   $0x80108854,0x4(%esp)
80102530:	80 
80102531:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102538:	e8 5b 2b 00 00       	call   80105098 <initlock>
  picenable(IRQ_IDE);
8010253d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102544:	e8 7b 18 00 00       	call   80103dc4 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102549:	a1 40 29 11 80       	mov    0x80112940,%eax
8010254e:	83 e8 01             	sub    $0x1,%eax
80102551:	89 44 24 04          	mov    %eax,0x4(%esp)
80102555:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010255c:	e8 0c 04 00 00       	call   8010296d <ioapicenable>
  idewait(0);
80102561:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102568:	e8 72 ff ff ff       	call   801024df <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010256d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102574:	00 
80102575:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010257c:	e8 1b ff ff ff       	call   8010249c <outb>
  for(i=0; i<1000; i++){
80102581:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102588:	eb 20                	jmp    801025aa <ideinit+0x87>
    if(inb(0x1f7) != 0){
8010258a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102591:	e8 c4 fe ff ff       	call   8010245a <inb>
80102596:	84 c0                	test   %al,%al
80102598:	74 0c                	je     801025a6 <ideinit+0x83>
      havedisk1 = 1;
8010259a:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801025a1:	00 00 00 
      break;
801025a4:	eb 0d                	jmp    801025b3 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025aa:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025b1:	7e d7                	jle    8010258a <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025b3:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025ba:	00 
801025bb:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025c2:	e8 d5 fe ff ff       	call   8010249c <outb>
}
801025c7:	c9                   	leave  
801025c8:	c3                   	ret    

801025c9 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025c9:	55                   	push   %ebp
801025ca:	89 e5                	mov    %esp,%ebp
801025cc:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025d3:	75 0c                	jne    801025e1 <idestart+0x18>
    panic("idestart");
801025d5:	c7 04 24 58 88 10 80 	movl   $0x80108858,(%esp)
801025dc:	e8 59 df ff ff       	call   8010053a <panic>

  idewait(0);
801025e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025e8:	e8 f2 fe ff ff       	call   801024df <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025f4:	00 
801025f5:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025fc:	e8 9b fe ff ff       	call   8010249c <outb>
  outb(0x1f2, 1);  // number of sectors
80102601:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102608:	00 
80102609:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102610:	e8 87 fe ff ff       	call   8010249c <outb>
  outb(0x1f3, b->sector & 0xff);
80102615:	8b 45 08             	mov    0x8(%ebp),%eax
80102618:	8b 40 08             	mov    0x8(%eax),%eax
8010261b:	0f b6 c0             	movzbl %al,%eax
8010261e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102622:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102629:	e8 6e fe ff ff       	call   8010249c <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010262e:	8b 45 08             	mov    0x8(%ebp),%eax
80102631:	8b 40 08             	mov    0x8(%eax),%eax
80102634:	c1 e8 08             	shr    $0x8,%eax
80102637:	0f b6 c0             	movzbl %al,%eax
8010263a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010263e:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102645:	e8 52 fe ff ff       	call   8010249c <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
8010264a:	8b 45 08             	mov    0x8(%ebp),%eax
8010264d:	8b 40 08             	mov    0x8(%eax),%eax
80102650:	c1 e8 10             	shr    $0x10,%eax
80102653:	0f b6 c0             	movzbl %al,%eax
80102656:	89 44 24 04          	mov    %eax,0x4(%esp)
8010265a:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102661:	e8 36 fe ff ff       	call   8010249c <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102666:	8b 45 08             	mov    0x8(%ebp),%eax
80102669:	8b 40 04             	mov    0x4(%eax),%eax
8010266c:	83 e0 01             	and    $0x1,%eax
8010266f:	c1 e0 04             	shl    $0x4,%eax
80102672:	89 c2                	mov    %eax,%edx
80102674:	8b 45 08             	mov    0x8(%ebp),%eax
80102677:	8b 40 08             	mov    0x8(%eax),%eax
8010267a:	c1 e8 18             	shr    $0x18,%eax
8010267d:	83 e0 0f             	and    $0xf,%eax
80102680:	09 d0                	or     %edx,%eax
80102682:	83 c8 e0             	or     $0xffffffe0,%eax
80102685:	0f b6 c0             	movzbl %al,%eax
80102688:	89 44 24 04          	mov    %eax,0x4(%esp)
8010268c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102693:	e8 04 fe ff ff       	call   8010249c <outb>
  if(b->flags & B_DIRTY){
80102698:	8b 45 08             	mov    0x8(%ebp),%eax
8010269b:	8b 00                	mov    (%eax),%eax
8010269d:	83 e0 04             	and    $0x4,%eax
801026a0:	85 c0                	test   %eax,%eax
801026a2:	74 34                	je     801026d8 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026a4:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026ab:	00 
801026ac:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026b3:	e8 e4 fd ff ff       	call   8010249c <outb>
    outsl(0x1f0, b->data, 512/4);
801026b8:	8b 45 08             	mov    0x8(%ebp),%eax
801026bb:	83 c0 18             	add    $0x18,%eax
801026be:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026c5:	00 
801026c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ca:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026d1:	e8 e4 fd ff ff       	call   801024ba <outsl>
801026d6:	eb 14                	jmp    801026ec <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026d8:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026df:	00 
801026e0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026e7:	e8 b0 fd ff ff       	call   8010249c <outb>
  }
}
801026ec:	c9                   	leave  
801026ed:	c3                   	ret    

801026ee <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026ee:	55                   	push   %ebp
801026ef:	89 e5                	mov    %esp,%ebp
801026f1:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026f4:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801026fb:	e8 b9 29 00 00       	call   801050b9 <acquire>
  if((b = idequeue) == 0){
80102700:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102705:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102708:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010270c:	75 11                	jne    8010271f <ideintr+0x31>
    release(&idelock);
8010270e:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102715:	e8 01 2a 00 00       	call   8010511b <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010271a:	e9 90 00 00 00       	jmp    801027af <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010271f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102722:	8b 40 14             	mov    0x14(%eax),%eax
80102725:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010272a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272d:	8b 00                	mov    (%eax),%eax
8010272f:	83 e0 04             	and    $0x4,%eax
80102732:	85 c0                	test   %eax,%eax
80102734:	75 2e                	jne    80102764 <ideintr+0x76>
80102736:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010273d:	e8 9d fd ff ff       	call   801024df <idewait>
80102742:	85 c0                	test   %eax,%eax
80102744:	78 1e                	js     80102764 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102749:	83 c0 18             	add    $0x18,%eax
8010274c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102753:	00 
80102754:	89 44 24 04          	mov    %eax,0x4(%esp)
80102758:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010275f:	e8 13 fd ff ff       	call   80102477 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102767:	8b 00                	mov    (%eax),%eax
80102769:	83 c8 02             	or     $0x2,%eax
8010276c:	89 c2                	mov    %eax,%edx
8010276e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102771:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102776:	8b 00                	mov    (%eax),%eax
80102778:	83 e0 fb             	and    $0xfffffffb,%eax
8010277b:	89 c2                	mov    %eax,%edx
8010277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102780:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102785:	89 04 24             	mov    %eax,(%esp)
80102788:	e8 a6 25 00 00       	call   80104d33 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010278d:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102792:	85 c0                	test   %eax,%eax
80102794:	74 0d                	je     801027a3 <ideintr+0xb5>
    idestart(idequeue);
80102796:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010279b:	89 04 24             	mov    %eax,(%esp)
8010279e:	e8 26 fe ff ff       	call   801025c9 <idestart>

  release(&idelock);
801027a3:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027aa:	e8 6c 29 00 00       	call   8010511b <release>
}
801027af:	c9                   	leave  
801027b0:	c3                   	ret    

801027b1 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027b1:	55                   	push   %ebp
801027b2:	89 e5                	mov    %esp,%ebp
801027b4:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027b7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ba:	8b 00                	mov    (%eax),%eax
801027bc:	83 e0 01             	and    $0x1,%eax
801027bf:	85 c0                	test   %eax,%eax
801027c1:	75 0c                	jne    801027cf <iderw+0x1e>
    panic("iderw: buf not busy");
801027c3:	c7 04 24 61 88 10 80 	movl   $0x80108861,(%esp)
801027ca:	e8 6b dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027cf:	8b 45 08             	mov    0x8(%ebp),%eax
801027d2:	8b 00                	mov    (%eax),%eax
801027d4:	83 e0 06             	and    $0x6,%eax
801027d7:	83 f8 02             	cmp    $0x2,%eax
801027da:	75 0c                	jne    801027e8 <iderw+0x37>
    panic("iderw: nothing to do");
801027dc:	c7 04 24 75 88 10 80 	movl   $0x80108875,(%esp)
801027e3:	e8 52 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027e8:	8b 45 08             	mov    0x8(%ebp),%eax
801027eb:	8b 40 04             	mov    0x4(%eax),%eax
801027ee:	85 c0                	test   %eax,%eax
801027f0:	74 15                	je     80102807 <iderw+0x56>
801027f2:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801027f7:	85 c0                	test   %eax,%eax
801027f9:	75 0c                	jne    80102807 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027fb:	c7 04 24 8a 88 10 80 	movl   $0x8010888a,(%esp)
80102802:	e8 33 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102807:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010280e:	e8 a6 28 00 00       	call   801050b9 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102813:	8b 45 08             	mov    0x8(%ebp),%eax
80102816:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010281d:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102824:	eb 0b                	jmp    80102831 <iderw+0x80>
80102826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102829:	8b 00                	mov    (%eax),%eax
8010282b:	83 c0 14             	add    $0x14,%eax
8010282e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102834:	8b 00                	mov    (%eax),%eax
80102836:	85 c0                	test   %eax,%eax
80102838:	75 ec                	jne    80102826 <iderw+0x75>
    ;
  *pp = b;
8010283a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010283d:	8b 55 08             	mov    0x8(%ebp),%edx
80102840:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102842:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102847:	3b 45 08             	cmp    0x8(%ebp),%eax
8010284a:	75 0d                	jne    80102859 <iderw+0xa8>
    idestart(b);
8010284c:	8b 45 08             	mov    0x8(%ebp),%eax
8010284f:	89 04 24             	mov    %eax,(%esp)
80102852:	e8 72 fd ff ff       	call   801025c9 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102857:	eb 15                	jmp    8010286e <iderw+0xbd>
80102859:	eb 13                	jmp    8010286e <iderw+0xbd>
    sleep(b, &idelock);
8010285b:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102862:	80 
80102863:	8b 45 08             	mov    0x8(%ebp),%eax
80102866:	89 04 24             	mov    %eax,(%esp)
80102869:	e8 ea 23 00 00       	call   80104c58 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010286e:	8b 45 08             	mov    0x8(%ebp),%eax
80102871:	8b 00                	mov    (%eax),%eax
80102873:	83 e0 06             	and    $0x6,%eax
80102876:	83 f8 02             	cmp    $0x2,%eax
80102879:	75 e0                	jne    8010285b <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
8010287b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102882:	e8 94 28 00 00       	call   8010511b <release>
}
80102887:	c9                   	leave  
80102888:	c3                   	ret    

80102889 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102889:	55                   	push   %ebp
8010288a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010288c:	a1 14 22 11 80       	mov    0x80112214,%eax
80102891:	8b 55 08             	mov    0x8(%ebp),%edx
80102894:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102896:	a1 14 22 11 80       	mov    0x80112214,%eax
8010289b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010289e:	5d                   	pop    %ebp
8010289f:	c3                   	ret    

801028a0 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801028a0:	55                   	push   %ebp
801028a1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028a3:	a1 14 22 11 80       	mov    0x80112214,%eax
801028a8:	8b 55 08             	mov    0x8(%ebp),%edx
801028ab:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028ad:	a1 14 22 11 80       	mov    0x80112214,%eax
801028b2:	8b 55 0c             	mov    0xc(%ebp),%edx
801028b5:	89 50 10             	mov    %edx,0x10(%eax)
}
801028b8:	5d                   	pop    %ebp
801028b9:	c3                   	ret    

801028ba <ioapicinit>:

void
ioapicinit(void)
{
801028ba:	55                   	push   %ebp
801028bb:	89 e5                	mov    %esp,%ebp
801028bd:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028c0:	a1 44 23 11 80       	mov    0x80112344,%eax
801028c5:	85 c0                	test   %eax,%eax
801028c7:	75 05                	jne    801028ce <ioapicinit+0x14>
    return;
801028c9:	e9 9d 00 00 00       	jmp    8010296b <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028ce:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
801028d5:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028df:	e8 a5 ff ff ff       	call   80102889 <ioapicread>
801028e4:	c1 e8 10             	shr    $0x10,%eax
801028e7:	25 ff 00 00 00       	and    $0xff,%eax
801028ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028f6:	e8 8e ff ff ff       	call   80102889 <ioapicread>
801028fb:	c1 e8 18             	shr    $0x18,%eax
801028fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102901:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
80102908:	0f b6 c0             	movzbl %al,%eax
8010290b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010290e:	74 0c                	je     8010291c <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102910:	c7 04 24 a8 88 10 80 	movl   $0x801088a8,(%esp)
80102917:	e8 84 da ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010291c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102923:	eb 3e                	jmp    80102963 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102928:	83 c0 20             	add    $0x20,%eax
8010292b:	0d 00 00 01 00       	or     $0x10000,%eax
80102930:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102933:	83 c2 08             	add    $0x8,%edx
80102936:	01 d2                	add    %edx,%edx
80102938:	89 44 24 04          	mov    %eax,0x4(%esp)
8010293c:	89 14 24             	mov    %edx,(%esp)
8010293f:	e8 5c ff ff ff       	call   801028a0 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102947:	83 c0 08             	add    $0x8,%eax
8010294a:	01 c0                	add    %eax,%eax
8010294c:	83 c0 01             	add    $0x1,%eax
8010294f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102956:	00 
80102957:	89 04 24             	mov    %eax,(%esp)
8010295a:	e8 41 ff ff ff       	call   801028a0 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010295f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102966:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102969:	7e ba                	jle    80102925 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010296b:	c9                   	leave  
8010296c:	c3                   	ret    

8010296d <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010296d:	55                   	push   %ebp
8010296e:	89 e5                	mov    %esp,%ebp
80102970:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102973:	a1 44 23 11 80       	mov    0x80112344,%eax
80102978:	85 c0                	test   %eax,%eax
8010297a:	75 02                	jne    8010297e <ioapicenable+0x11>
    return;
8010297c:	eb 37                	jmp    801029b5 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010297e:	8b 45 08             	mov    0x8(%ebp),%eax
80102981:	83 c0 20             	add    $0x20,%eax
80102984:	8b 55 08             	mov    0x8(%ebp),%edx
80102987:	83 c2 08             	add    $0x8,%edx
8010298a:	01 d2                	add    %edx,%edx
8010298c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102990:	89 14 24             	mov    %edx,(%esp)
80102993:	e8 08 ff ff ff       	call   801028a0 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102998:	8b 45 0c             	mov    0xc(%ebp),%eax
8010299b:	c1 e0 18             	shl    $0x18,%eax
8010299e:	8b 55 08             	mov    0x8(%ebp),%edx
801029a1:	83 c2 08             	add    $0x8,%edx
801029a4:	01 d2                	add    %edx,%edx
801029a6:	83 c2 01             	add    $0x1,%edx
801029a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ad:	89 14 24             	mov    %edx,(%esp)
801029b0:	e8 eb fe ff ff       	call   801028a0 <ioapicwrite>
}
801029b5:	c9                   	leave  
801029b6:	c3                   	ret    

801029b7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029b7:	55                   	push   %ebp
801029b8:	89 e5                	mov    %esp,%ebp
801029ba:	8b 45 08             	mov    0x8(%ebp),%eax
801029bd:	05 00 00 00 80       	add    $0x80000000,%eax
801029c2:	5d                   	pop    %ebp
801029c3:	c3                   	ret    

801029c4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029c4:	55                   	push   %ebp
801029c5:	89 e5                	mov    %esp,%ebp
801029c7:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029ca:	c7 44 24 04 da 88 10 	movl   $0x801088da,0x4(%esp)
801029d1:	80 
801029d2:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
801029d9:	e8 ba 26 00 00       	call   80105098 <initlock>
  kmem.use_lock = 0;
801029de:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
801029e5:	00 00 00 
  freerange(vstart, vend);
801029e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ef:	8b 45 08             	mov    0x8(%ebp),%eax
801029f2:	89 04 24             	mov    %eax,(%esp)
801029f5:	e8 26 00 00 00       	call   80102a20 <freerange>
}
801029fa:	c9                   	leave  
801029fb:	c3                   	ret    

801029fc <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801029fc:	55                   	push   %ebp
801029fd:	89 e5                	mov    %esp,%ebp
801029ff:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a05:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a09:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0c:	89 04 24             	mov    %eax,(%esp)
80102a0f:	e8 0c 00 00 00       	call   80102a20 <freerange>
  kmem.use_lock = 1;
80102a14:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102a1b:	00 00 00 
}
80102a1e:	c9                   	leave  
80102a1f:	c3                   	ret    

80102a20 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a20:	55                   	push   %ebp
80102a21:	89 e5                	mov    %esp,%ebp
80102a23:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a26:	8b 45 08             	mov    0x8(%ebp),%eax
80102a29:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a2e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a36:	eb 12                	jmp    80102a4a <freerange+0x2a>
    kfree(p);
80102a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3b:	89 04 24             	mov    %eax,(%esp)
80102a3e:	e8 16 00 00 00       	call   80102a59 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a43:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4d:	05 00 10 00 00       	add    $0x1000,%eax
80102a52:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a55:	76 e1                	jbe    80102a38 <freerange+0x18>
    kfree(p);
}
80102a57:	c9                   	leave  
80102a58:	c3                   	ret    

80102a59 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a59:	55                   	push   %ebp
80102a5a:	89 e5                	mov    %esp,%ebp
80102a5c:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a62:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a67:	85 c0                	test   %eax,%eax
80102a69:	75 1b                	jne    80102a86 <kfree+0x2d>
80102a6b:	81 7d 08 3c 8a 11 80 	cmpl   $0x80118a3c,0x8(%ebp)
80102a72:	72 12                	jb     80102a86 <kfree+0x2d>
80102a74:	8b 45 08             	mov    0x8(%ebp),%eax
80102a77:	89 04 24             	mov    %eax,(%esp)
80102a7a:	e8 38 ff ff ff       	call   801029b7 <v2p>
80102a7f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a84:	76 0c                	jbe    80102a92 <kfree+0x39>
    panic("kfree");
80102a86:	c7 04 24 df 88 10 80 	movl   $0x801088df,(%esp)
80102a8d:	e8 a8 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a92:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a99:	00 
80102a9a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aa1:	00 
80102aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa5:	89 04 24             	mov    %eax,(%esp)
80102aa8:	e8 60 28 00 00       	call   8010530d <memset>

  if(kmem.use_lock)
80102aad:	a1 54 22 11 80       	mov    0x80112254,%eax
80102ab2:	85 c0                	test   %eax,%eax
80102ab4:	74 0c                	je     80102ac2 <kfree+0x69>
    acquire(&kmem.lock);
80102ab6:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102abd:	e8 f7 25 00 00       	call   801050b9 <acquire>
  r = (struct run*)v;
80102ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ac8:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad1:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad6:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102adb:	a1 54 22 11 80       	mov    0x80112254,%eax
80102ae0:	85 c0                	test   %eax,%eax
80102ae2:	74 0c                	je     80102af0 <kfree+0x97>
    release(&kmem.lock);
80102ae4:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102aeb:	e8 2b 26 00 00       	call   8010511b <release>
}
80102af0:	c9                   	leave  
80102af1:	c3                   	ret    

80102af2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102af2:	55                   	push   %ebp
80102af3:	89 e5                	mov    %esp,%ebp
80102af5:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102af8:	a1 54 22 11 80       	mov    0x80112254,%eax
80102afd:	85 c0                	test   %eax,%eax
80102aff:	74 0c                	je     80102b0d <kalloc+0x1b>
    acquire(&kmem.lock);
80102b01:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b08:	e8 ac 25 00 00       	call   801050b9 <acquire>
  r = kmem.freelist;
80102b0d:	a1 58 22 11 80       	mov    0x80112258,%eax
80102b12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b19:	74 0a                	je     80102b25 <kalloc+0x33>
    kmem.freelist = r->next;
80102b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1e:	8b 00                	mov    (%eax),%eax
80102b20:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102b25:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b2a:	85 c0                	test   %eax,%eax
80102b2c:	74 0c                	je     80102b3a <kalloc+0x48>
    release(&kmem.lock);
80102b2e:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b35:	e8 e1 25 00 00       	call   8010511b <release>
  return (char*)r;
80102b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b3d:	c9                   	leave  
80102b3e:	c3                   	ret    

80102b3f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b3f:	55                   	push   %ebp
80102b40:	89 e5                	mov    %esp,%ebp
80102b42:	83 ec 14             	sub    $0x14,%esp
80102b45:	8b 45 08             	mov    0x8(%ebp),%eax
80102b48:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b4c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102b50:	89 c2                	mov    %eax,%edx
80102b52:	ec                   	in     (%dx),%al
80102b53:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102b56:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b5a:	c9                   	leave  
80102b5b:	c3                   	ret    

80102b5c <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b5c:	55                   	push   %ebp
80102b5d:	89 e5                	mov    %esp,%ebp
80102b5f:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b62:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b69:	e8 d1 ff ff ff       	call   80102b3f <inb>
80102b6e:	0f b6 c0             	movzbl %al,%eax
80102b71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b77:	83 e0 01             	and    $0x1,%eax
80102b7a:	85 c0                	test   %eax,%eax
80102b7c:	75 0a                	jne    80102b88 <kbdgetc+0x2c>
    return -1;
80102b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b83:	e9 25 01 00 00       	jmp    80102cad <kbdgetc+0x151>
  data = inb(KBDATAP);
80102b88:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b8f:	e8 ab ff ff ff       	call   80102b3f <inb>
80102b94:	0f b6 c0             	movzbl %al,%eax
80102b97:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102b9a:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ba1:	75 17                	jne    80102bba <kbdgetc+0x5e>
    shift |= E0ESC;
80102ba3:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ba8:	83 c8 40             	or     $0x40,%eax
80102bab:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102bb0:	b8 00 00 00 00       	mov    $0x0,%eax
80102bb5:	e9 f3 00 00 00       	jmp    80102cad <kbdgetc+0x151>
  } else if(data & 0x80){
80102bba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bbd:	25 80 00 00 00       	and    $0x80,%eax
80102bc2:	85 c0                	test   %eax,%eax
80102bc4:	74 45                	je     80102c0b <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bc6:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bcb:	83 e0 40             	and    $0x40,%eax
80102bce:	85 c0                	test   %eax,%eax
80102bd0:	75 08                	jne    80102bda <kbdgetc+0x7e>
80102bd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bd5:	83 e0 7f             	and    $0x7f,%eax
80102bd8:	eb 03                	jmp    80102bdd <kbdgetc+0x81>
80102bda:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bdd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102be0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102be3:	05 20 90 10 80       	add    $0x80109020,%eax
80102be8:	0f b6 00             	movzbl (%eax),%eax
80102beb:	83 c8 40             	or     $0x40,%eax
80102bee:	0f b6 c0             	movzbl %al,%eax
80102bf1:	f7 d0                	not    %eax
80102bf3:	89 c2                	mov    %eax,%edx
80102bf5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bfa:	21 d0                	and    %edx,%eax
80102bfc:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c01:	b8 00 00 00 00       	mov    $0x0,%eax
80102c06:	e9 a2 00 00 00       	jmp    80102cad <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102c0b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c10:	83 e0 40             	and    $0x40,%eax
80102c13:	85 c0                	test   %eax,%eax
80102c15:	74 14                	je     80102c2b <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c17:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c1e:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c23:	83 e0 bf             	and    $0xffffffbf,%eax
80102c26:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c2e:	05 20 90 10 80       	add    $0x80109020,%eax
80102c33:	0f b6 00             	movzbl (%eax),%eax
80102c36:	0f b6 d0             	movzbl %al,%edx
80102c39:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c3e:	09 d0                	or     %edx,%eax
80102c40:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102c45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c48:	05 20 91 10 80       	add    $0x80109120,%eax
80102c4d:	0f b6 00             	movzbl (%eax),%eax
80102c50:	0f b6 d0             	movzbl %al,%edx
80102c53:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c58:	31 d0                	xor    %edx,%eax
80102c5a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c5f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c64:	83 e0 03             	and    $0x3,%eax
80102c67:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102c6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c71:	01 d0                	add    %edx,%eax
80102c73:	0f b6 00             	movzbl (%eax),%eax
80102c76:	0f b6 c0             	movzbl %al,%eax
80102c79:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c7c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c81:	83 e0 08             	and    $0x8,%eax
80102c84:	85 c0                	test   %eax,%eax
80102c86:	74 22                	je     80102caa <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102c88:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c8c:	76 0c                	jbe    80102c9a <kbdgetc+0x13e>
80102c8e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102c92:	77 06                	ja     80102c9a <kbdgetc+0x13e>
      c += 'A' - 'a';
80102c94:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102c98:	eb 10                	jmp    80102caa <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102c9a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102c9e:	76 0a                	jbe    80102caa <kbdgetc+0x14e>
80102ca0:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ca4:	77 04                	ja     80102caa <kbdgetc+0x14e>
      c += 'a' - 'A';
80102ca6:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102caa:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102cad:	c9                   	leave  
80102cae:	c3                   	ret    

80102caf <kbdintr>:

void
kbdintr(void)
{
80102caf:	55                   	push   %ebp
80102cb0:	89 e5                	mov    %esp,%ebp
80102cb2:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102cb5:	c7 04 24 5c 2b 10 80 	movl   $0x80102b5c,(%esp)
80102cbc:	e8 ec da ff ff       	call   801007ad <consoleintr>
}
80102cc1:	c9                   	leave  
80102cc2:	c3                   	ret    

80102cc3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cc3:	55                   	push   %ebp
80102cc4:	89 e5                	mov    %esp,%ebp
80102cc6:	83 ec 14             	sub    $0x14,%esp
80102cc9:	8b 45 08             	mov    0x8(%ebp),%eax
80102ccc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cd0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cd4:	89 c2                	mov    %eax,%edx
80102cd6:	ec                   	in     (%dx),%al
80102cd7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cda:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cde:	c9                   	leave  
80102cdf:	c3                   	ret    

80102ce0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102ce0:	55                   	push   %ebp
80102ce1:	89 e5                	mov    %esp,%ebp
80102ce3:	83 ec 08             	sub    $0x8,%esp
80102ce6:	8b 55 08             	mov    0x8(%ebp),%edx
80102ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cec:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102cf0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cf3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102cf7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102cfb:	ee                   	out    %al,(%dx)
}
80102cfc:	c9                   	leave  
80102cfd:	c3                   	ret    

80102cfe <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cfe:	55                   	push   %ebp
80102cff:	89 e5                	mov    %esp,%ebp
80102d01:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d04:	9c                   	pushf  
80102d05:	58                   	pop    %eax
80102d06:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102d09:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102d0c:	c9                   	leave  
80102d0d:	c3                   	ret    

80102d0e <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d0e:	55                   	push   %ebp
80102d0f:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d11:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d16:	8b 55 08             	mov    0x8(%ebp),%edx
80102d19:	c1 e2 02             	shl    $0x2,%edx
80102d1c:	01 c2                	add    %eax,%edx
80102d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d21:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d23:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d28:	83 c0 20             	add    $0x20,%eax
80102d2b:	8b 00                	mov    (%eax),%eax
}
80102d2d:	5d                   	pop    %ebp
80102d2e:	c3                   	ret    

80102d2f <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d2f:	55                   	push   %ebp
80102d30:	89 e5                	mov    %esp,%ebp
80102d32:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d35:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d3a:	85 c0                	test   %eax,%eax
80102d3c:	75 05                	jne    80102d43 <lapicinit+0x14>
    return;
80102d3e:	e9 43 01 00 00       	jmp    80102e86 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d43:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d4a:	00 
80102d4b:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d52:	e8 b7 ff ff ff       	call   80102d0e <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d57:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d5e:	00 
80102d5f:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d66:	e8 a3 ff ff ff       	call   80102d0e <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d6b:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d72:	00 
80102d73:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d7a:	e8 8f ff ff ff       	call   80102d0e <lapicw>
  lapicw(TICR, 10000000); 
80102d7f:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d86:	00 
80102d87:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d8e:	e8 7b ff ff ff       	call   80102d0e <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d93:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d9a:	00 
80102d9b:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102da2:	e8 67 ff ff ff       	call   80102d0e <lapicw>
  lapicw(LINT1, MASKED);
80102da7:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dae:	00 
80102daf:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102db6:	e8 53 ff ff ff       	call   80102d0e <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102dbb:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102dc0:	83 c0 30             	add    $0x30,%eax
80102dc3:	8b 00                	mov    (%eax),%eax
80102dc5:	c1 e8 10             	shr    $0x10,%eax
80102dc8:	0f b6 c0             	movzbl %al,%eax
80102dcb:	83 f8 03             	cmp    $0x3,%eax
80102dce:	76 14                	jbe    80102de4 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102dd0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dd7:	00 
80102dd8:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102ddf:	e8 2a ff ff ff       	call   80102d0e <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102de4:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102deb:	00 
80102dec:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102df3:	e8 16 ff ff ff       	call   80102d0e <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102df8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102dff:	00 
80102e00:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e07:	e8 02 ff ff ff       	call   80102d0e <lapicw>
  lapicw(ESR, 0);
80102e0c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e13:	00 
80102e14:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e1b:	e8 ee fe ff ff       	call   80102d0e <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e20:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e27:	00 
80102e28:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e2f:	e8 da fe ff ff       	call   80102d0e <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e34:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e3b:	00 
80102e3c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e43:	e8 c6 fe ff ff       	call   80102d0e <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e48:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e4f:	00 
80102e50:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e57:	e8 b2 fe ff ff       	call   80102d0e <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e5c:	90                   	nop
80102e5d:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e62:	05 00 03 00 00       	add    $0x300,%eax
80102e67:	8b 00                	mov    (%eax),%eax
80102e69:	25 00 10 00 00       	and    $0x1000,%eax
80102e6e:	85 c0                	test   %eax,%eax
80102e70:	75 eb                	jne    80102e5d <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e79:	00 
80102e7a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e81:	e8 88 fe ff ff       	call   80102d0e <lapicw>
}
80102e86:	c9                   	leave  
80102e87:	c3                   	ret    

80102e88 <cpunum>:

int
cpunum(void)
{
80102e88:	55                   	push   %ebp
80102e89:	89 e5                	mov    %esp,%ebp
80102e8b:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e8e:	e8 6b fe ff ff       	call   80102cfe <readeflags>
80102e93:	25 00 02 00 00       	and    $0x200,%eax
80102e98:	85 c0                	test   %eax,%eax
80102e9a:	74 25                	je     80102ec1 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102e9c:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102ea1:	8d 50 01             	lea    0x1(%eax),%edx
80102ea4:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102eaa:	85 c0                	test   %eax,%eax
80102eac:	75 13                	jne    80102ec1 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eae:	8b 45 04             	mov    0x4(%ebp),%eax
80102eb1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eb5:	c7 04 24 e8 88 10 80 	movl   $0x801088e8,(%esp)
80102ebc:	e8 df d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102ec1:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ec6:	85 c0                	test   %eax,%eax
80102ec8:	74 0f                	je     80102ed9 <cpunum+0x51>
    return lapic[ID]>>24;
80102eca:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ecf:	83 c0 20             	add    $0x20,%eax
80102ed2:	8b 00                	mov    (%eax),%eax
80102ed4:	c1 e8 18             	shr    $0x18,%eax
80102ed7:	eb 05                	jmp    80102ede <cpunum+0x56>
  return 0;
80102ed9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102ede:	c9                   	leave  
80102edf:	c3                   	ret    

80102ee0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ee0:	55                   	push   %ebp
80102ee1:	89 e5                	mov    %esp,%ebp
80102ee3:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ee6:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102eeb:	85 c0                	test   %eax,%eax
80102eed:	74 14                	je     80102f03 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102eef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ef6:	00 
80102ef7:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102efe:	e8 0b fe ff ff       	call   80102d0e <lapicw>
}
80102f03:	c9                   	leave  
80102f04:	c3                   	ret    

80102f05 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f05:	55                   	push   %ebp
80102f06:	89 e5                	mov    %esp,%ebp
}
80102f08:	5d                   	pop    %ebp
80102f09:	c3                   	ret    

80102f0a <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f0a:	55                   	push   %ebp
80102f0b:	89 e5                	mov    %esp,%ebp
80102f0d:	83 ec 1c             	sub    $0x1c,%esp
80102f10:	8b 45 08             	mov    0x8(%ebp),%eax
80102f13:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f16:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f1d:	00 
80102f1e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f25:	e8 b6 fd ff ff       	call   80102ce0 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f2a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f31:	00 
80102f32:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f39:	e8 a2 fd ff ff       	call   80102ce0 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f3e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f45:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f48:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f50:	8d 50 02             	lea    0x2(%eax),%edx
80102f53:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f56:	c1 e8 04             	shr    $0x4,%eax
80102f59:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f5c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f60:	c1 e0 18             	shl    $0x18,%eax
80102f63:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f67:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f6e:	e8 9b fd ff ff       	call   80102d0e <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f73:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f7a:	00 
80102f7b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f82:	e8 87 fd ff ff       	call   80102d0e <lapicw>
  microdelay(200);
80102f87:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f8e:	e8 72 ff ff ff       	call   80102f05 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f93:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f9a:	00 
80102f9b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fa2:	e8 67 fd ff ff       	call   80102d0e <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102fa7:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fae:	e8 52 ff ff ff       	call   80102f05 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fb3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102fba:	eb 40                	jmp    80102ffc <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fbc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fc0:	c1 e0 18             	shl    $0x18,%eax
80102fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fc7:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fce:	e8 3b fd ff ff       	call   80102d0e <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fd6:	c1 e8 0c             	shr    $0xc,%eax
80102fd9:	80 cc 06             	or     $0x6,%ah
80102fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fe0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fe7:	e8 22 fd ff ff       	call   80102d0e <lapicw>
    microdelay(200);
80102fec:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ff3:	e8 0d ff ff ff       	call   80102f05 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ff8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102ffc:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103000:	7e ba                	jle    80102fbc <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103002:	c9                   	leave  
80103003:	c3                   	ret    

80103004 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103004:	55                   	push   %ebp
80103005:	89 e5                	mov    %esp,%ebp
80103007:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
8010300a:	8b 45 08             	mov    0x8(%ebp),%eax
8010300d:	0f b6 c0             	movzbl %al,%eax
80103010:	89 44 24 04          	mov    %eax,0x4(%esp)
80103014:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010301b:	e8 c0 fc ff ff       	call   80102ce0 <outb>
  microdelay(200);
80103020:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103027:	e8 d9 fe ff ff       	call   80102f05 <microdelay>

  return inb(CMOS_RETURN);
8010302c:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103033:	e8 8b fc ff ff       	call   80102cc3 <inb>
80103038:	0f b6 c0             	movzbl %al,%eax
}
8010303b:	c9                   	leave  
8010303c:	c3                   	ret    

8010303d <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010303d:	55                   	push   %ebp
8010303e:	89 e5                	mov    %esp,%ebp
80103040:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103043:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010304a:	e8 b5 ff ff ff       	call   80103004 <cmos_read>
8010304f:	8b 55 08             	mov    0x8(%ebp),%edx
80103052:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103054:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010305b:	e8 a4 ff ff ff       	call   80103004 <cmos_read>
80103060:	8b 55 08             	mov    0x8(%ebp),%edx
80103063:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103066:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010306d:	e8 92 ff ff ff       	call   80103004 <cmos_read>
80103072:	8b 55 08             	mov    0x8(%ebp),%edx
80103075:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103078:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010307f:	e8 80 ff ff ff       	call   80103004 <cmos_read>
80103084:	8b 55 08             	mov    0x8(%ebp),%edx
80103087:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010308a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103091:	e8 6e ff ff ff       	call   80103004 <cmos_read>
80103096:	8b 55 08             	mov    0x8(%ebp),%edx
80103099:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010309c:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801030a3:	e8 5c ff ff ff       	call   80103004 <cmos_read>
801030a8:	8b 55 08             	mov    0x8(%ebp),%edx
801030ab:	89 42 14             	mov    %eax,0x14(%edx)
}
801030ae:	c9                   	leave  
801030af:	c3                   	ret    

801030b0 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801030b0:	55                   	push   %ebp
801030b1:	89 e5                	mov    %esp,%ebp
801030b3:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801030b6:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801030bd:	e8 42 ff ff ff       	call   80103004 <cmos_read>
801030c2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801030c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030c8:	83 e0 04             	and    $0x4,%eax
801030cb:	85 c0                	test   %eax,%eax
801030cd:	0f 94 c0             	sete   %al
801030d0:	0f b6 c0             	movzbl %al,%eax
801030d3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801030d6:	8d 45 d8             	lea    -0x28(%ebp),%eax
801030d9:	89 04 24             	mov    %eax,(%esp)
801030dc:	e8 5c ff ff ff       	call   8010303d <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801030e1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801030e8:	e8 17 ff ff ff       	call   80103004 <cmos_read>
801030ed:	25 80 00 00 00       	and    $0x80,%eax
801030f2:	85 c0                	test   %eax,%eax
801030f4:	74 02                	je     801030f8 <cmostime+0x48>
        continue;
801030f6:	eb 36                	jmp    8010312e <cmostime+0x7e>
    fill_rtcdate(&t2);
801030f8:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030fb:	89 04 24             	mov    %eax,(%esp)
801030fe:	e8 3a ff ff ff       	call   8010303d <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103103:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010310a:	00 
8010310b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010310e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103112:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103115:	89 04 24             	mov    %eax,(%esp)
80103118:	e8 67 22 00 00       	call   80105384 <memcmp>
8010311d:	85 c0                	test   %eax,%eax
8010311f:	75 0d                	jne    8010312e <cmostime+0x7e>
      break;
80103121:	90                   	nop
  }

  // convert
  if (bcd) {
80103122:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103126:	0f 84 ac 00 00 00    	je     801031d8 <cmostime+0x128>
8010312c:	eb 02                	jmp    80103130 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010312e:	eb a6                	jmp    801030d6 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103130:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103133:	c1 e8 04             	shr    $0x4,%eax
80103136:	89 c2                	mov    %eax,%edx
80103138:	89 d0                	mov    %edx,%eax
8010313a:	c1 e0 02             	shl    $0x2,%eax
8010313d:	01 d0                	add    %edx,%eax
8010313f:	01 c0                	add    %eax,%eax
80103141:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103144:	83 e2 0f             	and    $0xf,%edx
80103147:	01 d0                	add    %edx,%eax
80103149:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010314c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010314f:	c1 e8 04             	shr    $0x4,%eax
80103152:	89 c2                	mov    %eax,%edx
80103154:	89 d0                	mov    %edx,%eax
80103156:	c1 e0 02             	shl    $0x2,%eax
80103159:	01 d0                	add    %edx,%eax
8010315b:	01 c0                	add    %eax,%eax
8010315d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103160:	83 e2 0f             	and    $0xf,%edx
80103163:	01 d0                	add    %edx,%eax
80103165:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103168:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010316b:	c1 e8 04             	shr    $0x4,%eax
8010316e:	89 c2                	mov    %eax,%edx
80103170:	89 d0                	mov    %edx,%eax
80103172:	c1 e0 02             	shl    $0x2,%eax
80103175:	01 d0                	add    %edx,%eax
80103177:	01 c0                	add    %eax,%eax
80103179:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010317c:	83 e2 0f             	and    $0xf,%edx
8010317f:	01 d0                	add    %edx,%eax
80103181:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103184:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103187:	c1 e8 04             	shr    $0x4,%eax
8010318a:	89 c2                	mov    %eax,%edx
8010318c:	89 d0                	mov    %edx,%eax
8010318e:	c1 e0 02             	shl    $0x2,%eax
80103191:	01 d0                	add    %edx,%eax
80103193:	01 c0                	add    %eax,%eax
80103195:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103198:	83 e2 0f             	and    $0xf,%edx
8010319b:	01 d0                	add    %edx,%eax
8010319d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801031a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801031a3:	c1 e8 04             	shr    $0x4,%eax
801031a6:	89 c2                	mov    %eax,%edx
801031a8:	89 d0                	mov    %edx,%eax
801031aa:	c1 e0 02             	shl    $0x2,%eax
801031ad:	01 d0                	add    %edx,%eax
801031af:	01 c0                	add    %eax,%eax
801031b1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031b4:	83 e2 0f             	and    $0xf,%edx
801031b7:	01 d0                	add    %edx,%eax
801031b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801031bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031bf:	c1 e8 04             	shr    $0x4,%eax
801031c2:	89 c2                	mov    %eax,%edx
801031c4:	89 d0                	mov    %edx,%eax
801031c6:	c1 e0 02             	shl    $0x2,%eax
801031c9:	01 d0                	add    %edx,%eax
801031cb:	01 c0                	add    %eax,%eax
801031cd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031d0:	83 e2 0f             	and    $0xf,%edx
801031d3:	01 d0                	add    %edx,%eax
801031d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801031d8:	8b 45 08             	mov    0x8(%ebp),%eax
801031db:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031de:	89 10                	mov    %edx,(%eax)
801031e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031e3:	89 50 04             	mov    %edx,0x4(%eax)
801031e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031e9:	89 50 08             	mov    %edx,0x8(%eax)
801031ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031ef:	89 50 0c             	mov    %edx,0xc(%eax)
801031f2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031f5:	89 50 10             	mov    %edx,0x10(%eax)
801031f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031fb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801031fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103201:	8b 40 14             	mov    0x14(%eax),%eax
80103204:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010320a:	8b 45 08             	mov    0x8(%ebp),%eax
8010320d:	89 50 14             	mov    %edx,0x14(%eax)
}
80103210:	c9                   	leave  
80103211:	c3                   	ret    

80103212 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103212:	55                   	push   %ebp
80103213:	89 e5                	mov    %esp,%ebp
80103215:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103218:	c7 44 24 04 14 89 10 	movl   $0x80108914,0x4(%esp)
8010321f:	80 
80103220:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103227:	e8 6c 1e 00 00       	call   80105098 <initlock>
  readsb(ROOTDEV, &sb);
8010322c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010322f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103233:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010323a:	e8 c2 e0 ff ff       	call   80101301 <readsb>
  log.start = sb.size - sb.nlog;
8010323f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103245:	29 c2                	sub    %eax,%edx
80103247:	89 d0                	mov    %edx,%eax
80103249:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
8010324e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103251:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = ROOTDEV;
80103256:	c7 05 a4 22 11 80 01 	movl   $0x1,0x801122a4
8010325d:	00 00 00 
  recover_from_log();
80103260:	e8 9a 01 00 00       	call   801033ff <recover_from_log>
}
80103265:	c9                   	leave  
80103266:	c3                   	ret    

80103267 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103267:	55                   	push   %ebp
80103268:	89 e5                	mov    %esp,%ebp
8010326a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010326d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103274:	e9 8c 00 00 00       	jmp    80103305 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103279:	8b 15 94 22 11 80    	mov    0x80112294,%edx
8010327f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103282:	01 d0                	add    %edx,%eax
80103284:	83 c0 01             	add    $0x1,%eax
80103287:	89 c2                	mov    %eax,%edx
80103289:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010328e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103292:	89 04 24             	mov    %eax,(%esp)
80103295:	e8 0c cf ff ff       	call   801001a6 <bread>
8010329a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010329d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032a0:	83 c0 10             	add    $0x10,%eax
801032a3:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801032aa:	89 c2                	mov    %eax,%edx
801032ac:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801032b1:	89 54 24 04          	mov    %edx,0x4(%esp)
801032b5:	89 04 24             	mov    %eax,(%esp)
801032b8:	e8 e9 ce ff ff       	call   801001a6 <bread>
801032bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801032c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032c3:	8d 50 18             	lea    0x18(%eax),%edx
801032c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032c9:	83 c0 18             	add    $0x18,%eax
801032cc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801032d3:	00 
801032d4:	89 54 24 04          	mov    %edx,0x4(%esp)
801032d8:	89 04 24             	mov    %eax,(%esp)
801032db:	e8 fc 20 00 00       	call   801053dc <memmove>
    bwrite(dbuf);  // write dst to disk
801032e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e3:	89 04 24             	mov    %eax,(%esp)
801032e6:	e8 f2 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801032eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032ee:	89 04 24             	mov    %eax,(%esp)
801032f1:	e8 21 cf ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801032f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f9:	89 04 24             	mov    %eax,(%esp)
801032fc:	e8 16 cf ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103301:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103305:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010330a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010330d:	0f 8f 66 ff ff ff    	jg     80103279 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103313:	c9                   	leave  
80103314:	c3                   	ret    

80103315 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103315:	55                   	push   %ebp
80103316:	89 e5                	mov    %esp,%ebp
80103318:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010331b:	a1 94 22 11 80       	mov    0x80112294,%eax
80103320:	89 c2                	mov    %eax,%edx
80103322:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103327:	89 54 24 04          	mov    %edx,0x4(%esp)
8010332b:	89 04 24             	mov    %eax,(%esp)
8010332e:	e8 73 ce ff ff       	call   801001a6 <bread>
80103333:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103336:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103339:	83 c0 18             	add    $0x18,%eax
8010333c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010333f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103342:	8b 00                	mov    (%eax),%eax
80103344:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
80103349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103350:	eb 1b                	jmp    8010336d <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103352:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103355:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103358:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010335c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010335f:	83 c2 10             	add    $0x10,%edx
80103362:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103369:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010336d:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103372:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103375:	7f db                	jg     80103352 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103377:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010337a:	89 04 24             	mov    %eax,(%esp)
8010337d:	e8 95 ce ff ff       	call   80100217 <brelse>
}
80103382:	c9                   	leave  
80103383:	c3                   	ret    

80103384 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103384:	55                   	push   %ebp
80103385:	89 e5                	mov    %esp,%ebp
80103387:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010338a:	a1 94 22 11 80       	mov    0x80112294,%eax
8010338f:	89 c2                	mov    %eax,%edx
80103391:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103396:	89 54 24 04          	mov    %edx,0x4(%esp)
8010339a:	89 04 24             	mov    %eax,(%esp)
8010339d:	e8 04 ce ff ff       	call   801001a6 <bread>
801033a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801033a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033a8:	83 c0 18             	add    $0x18,%eax
801033ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801033ae:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
801033b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033c0:	eb 1b                	jmp    801033dd <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c5:	83 c0 10             	add    $0x10,%eax
801033c8:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
801033cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033d5:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801033d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033dd:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801033e2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033e5:	7f db                	jg     801033c2 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801033e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ea:	89 04 24             	mov    %eax,(%esp)
801033ed:	e8 eb cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
801033f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033f5:	89 04 24             	mov    %eax,(%esp)
801033f8:	e8 1a ce ff ff       	call   80100217 <brelse>
}
801033fd:	c9                   	leave  
801033fe:	c3                   	ret    

801033ff <recover_from_log>:

static void
recover_from_log(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103405:	e8 0b ff ff ff       	call   80103315 <read_head>
  install_trans(); // if committed, copy from log to disk
8010340a:	e8 58 fe ff ff       	call   80103267 <install_trans>
  log.lh.n = 0;
8010340f:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103416:	00 00 00 
  write_head(); // clear the log
80103419:	e8 66 ff ff ff       	call   80103384 <write_head>
}
8010341e:	c9                   	leave  
8010341f:	c3                   	ret    

80103420 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103420:	55                   	push   %ebp
80103421:	89 e5                	mov    %esp,%ebp
80103423:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103426:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010342d:	e8 87 1c 00 00       	call   801050b9 <acquire>
  while(1){
    if(log.committing){
80103432:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103437:	85 c0                	test   %eax,%eax
80103439:	74 16                	je     80103451 <begin_op+0x31>
      sleep(&log, &log.lock);
8010343b:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103442:	80 
80103443:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010344a:	e8 09 18 00 00       	call   80104c58 <sleep>
8010344f:	eb 4f                	jmp    801034a0 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103451:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103457:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010345c:	8d 50 01             	lea    0x1(%eax),%edx
8010345f:	89 d0                	mov    %edx,%eax
80103461:	c1 e0 02             	shl    $0x2,%eax
80103464:	01 d0                	add    %edx,%eax
80103466:	01 c0                	add    %eax,%eax
80103468:	01 c8                	add    %ecx,%eax
8010346a:	83 f8 1e             	cmp    $0x1e,%eax
8010346d:	7e 16                	jle    80103485 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010346f:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103476:	80 
80103477:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010347e:	e8 d5 17 00 00       	call   80104c58 <sleep>
80103483:	eb 1b                	jmp    801034a0 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103485:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010348a:	83 c0 01             	add    $0x1,%eax
8010348d:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
80103492:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103499:	e8 7d 1c 00 00       	call   8010511b <release>
      break;
8010349e:	eb 02                	jmp    801034a2 <begin_op+0x82>
    }
  }
801034a0:	eb 90                	jmp    80103432 <begin_op+0x12>
}
801034a2:	c9                   	leave  
801034a3:	c3                   	ret    

801034a4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801034a4:	55                   	push   %ebp
801034a5:	89 e5                	mov    %esp,%ebp
801034a7:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801034aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801034b1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034b8:	e8 fc 1b 00 00       	call   801050b9 <acquire>
  log.outstanding -= 1;
801034bd:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034c2:	83 e8 01             	sub    $0x1,%eax
801034c5:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
801034ca:	a1 a0 22 11 80       	mov    0x801122a0,%eax
801034cf:	85 c0                	test   %eax,%eax
801034d1:	74 0c                	je     801034df <end_op+0x3b>
    panic("log.committing");
801034d3:	c7 04 24 18 89 10 80 	movl   $0x80108918,(%esp)
801034da:	e8 5b d0 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
801034df:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034e4:	85 c0                	test   %eax,%eax
801034e6:	75 13                	jne    801034fb <end_op+0x57>
    do_commit = 1;
801034e8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801034ef:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
801034f6:	00 00 00 
801034f9:	eb 0c                	jmp    80103507 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801034fb:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103502:	e8 2c 18 00 00       	call   80104d33 <wakeup>
  }
  release(&log.lock);
80103507:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010350e:	e8 08 1c 00 00       	call   8010511b <release>

  if(do_commit){
80103513:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103517:	74 33                	je     8010354c <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103519:	e8 de 00 00 00       	call   801035fc <commit>
    acquire(&log.lock);
8010351e:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103525:	e8 8f 1b 00 00       	call   801050b9 <acquire>
    log.committing = 0;
8010352a:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
80103531:	00 00 00 
    wakeup(&log);
80103534:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010353b:	e8 f3 17 00 00       	call   80104d33 <wakeup>
    release(&log.lock);
80103540:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103547:	e8 cf 1b 00 00       	call   8010511b <release>
  }
}
8010354c:	c9                   	leave  
8010354d:	c3                   	ret    

8010354e <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010354e:	55                   	push   %ebp
8010354f:	89 e5                	mov    %esp,%ebp
80103551:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103554:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010355b:	e9 8c 00 00 00       	jmp    801035ec <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103560:	8b 15 94 22 11 80    	mov    0x80112294,%edx
80103566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103569:	01 d0                	add    %edx,%eax
8010356b:	83 c0 01             	add    $0x1,%eax
8010356e:	89 c2                	mov    %eax,%edx
80103570:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103575:	89 54 24 04          	mov    %edx,0x4(%esp)
80103579:	89 04 24             	mov    %eax,(%esp)
8010357c:	e8 25 cc ff ff       	call   801001a6 <bread>
80103581:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103587:	83 c0 10             	add    $0x10,%eax
8010358a:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103591:	89 c2                	mov    %eax,%edx
80103593:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103598:	89 54 24 04          	mov    %edx,0x4(%esp)
8010359c:	89 04 24             	mov    %eax,(%esp)
8010359f:	e8 02 cc ff ff       	call   801001a6 <bread>
801035a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801035a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035aa:	8d 50 18             	lea    0x18(%eax),%edx
801035ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035b0:	83 c0 18             	add    $0x18,%eax
801035b3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801035ba:	00 
801035bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801035bf:	89 04 24             	mov    %eax,(%esp)
801035c2:	e8 15 1e 00 00       	call   801053dc <memmove>
    bwrite(to);  // write the log
801035c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ca:	89 04 24             	mov    %eax,(%esp)
801035cd:	e8 0b cc ff ff       	call   801001dd <bwrite>
    brelse(from); 
801035d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035d5:	89 04 24             	mov    %eax,(%esp)
801035d8:	e8 3a cc ff ff       	call   80100217 <brelse>
    brelse(to);
801035dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035e0:	89 04 24             	mov    %eax,(%esp)
801035e3:	e8 2f cc ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035ec:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801035f1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035f4:	0f 8f 66 ff ff ff    	jg     80103560 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801035fa:	c9                   	leave  
801035fb:	c3                   	ret    

801035fc <commit>:

static void
commit()
{
801035fc:	55                   	push   %ebp
801035fd:	89 e5                	mov    %esp,%ebp
801035ff:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103602:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103607:	85 c0                	test   %eax,%eax
80103609:	7e 1e                	jle    80103629 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010360b:	e8 3e ff ff ff       	call   8010354e <write_log>
    write_head();    // Write header to disk -- the real commit
80103610:	e8 6f fd ff ff       	call   80103384 <write_head>
    install_trans(); // Now install writes to home locations
80103615:	e8 4d fc ff ff       	call   80103267 <install_trans>
    log.lh.n = 0; 
8010361a:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103621:	00 00 00 
    write_head();    // Erase the transaction from the log
80103624:	e8 5b fd ff ff       	call   80103384 <write_head>
  }
}
80103629:	c9                   	leave  
8010362a:	c3                   	ret    

8010362b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010362b:	55                   	push   %ebp
8010362c:	89 e5                	mov    %esp,%ebp
8010362e:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103631:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103636:	83 f8 1d             	cmp    $0x1d,%eax
80103639:	7f 12                	jg     8010364d <log_write+0x22>
8010363b:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103640:	8b 15 98 22 11 80    	mov    0x80112298,%edx
80103646:	83 ea 01             	sub    $0x1,%edx
80103649:	39 d0                	cmp    %edx,%eax
8010364b:	7c 0c                	jl     80103659 <log_write+0x2e>
    panic("too big a transaction");
8010364d:	c7 04 24 27 89 10 80 	movl   $0x80108927,(%esp)
80103654:	e8 e1 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103659:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010365e:	85 c0                	test   %eax,%eax
80103660:	7f 0c                	jg     8010366e <log_write+0x43>
    panic("log_write outside of trans");
80103662:	c7 04 24 3d 89 10 80 	movl   $0x8010893d,(%esp)
80103669:	e8 cc ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010366e:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103675:	e8 3f 1a 00 00       	call   801050b9 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010367a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103681:	eb 1f                	jmp    801036a2 <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103686:	83 c0 10             	add    $0x10,%eax
80103689:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103690:	89 c2                	mov    %eax,%edx
80103692:	8b 45 08             	mov    0x8(%ebp),%eax
80103695:	8b 40 08             	mov    0x8(%eax),%eax
80103698:	39 c2                	cmp    %eax,%edx
8010369a:	75 02                	jne    8010369e <log_write+0x73>
      break;
8010369c:	eb 0e                	jmp    801036ac <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010369e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036a2:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036aa:	7f d7                	jg     80103683 <log_write+0x58>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
801036ac:	8b 45 08             	mov    0x8(%ebp),%eax
801036af:	8b 40 08             	mov    0x8(%eax),%eax
801036b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036b5:	83 c2 10             	add    $0x10,%edx
801036b8:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
  if (i == log.lh.n)
801036bf:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036c4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036c7:	75 0d                	jne    801036d6 <log_write+0xab>
    log.lh.n++;
801036c9:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036ce:	83 c0 01             	add    $0x1,%eax
801036d1:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
801036d6:	8b 45 08             	mov    0x8(%ebp),%eax
801036d9:	8b 00                	mov    (%eax),%eax
801036db:	83 c8 04             	or     $0x4,%eax
801036de:	89 c2                	mov    %eax,%edx
801036e0:	8b 45 08             	mov    0x8(%ebp),%eax
801036e3:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801036e5:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036ec:	e8 2a 1a 00 00       	call   8010511b <release>
}
801036f1:	c9                   	leave  
801036f2:	c3                   	ret    

801036f3 <v2p>:
801036f3:	55                   	push   %ebp
801036f4:	89 e5                	mov    %esp,%ebp
801036f6:	8b 45 08             	mov    0x8(%ebp),%eax
801036f9:	05 00 00 00 80       	add    $0x80000000,%eax
801036fe:	5d                   	pop    %ebp
801036ff:	c3                   	ret    

80103700 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103700:	55                   	push   %ebp
80103701:	89 e5                	mov    %esp,%ebp
80103703:	8b 45 08             	mov    0x8(%ebp),%eax
80103706:	05 00 00 00 80       	add    $0x80000000,%eax
8010370b:	5d                   	pop    %ebp
8010370c:	c3                   	ret    

8010370d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010370d:	55                   	push   %ebp
8010370e:	89 e5                	mov    %esp,%ebp
80103710:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103713:	8b 55 08             	mov    0x8(%ebp),%edx
80103716:	8b 45 0c             	mov    0xc(%ebp),%eax
80103719:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010371c:	f0 87 02             	lock xchg %eax,(%edx)
8010371f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103722:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103725:	c9                   	leave  
80103726:	c3                   	ret    

80103727 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103727:	55                   	push   %ebp
80103728:	89 e5                	mov    %esp,%ebp
8010372a:	83 e4 f0             	and    $0xfffffff0,%esp
8010372d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103730:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103737:	80 
80103738:	c7 04 24 3c 8a 11 80 	movl   $0x80118a3c,(%esp)
8010373f:	e8 80 f2 ff ff       	call   801029c4 <kinit1>
  kvmalloc();      // kernel page table
80103744:	e8 11 48 00 00       	call   80107f5a <kvmalloc>
  mpinit();        // collect info about this machine
80103749:	e8 46 04 00 00       	call   80103b94 <mpinit>
  lapicinit();
8010374e:	e8 dc f5 ff ff       	call   80102d2f <lapicinit>
  seginit();       // set up segments
80103753:	e8 95 41 00 00       	call   801078ed <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103758:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010375e:	0f b6 00             	movzbl (%eax),%eax
80103761:	0f b6 c0             	movzbl %al,%eax
80103764:	89 44 24 04          	mov    %eax,0x4(%esp)
80103768:	c7 04 24 58 89 10 80 	movl   $0x80108958,(%esp)
8010376f:	e8 2c cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103774:	e8 79 06 00 00       	call   80103df2 <picinit>
  ioapicinit();    // another interrupt controller
80103779:	e8 3c f1 ff ff       	call   801028ba <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010377e:	e8 fe d2 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103783:	e8 b4 34 00 00       	call   80106c3c <uartinit>
  pinit();         // process table
80103788:	e8 a3 0b 00 00       	call   80104330 <pinit>
  tvinit();        // trap vectors
8010378d:	e8 5c 30 00 00       	call   801067ee <tvinit>
  binit();         // buffer cache
80103792:	e8 9d c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103797:	e8 7e d7 ff ff       	call   80100f1a <fileinit>
  iinit();         // inode cache
8010379c:	e8 13 de ff ff       	call   801015b4 <iinit>
  ideinit();       // disk
801037a1:	e8 7d ed ff ff       	call   80102523 <ideinit>
  if(!ismp)
801037a6:	a1 44 23 11 80       	mov    0x80112344,%eax
801037ab:	85 c0                	test   %eax,%eax
801037ad:	75 05                	jne    801037b4 <main+0x8d>
    timerinit();   // uniprocessor timer
801037af:	e8 85 2f 00 00       	call   80106739 <timerinit>
  startothers();   // start other processors
801037b4:	e8 7f 00 00 00       	call   80103838 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037b9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037c0:	8e 
801037c1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037c8:	e8 2f f2 ff ff       	call   801029fc <kinit2>
  userinit();      // first user process
801037cd:	e8 cd 0c 00 00       	call   8010449f <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037d2:	e8 1a 00 00 00       	call   801037f1 <mpmain>

801037d7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037d7:	55                   	push   %ebp
801037d8:	89 e5                	mov    %esp,%ebp
801037da:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801037dd:	e8 8f 47 00 00       	call   80107f71 <switchkvm>
  seginit();
801037e2:	e8 06 41 00 00       	call   801078ed <seginit>
  lapicinit();
801037e7:	e8 43 f5 ff ff       	call   80102d2f <lapicinit>
  mpmain();
801037ec:	e8 00 00 00 00       	call   801037f1 <mpmain>

801037f1 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037f1:	55                   	push   %ebp
801037f2:	89 e5                	mov    %esp,%ebp
801037f4:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801037f7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037fd:	0f b6 00             	movzbl (%eax),%eax
80103800:	0f b6 c0             	movzbl %al,%eax
80103803:	89 44 24 04          	mov    %eax,0x4(%esp)
80103807:	c7 04 24 6f 89 10 80 	movl   $0x8010896f,(%esp)
8010380e:	e8 8d cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103813:	e8 4a 31 00 00       	call   80106962 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103818:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010381e:	05 a8 00 00 00       	add    $0xa8,%eax
80103823:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010382a:	00 
8010382b:	89 04 24             	mov    %eax,(%esp)
8010382e:	e8 da fe ff ff       	call   8010370d <xchg>
  scheduler();     // start running processes
80103833:	e8 5f 12 00 00       	call   80104a97 <scheduler>

80103838 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103838:	55                   	push   %ebp
80103839:	89 e5                	mov    %esp,%ebp
8010383b:	53                   	push   %ebx
8010383c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010383f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103846:	e8 b5 fe ff ff       	call   80103700 <p2v>
8010384b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010384e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103853:	89 44 24 08          	mov    %eax,0x8(%esp)
80103857:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010385e:	80 
8010385f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103862:	89 04 24             	mov    %eax,(%esp)
80103865:	e8 72 1b 00 00       	call   801053dc <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010386a:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
80103871:	e9 85 00 00 00       	jmp    801038fb <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103876:	e8 0d f6 ff ff       	call   80102e88 <cpunum>
8010387b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103881:	05 60 23 11 80       	add    $0x80112360,%eax
80103886:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103889:	75 02                	jne    8010388d <startothers+0x55>
      continue;
8010388b:	eb 67                	jmp    801038f4 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010388d:	e8 60 f2 ff ff       	call   80102af2 <kalloc>
80103892:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103898:	83 e8 04             	sub    $0x4,%eax
8010389b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010389e:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038a4:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a9:	83 e8 08             	sub    $0x8,%eax
801038ac:	c7 00 d7 37 10 80    	movl   $0x801037d7,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b5:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038b8:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801038bf:	e8 2f fe ff ff       	call   801036f3 <v2p>
801038c4:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c9:	89 04 24             	mov    %eax,(%esp)
801038cc:	e8 22 fe ff ff       	call   801036f3 <v2p>
801038d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038d4:	0f b6 12             	movzbl (%edx),%edx
801038d7:	0f b6 d2             	movzbl %dl,%edx
801038da:	89 44 24 04          	mov    %eax,0x4(%esp)
801038de:	89 14 24             	mov    %edx,(%esp)
801038e1:	e8 24 f6 ff ff       	call   80102f0a <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038e6:	90                   	nop
801038e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ea:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801038f0:	85 c0                	test   %eax,%eax
801038f2:	74 f3                	je     801038e7 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038f4:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801038fb:	a1 40 29 11 80       	mov    0x80112940,%eax
80103900:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103906:	05 60 23 11 80       	add    $0x80112360,%eax
8010390b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010390e:	0f 87 62 ff ff ff    	ja     80103876 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103914:	83 c4 24             	add    $0x24,%esp
80103917:	5b                   	pop    %ebx
80103918:	5d                   	pop    %ebp
80103919:	c3                   	ret    

8010391a <p2v>:
8010391a:	55                   	push   %ebp
8010391b:	89 e5                	mov    %esp,%ebp
8010391d:	8b 45 08             	mov    0x8(%ebp),%eax
80103920:	05 00 00 00 80       	add    $0x80000000,%eax
80103925:	5d                   	pop    %ebp
80103926:	c3                   	ret    

80103927 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103927:	55                   	push   %ebp
80103928:	89 e5                	mov    %esp,%ebp
8010392a:	83 ec 14             	sub    $0x14,%esp
8010392d:	8b 45 08             	mov    0x8(%ebp),%eax
80103930:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103934:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103938:	89 c2                	mov    %eax,%edx
8010393a:	ec                   	in     (%dx),%al
8010393b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010393e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103942:	c9                   	leave  
80103943:	c3                   	ret    

80103944 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103944:	55                   	push   %ebp
80103945:	89 e5                	mov    %esp,%ebp
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	8b 55 08             	mov    0x8(%ebp),%edx
8010394d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103950:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103954:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103957:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010395b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010395f:	ee                   	out    %al,(%dx)
}
80103960:	c9                   	leave  
80103961:	c3                   	ret    

80103962 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103962:	55                   	push   %ebp
80103963:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103965:	a1 44 b6 10 80       	mov    0x8010b644,%eax
8010396a:	89 c2                	mov    %eax,%edx
8010396c:	b8 60 23 11 80       	mov    $0x80112360,%eax
80103971:	29 c2                	sub    %eax,%edx
80103973:	89 d0                	mov    %edx,%eax
80103975:	c1 f8 02             	sar    $0x2,%eax
80103978:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010397e:	5d                   	pop    %ebp
8010397f:	c3                   	ret    

80103980 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103980:	55                   	push   %ebp
80103981:	89 e5                	mov    %esp,%ebp
80103983:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103986:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010398d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103994:	eb 15                	jmp    801039ab <sum+0x2b>
    sum += addr[i];
80103996:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103999:	8b 45 08             	mov    0x8(%ebp),%eax
8010399c:	01 d0                	add    %edx,%eax
8010399e:	0f b6 00             	movzbl (%eax),%eax
801039a1:	0f b6 c0             	movzbl %al,%eax
801039a4:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039a7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039b1:	7c e3                	jl     80103996 <sum+0x16>
    sum += addr[i];
  return sum;
801039b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039b6:	c9                   	leave  
801039b7:	c3                   	ret    

801039b8 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	89 04 24             	mov    %eax,(%esp)
801039c4:	e8 51 ff ff ff       	call   8010391a <p2v>
801039c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801039cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d2:	01 d0                	add    %edx,%eax
801039d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039dd:	eb 3f                	jmp    80103a1e <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039df:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039e6:	00 
801039e7:	c7 44 24 04 80 89 10 	movl   $0x80108980,0x4(%esp)
801039ee:	80 
801039ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f2:	89 04 24             	mov    %eax,(%esp)
801039f5:	e8 8a 19 00 00       	call   80105384 <memcmp>
801039fa:	85 c0                	test   %eax,%eax
801039fc:	75 1c                	jne    80103a1a <mpsearch1+0x62>
801039fe:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a05:	00 
80103a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a09:	89 04 24             	mov    %eax,(%esp)
80103a0c:	e8 6f ff ff ff       	call   80103980 <sum>
80103a11:	84 c0                	test   %al,%al
80103a13:	75 05                	jne    80103a1a <mpsearch1+0x62>
      return (struct mp*)p;
80103a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a18:	eb 11                	jmp    80103a2b <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a1a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a21:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a24:	72 b9                	jb     801039df <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a2b:	c9                   	leave  
80103a2c:	c3                   	ret    

80103a2d <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a2d:	55                   	push   %ebp
80103a2e:	89 e5                	mov    %esp,%ebp
80103a30:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a33:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3d:	83 c0 0f             	add    $0xf,%eax
80103a40:	0f b6 00             	movzbl (%eax),%eax
80103a43:	0f b6 c0             	movzbl %al,%eax
80103a46:	c1 e0 08             	shl    $0x8,%eax
80103a49:	89 c2                	mov    %eax,%edx
80103a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4e:	83 c0 0e             	add    $0xe,%eax
80103a51:	0f b6 00             	movzbl (%eax),%eax
80103a54:	0f b6 c0             	movzbl %al,%eax
80103a57:	09 d0                	or     %edx,%eax
80103a59:	c1 e0 04             	shl    $0x4,%eax
80103a5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a5f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a63:	74 21                	je     80103a86 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a65:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a6c:	00 
80103a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a70:	89 04 24             	mov    %eax,(%esp)
80103a73:	e8 40 ff ff ff       	call   801039b8 <mpsearch1>
80103a78:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a7b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a7f:	74 50                	je     80103ad1 <mpsearch+0xa4>
      return mp;
80103a81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a84:	eb 5f                	jmp    80103ae5 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a89:	83 c0 14             	add    $0x14,%eax
80103a8c:	0f b6 00             	movzbl (%eax),%eax
80103a8f:	0f b6 c0             	movzbl %al,%eax
80103a92:	c1 e0 08             	shl    $0x8,%eax
80103a95:	89 c2                	mov    %eax,%edx
80103a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a9a:	83 c0 13             	add    $0x13,%eax
80103a9d:	0f b6 00             	movzbl (%eax),%eax
80103aa0:	0f b6 c0             	movzbl %al,%eax
80103aa3:	09 d0                	or     %edx,%eax
80103aa5:	c1 e0 0a             	shl    $0xa,%eax
80103aa8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aae:	2d 00 04 00 00       	sub    $0x400,%eax
80103ab3:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103aba:	00 
80103abb:	89 04 24             	mov    %eax,(%esp)
80103abe:	e8 f5 fe ff ff       	call   801039b8 <mpsearch1>
80103ac3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ac6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aca:	74 05                	je     80103ad1 <mpsearch+0xa4>
      return mp;
80103acc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103acf:	eb 14                	jmp    80103ae5 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ad1:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ad8:	00 
80103ad9:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ae0:	e8 d3 fe ff ff       	call   801039b8 <mpsearch1>
}
80103ae5:	c9                   	leave  
80103ae6:	c3                   	ret    

80103ae7 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ae7:	55                   	push   %ebp
80103ae8:	89 e5                	mov    %esp,%ebp
80103aea:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103aed:	e8 3b ff ff ff       	call   80103a2d <mpsearch>
80103af2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103af5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103af9:	74 0a                	je     80103b05 <mpconfig+0x1e>
80103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afe:	8b 40 04             	mov    0x4(%eax),%eax
80103b01:	85 c0                	test   %eax,%eax
80103b03:	75 0a                	jne    80103b0f <mpconfig+0x28>
    return 0;
80103b05:	b8 00 00 00 00       	mov    $0x0,%eax
80103b0a:	e9 83 00 00 00       	jmp    80103b92 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b12:	8b 40 04             	mov    0x4(%eax),%eax
80103b15:	89 04 24             	mov    %eax,(%esp)
80103b18:	e8 fd fd ff ff       	call   8010391a <p2v>
80103b1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b20:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b27:	00 
80103b28:	c7 44 24 04 85 89 10 	movl   $0x80108985,0x4(%esp)
80103b2f:	80 
80103b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b33:	89 04 24             	mov    %eax,(%esp)
80103b36:	e8 49 18 00 00       	call   80105384 <memcmp>
80103b3b:	85 c0                	test   %eax,%eax
80103b3d:	74 07                	je     80103b46 <mpconfig+0x5f>
    return 0;
80103b3f:	b8 00 00 00 00       	mov    $0x0,%eax
80103b44:	eb 4c                	jmp    80103b92 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b49:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b4d:	3c 01                	cmp    $0x1,%al
80103b4f:	74 12                	je     80103b63 <mpconfig+0x7c>
80103b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b54:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b58:	3c 04                	cmp    $0x4,%al
80103b5a:	74 07                	je     80103b63 <mpconfig+0x7c>
    return 0;
80103b5c:	b8 00 00 00 00       	mov    $0x0,%eax
80103b61:	eb 2f                	jmp    80103b92 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b66:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b6a:	0f b7 c0             	movzwl %ax,%eax
80103b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b74:	89 04 24             	mov    %eax,(%esp)
80103b77:	e8 04 fe ff ff       	call   80103980 <sum>
80103b7c:	84 c0                	test   %al,%al
80103b7e:	74 07                	je     80103b87 <mpconfig+0xa0>
    return 0;
80103b80:	b8 00 00 00 00       	mov    $0x0,%eax
80103b85:	eb 0b                	jmp    80103b92 <mpconfig+0xab>
  *pmp = mp;
80103b87:	8b 45 08             	mov    0x8(%ebp),%eax
80103b8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b8d:	89 10                	mov    %edx,(%eax)
  return conf;
80103b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b92:	c9                   	leave  
80103b93:	c3                   	ret    

80103b94 <mpinit>:

void
mpinit(void)
{
80103b94:	55                   	push   %ebp
80103b95:	89 e5                	mov    %esp,%ebp
80103b97:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103b9a:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103ba1:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103ba4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103ba7:	89 04 24             	mov    %eax,(%esp)
80103baa:	e8 38 ff ff ff       	call   80103ae7 <mpconfig>
80103baf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bb6:	75 05                	jne    80103bbd <mpinit+0x29>
    return;
80103bb8:	e9 9c 01 00 00       	jmp    80103d59 <mpinit+0x1c5>
  ismp = 1;
80103bbd:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103bc4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bca:	8b 40 24             	mov    0x24(%eax),%eax
80103bcd:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd5:	83 c0 2c             	add    $0x2c,%eax
80103bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bde:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103be2:	0f b7 d0             	movzwl %ax,%edx
80103be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be8:	01 d0                	add    %edx,%eax
80103bea:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bed:	e9 f4 00 00 00       	jmp    80103ce6 <mpinit+0x152>
    switch(*p){
80103bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf5:	0f b6 00             	movzbl (%eax),%eax
80103bf8:	0f b6 c0             	movzbl %al,%eax
80103bfb:	83 f8 04             	cmp    $0x4,%eax
80103bfe:	0f 87 bf 00 00 00    	ja     80103cc3 <mpinit+0x12f>
80103c04:	8b 04 85 c8 89 10 80 	mov    -0x7fef7638(,%eax,4),%eax
80103c0b:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c16:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c1a:	0f b6 d0             	movzbl %al,%edx
80103c1d:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c22:	39 c2                	cmp    %eax,%edx
80103c24:	74 2d                	je     80103c53 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c29:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c2d:	0f b6 d0             	movzbl %al,%edx
80103c30:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c35:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c39:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c3d:	c7 04 24 8a 89 10 80 	movl   $0x8010898a,(%esp)
80103c44:	e8 57 c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c49:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103c50:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c53:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c56:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c5a:	0f b6 c0             	movzbl %al,%eax
80103c5d:	83 e0 02             	and    $0x2,%eax
80103c60:	85 c0                	test   %eax,%eax
80103c62:	74 15                	je     80103c79 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103c64:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c69:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c6f:	05 60 23 11 80       	add    $0x80112360,%eax
80103c74:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103c79:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103c7f:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c84:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103c8a:	81 c2 60 23 11 80    	add    $0x80112360,%edx
80103c90:	88 02                	mov    %al,(%edx)
      ncpu++;
80103c92:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c97:	83 c0 01             	add    $0x1,%eax
80103c9a:	a3 40 29 11 80       	mov    %eax,0x80112940
      p += sizeof(struct mpproc);
80103c9f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ca3:	eb 41                	jmp    80103ce6 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cae:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cb2:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103cb7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cbb:	eb 29                	jmp    80103ce6 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cbd:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cc1:	eb 23                	jmp    80103ce6 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc6:	0f b6 00             	movzbl (%eax),%eax
80103cc9:	0f b6 c0             	movzbl %al,%eax
80103ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cd0:	c7 04 24 a8 89 10 80 	movl   $0x801089a8,(%esp)
80103cd7:	e8 c4 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103cdc:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103ce3:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cec:	0f 82 00 ff ff ff    	jb     80103bf2 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103cf2:	a1 44 23 11 80       	mov    0x80112344,%eax
80103cf7:	85 c0                	test   %eax,%eax
80103cf9:	75 1d                	jne    80103d18 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cfb:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103d02:	00 00 00 
    lapic = 0;
80103d05:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103d0c:	00 00 00 
    ioapicid = 0;
80103d0f:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103d16:	eb 41                	jmp    80103d59 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d1b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d1f:	84 c0                	test   %al,%al
80103d21:	74 36                	je     80103d59 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d23:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d2a:	00 
80103d2b:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d32:	e8 0d fc ff ff       	call   80103944 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d37:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d3e:	e8 e4 fb ff ff       	call   80103927 <inb>
80103d43:	83 c8 01             	or     $0x1,%eax
80103d46:	0f b6 c0             	movzbl %al,%eax
80103d49:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d4d:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d54:	e8 eb fb ff ff       	call   80103944 <outb>
  }
}
80103d59:	c9                   	leave  
80103d5a:	c3                   	ret    

80103d5b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d5b:	55                   	push   %ebp
80103d5c:	89 e5                	mov    %esp,%ebp
80103d5e:	83 ec 08             	sub    $0x8,%esp
80103d61:	8b 55 08             	mov    0x8(%ebp),%edx
80103d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d67:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d6b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d6e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d72:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d76:	ee                   	out    %al,(%dx)
}
80103d77:	c9                   	leave  
80103d78:	c3                   	ret    

80103d79 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d79:	55                   	push   %ebp
80103d7a:	89 e5                	mov    %esp,%ebp
80103d7c:	83 ec 0c             	sub    $0xc,%esp
80103d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d82:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d86:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d8a:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103d90:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d94:	0f b6 c0             	movzbl %al,%eax
80103d97:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d9b:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103da2:	e8 b4 ff ff ff       	call   80103d5b <outb>
  outb(IO_PIC2+1, mask >> 8);
80103da7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dab:	66 c1 e8 08          	shr    $0x8,%ax
80103daf:	0f b6 c0             	movzbl %al,%eax
80103db2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103db6:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dbd:	e8 99 ff ff ff       	call   80103d5b <outb>
}
80103dc2:	c9                   	leave  
80103dc3:	c3                   	ret    

80103dc4 <picenable>:

void
picenable(int irq)
{
80103dc4:	55                   	push   %ebp
80103dc5:	89 e5                	mov    %esp,%ebp
80103dc7:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103dca:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcd:	ba 01 00 00 00       	mov    $0x1,%edx
80103dd2:	89 c1                	mov    %eax,%ecx
80103dd4:	d3 e2                	shl    %cl,%edx
80103dd6:	89 d0                	mov    %edx,%eax
80103dd8:	f7 d0                	not    %eax
80103dda:	89 c2                	mov    %eax,%edx
80103ddc:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103de3:	21 d0                	and    %edx,%eax
80103de5:	0f b7 c0             	movzwl %ax,%eax
80103de8:	89 04 24             	mov    %eax,(%esp)
80103deb:	e8 89 ff ff ff       	call   80103d79 <picsetmask>
}
80103df0:	c9                   	leave  
80103df1:	c3                   	ret    

80103df2 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103df2:	55                   	push   %ebp
80103df3:	89 e5                	mov    %esp,%ebp
80103df5:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103df8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103dff:	00 
80103e00:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e07:	e8 4f ff ff ff       	call   80103d5b <outb>
  outb(IO_PIC2+1, 0xFF);
80103e0c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e13:	00 
80103e14:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e1b:	e8 3b ff ff ff       	call   80103d5b <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e20:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e27:	00 
80103e28:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e2f:	e8 27 ff ff ff       	call   80103d5b <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e34:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e3b:	00 
80103e3c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e43:	e8 13 ff ff ff       	call   80103d5b <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e48:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e4f:	00 
80103e50:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e57:	e8 ff fe ff ff       	call   80103d5b <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e5c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e63:	00 
80103e64:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e6b:	e8 eb fe ff ff       	call   80103d5b <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e70:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e77:	00 
80103e78:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e7f:	e8 d7 fe ff ff       	call   80103d5b <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e84:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e8b:	00 
80103e8c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e93:	e8 c3 fe ff ff       	call   80103d5b <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103e98:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103e9f:	00 
80103ea0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ea7:	e8 af fe ff ff       	call   80103d5b <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103eac:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103eb3:	00 
80103eb4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ebb:	e8 9b fe ff ff       	call   80103d5b <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103ec0:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ec7:	00 
80103ec8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ecf:	e8 87 fe ff ff       	call   80103d5b <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ed4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103edb:	00 
80103edc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ee3:	e8 73 fe ff ff       	call   80103d5b <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ee8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103eef:	00 
80103ef0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ef7:	e8 5f fe ff ff       	call   80103d5b <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103efc:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f03:	00 
80103f04:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f0b:	e8 4b fe ff ff       	call   80103d5b <outb>

  if(irqmask != 0xFFFF)
80103f10:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f17:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f1b:	74 12                	je     80103f2f <picinit+0x13d>
    picsetmask(irqmask);
80103f1d:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f24:	0f b7 c0             	movzwl %ax,%eax
80103f27:	89 04 24             	mov    %eax,(%esp)
80103f2a:	e8 4a fe ff ff       	call   80103d79 <picsetmask>
}
80103f2f:	c9                   	leave  
80103f30:	c3                   	ret    

80103f31 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f31:	55                   	push   %ebp
80103f32:	89 e5                	mov    %esp,%ebp
80103f34:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f41:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f47:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f4a:	8b 10                	mov    (%eax),%edx
80103f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f51:	e8 e0 cf ff ff       	call   80100f36 <filealloc>
80103f56:	8b 55 08             	mov    0x8(%ebp),%edx
80103f59:	89 02                	mov    %eax,(%edx)
80103f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5e:	8b 00                	mov    (%eax),%eax
80103f60:	85 c0                	test   %eax,%eax
80103f62:	0f 84 c8 00 00 00    	je     80104030 <pipealloc+0xff>
80103f68:	e8 c9 cf ff ff       	call   80100f36 <filealloc>
80103f6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f70:	89 02                	mov    %eax,(%edx)
80103f72:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f75:	8b 00                	mov    (%eax),%eax
80103f77:	85 c0                	test   %eax,%eax
80103f79:	0f 84 b1 00 00 00    	je     80104030 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f7f:	e8 6e eb ff ff       	call   80102af2 <kalloc>
80103f84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f8b:	75 05                	jne    80103f92 <pipealloc+0x61>
    goto bad;
80103f8d:	e9 9e 00 00 00       	jmp    80104030 <pipealloc+0xff>
  p->readopen = 1;
80103f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f95:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f9c:	00 00 00 
  p->writeopen = 1;
80103f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fa2:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fa9:	00 00 00 
  p->nwrite = 0;
80103fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103faf:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fb6:	00 00 00 
  p->nread = 0;
80103fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fbc:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fc3:	00 00 00 
  initlock(&p->lock, "pipe");
80103fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc9:	c7 44 24 04 dc 89 10 	movl   $0x801089dc,0x4(%esp)
80103fd0:	80 
80103fd1:	89 04 24             	mov    %eax,(%esp)
80103fd4:	e8 bf 10 00 00       	call   80105098 <initlock>
  (*f0)->type = FD_PIPE;
80103fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdc:	8b 00                	mov    (%eax),%eax
80103fde:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe7:	8b 00                	mov    (%eax),%eax
80103fe9:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fed:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff0:	8b 00                	mov    (%eax),%eax
80103ff2:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff9:	8b 00                	mov    (%eax),%eax
80103ffb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ffe:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104001:	8b 45 0c             	mov    0xc(%ebp),%eax
80104004:	8b 00                	mov    (%eax),%eax
80104006:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010400c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010400f:	8b 00                	mov    (%eax),%eax
80104011:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104015:	8b 45 0c             	mov    0xc(%ebp),%eax
80104018:	8b 00                	mov    (%eax),%eax
8010401a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010401e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104021:	8b 00                	mov    (%eax),%eax
80104023:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104026:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104029:	b8 00 00 00 00       	mov    $0x0,%eax
8010402e:	eb 42                	jmp    80104072 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104030:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104034:	74 0b                	je     80104041 <pipealloc+0x110>
    kfree((char*)p);
80104036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104039:	89 04 24             	mov    %eax,(%esp)
8010403c:	e8 18 ea ff ff       	call   80102a59 <kfree>
  if(*f0)
80104041:	8b 45 08             	mov    0x8(%ebp),%eax
80104044:	8b 00                	mov    (%eax),%eax
80104046:	85 c0                	test   %eax,%eax
80104048:	74 0d                	je     80104057 <pipealloc+0x126>
    fileclose(*f0);
8010404a:	8b 45 08             	mov    0x8(%ebp),%eax
8010404d:	8b 00                	mov    (%eax),%eax
8010404f:	89 04 24             	mov    %eax,(%esp)
80104052:	e8 87 cf ff ff       	call   80100fde <fileclose>
  if(*f1)
80104057:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405a:	8b 00                	mov    (%eax),%eax
8010405c:	85 c0                	test   %eax,%eax
8010405e:	74 0d                	je     8010406d <pipealloc+0x13c>
    fileclose(*f1);
80104060:	8b 45 0c             	mov    0xc(%ebp),%eax
80104063:	8b 00                	mov    (%eax),%eax
80104065:	89 04 24             	mov    %eax,(%esp)
80104068:	e8 71 cf ff ff       	call   80100fde <fileclose>
  return -1;
8010406d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104072:	c9                   	leave  
80104073:	c3                   	ret    

80104074 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104074:	55                   	push   %ebp
80104075:	89 e5                	mov    %esp,%ebp
80104077:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
8010407a:	8b 45 08             	mov    0x8(%ebp),%eax
8010407d:	89 04 24             	mov    %eax,(%esp)
80104080:	e8 34 10 00 00       	call   801050b9 <acquire>
  if(writable){
80104085:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104089:	74 1f                	je     801040aa <pipeclose+0x36>
    p->writeopen = 0;
8010408b:	8b 45 08             	mov    0x8(%ebp),%eax
8010408e:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104095:	00 00 00 
    wakeup(&p->nread);
80104098:	8b 45 08             	mov    0x8(%ebp),%eax
8010409b:	05 34 02 00 00       	add    $0x234,%eax
801040a0:	89 04 24             	mov    %eax,(%esp)
801040a3:	e8 8b 0c 00 00       	call   80104d33 <wakeup>
801040a8:	eb 1d                	jmp    801040c7 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040b4:	00 00 00 
    wakeup(&p->nwrite);
801040b7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ba:	05 38 02 00 00       	add    $0x238,%eax
801040bf:	89 04 24             	mov    %eax,(%esp)
801040c2:	e8 6c 0c 00 00       	call   80104d33 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040c7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ca:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040d0:	85 c0                	test   %eax,%eax
801040d2:	75 25                	jne    801040f9 <pipeclose+0x85>
801040d4:	8b 45 08             	mov    0x8(%ebp),%eax
801040d7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040dd:	85 c0                	test   %eax,%eax
801040df:	75 18                	jne    801040f9 <pipeclose+0x85>
    release(&p->lock);
801040e1:	8b 45 08             	mov    0x8(%ebp),%eax
801040e4:	89 04 24             	mov    %eax,(%esp)
801040e7:	e8 2f 10 00 00       	call   8010511b <release>
    kfree((char*)p);
801040ec:	8b 45 08             	mov    0x8(%ebp),%eax
801040ef:	89 04 24             	mov    %eax,(%esp)
801040f2:	e8 62 e9 ff ff       	call   80102a59 <kfree>
801040f7:	eb 0b                	jmp    80104104 <pipeclose+0x90>
  } else
    release(&p->lock);
801040f9:	8b 45 08             	mov    0x8(%ebp),%eax
801040fc:	89 04 24             	mov    %eax,(%esp)
801040ff:	e8 17 10 00 00       	call   8010511b <release>
}
80104104:	c9                   	leave  
80104105:	c3                   	ret    

80104106 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104106:	55                   	push   %ebp
80104107:	89 e5                	mov    %esp,%ebp
80104109:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
8010410c:	8b 45 08             	mov    0x8(%ebp),%eax
8010410f:	89 04 24             	mov    %eax,(%esp)
80104112:	e8 a2 0f 00 00       	call   801050b9 <acquire>
  for(i = 0; i < n; i++){
80104117:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010411e:	e9 a6 00 00 00       	jmp    801041c9 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104123:	eb 57                	jmp    8010417c <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80104125:	8b 45 08             	mov    0x8(%ebp),%eax
80104128:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010412e:	85 c0                	test   %eax,%eax
80104130:	74 0d                	je     8010413f <pipewrite+0x39>
80104132:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104138:	8b 40 24             	mov    0x24(%eax),%eax
8010413b:	85 c0                	test   %eax,%eax
8010413d:	74 15                	je     80104154 <pipewrite+0x4e>
        release(&p->lock);
8010413f:	8b 45 08             	mov    0x8(%ebp),%eax
80104142:	89 04 24             	mov    %eax,(%esp)
80104145:	e8 d1 0f 00 00       	call   8010511b <release>
        return -1;
8010414a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010414f:	e9 9f 00 00 00       	jmp    801041f3 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104154:	8b 45 08             	mov    0x8(%ebp),%eax
80104157:	05 34 02 00 00       	add    $0x234,%eax
8010415c:	89 04 24             	mov    %eax,(%esp)
8010415f:	e8 cf 0b 00 00       	call   80104d33 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104164:	8b 45 08             	mov    0x8(%ebp),%eax
80104167:	8b 55 08             	mov    0x8(%ebp),%edx
8010416a:	81 c2 38 02 00 00    	add    $0x238,%edx
80104170:	89 44 24 04          	mov    %eax,0x4(%esp)
80104174:	89 14 24             	mov    %edx,(%esp)
80104177:	e8 dc 0a 00 00       	call   80104c58 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104185:	8b 45 08             	mov    0x8(%ebp),%eax
80104188:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010418e:	05 00 02 00 00       	add    $0x200,%eax
80104193:	39 c2                	cmp    %eax,%edx
80104195:	74 8e                	je     80104125 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104197:	8b 45 08             	mov    0x8(%ebp),%eax
8010419a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041a0:	8d 48 01             	lea    0x1(%eax),%ecx
801041a3:	8b 55 08             	mov    0x8(%ebp),%edx
801041a6:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801041ac:	25 ff 01 00 00       	and    $0x1ff,%eax
801041b1:	89 c1                	mov    %eax,%ecx
801041b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b9:	01 d0                	add    %edx,%eax
801041bb:	0f b6 10             	movzbl (%eax),%edx
801041be:	8b 45 08             	mov    0x8(%ebp),%eax
801041c1:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041cc:	3b 45 10             	cmp    0x10(%ebp),%eax
801041cf:	0f 8c 4e ff ff ff    	jl     80104123 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041d5:	8b 45 08             	mov    0x8(%ebp),%eax
801041d8:	05 34 02 00 00       	add    $0x234,%eax
801041dd:	89 04 24             	mov    %eax,(%esp)
801041e0:	e8 4e 0b 00 00       	call   80104d33 <wakeup>
  release(&p->lock);
801041e5:	8b 45 08             	mov    0x8(%ebp),%eax
801041e8:	89 04 24             	mov    %eax,(%esp)
801041eb:	e8 2b 0f 00 00       	call   8010511b <release>
  return n;
801041f0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041f3:	c9                   	leave  
801041f4:	c3                   	ret    

801041f5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041f5:	55                   	push   %ebp
801041f6:	89 e5                	mov    %esp,%ebp
801041f8:	53                   	push   %ebx
801041f9:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041fc:	8b 45 08             	mov    0x8(%ebp),%eax
801041ff:	89 04 24             	mov    %eax,(%esp)
80104202:	e8 b2 0e 00 00       	call   801050b9 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104207:	eb 3a                	jmp    80104243 <piperead+0x4e>
    if(proc->killed){
80104209:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010420f:	8b 40 24             	mov    0x24(%eax),%eax
80104212:	85 c0                	test   %eax,%eax
80104214:	74 15                	je     8010422b <piperead+0x36>
      release(&p->lock);
80104216:	8b 45 08             	mov    0x8(%ebp),%eax
80104219:	89 04 24             	mov    %eax,(%esp)
8010421c:	e8 fa 0e 00 00       	call   8010511b <release>
      return -1;
80104221:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104226:	e9 b5 00 00 00       	jmp    801042e0 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010422b:	8b 45 08             	mov    0x8(%ebp),%eax
8010422e:	8b 55 08             	mov    0x8(%ebp),%edx
80104231:	81 c2 34 02 00 00    	add    $0x234,%edx
80104237:	89 44 24 04          	mov    %eax,0x4(%esp)
8010423b:	89 14 24             	mov    %edx,(%esp)
8010423e:	e8 15 0a 00 00       	call   80104c58 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010424c:	8b 45 08             	mov    0x8(%ebp),%eax
8010424f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104255:	39 c2                	cmp    %eax,%edx
80104257:	75 0d                	jne    80104266 <piperead+0x71>
80104259:	8b 45 08             	mov    0x8(%ebp),%eax
8010425c:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104262:	85 c0                	test   %eax,%eax
80104264:	75 a3                	jne    80104209 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010426d:	eb 4b                	jmp    801042ba <piperead+0xc5>
    if(p->nread == p->nwrite)
8010426f:	8b 45 08             	mov    0x8(%ebp),%eax
80104272:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104278:	8b 45 08             	mov    0x8(%ebp),%eax
8010427b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104281:	39 c2                	cmp    %eax,%edx
80104283:	75 02                	jne    80104287 <piperead+0x92>
      break;
80104285:	eb 3b                	jmp    801042c2 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104287:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010428a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010428d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104290:	8b 45 08             	mov    0x8(%ebp),%eax
80104293:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104299:	8d 48 01             	lea    0x1(%eax),%ecx
8010429c:	8b 55 08             	mov    0x8(%ebp),%edx
8010429f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801042a5:	25 ff 01 00 00       	and    $0x1ff,%eax
801042aa:	89 c2                	mov    %eax,%edx
801042ac:	8b 45 08             	mov    0x8(%ebp),%eax
801042af:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801042b4:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042bd:	3b 45 10             	cmp    0x10(%ebp),%eax
801042c0:	7c ad                	jl     8010426f <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	05 38 02 00 00       	add    $0x238,%eax
801042ca:	89 04 24             	mov    %eax,(%esp)
801042cd:	e8 61 0a 00 00       	call   80104d33 <wakeup>
  release(&p->lock);
801042d2:	8b 45 08             	mov    0x8(%ebp),%eax
801042d5:	89 04 24             	mov    %eax,(%esp)
801042d8:	e8 3e 0e 00 00       	call   8010511b <release>
  return i;
801042dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042e0:	83 c4 24             	add    $0x24,%esp
801042e3:	5b                   	pop    %ebx
801042e4:	5d                   	pop    %ebp
801042e5:	c3                   	ret    

801042e6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042e6:	55                   	push   %ebp
801042e7:	89 e5                	mov    %esp,%ebp
801042e9:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042ec:	9c                   	pushf  
801042ed:	58                   	pop    %eax
801042ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801042f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801042f4:	c9                   	leave  
801042f5:	c3                   	ret    

801042f6 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042f6:	55                   	push   %ebp
801042f7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042f9:	fb                   	sti    
}
801042fa:	5d                   	pop    %ebp
801042fb:	c3                   	ret    

801042fc <cas>:
  asm volatile("movl %0,%%cr3" : : "r" (val));
}

static inline int 
cas(volatile int *addr, int expected, int newval)
{
801042fc:	55                   	push   %ebp
801042fd:	89 e5                	mov    %esp,%ebp
801042ff:	56                   	push   %esi
80104300:	53                   	push   %ebx
80104301:	83 ec 10             	sub    $0x10,%esp
	int result = 0;
80104304:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	
    asm volatile(
8010430b:	8b 55 08             	mov    0x8(%ebp),%edx
8010430e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104311:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104314:	8b 75 08             	mov    0x8(%ebp),%esi
80104317:	89 cb                	mov    %ecx,%ebx
80104319:	f0 0f b1 1a          	lock cmpxchg %ebx,(%edx)
8010431d:	0f 94 c0             	sete   %al
80104320:	0f b6 c0             	movzbl %al,%eax
80104323:	89 45 f4             	mov    %eax,-0xc(%ebp)
        "movzx %%al, %1\n\t" 		// store result of comparison in 'result'
        : "+m" (*addr), "=r" (result)
        : "a" (expected), "b" (newval)
        : "cc");

    return result;
80104326:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104329:	83 c4 10             	add    $0x10,%esp
8010432c:	5b                   	pop    %ebx
8010432d:	5e                   	pop    %esi
8010432e:	5d                   	pop    %ebp
8010432f:	c3                   	ret    

80104330 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104330:	55                   	push   %ebp
80104331:	89 e5                	mov    %esp,%ebp
80104333:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104336:	c7 44 24 04 e1 89 10 	movl   $0x801089e1,0x4(%esp)
8010433d:	80 
8010433e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104345:	e8 4e 0d 00 00       	call   80105098 <initlock>
}
8010434a:	c9                   	leave  
8010434b:	c3                   	ret    

8010434c <allocpid>:

int 
allocpid(void) 
{
8010434c:	55                   	push   %ebp
8010434d:	89 e5                	mov    %esp,%ebp
8010434f:	83 ec 1c             	sub    $0x1c,%esp
  //acquire(&ptable.lock);
  //pid = nextpid++;
  //release(&ptable.lock);

  do{
    pid = nextpid;
80104352:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104357:	89 45 fc             	mov    %eax,-0x4(%ebp)
  } while(!cas(&nextpid, pid, pid+1));
8010435a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010435d:	83 c0 01             	add    $0x1,%eax
80104360:	89 44 24 08          	mov    %eax,0x8(%esp)
80104364:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104367:	89 44 24 04          	mov    %eax,0x4(%esp)
8010436b:	c7 04 24 04 b0 10 80 	movl   $0x8010b004,(%esp)
80104372:	e8 85 ff ff ff       	call   801042fc <cas>
80104377:	85 c0                	test   %eax,%eax
80104379:	74 d7                	je     80104352 <allocpid+0x6>
  return pid + 1;
8010437b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010437e:	83 c0 01             	add    $0x1,%eax
}
80104381:	c9                   	leave  
80104382:	c3                   	ret    

80104383 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104383:	55                   	push   %ebp
80104384:	89 e5                	mov    %esp,%ebp
80104386:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  //acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104389:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104390:	eb 4c                	jmp    801043de <allocproc+0x5b>
    //if(p->state == UNUSED)
    if(cas(&p->state, UNUSED, EMBRYO))
80104392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104395:	83 c0 0c             	add    $0xc,%eax
80104398:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010439f:	00 
801043a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043a7:	00 
801043a8:	89 04 24             	mov    %eax,(%esp)
801043ab:	e8 4c ff ff ff       	call   801042fc <cas>
801043b0:	85 c0                	test   %eax,%eax
801043b2:	74 23                	je     801043d7 <allocproc+0x54>
      goto found;
801043b4:	90                   	nop

found:
  //p->state = EMBRYO;  
  //release(&ptable.lock);

  p->pid = allocpid();
801043b5:	e8 92 ff ff ff       	call   8010434c <allocpid>
801043ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043bd:	89 42 10             	mov    %eax,0x10(%edx)

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043c0:	e8 2d e7 ff ff       	call   80102af2 <kalloc>
801043c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043c8:	89 42 08             	mov    %eax,0x8(%edx)
801043cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ce:	8b 40 08             	mov    0x8(%eax),%eax
801043d1:	85 c0                	test   %eax,%eax
801043d3:	75 30                	jne    80104405 <allocproc+0x82>
801043d5:	eb 1a                	jmp    801043f1 <allocproc+0x6e>
{
  struct proc *p;
  char *sp;

  //acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043d7:	81 45 f4 60 01 00 00 	addl   $0x160,-0xc(%ebp)
801043de:	81 7d f4 94 81 11 80 	cmpl   $0x80118194,-0xc(%ebp)
801043e5:	72 ab                	jb     80104392 <allocproc+0xf>
    //if(p->state == UNUSED)
    if(cas(&p->state, UNUSED, EMBRYO))
      goto found;
  //release(&ptable.lock);
  return 0;
801043e7:	b8 00 00 00 00       	mov    $0x0,%eax
801043ec:	e9 ac 00 00 00       	jmp    8010449d <allocproc+0x11a>

  p->pid = allocpid();

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043fb:	b8 00 00 00 00       	mov    $0x0,%eax
80104400:	e9 98 00 00 00       	jmp    8010449d <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
80104405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104408:	8b 40 08             	mov    0x8(%eax),%eax
8010440b:	05 00 10 00 00       	add    $0x1000,%eax
80104410:	89 45 ec             	mov    %eax,-0x14(%ebp)
  

  //initialize cstack
  struct cstackframe *csf;
  for(csf = p->pending_signals.frames; csf < &p->pending_signals.frames[MAX_CSTACK_FRAMES]; csf++) {
80104413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104416:	83 c0 7c             	add    $0x7c,%eax
80104419:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010441c:	eb 0e                	jmp    8010442c <allocproc+0xa9>
    csf->used = 0;
8010441e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104421:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  sp = p->kstack + KSTACKSIZE;
  

  //initialize cstack
  struct cstackframe *csf;
  for(csf = p->pending_signals.frames; csf < &p->pending_signals.frames[MAX_CSTACK_FRAMES]; csf++) {
80104428:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
8010442c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442f:	05 44 01 00 00       	add    $0x144,%eax
80104434:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104437:	77 e5                	ja     8010441e <allocproc+0x9b>
    csf->used = 0;
  }
  p->pending_signals.head = 0;
80104439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443c:	c7 80 44 01 00 00 00 	movl   $0x0,0x144(%eax)
80104443:	00 00 00 

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104446:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
8010444a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104450:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104453:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80104457:	ba a9 67 10 80       	mov    $0x801067a9,%edx
8010445c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010445f:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104461:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80104465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104468:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010446b:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010446e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104471:	8b 40 1c             	mov    0x1c(%eax),%eax
80104474:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010447b:	00 
8010447c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104483:	00 
80104484:	89 04 24             	mov    %eax,(%esp)
80104487:	e8 81 0e 00 00       	call   8010530d <memset>
  p->context->eip = (uint)forkret;
8010448c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104492:	ba 2c 4c 10 80       	mov    $0x80104c2c,%edx
80104497:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010449a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010449d:	c9                   	leave  
8010449e:	c3                   	ret    

8010449f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010449f:	55                   	push   %ebp
801044a0:	89 e5                	mov    %esp,%ebp
801044a2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044a5:	e8 d9 fe ff ff       	call   80104383 <allocproc>
801044aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b0:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
801044b5:	e8 e3 39 00 00       	call   80107e9d <setupkvm>
801044ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044bd:	89 42 04             	mov    %eax,0x4(%edx)
801044c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c3:	8b 40 04             	mov    0x4(%eax),%eax
801044c6:	85 c0                	test   %eax,%eax
801044c8:	75 0c                	jne    801044d6 <userinit+0x37>
    panic("userinit: out of memory?");
801044ca:	c7 04 24 e8 89 10 80 	movl   $0x801089e8,(%esp)
801044d1:	e8 64 c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044d6:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044de:	8b 40 04             	mov    0x4(%eax),%eax
801044e1:	89 54 24 08          	mov    %edx,0x8(%esp)
801044e5:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044ec:	80 
801044ed:	89 04 24             	mov    %eax,(%esp)
801044f0:	e8 00 3c 00 00       	call   801080f5 <inituvm>
  p->sz = PGSIZE;
801044f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104501:	8b 40 18             	mov    0x18(%eax),%eax
80104504:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010450b:	00 
8010450c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104513:	00 
80104514:	89 04 24             	mov    %eax,(%esp)
80104517:	e8 f1 0d 00 00       	call   8010530d <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010451c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451f:	8b 40 18             	mov    0x18(%eax),%eax
80104522:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452b:	8b 40 18             	mov    0x18(%eax),%eax
8010452e:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104537:	8b 40 18             	mov    0x18(%eax),%eax
8010453a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453d:	8b 52 18             	mov    0x18(%edx),%edx
80104540:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104544:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454b:	8b 40 18             	mov    0x18(%eax),%eax
8010454e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104551:	8b 52 18             	mov    0x18(%edx),%edx
80104554:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104558:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010455c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455f:	8b 40 18             	mov    0x18(%eax),%eax
80104562:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456c:	8b 40 18             	mov    0x18(%eax),%eax
8010456f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104579:	8b 40 18             	mov    0x18(%eax),%eax
8010457c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104586:	83 c0 6c             	add    $0x6c,%eax
80104589:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104590:	00 
80104591:	c7 44 24 04 01 8a 10 	movl   $0x80108a01,0x4(%esp)
80104598:	80 
80104599:	89 04 24             	mov    %eax,(%esp)
8010459c:	e8 8c 0f 00 00       	call   8010552d <safestrcpy>
  p->cwd = namei("/");
801045a1:	c7 04 24 0a 8a 10 80 	movl   $0x80108a0a,(%esp)
801045a8:	e8 69 de ff ff       	call   80102416 <namei>
801045ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b0:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801045b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045bd:	c9                   	leave  
801045be:	c3                   	ret    

801045bf <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045bf:	55                   	push   %ebp
801045c0:	89 e5                	mov    %esp,%ebp
801045c2:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045cb:	8b 00                	mov    (%eax),%eax
801045cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045d4:	7e 34                	jle    8010460a <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045d6:	8b 55 08             	mov    0x8(%ebp),%edx
801045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dc:	01 c2                	add    %eax,%edx
801045de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045e4:	8b 40 04             	mov    0x4(%eax),%eax
801045e7:	89 54 24 08          	mov    %edx,0x8(%esp)
801045eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ee:	89 54 24 04          	mov    %edx,0x4(%esp)
801045f2:	89 04 24             	mov    %eax,(%esp)
801045f5:	e8 71 3c 00 00       	call   8010826b <allocuvm>
801045fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104601:	75 41                	jne    80104644 <growproc+0x85>
      return -1;
80104603:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104608:	eb 58                	jmp    80104662 <growproc+0xa3>
  } else if(n < 0){
8010460a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010460e:	79 34                	jns    80104644 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104610:	8b 55 08             	mov    0x8(%ebp),%edx
80104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104616:	01 c2                	add    %eax,%edx
80104618:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010461e:	8b 40 04             	mov    0x4(%eax),%eax
80104621:	89 54 24 08          	mov    %edx,0x8(%esp)
80104625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104628:	89 54 24 04          	mov    %edx,0x4(%esp)
8010462c:	89 04 24             	mov    %eax,(%esp)
8010462f:	e8 11 3d 00 00       	call   80108345 <deallocuvm>
80104634:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104637:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010463b:	75 07                	jne    80104644 <growproc+0x85>
      return -1;
8010463d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104642:	eb 1e                	jmp    80104662 <growproc+0xa3>
  }
  proc->sz = sz;
80104644:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010464a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464d:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010464f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104655:	89 04 24             	mov    %eax,(%esp)
80104658:	e8 31 39 00 00       	call   80107f8e <switchuvm>
  return 0;
8010465d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104662:	c9                   	leave  
80104663:	c3                   	ret    

80104664 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104664:	55                   	push   %ebp
80104665:	89 e5                	mov    %esp,%ebp
80104667:	57                   	push   %edi
80104668:	56                   	push   %esi
80104669:	53                   	push   %ebx
8010466a:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010466d:	e8 11 fd ff ff       	call   80104383 <allocproc>
80104672:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104675:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104679:	75 0a                	jne    80104685 <fork+0x21>
    return -1;
8010467b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104680:	e9 67 01 00 00       	jmp    801047ec <fork+0x188>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104685:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468b:	8b 10                	mov    (%eax),%edx
8010468d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104693:	8b 40 04             	mov    0x4(%eax),%eax
80104696:	89 54 24 04          	mov    %edx,0x4(%esp)
8010469a:	89 04 24             	mov    %eax,(%esp)
8010469d:	e8 3f 3e 00 00       	call   801084e1 <copyuvm>
801046a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046a5:	89 42 04             	mov    %eax,0x4(%edx)
801046a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ab:	8b 40 04             	mov    0x4(%eax),%eax
801046ae:	85 c0                	test   %eax,%eax
801046b0:	75 2c                	jne    801046de <fork+0x7a>
    kfree(np->kstack);
801046b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b5:	8b 40 08             	mov    0x8(%eax),%eax
801046b8:	89 04 24             	mov    %eax,(%esp)
801046bb:	e8 99 e3 ff ff       	call   80102a59 <kfree>
    np->kstack = 0;
801046c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046cd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d9:	e9 0e 01 00 00       	jmp    801047ec <fork+0x188>
  }
  np->sz = proc->sz;
801046de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e4:	8b 10                	mov    (%eax),%edx
801046e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e9:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046eb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f5:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fb:	8b 50 18             	mov    0x18(%eax),%edx
801046fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104704:	8b 40 18             	mov    0x18(%eax),%eax
80104707:	89 c3                	mov    %eax,%ebx
80104709:	b8 13 00 00 00       	mov    $0x13,%eax
8010470e:	89 d7                	mov    %edx,%edi
80104710:	89 de                	mov    %ebx,%esi
80104712:	89 c1                	mov    %eax,%ecx
80104714:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104716:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104719:	8b 40 18             	mov    0x18(%eax),%eax
8010471c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104723:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010472a:	eb 3d                	jmp    80104769 <fork+0x105>
    if(proc->ofile[i])
8010472c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104732:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104735:	83 c2 08             	add    $0x8,%edx
80104738:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010473c:	85 c0                	test   %eax,%eax
8010473e:	74 25                	je     80104765 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104740:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104746:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104749:	83 c2 08             	add    $0x8,%edx
8010474c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104750:	89 04 24             	mov    %eax,(%esp)
80104753:	e8 3e c8 ff ff       	call   80100f96 <filedup>
80104758:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010475b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010475e:	83 c1 08             	add    $0x8,%ecx
80104761:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104765:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104769:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010476d:	7e bd                	jle    8010472c <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010476f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104775:	8b 40 68             	mov    0x68(%eax),%eax
80104778:	89 04 24             	mov    %eax,(%esp)
8010477b:	e8 b9 d0 ff ff       	call   80101839 <idup>
80104780:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104783:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104786:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010478c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010478f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104792:	83 c0 6c             	add    $0x6c,%eax
80104795:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010479c:	00 
8010479d:	89 54 24 04          	mov    %edx,0x4(%esp)
801047a1:	89 04 24             	mov    %eax,(%esp)
801047a4:	e8 84 0d 00 00       	call   8010552d <safestrcpy>
  np->sighandler = proc->sighandler; 
801047a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047af:	8b 90 5c 01 00 00    	mov    0x15c(%eax),%edx
801047b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b8:	89 90 5c 01 00 00    	mov    %edx,0x15c(%eax)
  //copy signal handler

  pid = np->pid;
801047be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c1:	8b 40 10             	mov    0x10(%eax),%eax
801047c4:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801047c7:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047ce:	e8 e6 08 00 00       	call   801050b9 <acquire>
  np->state = RUNNABLE;
801047d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047dd:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047e4:	e8 32 09 00 00       	call   8010511b <release>
  
  return pid;
801047e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047ec:	83 c4 2c             	add    $0x2c,%esp
801047ef:	5b                   	pop    %ebx
801047f0:	5e                   	pop    %esi
801047f1:	5f                   	pop    %edi
801047f2:	5d                   	pop    %ebp
801047f3:	c3                   	ret    

801047f4 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047f4:	55                   	push   %ebp
801047f5:	89 e5                	mov    %esp,%ebp
801047f7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047fa:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104801:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104806:	39 c2                	cmp    %eax,%edx
80104808:	75 0c                	jne    80104816 <exit+0x22>
    panic("init exiting");
8010480a:	c7 04 24 0c 8a 10 80 	movl   $0x80108a0c,(%esp)
80104811:	e8 24 bd ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104816:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010481d:	eb 44                	jmp    80104863 <exit+0x6f>
    if(proc->ofile[fd]){
8010481f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104825:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104828:	83 c2 08             	add    $0x8,%edx
8010482b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010482f:	85 c0                	test   %eax,%eax
80104831:	74 2c                	je     8010485f <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104833:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104839:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010483c:	83 c2 08             	add    $0x8,%edx
8010483f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104843:	89 04 24             	mov    %eax,(%esp)
80104846:	e8 93 c7 ff ff       	call   80100fde <fileclose>
      proc->ofile[fd] = 0;
8010484b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104851:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104854:	83 c2 08             	add    $0x8,%edx
80104857:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010485e:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010485f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104863:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104867:	7e b6                	jle    8010481f <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104869:	e8 b2 eb ff ff       	call   80103420 <begin_op>
  iput(proc->cwd);
8010486e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104874:	8b 40 68             	mov    0x68(%eax),%eax
80104877:	89 04 24             	mov    %eax,(%esp)
8010487a:	e8 9f d1 ff ff       	call   80101a1e <iput>
  end_op();
8010487f:	e8 20 ec ff ff       	call   801034a4 <end_op>
  proc->cwd = 0;
80104884:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104891:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104898:	e8 1c 08 00 00       	call   801050b9 <acquire>

  proc->state = ZOMBIE;
8010489d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801048aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b0:	8b 40 14             	mov    0x14(%eax),%eax
801048b3:	89 04 24             	mov    %eax,(%esp)
801048b6:	e8 2b 04 00 00       	call   80104ce6 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048bb:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801048c2:	eb 3b                	jmp    801048ff <exit+0x10b>
    if(p->parent == proc){
801048c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c7:	8b 50 14             	mov    0x14(%eax),%edx
801048ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d0:	39 c2                	cmp    %eax,%edx
801048d2:	75 24                	jne    801048f8 <exit+0x104>
      p->parent = initproc;
801048d4:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801048da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048dd:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e3:	8b 40 0c             	mov    0xc(%eax),%eax
801048e6:	83 f8 05             	cmp    $0x5,%eax
801048e9:	75 0d                	jne    801048f8 <exit+0x104>
        wakeup1(initproc);
801048eb:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048f0:	89 04 24             	mov    %eax,(%esp)
801048f3:	e8 ee 03 00 00       	call   80104ce6 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048f8:	81 45 f4 60 01 00 00 	addl   $0x160,-0xc(%ebp)
801048ff:	81 7d f4 94 81 11 80 	cmpl   $0x80118194,-0xc(%ebp)
80104906:	72 bc                	jb     801048c4 <exit+0xd0>
    }
  }

  // Jump into the scheduler, never to return.
  
  sched();
80104908:	e8 3b 02 00 00       	call   80104b48 <sched>
  panic("zombie exit");
8010490d:	c7 04 24 19 8a 10 80 	movl   $0x80108a19,(%esp)
80104914:	e8 21 bc ff ff       	call   8010053a <panic>

80104919 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104919:	55                   	push   %ebp
8010491a:	89 e5                	mov    %esp,%ebp
8010491c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010491f:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104926:	e8 8e 07 00 00       	call   801050b9 <acquire>
  for(;;){
    proc->chan = (int)proc;
8010492b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104931:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104938:	89 50 20             	mov    %edx,0x20(%eax)
    proc->state = SLEEPING;    
8010493b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104941:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
    // Scan through table looking for zombie children.
    havekids = 0;
80104948:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010494f:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104956:	e9 84 00 00 00       	jmp    801049df <wait+0xc6>
      if(p->parent != proc)
8010495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495e:	8b 50 14             	mov    0x14(%eax),%edx
80104961:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104967:	39 c2                	cmp    %eax,%edx
80104969:	74 02                	je     8010496d <wait+0x54>
        continue;
8010496b:	eb 6b                	jmp    801049d8 <wait+0xbf>
      havekids = 1;
8010496d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104977:	8b 40 0c             	mov    0xc(%eax),%eax
8010497a:	83 f8 05             	cmp    $0x5,%eax
8010497d:	75 59                	jne    801049d8 <wait+0xbf>
        // Found one.
        pid = p->pid;
8010497f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104982:	8b 40 10             	mov    0x10(%eax),%eax
80104985:	89 45 ec             	mov    %eax,-0x14(%ebp)
        p->state = UNUSED;
80104988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104995:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010499c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a9:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)

        proc->chan = 0;
801049ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b3:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
        proc->state = RUNNING;
801049ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c0:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        release(&ptable.lock);
801049c7:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049ce:	e8 48 07 00 00       	call   8010511b <release>
        return pid;
801049d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049d6:	eb 5e                	jmp    80104a36 <wait+0x11d>
  for(;;){
    proc->chan = (int)proc;
    proc->state = SLEEPING;    
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d8:	81 45 f4 60 01 00 00 	addl   $0x160,-0xc(%ebp)
801049df:	81 7d f4 94 81 11 80 	cmpl   $0x80118194,-0xc(%ebp)
801049e6:	0f 82 6f ff ff ff    	jb     8010495b <wait+0x42>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049f0:	74 0d                	je     801049ff <wait+0xe6>
801049f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f8:	8b 40 24             	mov    0x24(%eax),%eax
801049fb:	85 c0                	test   %eax,%eax
801049fd:	74 2d                	je     80104a2c <wait+0x113>
      proc->chan = 0;
801049ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a05:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      proc->state = RUNNING;      
80104a0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a12:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      release(&ptable.lock);
80104a19:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a20:	e8 f6 06 00 00       	call   8010511b <release>
      return -1;
80104a25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a2a:	eb 0a                	jmp    80104a36 <wait+0x11d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sched();
80104a2c:	e8 17 01 00 00       	call   80104b48 <sched>
  }
80104a31:	e9 f5 fe ff ff       	jmp    8010492b <wait+0x12>
}
80104a36:	c9                   	leave  
80104a37:	c3                   	ret    

80104a38 <freeproc>:

void 
freeproc(struct proc *p)
{
80104a38:	55                   	push   %ebp
80104a39:	89 e5                	mov    %esp,%ebp
80104a3b:	83 ec 18             	sub    $0x18,%esp
  if (!p || p->state != ZOMBIE)
80104a3e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a42:	74 0b                	je     80104a4f <freeproc+0x17>
80104a44:	8b 45 08             	mov    0x8(%ebp),%eax
80104a47:	8b 40 0c             	mov    0xc(%eax),%eax
80104a4a:	83 f8 05             	cmp    $0x5,%eax
80104a4d:	74 0c                	je     80104a5b <freeproc+0x23>
    panic("freeproc not zombie");
80104a4f:	c7 04 24 25 8a 10 80 	movl   $0x80108a25,(%esp)
80104a56:	e8 df ba ff ff       	call   8010053a <panic>
  kfree(p->kstack);
80104a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5e:	8b 40 08             	mov    0x8(%eax),%eax
80104a61:	89 04 24             	mov    %eax,(%esp)
80104a64:	e8 f0 df ff ff       	call   80102a59 <kfree>
  p->kstack = 0;
80104a69:	8b 45 08             	mov    0x8(%ebp),%eax
80104a6c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  freevm(p->pgdir);
80104a73:	8b 45 08             	mov    0x8(%ebp),%eax
80104a76:	8b 40 04             	mov    0x4(%eax),%eax
80104a79:	89 04 24             	mov    %eax,(%esp)
80104a7c:	e8 80 39 00 00       	call   80108401 <freevm>
  p->killed = 0;
80104a81:	8b 45 08             	mov    0x8(%ebp),%eax
80104a84:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
  p->chan = 0;
80104a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8e:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
}
80104a95:	c9                   	leave  
80104a96:	c3                   	ret    

80104a97 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a97:	55                   	push   %ebp
80104a98:	89 e5                	mov    %esp,%ebp
80104a9a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a9d:	e8 54 f8 ff ff       	call   801042f6 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104aa2:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104aa9:	e8 0b 06 00 00       	call   801050b9 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aae:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104ab5:	eb 77                	jmp    80104b2e <scheduler+0x97>
      if(p->state != RUNNABLE)
80104ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aba:	8b 40 0c             	mov    0xc(%eax),%eax
80104abd:	83 f8 03             	cmp    $0x3,%eax
80104ac0:	74 02                	je     80104ac4 <scheduler+0x2d>
        continue;
80104ac2:	eb 63                	jmp    80104b27 <scheduler+0x90>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac7:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad0:	89 04 24             	mov    %eax,(%esp)
80104ad3:	e8 b6 34 00 00       	call   80107f8e <switchuvm>
      p->state = RUNNING;
80104ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adb:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104ae2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ae8:	8b 40 1c             	mov    0x1c(%eax),%eax
80104aeb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104af2:	83 c2 04             	add    $0x4,%edx
80104af5:	89 44 24 04          	mov    %eax,0x4(%esp)
80104af9:	89 14 24             	mov    %edx,(%esp)
80104afc:	e8 9d 0a 00 00       	call   8010559e <swtch>
      switchkvm();
80104b01:	e8 6b 34 00 00       	call   80107f71 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104b06:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104b0d:	00 00 00 00 
      if (p->state == ZOMBIE)
80104b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b14:	8b 40 0c             	mov    0xc(%eax),%eax
80104b17:	83 f8 05             	cmp    $0x5,%eax
80104b1a:	75 0b                	jne    80104b27 <scheduler+0x90>
        freeproc(p);
80104b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1f:	89 04 24             	mov    %eax,(%esp)
80104b22:	e8 11 ff ff ff       	call   80104a38 <freeproc>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b27:	81 45 f4 60 01 00 00 	addl   $0x160,-0xc(%ebp)
80104b2e:	81 7d f4 94 81 11 80 	cmpl   $0x80118194,-0xc(%ebp)
80104b35:	72 80                	jb     80104ab7 <scheduler+0x20>
      // It should have changed its p->state before coming back.
      proc = 0;
      if (p->state == ZOMBIE)
        freeproc(p);
    }
    release(&ptable.lock);
80104b37:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b3e:	e8 d8 05 00 00       	call   8010511b <release>

  }
80104b43:	e9 55 ff ff ff       	jmp    80104a9d <scheduler+0x6>

80104b48 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104b48:	55                   	push   %ebp
80104b49:	89 e5                	mov    %esp,%ebp
80104b4b:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104b4e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b55:	e8 89 06 00 00       	call   801051e3 <holding>
80104b5a:	85 c0                	test   %eax,%eax
80104b5c:	75 0c                	jne    80104b6a <sched+0x22>
    panic("sched ptable.lock");
80104b5e:	c7 04 24 39 8a 10 80 	movl   $0x80108a39,(%esp)
80104b65:	e8 d0 b9 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104b6a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b70:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104b76:	83 f8 01             	cmp    $0x1,%eax
80104b79:	74 0c                	je     80104b87 <sched+0x3f>
    panic("sched locks");
80104b7b:	c7 04 24 4b 8a 10 80 	movl   $0x80108a4b,(%esp)
80104b82:	e8 b3 b9 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104b87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b8d:	8b 40 0c             	mov    0xc(%eax),%eax
80104b90:	83 f8 04             	cmp    $0x4,%eax
80104b93:	75 0c                	jne    80104ba1 <sched+0x59>
    panic("sched running");
80104b95:	c7 04 24 57 8a 10 80 	movl   $0x80108a57,(%esp)
80104b9c:	e8 99 b9 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104ba1:	e8 40 f7 ff ff       	call   801042e6 <readeflags>
80104ba6:	25 00 02 00 00       	and    $0x200,%eax
80104bab:	85 c0                	test   %eax,%eax
80104bad:	74 0c                	je     80104bbb <sched+0x73>
    panic("sched interruptible");
80104baf:	c7 04 24 65 8a 10 80 	movl   $0x80108a65,(%esp)
80104bb6:	e8 7f b9 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104bbb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bc1:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104bc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104bca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bd0:	8b 40 04             	mov    0x4(%eax),%eax
80104bd3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bda:	83 c2 1c             	add    $0x1c,%edx
80104bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80104be1:	89 14 24             	mov    %edx,(%esp)
80104be4:	e8 b5 09 00 00       	call   8010559e <swtch>
  cpu->intena = intena;
80104be9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bef:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bf2:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104bf8:	c9                   	leave  
80104bf9:	c3                   	ret    

80104bfa <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104bfa:	55                   	push   %ebp
80104bfb:	89 e5                	mov    %esp,%ebp
80104bfd:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104c00:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c07:	e8 ad 04 00 00       	call   801050b9 <acquire>
  proc->state = RUNNABLE;
80104c0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c12:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104c19:	e8 2a ff ff ff       	call   80104b48 <sched>
  release(&ptable.lock);
80104c1e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c25:	e8 f1 04 00 00       	call   8010511b <release>
}
80104c2a:	c9                   	leave  
80104c2b:	c3                   	ret    

80104c2c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104c2c:	55                   	push   %ebp
80104c2d:	89 e5                	mov    %esp,%ebp
80104c2f:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104c32:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c39:	e8 dd 04 00 00       	call   8010511b <release>

  if (first) {
80104c3e:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104c43:	85 c0                	test   %eax,%eax
80104c45:	74 0f                	je     80104c56 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104c47:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104c4e:	00 00 00 
    initlog();
80104c51:	e8 bc e5 ff ff       	call   80103212 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104c56:	c9                   	leave  
80104c57:	c3                   	ret    

80104c58 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c58:	55                   	push   %ebp
80104c59:	89 e5                	mov    %esp,%ebp
80104c5b:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104c5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c64:	85 c0                	test   %eax,%eax
80104c66:	75 0c                	jne    80104c74 <sleep+0x1c>
    panic("sleep");
80104c68:	c7 04 24 79 8a 10 80 	movl   $0x80108a79,(%esp)
80104c6f:	e8 c6 b8 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104c74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c78:	75 0c                	jne    80104c86 <sleep+0x2e>
    panic("sleep without lk");
80104c7a:	c7 04 24 7f 8a 10 80 	movl   $0x80108a7f,(%esp)
80104c81:	e8 b4 b8 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c86:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104c8d:	74 17                	je     80104ca6 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c8f:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c96:	e8 1e 04 00 00       	call   801050b9 <acquire>
    release(lk);
80104c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c9e:	89 04 24             	mov    %eax,(%esp)
80104ca1:	e8 75 04 00 00       	call   8010511b <release>
  }

  // Go to sleep.
  proc->chan = (int)chan;
80104ca6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cac:	8b 55 08             	mov    0x8(%ebp),%edx
80104caf:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104cb2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cb8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)


  sched();
80104cbf:	e8 84 fe ff ff       	call   80104b48 <sched>

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104cc4:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104ccb:	74 17                	je     80104ce4 <sleep+0x8c>
    release(&ptable.lock);
80104ccd:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104cd4:	e8 42 04 00 00       	call   8010511b <release>
    acquire(lk);
80104cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cdc:	89 04 24             	mov    %eax,(%esp)
80104cdf:	e8 d5 03 00 00       	call   801050b9 <acquire>
  }
}
80104ce4:	c9                   	leave  
80104ce5:	c3                   	ret    

80104ce6 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ce6:	55                   	push   %ebp
80104ce7:	89 e5                	mov    %esp,%ebp
80104ce9:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cec:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104cf3:	eb 33                	jmp    80104d28 <wakeup1+0x42>
    if(p->state == SLEEPING && p->chan == (int)chan){
80104cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cf8:	8b 40 0c             	mov    0xc(%eax),%eax
80104cfb:	83 f8 02             	cmp    $0x2,%eax
80104cfe:	75 21                	jne    80104d21 <wakeup1+0x3b>
80104d00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d03:	8b 50 20             	mov    0x20(%eax),%edx
80104d06:	8b 45 08             	mov    0x8(%ebp),%eax
80104d09:	39 c2                	cmp    %eax,%edx
80104d0b:	75 14                	jne    80104d21 <wakeup1+0x3b>
      // Tidy up.
      p->chan = 0;
80104d0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d10:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      p->state = RUNNABLE;
80104d17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d1a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d21:	81 45 fc 60 01 00 00 	addl   $0x160,-0x4(%ebp)
80104d28:	81 7d fc 94 81 11 80 	cmpl   $0x80118194,-0x4(%ebp)
80104d2f:	72 c4                	jb     80104cf5 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == (int)chan){
      // Tidy up.
      p->chan = 0;
      p->state = RUNNABLE;
    }
}
80104d31:	c9                   	leave  
80104d32:	c3                   	ret    

80104d33 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d33:	55                   	push   %ebp
80104d34:	89 e5                	mov    %esp,%ebp
80104d36:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104d39:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d40:	e8 74 03 00 00       	call   801050b9 <acquire>
  wakeup1(chan);
80104d45:	8b 45 08             	mov    0x8(%ebp),%eax
80104d48:	89 04 24             	mov    %eax,(%esp)
80104d4b:	e8 96 ff ff ff       	call   80104ce6 <wakeup1>
  release(&ptable.lock);
80104d50:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d57:	e8 bf 03 00 00       	call   8010511b <release>
}
80104d5c:	c9                   	leave  
80104d5d:	c3                   	ret    

80104d5e <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d5e:	55                   	push   %ebp
80104d5f:	89 e5                	mov    %esp,%ebp
80104d61:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d64:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d6b:	e8 49 03 00 00       	call   801050b9 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d70:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104d77:	eb 50                	jmp    80104dc9 <kill+0x6b>
    if(p->pid == pid){
80104d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7c:	8b 40 10             	mov    0x10(%eax),%eax
80104d7f:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d82:	75 32                	jne    80104db6 <kill+0x58>
      p->killed = 1;
80104d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d87:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d91:	8b 40 0c             	mov    0xc(%eax),%eax
80104d94:	83 f8 02             	cmp    $0x2,%eax
80104d97:	75 0a                	jne    80104da3 <kill+0x45>
        p->state = RUNNABLE;
80104d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      
      release(&ptable.lock);
80104da3:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104daa:	e8 6c 03 00 00       	call   8010511b <release>
      return 0;
80104daf:	b8 00 00 00 00       	mov    $0x0,%eax
80104db4:	eb 21                	jmp    80104dd7 <kill+0x79>

      //int pid_test = p->pid;
      //cas(&pid_test, pid_test, 1);
      //cprintf("res = %d,    pid = %d", res, pid_test);
  
    release(&ptable.lock);
80104db6:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104dbd:	e8 59 03 00 00       	call   8010511b <release>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dc2:	81 45 f4 60 01 00 00 	addl   $0x160,-0xc(%ebp)
80104dc9:	81 7d f4 94 81 11 80 	cmpl   $0x80118194,-0xc(%ebp)
80104dd0:	72 a7                	jb     80104d79 <kill+0x1b>
      //cprintf("res = %d,    pid = %d", res, pid_test);
  
    release(&ptable.lock);
  }

  return -1;
80104dd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dd7:	c9                   	leave  
80104dd8:	c3                   	ret    

80104dd9 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104dd9:	55                   	push   %ebp
80104dda:	89 e5                	mov    %esp,%ebp
80104ddc:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ddf:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104de6:	e9 e3 00 00 00       	jmp    80104ece <procdump+0xf5>
    if(p->state == UNUSED)
80104deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dee:	8b 40 0c             	mov    0xc(%eax),%eax
80104df1:	85 c0                	test   %eax,%eax
80104df3:	75 05                	jne    80104dfa <procdump+0x21>
      continue;
80104df5:	e9 cd 00 00 00       	jmp    80104ec7 <procdump+0xee>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dfd:	8b 40 0c             	mov    0xc(%eax),%eax
80104e00:	85 c0                	test   %eax,%eax
80104e02:	78 2e                	js     80104e32 <procdump+0x59>
80104e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e07:	8b 40 0c             	mov    0xc(%eax),%eax
80104e0a:	83 f8 05             	cmp    $0x5,%eax
80104e0d:	77 23                	ja     80104e32 <procdump+0x59>
80104e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e12:	8b 40 0c             	mov    0xc(%eax),%eax
80104e15:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104e1c:	85 c0                	test   %eax,%eax
80104e1e:	74 12                	je     80104e32 <procdump+0x59>
      state = states[p->state];
80104e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e23:	8b 40 0c             	mov    0xc(%eax),%eax
80104e26:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104e2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e30:	eb 07                	jmp    80104e39 <procdump+0x60>
    else
      state = "???";
80104e32:	c7 45 ec 90 8a 10 80 	movl   $0x80108a90,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3c:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e42:	8b 40 10             	mov    0x10(%eax),%eax
80104e45:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104e49:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104e4c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104e50:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e54:	c7 04 24 94 8a 10 80 	movl   $0x80108a94,(%esp)
80104e5b:	e8 40 b5 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e63:	8b 40 0c             	mov    0xc(%eax),%eax
80104e66:	83 f8 02             	cmp    $0x2,%eax
80104e69:	75 50                	jne    80104ebb <procdump+0xe2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e6e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e71:	8b 40 0c             	mov    0xc(%eax),%eax
80104e74:	83 c0 08             	add    $0x8,%eax
80104e77:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104e7a:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e7e:	89 04 24             	mov    %eax,(%esp)
80104e81:	e8 e4 02 00 00       	call   8010516a <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104e86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e8d:	eb 1b                	jmp    80104eaa <procdump+0xd1>
        cprintf(" %p", pc[i]);
80104e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e92:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e96:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e9a:	c7 04 24 9d 8a 10 80 	movl   $0x80108a9d,(%esp)
80104ea1:	e8 fa b4 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104ea6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104eaa:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104eae:	7f 0b                	jg     80104ebb <procdump+0xe2>
80104eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104eb7:	85 c0                	test   %eax,%eax
80104eb9:	75 d4                	jne    80104e8f <procdump+0xb6>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104ebb:	c7 04 24 a1 8a 10 80 	movl   $0x80108aa1,(%esp)
80104ec2:	e8 d9 b4 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ec7:	81 45 f0 60 01 00 00 	addl   $0x160,-0x10(%ebp)
80104ece:	81 7d f0 94 81 11 80 	cmpl   $0x80118194,-0x10(%ebp)
80104ed5:	0f 82 10 ff ff ff    	jb     80104deb <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104edb:	c9                   	leave  
80104edc:	c3                   	ret    

80104edd <sigset>:

void* 
sigset(void* new_handler)
{
80104edd:	55                   	push   %ebp
80104ede:	89 e5                	mov    %esp,%ebp
80104ee0:	83 ec 10             	sub    $0x10,%esp
  sig_handler oldhandler = proc->sighandler; 
80104ee3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee9:	8b 80 5c 01 00 00    	mov    0x15c(%eax),%eax
80104eef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  proc->sighandler = new_handler;
80104ef2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ef8:	8b 55 08             	mov    0x8(%ebp),%edx
80104efb:	89 90 5c 01 00 00    	mov    %edx,0x15c(%eax)
  return oldhandler;
80104f01:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f04:	c9                   	leave  
80104f05:	c3                   	ret    

80104f06 <sigsend>:

int
sigsend(int dest_pid, int value)
{
80104f06:	55                   	push   %ebp
80104f07:	89 e5                	mov    %esp,%ebp
80104f09:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104f0c:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104f13:	eb 4d                	jmp    80104f62 <sigsend+0x5c>
    if (p->pid == dest_pid) {
80104f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f18:	8b 40 10             	mov    0x10(%eax),%eax
80104f1b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f1e:	75 3b                	jne    80104f5b <sigsend+0x55>
      //found dest_pid process
  
      if (push(&p->pending_signals, proc->pid, dest_pid, value)) //if push succeed return 0 otherwise return -1
80104f20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f26:	8b 40 10             	mov    0x10(%eax),%eax
80104f29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f2c:	8d 4a 7c             	lea    0x7c(%edx),%ecx
80104f2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f32:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f36:	8b 55 08             	mov    0x8(%ebp),%edx
80104f39:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f41:	89 0c 24             	mov    %ecx,(%esp)
80104f44:	e8 29 00 00 00       	call   80104f72 <push>
80104f49:	85 c0                	test   %eax,%eax
80104f4b:	74 07                	je     80104f54 <sigsend+0x4e>
        return 0;
80104f4d:	b8 00 00 00 00       	mov    $0x0,%eax
80104f52:	eb 1c                	jmp    80104f70 <sigsend+0x6a>
      else
        return -1;
80104f54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f59:	eb 15                	jmp    80104f70 <sigsend+0x6a>
int
sigsend(int dest_pid, int value)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104f5b:	81 45 f4 60 01 00 00 	addl   $0x160,-0xc(%ebp)
80104f62:	81 7d f4 94 81 11 80 	cmpl   $0x80118194,-0xc(%ebp)
80104f69:	72 aa                	jb     80104f15 <sigsend+0xf>
        return 0;
      else
        return -1;
    }
  }
  return -1;  
80104f6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f70:	c9                   	leave  
80104f71:	c3                   	ret    

80104f72 <push>:

// -------------- cstack implementation ------------
int 
push(struct cstack *cstack, int sender_pid, int recepient_pid, int value)
{
80104f72:	55                   	push   %ebp
80104f73:	89 e5                	mov    %esp,%ebp
80104f75:	83 ec 1c             	sub    $0x1c,%esp
  struct cstackframe *csf;
  for(csf = cstack->frames; csf < &cstack->frames[MAX_CSTACK_FRAMES]; csf++) {
80104f78:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f7e:	eb 48                	jmp    80104fc8 <push+0x56>
    if(cas(&csf->used, 0, 1)) 
80104f80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f83:	83 c0 0c             	add    $0xc,%eax
80104f86:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80104f8d:	00 
80104f8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104f95:	00 
80104f96:	89 04 24             	mov    %eax,(%esp)
80104f99:	e8 5e f3 ff ff       	call   801042fc <cas>
80104f9e:	85 c0                	test   %eax,%eax
80104fa0:	74 1d                	je     80104fbf <push+0x4d>
      goto found;
80104fa2:	90                   	nop
  return 0;

  //found an unused signal
  found:
  // copy values
  csf->sender_pid = sender_pid;
80104fa3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fa9:	89 10                	mov    %edx,(%eax)
  csf->recepient_pid = recepient_pid;
80104fab:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fae:	8b 55 10             	mov    0x10(%ebp),%edx
80104fb1:	89 50 04             	mov    %edx,0x4(%eax)
  csf->value = value;
80104fb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb7:	8b 55 14             	mov    0x14(%ebp),%edx
80104fba:	89 50 08             	mov    %edx,0x8(%eax)
80104fbd:	eb 20                	jmp    80104fdf <push+0x6d>
// -------------- cstack implementation ------------
int 
push(struct cstack *cstack, int sender_pid, int recepient_pid, int value)
{
  struct cstackframe *csf;
  for(csf = cstack->frames; csf < &cstack->frames[MAX_CSTACK_FRAMES]; csf++) {
80104fbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fc2:	83 c0 14             	add    $0x14,%eax
80104fc5:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcb:	8d 90 c8 00 00 00    	lea    0xc8(%eax),%edx
80104fd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fd4:	39 c2                	cmp    %eax,%edx
80104fd6:	77 a8                	ja     80104f80 <push+0xe>
    if(cas(&csf->used, 0, 1)) 
      goto found;
  }

  //stack is full
  return 0;
80104fd8:	b8 00 00 00 00       	mov    $0x0,%eax
80104fdd:	eb 3a                	jmp    80105019 <push+0xa7>
  csf->sender_pid = sender_pid;
  csf->recepient_pid = recepient_pid;
  csf->value = value;
  
  do {
    csf->next = cstack->head;
80104fdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fe2:	8b 55 08             	mov    0x8(%ebp),%edx
80104fe5:	8b 92 c8 00 00 00    	mov    0xc8(%edx),%edx
80104feb:	89 50 10             	mov    %edx,0x10(%eax)
  } while (!cas((int*)&(cstack->head), (int)csf->next, (int)&csf));
80104fee:	8d 55 fc             	lea    -0x4(%ebp),%edx
80104ff1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ff4:	8b 40 10             	mov    0x10(%eax),%eax
80104ff7:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ffa:	81 c1 c8 00 00 00    	add    $0xc8,%ecx
80105000:	89 54 24 08          	mov    %edx,0x8(%esp)
80105004:	89 44 24 04          	mov    %eax,0x4(%esp)
80105008:	89 0c 24             	mov    %ecx,(%esp)
8010500b:	e8 ec f2 ff ff       	call   801042fc <cas>
80105010:	85 c0                	test   %eax,%eax
80105012:	74 cb                	je     80104fdf <push+0x6d>

  return 1;
80105014:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105019:	c9                   	leave  
8010501a:	c3                   	ret    

8010501b <pop>:

struct cstackframe*
pop(struct cstack *cstack)
{
8010501b:	55                   	push   %ebp
8010501c:	89 e5                	mov    %esp,%ebp
8010501e:	83 ec 1c             	sub    $0x1c,%esp
  struct cstackframe *csf;
  struct cstackframe *next;
  
  do {
    csf = cstack->head;
80105021:	8b 45 08             	mov    0x8(%ebp),%eax
80105024:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
8010502a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (!csf)
8010502d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105031:	75 07                	jne    8010503a <pop+0x1f>
      return 0;
80105033:	b8 00 00 00 00       	mov    $0x0,%eax
80105038:	eb 26                	jmp    80105060 <pop+0x45>
  } while (!cas((int*)&(cstack->head), (int)csf, (int)&next));
8010503a:	8d 55 f8             	lea    -0x8(%ebp),%edx
8010503d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105040:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105043:	81 c1 c8 00 00 00    	add    $0xc8,%ecx
80105049:	89 54 24 08          	mov    %edx,0x8(%esp)
8010504d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105051:	89 0c 24             	mov    %ecx,(%esp)
80105054:	e8 a3 f2 ff ff       	call   801042fc <cas>
80105059:	85 c0                	test   %eax,%eax
8010505b:	74 c4                	je     80105021 <pop+0x6>
  
  //csf->used = 0;
  return csf;
8010505d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105060:	c9                   	leave  
80105061:	c3                   	ret    

80105062 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105062:	55                   	push   %ebp
80105063:	89 e5                	mov    %esp,%ebp
80105065:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105068:	9c                   	pushf  
80105069:	58                   	pop    %eax
8010506a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010506d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105070:	c9                   	leave  
80105071:	c3                   	ret    

80105072 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105072:	55                   	push   %ebp
80105073:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105075:	fa                   	cli    
}
80105076:	5d                   	pop    %ebp
80105077:	c3                   	ret    

80105078 <sti>:

static inline void
sti(void)
{
80105078:	55                   	push   %ebp
80105079:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010507b:	fb                   	sti    
}
8010507c:	5d                   	pop    %ebp
8010507d:	c3                   	ret    

8010507e <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010507e:	55                   	push   %ebp
8010507f:	89 e5                	mov    %esp,%ebp
80105081:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105084:	8b 55 08             	mov    0x8(%ebp),%edx
80105087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010508a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010508d:	f0 87 02             	lock xchg %eax,(%edx)
80105090:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105093:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105096:	c9                   	leave  
80105097:	c3                   	ret    

80105098 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105098:	55                   	push   %ebp
80105099:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010509b:	8b 45 08             	mov    0x8(%ebp),%eax
8010509e:	8b 55 0c             	mov    0xc(%ebp),%edx
801050a1:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801050a4:	8b 45 08             	mov    0x8(%ebp),%eax
801050a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050ad:	8b 45 08             	mov    0x8(%ebp),%eax
801050b0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050b7:	5d                   	pop    %ebp
801050b8:	c3                   	ret    

801050b9 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050b9:	55                   	push   %ebp
801050ba:	89 e5                	mov    %esp,%ebp
801050bc:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050bf:	e8 49 01 00 00       	call   8010520d <pushcli>
  if(holding(lk))
801050c4:	8b 45 08             	mov    0x8(%ebp),%eax
801050c7:	89 04 24             	mov    %eax,(%esp)
801050ca:	e8 14 01 00 00       	call   801051e3 <holding>
801050cf:	85 c0                	test   %eax,%eax
801050d1:	74 0c                	je     801050df <acquire+0x26>
    panic("acquire");
801050d3:	c7 04 24 cd 8a 10 80 	movl   $0x80108acd,(%esp)
801050da:	e8 5b b4 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050df:	90                   	nop
801050e0:	8b 45 08             	mov    0x8(%ebp),%eax
801050e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801050ea:	00 
801050eb:	89 04 24             	mov    %eax,(%esp)
801050ee:	e8 8b ff ff ff       	call   8010507e <xchg>
801050f3:	85 c0                	test   %eax,%eax
801050f5:	75 e9                	jne    801050e0 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050f7:	8b 45 08             	mov    0x8(%ebp),%eax
801050fa:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105101:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105104:	8b 45 08             	mov    0x8(%ebp),%eax
80105107:	83 c0 0c             	add    $0xc,%eax
8010510a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010510e:	8d 45 08             	lea    0x8(%ebp),%eax
80105111:	89 04 24             	mov    %eax,(%esp)
80105114:	e8 51 00 00 00       	call   8010516a <getcallerpcs>
}
80105119:	c9                   	leave  
8010511a:	c3                   	ret    

8010511b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010511b:	55                   	push   %ebp
8010511c:	89 e5                	mov    %esp,%ebp
8010511e:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105121:	8b 45 08             	mov    0x8(%ebp),%eax
80105124:	89 04 24             	mov    %eax,(%esp)
80105127:	e8 b7 00 00 00       	call   801051e3 <holding>
8010512c:	85 c0                	test   %eax,%eax
8010512e:	75 0c                	jne    8010513c <release+0x21>
    panic("release");
80105130:	c7 04 24 d5 8a 10 80 	movl   $0x80108ad5,(%esp)
80105137:	e8 fe b3 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
8010513c:	8b 45 08             	mov    0x8(%ebp),%eax
8010513f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105146:	8b 45 08             	mov    0x8(%ebp),%eax
80105149:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105150:	8b 45 08             	mov    0x8(%ebp),%eax
80105153:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010515a:	00 
8010515b:	89 04 24             	mov    %eax,(%esp)
8010515e:	e8 1b ff ff ff       	call   8010507e <xchg>

  popcli();
80105163:	e8 e9 00 00 00       	call   80105251 <popcli>
}
80105168:	c9                   	leave  
80105169:	c3                   	ret    

8010516a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010516a:	55                   	push   %ebp
8010516b:	89 e5                	mov    %esp,%ebp
8010516d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105170:	8b 45 08             	mov    0x8(%ebp),%eax
80105173:	83 e8 08             	sub    $0x8,%eax
80105176:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105179:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105180:	eb 38                	jmp    801051ba <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105182:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105186:	74 38                	je     801051c0 <getcallerpcs+0x56>
80105188:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010518f:	76 2f                	jbe    801051c0 <getcallerpcs+0x56>
80105191:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105195:	74 29                	je     801051c0 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105197:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010519a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a4:	01 c2                	add    %eax,%edx
801051a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051a9:	8b 40 04             	mov    0x4(%eax),%eax
801051ac:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801051ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051b1:	8b 00                	mov    (%eax),%eax
801051b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801051b6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051ba:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051be:	7e c2                	jle    80105182 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051c0:	eb 19                	jmp    801051db <getcallerpcs+0x71>
    pcs[i] = 0;
801051c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801051cf:	01 d0                	add    %edx,%eax
801051d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051d7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051db:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051df:	7e e1                	jle    801051c2 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801051e1:	c9                   	leave  
801051e2:	c3                   	ret    

801051e3 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051e3:	55                   	push   %ebp
801051e4:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051e6:	8b 45 08             	mov    0x8(%ebp),%eax
801051e9:	8b 00                	mov    (%eax),%eax
801051eb:	85 c0                	test   %eax,%eax
801051ed:	74 17                	je     80105206 <holding+0x23>
801051ef:	8b 45 08             	mov    0x8(%ebp),%eax
801051f2:	8b 50 08             	mov    0x8(%eax),%edx
801051f5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051fb:	39 c2                	cmp    %eax,%edx
801051fd:	75 07                	jne    80105206 <holding+0x23>
801051ff:	b8 01 00 00 00       	mov    $0x1,%eax
80105204:	eb 05                	jmp    8010520b <holding+0x28>
80105206:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010520b:	5d                   	pop    %ebp
8010520c:	c3                   	ret    

8010520d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010520d:	55                   	push   %ebp
8010520e:	89 e5                	mov    %esp,%ebp
80105210:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105213:	e8 4a fe ff ff       	call   80105062 <readeflags>
80105218:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010521b:	e8 52 fe ff ff       	call   80105072 <cli>
  if(cpu->ncli++ == 0)
80105220:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105227:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
8010522d:	8d 48 01             	lea    0x1(%eax),%ecx
80105230:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105236:	85 c0                	test   %eax,%eax
80105238:	75 15                	jne    8010524f <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010523a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105240:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105243:	81 e2 00 02 00 00    	and    $0x200,%edx
80105249:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010524f:	c9                   	leave  
80105250:	c3                   	ret    

80105251 <popcli>:

void
popcli(void)
{
80105251:	55                   	push   %ebp
80105252:	89 e5                	mov    %esp,%ebp
80105254:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105257:	e8 06 fe ff ff       	call   80105062 <readeflags>
8010525c:	25 00 02 00 00       	and    $0x200,%eax
80105261:	85 c0                	test   %eax,%eax
80105263:	74 0c                	je     80105271 <popcli+0x20>
    panic("popcli - interruptible");
80105265:	c7 04 24 dd 8a 10 80 	movl   $0x80108add,(%esp)
8010526c:	e8 c9 b2 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105271:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105277:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010527d:	83 ea 01             	sub    $0x1,%edx
80105280:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105286:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010528c:	85 c0                	test   %eax,%eax
8010528e:	79 0c                	jns    8010529c <popcli+0x4b>
    panic("popcli");
80105290:	c7 04 24 f4 8a 10 80 	movl   $0x80108af4,(%esp)
80105297:	e8 9e b2 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010529c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052a2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801052a8:	85 c0                	test   %eax,%eax
801052aa:	75 15                	jne    801052c1 <popcli+0x70>
801052ac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052b2:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052b8:	85 c0                	test   %eax,%eax
801052ba:	74 05                	je     801052c1 <popcli+0x70>
    sti();
801052bc:	e8 b7 fd ff ff       	call   80105078 <sti>
}
801052c1:	c9                   	leave  
801052c2:	c3                   	ret    

801052c3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801052c3:	55                   	push   %ebp
801052c4:	89 e5                	mov    %esp,%ebp
801052c6:	57                   	push   %edi
801052c7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052cb:	8b 55 10             	mov    0x10(%ebp),%edx
801052ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d1:	89 cb                	mov    %ecx,%ebx
801052d3:	89 df                	mov    %ebx,%edi
801052d5:	89 d1                	mov    %edx,%ecx
801052d7:	fc                   	cld    
801052d8:	f3 aa                	rep stos %al,%es:(%edi)
801052da:	89 ca                	mov    %ecx,%edx
801052dc:	89 fb                	mov    %edi,%ebx
801052de:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052e1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052e4:	5b                   	pop    %ebx
801052e5:	5f                   	pop    %edi
801052e6:	5d                   	pop    %ebp
801052e7:	c3                   	ret    

801052e8 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801052e8:	55                   	push   %ebp
801052e9:	89 e5                	mov    %esp,%ebp
801052eb:	57                   	push   %edi
801052ec:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052f0:	8b 55 10             	mov    0x10(%ebp),%edx
801052f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f6:	89 cb                	mov    %ecx,%ebx
801052f8:	89 df                	mov    %ebx,%edi
801052fa:	89 d1                	mov    %edx,%ecx
801052fc:	fc                   	cld    
801052fd:	f3 ab                	rep stos %eax,%es:(%edi)
801052ff:	89 ca                	mov    %ecx,%edx
80105301:	89 fb                	mov    %edi,%ebx
80105303:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105306:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105309:	5b                   	pop    %ebx
8010530a:	5f                   	pop    %edi
8010530b:	5d                   	pop    %ebp
8010530c:	c3                   	ret    

8010530d <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010530d:	55                   	push   %ebp
8010530e:	89 e5                	mov    %esp,%ebp
80105310:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105313:	8b 45 08             	mov    0x8(%ebp),%eax
80105316:	83 e0 03             	and    $0x3,%eax
80105319:	85 c0                	test   %eax,%eax
8010531b:	75 49                	jne    80105366 <memset+0x59>
8010531d:	8b 45 10             	mov    0x10(%ebp),%eax
80105320:	83 e0 03             	and    $0x3,%eax
80105323:	85 c0                	test   %eax,%eax
80105325:	75 3f                	jne    80105366 <memset+0x59>
    c &= 0xFF;
80105327:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010532e:	8b 45 10             	mov    0x10(%ebp),%eax
80105331:	c1 e8 02             	shr    $0x2,%eax
80105334:	89 c2                	mov    %eax,%edx
80105336:	8b 45 0c             	mov    0xc(%ebp),%eax
80105339:	c1 e0 18             	shl    $0x18,%eax
8010533c:	89 c1                	mov    %eax,%ecx
8010533e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105341:	c1 e0 10             	shl    $0x10,%eax
80105344:	09 c1                	or     %eax,%ecx
80105346:	8b 45 0c             	mov    0xc(%ebp),%eax
80105349:	c1 e0 08             	shl    $0x8,%eax
8010534c:	09 c8                	or     %ecx,%eax
8010534e:	0b 45 0c             	or     0xc(%ebp),%eax
80105351:	89 54 24 08          	mov    %edx,0x8(%esp)
80105355:	89 44 24 04          	mov    %eax,0x4(%esp)
80105359:	8b 45 08             	mov    0x8(%ebp),%eax
8010535c:	89 04 24             	mov    %eax,(%esp)
8010535f:	e8 84 ff ff ff       	call   801052e8 <stosl>
80105364:	eb 19                	jmp    8010537f <memset+0x72>
  } else
    stosb(dst, c, n);
80105366:	8b 45 10             	mov    0x10(%ebp),%eax
80105369:	89 44 24 08          	mov    %eax,0x8(%esp)
8010536d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105370:	89 44 24 04          	mov    %eax,0x4(%esp)
80105374:	8b 45 08             	mov    0x8(%ebp),%eax
80105377:	89 04 24             	mov    %eax,(%esp)
8010537a:	e8 44 ff ff ff       	call   801052c3 <stosb>
  return dst;
8010537f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105382:	c9                   	leave  
80105383:	c3                   	ret    

80105384 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105384:	55                   	push   %ebp
80105385:	89 e5                	mov    %esp,%ebp
80105387:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010538a:	8b 45 08             	mov    0x8(%ebp),%eax
8010538d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105390:	8b 45 0c             	mov    0xc(%ebp),%eax
80105393:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105396:	eb 30                	jmp    801053c8 <memcmp+0x44>
    if(*s1 != *s2)
80105398:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539b:	0f b6 10             	movzbl (%eax),%edx
8010539e:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053a1:	0f b6 00             	movzbl (%eax),%eax
801053a4:	38 c2                	cmp    %al,%dl
801053a6:	74 18                	je     801053c0 <memcmp+0x3c>
      return *s1 - *s2;
801053a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ab:	0f b6 00             	movzbl (%eax),%eax
801053ae:	0f b6 d0             	movzbl %al,%edx
801053b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b4:	0f b6 00             	movzbl (%eax),%eax
801053b7:	0f b6 c0             	movzbl %al,%eax
801053ba:	29 c2                	sub    %eax,%edx
801053bc:	89 d0                	mov    %edx,%eax
801053be:	eb 1a                	jmp    801053da <memcmp+0x56>
    s1++, s2++;
801053c0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053c4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801053c8:	8b 45 10             	mov    0x10(%ebp),%eax
801053cb:	8d 50 ff             	lea    -0x1(%eax),%edx
801053ce:	89 55 10             	mov    %edx,0x10(%ebp)
801053d1:	85 c0                	test   %eax,%eax
801053d3:	75 c3                	jne    80105398 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801053d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053da:	c9                   	leave  
801053db:	c3                   	ret    

801053dc <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053dc:	55                   	push   %ebp
801053dd:	89 e5                	mov    %esp,%ebp
801053df:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053e8:	8b 45 08             	mov    0x8(%ebp),%eax
801053eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053f4:	73 3d                	jae    80105433 <memmove+0x57>
801053f6:	8b 45 10             	mov    0x10(%ebp),%eax
801053f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053fc:	01 d0                	add    %edx,%eax
801053fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105401:	76 30                	jbe    80105433 <memmove+0x57>
    s += n;
80105403:	8b 45 10             	mov    0x10(%ebp),%eax
80105406:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105409:	8b 45 10             	mov    0x10(%ebp),%eax
8010540c:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010540f:	eb 13                	jmp    80105424 <memmove+0x48>
      *--d = *--s;
80105411:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105415:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105419:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010541c:	0f b6 10             	movzbl (%eax),%edx
8010541f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105422:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105424:	8b 45 10             	mov    0x10(%ebp),%eax
80105427:	8d 50 ff             	lea    -0x1(%eax),%edx
8010542a:	89 55 10             	mov    %edx,0x10(%ebp)
8010542d:	85 c0                	test   %eax,%eax
8010542f:	75 e0                	jne    80105411 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105431:	eb 26                	jmp    80105459 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105433:	eb 17                	jmp    8010544c <memmove+0x70>
      *d++ = *s++;
80105435:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105438:	8d 50 01             	lea    0x1(%eax),%edx
8010543b:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010543e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105441:	8d 4a 01             	lea    0x1(%edx),%ecx
80105444:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105447:	0f b6 12             	movzbl (%edx),%edx
8010544a:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010544c:	8b 45 10             	mov    0x10(%ebp),%eax
8010544f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105452:	89 55 10             	mov    %edx,0x10(%ebp)
80105455:	85 c0                	test   %eax,%eax
80105457:	75 dc                	jne    80105435 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105459:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010545c:	c9                   	leave  
8010545d:	c3                   	ret    

8010545e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010545e:	55                   	push   %ebp
8010545f:	89 e5                	mov    %esp,%ebp
80105461:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105464:	8b 45 10             	mov    0x10(%ebp),%eax
80105467:	89 44 24 08          	mov    %eax,0x8(%esp)
8010546b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010546e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105472:	8b 45 08             	mov    0x8(%ebp),%eax
80105475:	89 04 24             	mov    %eax,(%esp)
80105478:	e8 5f ff ff ff       	call   801053dc <memmove>
}
8010547d:	c9                   	leave  
8010547e:	c3                   	ret    

8010547f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010547f:	55                   	push   %ebp
80105480:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105482:	eb 0c                	jmp    80105490 <strncmp+0x11>
    n--, p++, q++;
80105484:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105488:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010548c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105490:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105494:	74 1a                	je     801054b0 <strncmp+0x31>
80105496:	8b 45 08             	mov    0x8(%ebp),%eax
80105499:	0f b6 00             	movzbl (%eax),%eax
8010549c:	84 c0                	test   %al,%al
8010549e:	74 10                	je     801054b0 <strncmp+0x31>
801054a0:	8b 45 08             	mov    0x8(%ebp),%eax
801054a3:	0f b6 10             	movzbl (%eax),%edx
801054a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a9:	0f b6 00             	movzbl (%eax),%eax
801054ac:	38 c2                	cmp    %al,%dl
801054ae:	74 d4                	je     80105484 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801054b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b4:	75 07                	jne    801054bd <strncmp+0x3e>
    return 0;
801054b6:	b8 00 00 00 00       	mov    $0x0,%eax
801054bb:	eb 16                	jmp    801054d3 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801054bd:	8b 45 08             	mov    0x8(%ebp),%eax
801054c0:	0f b6 00             	movzbl (%eax),%eax
801054c3:	0f b6 d0             	movzbl %al,%edx
801054c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801054c9:	0f b6 00             	movzbl (%eax),%eax
801054cc:	0f b6 c0             	movzbl %al,%eax
801054cf:	29 c2                	sub    %eax,%edx
801054d1:	89 d0                	mov    %edx,%eax
}
801054d3:	5d                   	pop    %ebp
801054d4:	c3                   	ret    

801054d5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054d5:	55                   	push   %ebp
801054d6:	89 e5                	mov    %esp,%ebp
801054d8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054db:	8b 45 08             	mov    0x8(%ebp),%eax
801054de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054e1:	90                   	nop
801054e2:	8b 45 10             	mov    0x10(%ebp),%eax
801054e5:	8d 50 ff             	lea    -0x1(%eax),%edx
801054e8:	89 55 10             	mov    %edx,0x10(%ebp)
801054eb:	85 c0                	test   %eax,%eax
801054ed:	7e 1e                	jle    8010550d <strncpy+0x38>
801054ef:	8b 45 08             	mov    0x8(%ebp),%eax
801054f2:	8d 50 01             	lea    0x1(%eax),%edx
801054f5:	89 55 08             	mov    %edx,0x8(%ebp)
801054f8:	8b 55 0c             	mov    0xc(%ebp),%edx
801054fb:	8d 4a 01             	lea    0x1(%edx),%ecx
801054fe:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105501:	0f b6 12             	movzbl (%edx),%edx
80105504:	88 10                	mov    %dl,(%eax)
80105506:	0f b6 00             	movzbl (%eax),%eax
80105509:	84 c0                	test   %al,%al
8010550b:	75 d5                	jne    801054e2 <strncpy+0xd>
    ;
  while(n-- > 0)
8010550d:	eb 0c                	jmp    8010551b <strncpy+0x46>
    *s++ = 0;
8010550f:	8b 45 08             	mov    0x8(%ebp),%eax
80105512:	8d 50 01             	lea    0x1(%eax),%edx
80105515:	89 55 08             	mov    %edx,0x8(%ebp)
80105518:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010551b:	8b 45 10             	mov    0x10(%ebp),%eax
8010551e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105521:	89 55 10             	mov    %edx,0x10(%ebp)
80105524:	85 c0                	test   %eax,%eax
80105526:	7f e7                	jg     8010550f <strncpy+0x3a>
    *s++ = 0;
  return os;
80105528:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010552b:	c9                   	leave  
8010552c:	c3                   	ret    

8010552d <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010552d:	55                   	push   %ebp
8010552e:	89 e5                	mov    %esp,%ebp
80105530:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105533:	8b 45 08             	mov    0x8(%ebp),%eax
80105536:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105539:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010553d:	7f 05                	jg     80105544 <safestrcpy+0x17>
    return os;
8010553f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105542:	eb 31                	jmp    80105575 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105544:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105548:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010554c:	7e 1e                	jle    8010556c <safestrcpy+0x3f>
8010554e:	8b 45 08             	mov    0x8(%ebp),%eax
80105551:	8d 50 01             	lea    0x1(%eax),%edx
80105554:	89 55 08             	mov    %edx,0x8(%ebp)
80105557:	8b 55 0c             	mov    0xc(%ebp),%edx
8010555a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010555d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105560:	0f b6 12             	movzbl (%edx),%edx
80105563:	88 10                	mov    %dl,(%eax)
80105565:	0f b6 00             	movzbl (%eax),%eax
80105568:	84 c0                	test   %al,%al
8010556a:	75 d8                	jne    80105544 <safestrcpy+0x17>
    ;
  *s = 0;
8010556c:	8b 45 08             	mov    0x8(%ebp),%eax
8010556f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105572:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105575:	c9                   	leave  
80105576:	c3                   	ret    

80105577 <strlen>:

int
strlen(const char *s)
{
80105577:	55                   	push   %ebp
80105578:	89 e5                	mov    %esp,%ebp
8010557a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010557d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105584:	eb 04                	jmp    8010558a <strlen+0x13>
80105586:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010558a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010558d:	8b 45 08             	mov    0x8(%ebp),%eax
80105590:	01 d0                	add    %edx,%eax
80105592:	0f b6 00             	movzbl (%eax),%eax
80105595:	84 c0                	test   %al,%al
80105597:	75 ed                	jne    80105586 <strlen+0xf>
    ;
  return n;
80105599:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010559c:	c9                   	leave  
8010559d:	c3                   	ret    

8010559e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010559e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055a2:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055a6:	55                   	push   %ebp
  pushl %ebx
801055a7:	53                   	push   %ebx
  pushl %esi
801055a8:	56                   	push   %esi
  pushl %edi
801055a9:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055aa:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055ac:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055ae:	5f                   	pop    %edi
  popl %esi
801055af:	5e                   	pop    %esi
  popl %ebx
801055b0:	5b                   	pop    %ebx
  popl %ebp
801055b1:	5d                   	pop    %ebp
  ret
801055b2:	c3                   	ret    

801055b3 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055b3:	55                   	push   %ebp
801055b4:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801055b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055bc:	8b 00                	mov    (%eax),%eax
801055be:	3b 45 08             	cmp    0x8(%ebp),%eax
801055c1:	76 12                	jbe    801055d5 <fetchint+0x22>
801055c3:	8b 45 08             	mov    0x8(%ebp),%eax
801055c6:	8d 50 04             	lea    0x4(%eax),%edx
801055c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055cf:	8b 00                	mov    (%eax),%eax
801055d1:	39 c2                	cmp    %eax,%edx
801055d3:	76 07                	jbe    801055dc <fetchint+0x29>
    return -1;
801055d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055da:	eb 0f                	jmp    801055eb <fetchint+0x38>
  *ip = *(int*)(addr);
801055dc:	8b 45 08             	mov    0x8(%ebp),%eax
801055df:	8b 10                	mov    (%eax),%edx
801055e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e4:	89 10                	mov    %edx,(%eax)
  return 0;
801055e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055eb:	5d                   	pop    %ebp
801055ec:	c3                   	ret    

801055ed <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055ed:	55                   	push   %ebp
801055ee:	89 e5                	mov    %esp,%ebp
801055f0:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801055f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055f9:	8b 00                	mov    (%eax),%eax
801055fb:	3b 45 08             	cmp    0x8(%ebp),%eax
801055fe:	77 07                	ja     80105607 <fetchstr+0x1a>
    return -1;
80105600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105605:	eb 46                	jmp    8010564d <fetchstr+0x60>
  *pp = (char*)addr;
80105607:	8b 55 08             	mov    0x8(%ebp),%edx
8010560a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010560d:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010560f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105615:	8b 00                	mov    (%eax),%eax
80105617:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010561a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010561d:	8b 00                	mov    (%eax),%eax
8010561f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105622:	eb 1c                	jmp    80105640 <fetchstr+0x53>
    if(*s == 0)
80105624:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105627:	0f b6 00             	movzbl (%eax),%eax
8010562a:	84 c0                	test   %al,%al
8010562c:	75 0e                	jne    8010563c <fetchstr+0x4f>
      return s - *pp;
8010562e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105631:	8b 45 0c             	mov    0xc(%ebp),%eax
80105634:	8b 00                	mov    (%eax),%eax
80105636:	29 c2                	sub    %eax,%edx
80105638:	89 d0                	mov    %edx,%eax
8010563a:	eb 11                	jmp    8010564d <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010563c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105640:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105643:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105646:	72 dc                	jb     80105624 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105648:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010564d:	c9                   	leave  
8010564e:	c3                   	ret    

8010564f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010564f:	55                   	push   %ebp
80105650:	89 e5                	mov    %esp,%ebp
80105652:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105655:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565b:	8b 40 18             	mov    0x18(%eax),%eax
8010565e:	8b 50 44             	mov    0x44(%eax),%edx
80105661:	8b 45 08             	mov    0x8(%ebp),%eax
80105664:	c1 e0 02             	shl    $0x2,%eax
80105667:	01 d0                	add    %edx,%eax
80105669:	8d 50 04             	lea    0x4(%eax),%edx
8010566c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010566f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105673:	89 14 24             	mov    %edx,(%esp)
80105676:	e8 38 ff ff ff       	call   801055b3 <fetchint>
}
8010567b:	c9                   	leave  
8010567c:	c3                   	ret    

8010567d <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010567d:	55                   	push   %ebp
8010567e:	89 e5                	mov    %esp,%ebp
80105680:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105683:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105686:	89 44 24 04          	mov    %eax,0x4(%esp)
8010568a:	8b 45 08             	mov    0x8(%ebp),%eax
8010568d:	89 04 24             	mov    %eax,(%esp)
80105690:	e8 ba ff ff ff       	call   8010564f <argint>
80105695:	85 c0                	test   %eax,%eax
80105697:	79 07                	jns    801056a0 <argptr+0x23>
    return -1;
80105699:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010569e:	eb 3d                	jmp    801056dd <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801056a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a3:	89 c2                	mov    %eax,%edx
801056a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ab:	8b 00                	mov    (%eax),%eax
801056ad:	39 c2                	cmp    %eax,%edx
801056af:	73 16                	jae    801056c7 <argptr+0x4a>
801056b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056b4:	89 c2                	mov    %eax,%edx
801056b6:	8b 45 10             	mov    0x10(%ebp),%eax
801056b9:	01 c2                	add    %eax,%edx
801056bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c1:	8b 00                	mov    (%eax),%eax
801056c3:	39 c2                	cmp    %eax,%edx
801056c5:	76 07                	jbe    801056ce <argptr+0x51>
    return -1;
801056c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056cc:	eb 0f                	jmp    801056dd <argptr+0x60>
  *pp = (char*)i;
801056ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056d1:	89 c2                	mov    %eax,%edx
801056d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d6:	89 10                	mov    %edx,(%eax)
  return 0;
801056d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056dd:	c9                   	leave  
801056de:	c3                   	ret    

801056df <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801056df:	55                   	push   %ebp
801056e0:	89 e5                	mov    %esp,%ebp
801056e2:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801056e5:	8d 45 fc             	lea    -0x4(%ebp),%eax
801056e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801056ec:	8b 45 08             	mov    0x8(%ebp),%eax
801056ef:	89 04 24             	mov    %eax,(%esp)
801056f2:	e8 58 ff ff ff       	call   8010564f <argint>
801056f7:	85 c0                	test   %eax,%eax
801056f9:	79 07                	jns    80105702 <argstr+0x23>
    return -1;
801056fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105700:	eb 12                	jmp    80105714 <argstr+0x35>
  return fetchstr(addr, pp);
80105702:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105705:	8b 55 0c             	mov    0xc(%ebp),%edx
80105708:	89 54 24 04          	mov    %edx,0x4(%esp)
8010570c:	89 04 24             	mov    %eax,(%esp)
8010570f:	e8 d9 fe ff ff       	call   801055ed <fetchstr>
}
80105714:	c9                   	leave  
80105715:	c3                   	ret    

80105716 <syscall>:
[SYS_sigsend]  sys_sigsend,
};

void
syscall(void)
{
80105716:	55                   	push   %ebp
80105717:	89 e5                	mov    %esp,%ebp
80105719:	53                   	push   %ebx
8010571a:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010571d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105723:	8b 40 18             	mov    0x18(%eax),%eax
80105726:	8b 40 1c             	mov    0x1c(%eax),%eax
80105729:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010572c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105730:	7e 30                	jle    80105762 <syscall+0x4c>
80105732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105735:	83 f8 17             	cmp    $0x17,%eax
80105738:	77 28                	ja     80105762 <syscall+0x4c>
8010573a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010573d:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105744:	85 c0                	test   %eax,%eax
80105746:	74 1a                	je     80105762 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105748:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010574e:	8b 58 18             	mov    0x18(%eax),%ebx
80105751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105754:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010575b:	ff d0                	call   *%eax
8010575d:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105760:	eb 3d                	jmp    8010579f <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105762:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105768:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010576b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105771:	8b 40 10             	mov    0x10(%eax),%eax
80105774:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105777:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010577b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010577f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105783:	c7 04 24 fb 8a 10 80 	movl   $0x80108afb,(%esp)
8010578a:	e8 11 ac ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010578f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105795:	8b 40 18             	mov    0x18(%eax),%eax
80105798:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010579f:	83 c4 24             	add    $0x24,%esp
801057a2:	5b                   	pop    %ebx
801057a3:	5d                   	pop    %ebp
801057a4:	c3                   	ret    

801057a5 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057a5:	55                   	push   %ebp
801057a6:	89 e5                	mov    %esp,%ebp
801057a8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801057b2:	8b 45 08             	mov    0x8(%ebp),%eax
801057b5:	89 04 24             	mov    %eax,(%esp)
801057b8:	e8 92 fe ff ff       	call   8010564f <argint>
801057bd:	85 c0                	test   %eax,%eax
801057bf:	79 07                	jns    801057c8 <argfd+0x23>
    return -1;
801057c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c6:	eb 50                	jmp    80105818 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801057c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057cb:	85 c0                	test   %eax,%eax
801057cd:	78 21                	js     801057f0 <argfd+0x4b>
801057cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d2:	83 f8 0f             	cmp    $0xf,%eax
801057d5:	7f 19                	jg     801057f0 <argfd+0x4b>
801057d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057e0:	83 c2 08             	add    $0x8,%edx
801057e3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057ee:	75 07                	jne    801057f7 <argfd+0x52>
    return -1;
801057f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f5:	eb 21                	jmp    80105818 <argfd+0x73>
  if(pfd)
801057f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801057fb:	74 08                	je     80105805 <argfd+0x60>
    *pfd = fd;
801057fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105800:	8b 45 0c             	mov    0xc(%ebp),%eax
80105803:	89 10                	mov    %edx,(%eax)
  if(pf)
80105805:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105809:	74 08                	je     80105813 <argfd+0x6e>
    *pf = f;
8010580b:	8b 45 10             	mov    0x10(%ebp),%eax
8010580e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105811:	89 10                	mov    %edx,(%eax)
  return 0;
80105813:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105818:	c9                   	leave  
80105819:	c3                   	ret    

8010581a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010581a:	55                   	push   %ebp
8010581b:	89 e5                	mov    %esp,%ebp
8010581d:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105820:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105827:	eb 30                	jmp    80105859 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105829:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010582f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105832:	83 c2 08             	add    $0x8,%edx
80105835:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105839:	85 c0                	test   %eax,%eax
8010583b:	75 18                	jne    80105855 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010583d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105843:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105846:	8d 4a 08             	lea    0x8(%edx),%ecx
80105849:	8b 55 08             	mov    0x8(%ebp),%edx
8010584c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105850:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105853:	eb 0f                	jmp    80105864 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105855:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105859:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010585d:	7e ca                	jle    80105829 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010585f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105864:	c9                   	leave  
80105865:	c3                   	ret    

80105866 <sys_dup>:

int
sys_dup(void)
{
80105866:	55                   	push   %ebp
80105867:	89 e5                	mov    %esp,%ebp
80105869:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010586c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010586f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105873:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010587a:	00 
8010587b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105882:	e8 1e ff ff ff       	call   801057a5 <argfd>
80105887:	85 c0                	test   %eax,%eax
80105889:	79 07                	jns    80105892 <sys_dup+0x2c>
    return -1;
8010588b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105890:	eb 29                	jmp    801058bb <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105895:	89 04 24             	mov    %eax,(%esp)
80105898:	e8 7d ff ff ff       	call   8010581a <fdalloc>
8010589d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058a4:	79 07                	jns    801058ad <sys_dup+0x47>
    return -1;
801058a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ab:	eb 0e                	jmp    801058bb <sys_dup+0x55>
  filedup(f);
801058ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b0:	89 04 24             	mov    %eax,(%esp)
801058b3:	e8 de b6 ff ff       	call   80100f96 <filedup>
  return fd;
801058b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058bb:	c9                   	leave  
801058bc:	c3                   	ret    

801058bd <sys_read>:

int
sys_read(void)
{
801058bd:	55                   	push   %ebp
801058be:	89 e5                	mov    %esp,%ebp
801058c0:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058c6:	89 44 24 08          	mov    %eax,0x8(%esp)
801058ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058d1:	00 
801058d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058d9:	e8 c7 fe ff ff       	call   801057a5 <argfd>
801058de:	85 c0                	test   %eax,%eax
801058e0:	78 35                	js     80105917 <sys_read+0x5a>
801058e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801058e9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801058f0:	e8 5a fd ff ff       	call   8010564f <argint>
801058f5:	85 c0                	test   %eax,%eax
801058f7:	78 1e                	js     80105917 <sys_read+0x5a>
801058f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fc:	89 44 24 08          	mov    %eax,0x8(%esp)
80105900:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105903:	89 44 24 04          	mov    %eax,0x4(%esp)
80105907:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010590e:	e8 6a fd ff ff       	call   8010567d <argptr>
80105913:	85 c0                	test   %eax,%eax
80105915:	79 07                	jns    8010591e <sys_read+0x61>
    return -1;
80105917:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591c:	eb 19                	jmp    80105937 <sys_read+0x7a>
  return fileread(f, p, n);
8010591e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105921:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105927:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010592b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010592f:	89 04 24             	mov    %eax,(%esp)
80105932:	e8 cc b7 ff ff       	call   80101103 <fileread>
}
80105937:	c9                   	leave  
80105938:	c3                   	ret    

80105939 <sys_write>:

int
sys_write(void)
{
80105939:	55                   	push   %ebp
8010593a:	89 e5                	mov    %esp,%ebp
8010593c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010593f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105942:	89 44 24 08          	mov    %eax,0x8(%esp)
80105946:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010594d:	00 
8010594e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105955:	e8 4b fe ff ff       	call   801057a5 <argfd>
8010595a:	85 c0                	test   %eax,%eax
8010595c:	78 35                	js     80105993 <sys_write+0x5a>
8010595e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105961:	89 44 24 04          	mov    %eax,0x4(%esp)
80105965:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010596c:	e8 de fc ff ff       	call   8010564f <argint>
80105971:	85 c0                	test   %eax,%eax
80105973:	78 1e                	js     80105993 <sys_write+0x5a>
80105975:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105978:	89 44 24 08          	mov    %eax,0x8(%esp)
8010597c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010597f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105983:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010598a:	e8 ee fc ff ff       	call   8010567d <argptr>
8010598f:	85 c0                	test   %eax,%eax
80105991:	79 07                	jns    8010599a <sys_write+0x61>
    return -1;
80105993:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105998:	eb 19                	jmp    801059b3 <sys_write+0x7a>
  return filewrite(f, p, n);
8010599a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010599d:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801059ab:	89 04 24             	mov    %eax,(%esp)
801059ae:	e8 0c b8 ff ff       	call   801011bf <filewrite>
}
801059b3:	c9                   	leave  
801059b4:	c3                   	ret    

801059b5 <sys_close>:

int
sys_close(void)
{
801059b5:	55                   	push   %ebp
801059b6:	89 e5                	mov    %esp,%ebp
801059b8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801059bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059be:	89 44 24 08          	mov    %eax,0x8(%esp)
801059c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801059c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059d0:	e8 d0 fd ff ff       	call   801057a5 <argfd>
801059d5:	85 c0                	test   %eax,%eax
801059d7:	79 07                	jns    801059e0 <sys_close+0x2b>
    return -1;
801059d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059de:	eb 24                	jmp    80105a04 <sys_close+0x4f>
  proc->ofile[fd] = 0;
801059e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059e9:	83 c2 08             	add    $0x8,%edx
801059ec:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801059f3:	00 
  fileclose(f);
801059f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f7:	89 04 24             	mov    %eax,(%esp)
801059fa:	e8 df b5 ff ff       	call   80100fde <fileclose>
  return 0;
801059ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a04:	c9                   	leave  
80105a05:	c3                   	ret    

80105a06 <sys_fstat>:

int
sys_fstat(void)
{
80105a06:	55                   	push   %ebp
80105a07:	89 e5                	mov    %esp,%ebp
80105a09:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a0f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a13:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a1a:	00 
80105a1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a22:	e8 7e fd ff ff       	call   801057a5 <argfd>
80105a27:	85 c0                	test   %eax,%eax
80105a29:	78 1f                	js     80105a4a <sys_fstat+0x44>
80105a2b:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105a32:	00 
80105a33:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a36:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a41:	e8 37 fc ff ff       	call   8010567d <argptr>
80105a46:	85 c0                	test   %eax,%eax
80105a48:	79 07                	jns    80105a51 <sys_fstat+0x4b>
    return -1;
80105a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4f:	eb 12                	jmp    80105a63 <sys_fstat+0x5d>
  return filestat(f, st);
80105a51:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a57:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a5b:	89 04 24             	mov    %eax,(%esp)
80105a5e:	e8 51 b6 ff ff       	call   801010b4 <filestat>
}
80105a63:	c9                   	leave  
80105a64:	c3                   	ret    

80105a65 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105a65:	55                   	push   %ebp
80105a66:	89 e5                	mov    %esp,%ebp
80105a68:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a6b:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a79:	e8 61 fc ff ff       	call   801056df <argstr>
80105a7e:	85 c0                	test   %eax,%eax
80105a80:	78 17                	js     80105a99 <sys_link+0x34>
80105a82:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a85:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a90:	e8 4a fc ff ff       	call   801056df <argstr>
80105a95:	85 c0                	test   %eax,%eax
80105a97:	79 0a                	jns    80105aa3 <sys_link+0x3e>
    return -1;
80105a99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9e:	e9 42 01 00 00       	jmp    80105be5 <sys_link+0x180>

  begin_op();
80105aa3:	e8 78 d9 ff ff       	call   80103420 <begin_op>
  if((ip = namei(old)) == 0){
80105aa8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105aab:	89 04 24             	mov    %eax,(%esp)
80105aae:	e8 63 c9 ff ff       	call   80102416 <namei>
80105ab3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ab6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aba:	75 0f                	jne    80105acb <sys_link+0x66>
    end_op();
80105abc:	e8 e3 d9 ff ff       	call   801034a4 <end_op>
    return -1;
80105ac1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac6:	e9 1a 01 00 00       	jmp    80105be5 <sys_link+0x180>
  }

  ilock(ip);
80105acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ace:	89 04 24             	mov    %eax,(%esp)
80105ad1:	e8 95 bd ff ff       	call   8010186b <ilock>
  if(ip->type == T_DIR){
80105ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105add:	66 83 f8 01          	cmp    $0x1,%ax
80105ae1:	75 1a                	jne    80105afd <sys_link+0x98>
    iunlockput(ip);
80105ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae6:	89 04 24             	mov    %eax,(%esp)
80105ae9:	e8 01 c0 ff ff       	call   80101aef <iunlockput>
    end_op();
80105aee:	e8 b1 d9 ff ff       	call   801034a4 <end_op>
    return -1;
80105af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af8:	e9 e8 00 00 00       	jmp    80105be5 <sys_link+0x180>
  }

  ip->nlink++;
80105afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b00:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b04:	8d 50 01             	lea    0x1(%eax),%edx
80105b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b11:	89 04 24             	mov    %eax,(%esp)
80105b14:	e8 96 bb ff ff       	call   801016af <iupdate>
  iunlock(ip);
80105b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1c:	89 04 24             	mov    %eax,(%esp)
80105b1f:	e8 95 be ff ff       	call   801019b9 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105b24:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b27:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b2a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b2e:	89 04 24             	mov    %eax,(%esp)
80105b31:	e8 02 c9 ff ff       	call   80102438 <nameiparent>
80105b36:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b3d:	75 02                	jne    80105b41 <sys_link+0xdc>
    goto bad;
80105b3f:	eb 68                	jmp    80105ba9 <sys_link+0x144>
  ilock(dp);
80105b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b44:	89 04 24             	mov    %eax,(%esp)
80105b47:	e8 1f bd ff ff       	call   8010186b <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4f:	8b 10                	mov    (%eax),%edx
80105b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b54:	8b 00                	mov    (%eax),%eax
80105b56:	39 c2                	cmp    %eax,%edx
80105b58:	75 20                	jne    80105b7a <sys_link+0x115>
80105b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5d:	8b 40 04             	mov    0x4(%eax),%eax
80105b60:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b64:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b67:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6e:	89 04 24             	mov    %eax,(%esp)
80105b71:	e8 e0 c5 ff ff       	call   80102156 <dirlink>
80105b76:	85 c0                	test   %eax,%eax
80105b78:	79 0d                	jns    80105b87 <sys_link+0x122>
    iunlockput(dp);
80105b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7d:	89 04 24             	mov    %eax,(%esp)
80105b80:	e8 6a bf ff ff       	call   80101aef <iunlockput>
    goto bad;
80105b85:	eb 22                	jmp    80105ba9 <sys_link+0x144>
  }
  iunlockput(dp);
80105b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8a:	89 04 24             	mov    %eax,(%esp)
80105b8d:	e8 5d bf ff ff       	call   80101aef <iunlockput>
  iput(ip);
80105b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b95:	89 04 24             	mov    %eax,(%esp)
80105b98:	e8 81 be ff ff       	call   80101a1e <iput>

  end_op();
80105b9d:	e8 02 d9 ff ff       	call   801034a4 <end_op>

  return 0;
80105ba2:	b8 00 00 00 00       	mov    $0x0,%eax
80105ba7:	eb 3c                	jmp    80105be5 <sys_link+0x180>

bad:
  ilock(ip);
80105ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bac:	89 04 24             	mov    %eax,(%esp)
80105baf:	e8 b7 bc ff ff       	call   8010186b <ilock>
  ip->nlink--;
80105bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bbb:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc8:	89 04 24             	mov    %eax,(%esp)
80105bcb:	e8 df ba ff ff       	call   801016af <iupdate>
  iunlockput(ip);
80105bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd3:	89 04 24             	mov    %eax,(%esp)
80105bd6:	e8 14 bf ff ff       	call   80101aef <iunlockput>
  end_op();
80105bdb:	e8 c4 d8 ff ff       	call   801034a4 <end_op>
  return -1;
80105be0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105be5:	c9                   	leave  
80105be6:	c3                   	ret    

80105be7 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105be7:	55                   	push   %ebp
80105be8:	89 e5                	mov    %esp,%ebp
80105bea:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bed:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105bf4:	eb 4b                	jmp    80105c41 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf9:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c00:	00 
80105c01:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c05:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c08:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c0f:	89 04 24             	mov    %eax,(%esp)
80105c12:	e8 61 c1 ff ff       	call   80101d78 <readi>
80105c17:	83 f8 10             	cmp    $0x10,%eax
80105c1a:	74 0c                	je     80105c28 <isdirempty+0x41>
      panic("isdirempty: readi");
80105c1c:	c7 04 24 17 8b 10 80 	movl   $0x80108b17,(%esp)
80105c23:	e8 12 a9 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105c28:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c2c:	66 85 c0             	test   %ax,%ax
80105c2f:	74 07                	je     80105c38 <isdirempty+0x51>
      return 0;
80105c31:	b8 00 00 00 00       	mov    $0x0,%eax
80105c36:	eb 1b                	jmp    80105c53 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3b:	83 c0 10             	add    $0x10,%eax
80105c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c44:	8b 45 08             	mov    0x8(%ebp),%eax
80105c47:	8b 40 18             	mov    0x18(%eax),%eax
80105c4a:	39 c2                	cmp    %eax,%edx
80105c4c:	72 a8                	jb     80105bf6 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105c4e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c53:	c9                   	leave  
80105c54:	c3                   	ret    

80105c55 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c55:	55                   	push   %ebp
80105c56:	89 e5                	mov    %esp,%ebp
80105c58:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c5b:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c69:	e8 71 fa ff ff       	call   801056df <argstr>
80105c6e:	85 c0                	test   %eax,%eax
80105c70:	79 0a                	jns    80105c7c <sys_unlink+0x27>
    return -1;
80105c72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c77:	e9 af 01 00 00       	jmp    80105e2b <sys_unlink+0x1d6>

  begin_op();
80105c7c:	e8 9f d7 ff ff       	call   80103420 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c81:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c84:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c87:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c8b:	89 04 24             	mov    %eax,(%esp)
80105c8e:	e8 a5 c7 ff ff       	call   80102438 <nameiparent>
80105c93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c9a:	75 0f                	jne    80105cab <sys_unlink+0x56>
    end_op();
80105c9c:	e8 03 d8 ff ff       	call   801034a4 <end_op>
    return -1;
80105ca1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca6:	e9 80 01 00 00       	jmp    80105e2b <sys_unlink+0x1d6>
  }

  ilock(dp);
80105cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cae:	89 04 24             	mov    %eax,(%esp)
80105cb1:	e8 b5 bb ff ff       	call   8010186b <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105cb6:	c7 44 24 04 29 8b 10 	movl   $0x80108b29,0x4(%esp)
80105cbd:	80 
80105cbe:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cc1:	89 04 24             	mov    %eax,(%esp)
80105cc4:	e8 a2 c3 ff ff       	call   8010206b <namecmp>
80105cc9:	85 c0                	test   %eax,%eax
80105ccb:	0f 84 45 01 00 00    	je     80105e16 <sys_unlink+0x1c1>
80105cd1:	c7 44 24 04 2b 8b 10 	movl   $0x80108b2b,0x4(%esp)
80105cd8:	80 
80105cd9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cdc:	89 04 24             	mov    %eax,(%esp)
80105cdf:	e8 87 c3 ff ff       	call   8010206b <namecmp>
80105ce4:	85 c0                	test   %eax,%eax
80105ce6:	0f 84 2a 01 00 00    	je     80105e16 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105cec:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105cef:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cf3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cfd:	89 04 24             	mov    %eax,(%esp)
80105d00:	e8 88 c3 ff ff       	call   8010208d <dirlookup>
80105d05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d0c:	75 05                	jne    80105d13 <sys_unlink+0xbe>
    goto bad;
80105d0e:	e9 03 01 00 00       	jmp    80105e16 <sys_unlink+0x1c1>
  ilock(ip);
80105d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d16:	89 04 24             	mov    %eax,(%esp)
80105d19:	e8 4d bb ff ff       	call   8010186b <ilock>

  if(ip->nlink < 1)
80105d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d21:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d25:	66 85 c0             	test   %ax,%ax
80105d28:	7f 0c                	jg     80105d36 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105d2a:	c7 04 24 2e 8b 10 80 	movl   $0x80108b2e,(%esp)
80105d31:	e8 04 a8 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d39:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d3d:	66 83 f8 01          	cmp    $0x1,%ax
80105d41:	75 1f                	jne    80105d62 <sys_unlink+0x10d>
80105d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d46:	89 04 24             	mov    %eax,(%esp)
80105d49:	e8 99 fe ff ff       	call   80105be7 <isdirempty>
80105d4e:	85 c0                	test   %eax,%eax
80105d50:	75 10                	jne    80105d62 <sys_unlink+0x10d>
    iunlockput(ip);
80105d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d55:	89 04 24             	mov    %eax,(%esp)
80105d58:	e8 92 bd ff ff       	call   80101aef <iunlockput>
    goto bad;
80105d5d:	e9 b4 00 00 00       	jmp    80105e16 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105d62:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105d69:	00 
80105d6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d71:	00 
80105d72:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d75:	89 04 24             	mov    %eax,(%esp)
80105d78:	e8 90 f5 ff ff       	call   8010530d <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d7d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d80:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d87:	00 
80105d88:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d8c:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d96:	89 04 24             	mov    %eax,(%esp)
80105d99:	e8 3e c1 ff ff       	call   80101edc <writei>
80105d9e:	83 f8 10             	cmp    $0x10,%eax
80105da1:	74 0c                	je     80105daf <sys_unlink+0x15a>
    panic("unlink: writei");
80105da3:	c7 04 24 40 8b 10 80 	movl   $0x80108b40,(%esp)
80105daa:	e8 8b a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105db6:	66 83 f8 01          	cmp    $0x1,%ax
80105dba:	75 1c                	jne    80105dd8 <sys_unlink+0x183>
    dp->nlink--;
80105dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105dc3:	8d 50 ff             	lea    -0x1(%eax),%edx
80105dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc9:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd0:	89 04 24             	mov    %eax,(%esp)
80105dd3:	e8 d7 b8 ff ff       	call   801016af <iupdate>
  }
  iunlockput(dp);
80105dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddb:	89 04 24             	mov    %eax,(%esp)
80105dde:	e8 0c bd ff ff       	call   80101aef <iunlockput>

  ip->nlink--;
80105de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105dea:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df0:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df7:	89 04 24             	mov    %eax,(%esp)
80105dfa:	e8 b0 b8 ff ff       	call   801016af <iupdate>
  iunlockput(ip);
80105dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e02:	89 04 24             	mov    %eax,(%esp)
80105e05:	e8 e5 bc ff ff       	call   80101aef <iunlockput>

  end_op();
80105e0a:	e8 95 d6 ff ff       	call   801034a4 <end_op>

  return 0;
80105e0f:	b8 00 00 00 00       	mov    $0x0,%eax
80105e14:	eb 15                	jmp    80105e2b <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e19:	89 04 24             	mov    %eax,(%esp)
80105e1c:	e8 ce bc ff ff       	call   80101aef <iunlockput>
  end_op();
80105e21:	e8 7e d6 ff ff       	call   801034a4 <end_op>
  return -1;
80105e26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e2b:	c9                   	leave  
80105e2c:	c3                   	ret    

80105e2d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e2d:	55                   	push   %ebp
80105e2e:	89 e5                	mov    %esp,%ebp
80105e30:	83 ec 48             	sub    $0x48,%esp
80105e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e36:	8b 55 10             	mov    0x10(%ebp),%edx
80105e39:	8b 45 14             	mov    0x14(%ebp),%eax
80105e3c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e40:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e44:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e48:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105e52:	89 04 24             	mov    %eax,(%esp)
80105e55:	e8 de c5 ff ff       	call   80102438 <nameiparent>
80105e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e61:	75 0a                	jne    80105e6d <create+0x40>
    return 0;
80105e63:	b8 00 00 00 00       	mov    $0x0,%eax
80105e68:	e9 7e 01 00 00       	jmp    80105feb <create+0x1be>
  ilock(dp);
80105e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e70:	89 04 24             	mov    %eax,(%esp)
80105e73:	e8 f3 b9 ff ff       	call   8010186b <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e78:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e7b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e7f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e82:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e89:	89 04 24             	mov    %eax,(%esp)
80105e8c:	e8 fc c1 ff ff       	call   8010208d <dirlookup>
80105e91:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e94:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e98:	74 47                	je     80105ee1 <create+0xb4>
    iunlockput(dp);
80105e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9d:	89 04 24             	mov    %eax,(%esp)
80105ea0:	e8 4a bc ff ff       	call   80101aef <iunlockput>
    ilock(ip);
80105ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea8:	89 04 24             	mov    %eax,(%esp)
80105eab:	e8 bb b9 ff ff       	call   8010186b <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105eb0:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105eb5:	75 15                	jne    80105ecc <create+0x9f>
80105eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eba:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ebe:	66 83 f8 02          	cmp    $0x2,%ax
80105ec2:	75 08                	jne    80105ecc <create+0x9f>
      return ip;
80105ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec7:	e9 1f 01 00 00       	jmp    80105feb <create+0x1be>
    iunlockput(ip);
80105ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ecf:	89 04 24             	mov    %eax,(%esp)
80105ed2:	e8 18 bc ff ff       	call   80101aef <iunlockput>
    return 0;
80105ed7:	b8 00 00 00 00       	mov    $0x0,%eax
80105edc:	e9 0a 01 00 00       	jmp    80105feb <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105ee1:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee8:	8b 00                	mov    (%eax),%eax
80105eea:	89 54 24 04          	mov    %edx,0x4(%esp)
80105eee:	89 04 24             	mov    %eax,(%esp)
80105ef1:	e8 da b6 ff ff       	call   801015d0 <ialloc>
80105ef6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ef9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105efd:	75 0c                	jne    80105f0b <create+0xde>
    panic("create: ialloc");
80105eff:	c7 04 24 4f 8b 10 80 	movl   $0x80108b4f,(%esp)
80105f06:	e8 2f a6 ff ff       	call   8010053a <panic>

  ilock(ip);
80105f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0e:	89 04 24             	mov    %eax,(%esp)
80105f11:	e8 55 b9 ff ff       	call   8010186b <ilock>
  ip->major = major;
80105f16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f19:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f1d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f24:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f28:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f38:	89 04 24             	mov    %eax,(%esp)
80105f3b:	e8 6f b7 ff ff       	call   801016af <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105f40:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f45:	75 6a                	jne    80105fb1 <create+0x184>
    dp->nlink++;  // for ".."
80105f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f4e:	8d 50 01             	lea    0x1(%eax),%edx
80105f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f54:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5b:	89 04 24             	mov    %eax,(%esp)
80105f5e:	e8 4c b7 ff ff       	call   801016af <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f66:	8b 40 04             	mov    0x4(%eax),%eax
80105f69:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f6d:	c7 44 24 04 29 8b 10 	movl   $0x80108b29,0x4(%esp)
80105f74:	80 
80105f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f78:	89 04 24             	mov    %eax,(%esp)
80105f7b:	e8 d6 c1 ff ff       	call   80102156 <dirlink>
80105f80:	85 c0                	test   %eax,%eax
80105f82:	78 21                	js     80105fa5 <create+0x178>
80105f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f87:	8b 40 04             	mov    0x4(%eax),%eax
80105f8a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f8e:	c7 44 24 04 2b 8b 10 	movl   $0x80108b2b,0x4(%esp)
80105f95:	80 
80105f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f99:	89 04 24             	mov    %eax,(%esp)
80105f9c:	e8 b5 c1 ff ff       	call   80102156 <dirlink>
80105fa1:	85 c0                	test   %eax,%eax
80105fa3:	79 0c                	jns    80105fb1 <create+0x184>
      panic("create dots");
80105fa5:	c7 04 24 5e 8b 10 80 	movl   $0x80108b5e,(%esp)
80105fac:	e8 89 a5 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105fb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb4:	8b 40 04             	mov    0x4(%eax),%eax
80105fb7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fbb:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc5:	89 04 24             	mov    %eax,(%esp)
80105fc8:	e8 89 c1 ff ff       	call   80102156 <dirlink>
80105fcd:	85 c0                	test   %eax,%eax
80105fcf:	79 0c                	jns    80105fdd <create+0x1b0>
    panic("create: dirlink");
80105fd1:	c7 04 24 6a 8b 10 80 	movl   $0x80108b6a,(%esp)
80105fd8:	e8 5d a5 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80105fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe0:	89 04 24             	mov    %eax,(%esp)
80105fe3:	e8 07 bb ff ff       	call   80101aef <iunlockput>

  return ip;
80105fe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105feb:	c9                   	leave  
80105fec:	c3                   	ret    

80105fed <sys_open>:

int
sys_open(void)
{
80105fed:	55                   	push   %ebp
80105fee:	89 e5                	mov    %esp,%ebp
80105ff0:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ff3:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ffa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106001:	e8 d9 f6 ff ff       	call   801056df <argstr>
80106006:	85 c0                	test   %eax,%eax
80106008:	78 17                	js     80106021 <sys_open+0x34>
8010600a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010600d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106011:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106018:	e8 32 f6 ff ff       	call   8010564f <argint>
8010601d:	85 c0                	test   %eax,%eax
8010601f:	79 0a                	jns    8010602b <sys_open+0x3e>
    return -1;
80106021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106026:	e9 5c 01 00 00       	jmp    80106187 <sys_open+0x19a>

  begin_op();
8010602b:	e8 f0 d3 ff ff       	call   80103420 <begin_op>

  if(omode & O_CREATE){
80106030:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106033:	25 00 02 00 00       	and    $0x200,%eax
80106038:	85 c0                	test   %eax,%eax
8010603a:	74 3b                	je     80106077 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010603c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010603f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106046:	00 
80106047:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010604e:	00 
8010604f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106056:	00 
80106057:	89 04 24             	mov    %eax,(%esp)
8010605a:	e8 ce fd ff ff       	call   80105e2d <create>
8010605f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106062:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106066:	75 6b                	jne    801060d3 <sys_open+0xe6>
      end_op();
80106068:	e8 37 d4 ff ff       	call   801034a4 <end_op>
      return -1;
8010606d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106072:	e9 10 01 00 00       	jmp    80106187 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80106077:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010607a:	89 04 24             	mov    %eax,(%esp)
8010607d:	e8 94 c3 ff ff       	call   80102416 <namei>
80106082:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106085:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106089:	75 0f                	jne    8010609a <sys_open+0xad>
      end_op();
8010608b:	e8 14 d4 ff ff       	call   801034a4 <end_op>
      return -1;
80106090:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106095:	e9 ed 00 00 00       	jmp    80106187 <sys_open+0x19a>
    }
    ilock(ip);
8010609a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609d:	89 04 24             	mov    %eax,(%esp)
801060a0:	e8 c6 b7 ff ff       	call   8010186b <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801060a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060ac:	66 83 f8 01          	cmp    $0x1,%ax
801060b0:	75 21                	jne    801060d3 <sys_open+0xe6>
801060b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060b5:	85 c0                	test   %eax,%eax
801060b7:	74 1a                	je     801060d3 <sys_open+0xe6>
      iunlockput(ip);
801060b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bc:	89 04 24             	mov    %eax,(%esp)
801060bf:	e8 2b ba ff ff       	call   80101aef <iunlockput>
      end_op();
801060c4:	e8 db d3 ff ff       	call   801034a4 <end_op>
      return -1;
801060c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ce:	e9 b4 00 00 00       	jmp    80106187 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801060d3:	e8 5e ae ff ff       	call   80100f36 <filealloc>
801060d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060df:	74 14                	je     801060f5 <sys_open+0x108>
801060e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e4:	89 04 24             	mov    %eax,(%esp)
801060e7:	e8 2e f7 ff ff       	call   8010581a <fdalloc>
801060ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
801060ef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801060f3:	79 28                	jns    8010611d <sys_open+0x130>
    if(f)
801060f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060f9:	74 0b                	je     80106106 <sys_open+0x119>
      fileclose(f);
801060fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fe:	89 04 24             	mov    %eax,(%esp)
80106101:	e8 d8 ae ff ff       	call   80100fde <fileclose>
    iunlockput(ip);
80106106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106109:	89 04 24             	mov    %eax,(%esp)
8010610c:	e8 de b9 ff ff       	call   80101aef <iunlockput>
    end_op();
80106111:	e8 8e d3 ff ff       	call   801034a4 <end_op>
    return -1;
80106116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611b:	eb 6a                	jmp    80106187 <sys_open+0x19a>
  }
  iunlock(ip);
8010611d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106120:	89 04 24             	mov    %eax,(%esp)
80106123:	e8 91 b8 ff ff       	call   801019b9 <iunlock>
  end_op();
80106128:	e8 77 d3 ff ff       	call   801034a4 <end_op>

  f->type = FD_INODE;
8010612d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106130:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106139:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010613c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010613f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106142:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106149:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010614c:	83 e0 01             	and    $0x1,%eax
8010614f:	85 c0                	test   %eax,%eax
80106151:	0f 94 c0             	sete   %al
80106154:	89 c2                	mov    %eax,%edx
80106156:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106159:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010615c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010615f:	83 e0 01             	and    $0x1,%eax
80106162:	85 c0                	test   %eax,%eax
80106164:	75 0a                	jne    80106170 <sys_open+0x183>
80106166:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106169:	83 e0 02             	and    $0x2,%eax
8010616c:	85 c0                	test   %eax,%eax
8010616e:	74 07                	je     80106177 <sys_open+0x18a>
80106170:	b8 01 00 00 00       	mov    $0x1,%eax
80106175:	eb 05                	jmp    8010617c <sys_open+0x18f>
80106177:	b8 00 00 00 00       	mov    $0x0,%eax
8010617c:	89 c2                	mov    %eax,%edx
8010617e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106181:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106184:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106187:	c9                   	leave  
80106188:	c3                   	ret    

80106189 <sys_mkdir>:

int
sys_mkdir(void)
{
80106189:	55                   	push   %ebp
8010618a:	89 e5                	mov    %esp,%ebp
8010618c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010618f:	e8 8c d2 ff ff       	call   80103420 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106194:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106197:	89 44 24 04          	mov    %eax,0x4(%esp)
8010619b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061a2:	e8 38 f5 ff ff       	call   801056df <argstr>
801061a7:	85 c0                	test   %eax,%eax
801061a9:	78 2c                	js     801061d7 <sys_mkdir+0x4e>
801061ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061b5:	00 
801061b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801061bd:	00 
801061be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801061c5:	00 
801061c6:	89 04 24             	mov    %eax,(%esp)
801061c9:	e8 5f fc ff ff       	call   80105e2d <create>
801061ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061d5:	75 0c                	jne    801061e3 <sys_mkdir+0x5a>
    end_op();
801061d7:	e8 c8 d2 ff ff       	call   801034a4 <end_op>
    return -1;
801061dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e1:	eb 15                	jmp    801061f8 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801061e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e6:	89 04 24             	mov    %eax,(%esp)
801061e9:	e8 01 b9 ff ff       	call   80101aef <iunlockput>
  end_op();
801061ee:	e8 b1 d2 ff ff       	call   801034a4 <end_op>
  return 0;
801061f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f8:	c9                   	leave  
801061f9:	c3                   	ret    

801061fa <sys_mknod>:

int
sys_mknod(void)
{
801061fa:	55                   	push   %ebp
801061fb:	89 e5                	mov    %esp,%ebp
801061fd:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106200:	e8 1b d2 ff ff       	call   80103420 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106205:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106208:	89 44 24 04          	mov    %eax,0x4(%esp)
8010620c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106213:	e8 c7 f4 ff ff       	call   801056df <argstr>
80106218:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010621b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010621f:	78 5e                	js     8010627f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106221:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106224:	89 44 24 04          	mov    %eax,0x4(%esp)
80106228:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010622f:	e8 1b f4 ff ff       	call   8010564f <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106234:	85 c0                	test   %eax,%eax
80106236:	78 47                	js     8010627f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106238:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010623b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010623f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106246:	e8 04 f4 ff ff       	call   8010564f <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010624b:	85 c0                	test   %eax,%eax
8010624d:	78 30                	js     8010627f <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010624f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106252:	0f bf c8             	movswl %ax,%ecx
80106255:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106258:	0f bf d0             	movswl %ax,%edx
8010625b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010625e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106262:	89 54 24 08          	mov    %edx,0x8(%esp)
80106266:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010626d:	00 
8010626e:	89 04 24             	mov    %eax,(%esp)
80106271:	e8 b7 fb ff ff       	call   80105e2d <create>
80106276:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106279:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010627d:	75 0c                	jne    8010628b <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010627f:	e8 20 d2 ff ff       	call   801034a4 <end_op>
    return -1;
80106284:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106289:	eb 15                	jmp    801062a0 <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010628b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010628e:	89 04 24             	mov    %eax,(%esp)
80106291:	e8 59 b8 ff ff       	call   80101aef <iunlockput>
  end_op();
80106296:	e8 09 d2 ff ff       	call   801034a4 <end_op>
  return 0;
8010629b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062a0:	c9                   	leave  
801062a1:	c3                   	ret    

801062a2 <sys_chdir>:

int
sys_chdir(void)
{
801062a2:	55                   	push   %ebp
801062a3:	89 e5                	mov    %esp,%ebp
801062a5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801062a8:	e8 73 d1 ff ff       	call   80103420 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062bb:	e8 1f f4 ff ff       	call   801056df <argstr>
801062c0:	85 c0                	test   %eax,%eax
801062c2:	78 14                	js     801062d8 <sys_chdir+0x36>
801062c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c7:	89 04 24             	mov    %eax,(%esp)
801062ca:	e8 47 c1 ff ff       	call   80102416 <namei>
801062cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062d6:	75 0c                	jne    801062e4 <sys_chdir+0x42>
    end_op();
801062d8:	e8 c7 d1 ff ff       	call   801034a4 <end_op>
    return -1;
801062dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e2:	eb 61                	jmp    80106345 <sys_chdir+0xa3>
  }
  ilock(ip);
801062e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e7:	89 04 24             	mov    %eax,(%esp)
801062ea:	e8 7c b5 ff ff       	call   8010186b <ilock>
  if(ip->type != T_DIR){
801062ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801062f6:	66 83 f8 01          	cmp    $0x1,%ax
801062fa:	74 17                	je     80106313 <sys_chdir+0x71>
    iunlockput(ip);
801062fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ff:	89 04 24             	mov    %eax,(%esp)
80106302:	e8 e8 b7 ff ff       	call   80101aef <iunlockput>
    end_op();
80106307:	e8 98 d1 ff ff       	call   801034a4 <end_op>
    return -1;
8010630c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106311:	eb 32                	jmp    80106345 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106316:	89 04 24             	mov    %eax,(%esp)
80106319:	e8 9b b6 ff ff       	call   801019b9 <iunlock>
  iput(proc->cwd);
8010631e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106324:	8b 40 68             	mov    0x68(%eax),%eax
80106327:	89 04 24             	mov    %eax,(%esp)
8010632a:	e8 ef b6 ff ff       	call   80101a1e <iput>
  end_op();
8010632f:	e8 70 d1 ff ff       	call   801034a4 <end_op>
  proc->cwd = ip;
80106334:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010633a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010633d:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106340:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106345:	c9                   	leave  
80106346:	c3                   	ret    

80106347 <sys_exec>:

int
sys_exec(void)
{
80106347:	55                   	push   %ebp
80106348:	89 e5                	mov    %esp,%ebp
8010634a:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106350:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106353:	89 44 24 04          	mov    %eax,0x4(%esp)
80106357:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010635e:	e8 7c f3 ff ff       	call   801056df <argstr>
80106363:	85 c0                	test   %eax,%eax
80106365:	78 1a                	js     80106381 <sys_exec+0x3a>
80106367:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010636d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106371:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106378:	e8 d2 f2 ff ff       	call   8010564f <argint>
8010637d:	85 c0                	test   %eax,%eax
8010637f:	79 0a                	jns    8010638b <sys_exec+0x44>
    return -1;
80106381:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106386:	e9 c8 00 00 00       	jmp    80106453 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
8010638b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106392:	00 
80106393:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010639a:	00 
8010639b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063a1:	89 04 24             	mov    %eax,(%esp)
801063a4:	e8 64 ef ff ff       	call   8010530d <memset>
  for(i=0;; i++){
801063a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b3:	83 f8 1f             	cmp    $0x1f,%eax
801063b6:	76 0a                	jbe    801063c2 <sys_exec+0x7b>
      return -1;
801063b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bd:	e9 91 00 00 00       	jmp    80106453 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801063c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c5:	c1 e0 02             	shl    $0x2,%eax
801063c8:	89 c2                	mov    %eax,%edx
801063ca:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063d0:	01 c2                	add    %eax,%edx
801063d2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801063d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801063dc:	89 14 24             	mov    %edx,(%esp)
801063df:	e8 cf f1 ff ff       	call   801055b3 <fetchint>
801063e4:	85 c0                	test   %eax,%eax
801063e6:	79 07                	jns    801063ef <sys_exec+0xa8>
      return -1;
801063e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ed:	eb 64                	jmp    80106453 <sys_exec+0x10c>
    if(uarg == 0){
801063ef:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063f5:	85 c0                	test   %eax,%eax
801063f7:	75 26                	jne    8010641f <sys_exec+0xd8>
      argv[i] = 0;
801063f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fc:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106403:	00 00 00 00 
      break;
80106407:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106408:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106411:	89 54 24 04          	mov    %edx,0x4(%esp)
80106415:	89 04 24             	mov    %eax,(%esp)
80106418:	e8 d2 a6 ff ff       	call   80100aef <exec>
8010641d:	eb 34                	jmp    80106453 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010641f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106425:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106428:	c1 e2 02             	shl    $0x2,%edx
8010642b:	01 c2                	add    %eax,%edx
8010642d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106433:	89 54 24 04          	mov    %edx,0x4(%esp)
80106437:	89 04 24             	mov    %eax,(%esp)
8010643a:	e8 ae f1 ff ff       	call   801055ed <fetchstr>
8010643f:	85 c0                	test   %eax,%eax
80106441:	79 07                	jns    8010644a <sys_exec+0x103>
      return -1;
80106443:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106448:	eb 09                	jmp    80106453 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010644a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010644e:	e9 5d ff ff ff       	jmp    801063b0 <sys_exec+0x69>
  return exec(path, argv);
}
80106453:	c9                   	leave  
80106454:	c3                   	ret    

80106455 <sys_pipe>:

int
sys_pipe(void)
{
80106455:	55                   	push   %ebp
80106456:	89 e5                	mov    %esp,%ebp
80106458:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010645b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106462:	00 
80106463:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106466:	89 44 24 04          	mov    %eax,0x4(%esp)
8010646a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106471:	e8 07 f2 ff ff       	call   8010567d <argptr>
80106476:	85 c0                	test   %eax,%eax
80106478:	79 0a                	jns    80106484 <sys_pipe+0x2f>
    return -1;
8010647a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647f:	e9 9b 00 00 00       	jmp    8010651f <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106484:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106487:	89 44 24 04          	mov    %eax,0x4(%esp)
8010648b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010648e:	89 04 24             	mov    %eax,(%esp)
80106491:	e8 9b da ff ff       	call   80103f31 <pipealloc>
80106496:	85 c0                	test   %eax,%eax
80106498:	79 07                	jns    801064a1 <sys_pipe+0x4c>
    return -1;
8010649a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649f:	eb 7e                	jmp    8010651f <sys_pipe+0xca>
  fd0 = -1;
801064a1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ab:	89 04 24             	mov    %eax,(%esp)
801064ae:	e8 67 f3 ff ff       	call   8010581a <fdalloc>
801064b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064ba:	78 14                	js     801064d0 <sys_pipe+0x7b>
801064bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064bf:	89 04 24             	mov    %eax,(%esp)
801064c2:	e8 53 f3 ff ff       	call   8010581a <fdalloc>
801064c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064ce:	79 37                	jns    80106507 <sys_pipe+0xb2>
    if(fd0 >= 0)
801064d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064d4:	78 14                	js     801064ea <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801064d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064df:	83 c2 08             	add    $0x8,%edx
801064e2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064e9:	00 
    fileclose(rf);
801064ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ed:	89 04 24             	mov    %eax,(%esp)
801064f0:	e8 e9 aa ff ff       	call   80100fde <fileclose>
    fileclose(wf);
801064f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064f8:	89 04 24             	mov    %eax,(%esp)
801064fb:	e8 de aa ff ff       	call   80100fde <fileclose>
    return -1;
80106500:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106505:	eb 18                	jmp    8010651f <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106507:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010650a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010650d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010650f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106512:	8d 50 04             	lea    0x4(%eax),%edx
80106515:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106518:	89 02                	mov    %eax,(%edx)
  return 0;
8010651a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010651f:	c9                   	leave  
80106520:	c3                   	ret    

80106521 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106521:	55                   	push   %ebp
80106522:	89 e5                	mov    %esp,%ebp
80106524:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106527:	e8 38 e1 ff ff       	call   80104664 <fork>
}
8010652c:	c9                   	leave  
8010652d:	c3                   	ret    

8010652e <sys_exit>:

int
sys_exit(void)
{
8010652e:	55                   	push   %ebp
8010652f:	89 e5                	mov    %esp,%ebp
80106531:	83 ec 08             	sub    $0x8,%esp
  exit();
80106534:	e8 bb e2 ff ff       	call   801047f4 <exit>
  return 0;  // not reached
80106539:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010653e:	c9                   	leave  
8010653f:	c3                   	ret    

80106540 <sys_wait>:

int
sys_wait(void)
{
80106540:	55                   	push   %ebp
80106541:	89 e5                	mov    %esp,%ebp
80106543:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106546:	e8 ce e3 ff ff       	call   80104919 <wait>
}
8010654b:	c9                   	leave  
8010654c:	c3                   	ret    

8010654d <sys_kill>:

int
sys_kill(void)
{
8010654d:	55                   	push   %ebp
8010654e:	89 e5                	mov    %esp,%ebp
80106550:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106553:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106556:	89 44 24 04          	mov    %eax,0x4(%esp)
8010655a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106561:	e8 e9 f0 ff ff       	call   8010564f <argint>
80106566:	85 c0                	test   %eax,%eax
80106568:	79 07                	jns    80106571 <sys_kill+0x24>
    return -1;
8010656a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656f:	eb 0b                	jmp    8010657c <sys_kill+0x2f>
  return kill(pid);
80106571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106574:	89 04 24             	mov    %eax,(%esp)
80106577:	e8 e2 e7 ff ff       	call   80104d5e <kill>
}
8010657c:	c9                   	leave  
8010657d:	c3                   	ret    

8010657e <sys_getpid>:

int
sys_getpid(void)
{
8010657e:	55                   	push   %ebp
8010657f:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106581:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106587:	8b 40 10             	mov    0x10(%eax),%eax
}
8010658a:	5d                   	pop    %ebp
8010658b:	c3                   	ret    

8010658c <sys_sbrk>:

int
sys_sbrk(void)
{
8010658c:	55                   	push   %ebp
8010658d:	89 e5                	mov    %esp,%ebp
8010658f:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106592:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106595:	89 44 24 04          	mov    %eax,0x4(%esp)
80106599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065a0:	e8 aa f0 ff ff       	call   8010564f <argint>
801065a5:	85 c0                	test   %eax,%eax
801065a7:	79 07                	jns    801065b0 <sys_sbrk+0x24>
    return -1;
801065a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ae:	eb 24                	jmp    801065d4 <sys_sbrk+0x48>
  addr = proc->sz;
801065b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065b6:	8b 00                	mov    (%eax),%eax
801065b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065be:	89 04 24             	mov    %eax,(%esp)
801065c1:	e8 f9 df ff ff       	call   801045bf <growproc>
801065c6:	85 c0                	test   %eax,%eax
801065c8:	79 07                	jns    801065d1 <sys_sbrk+0x45>
    return -1;
801065ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065cf:	eb 03                	jmp    801065d4 <sys_sbrk+0x48>
  return addr;
801065d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065d4:	c9                   	leave  
801065d5:	c3                   	ret    

801065d6 <sys_sleep>:

int
sys_sleep(void)
{
801065d6:	55                   	push   %ebp
801065d7:	89 e5                	mov    %esp,%ebp
801065d9:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801065dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065df:	89 44 24 04          	mov    %eax,0x4(%esp)
801065e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065ea:	e8 60 f0 ff ff       	call   8010564f <argint>
801065ef:	85 c0                	test   %eax,%eax
801065f1:	79 07                	jns    801065fa <sys_sleep+0x24>
    return -1;
801065f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f8:	eb 6c                	jmp    80106666 <sys_sleep+0x90>
  acquire(&tickslock);
801065fa:	c7 04 24 a0 81 11 80 	movl   $0x801181a0,(%esp)
80106601:	e8 b3 ea ff ff       	call   801050b9 <acquire>
  ticks0 = ticks;
80106606:	a1 e0 89 11 80       	mov    0x801189e0,%eax
8010660b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010660e:	eb 34                	jmp    80106644 <sys_sleep+0x6e>
    if(proc->killed){
80106610:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106616:	8b 40 24             	mov    0x24(%eax),%eax
80106619:	85 c0                	test   %eax,%eax
8010661b:	74 13                	je     80106630 <sys_sleep+0x5a>
      release(&tickslock);
8010661d:	c7 04 24 a0 81 11 80 	movl   $0x801181a0,(%esp)
80106624:	e8 f2 ea ff ff       	call   8010511b <release>
      return -1;
80106629:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662e:	eb 36                	jmp    80106666 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106630:	c7 44 24 04 a0 81 11 	movl   $0x801181a0,0x4(%esp)
80106637:	80 
80106638:	c7 04 24 e0 89 11 80 	movl   $0x801189e0,(%esp)
8010663f:	e8 14 e6 ff ff       	call   80104c58 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106644:	a1 e0 89 11 80       	mov    0x801189e0,%eax
80106649:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010664c:	89 c2                	mov    %eax,%edx
8010664e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106651:	39 c2                	cmp    %eax,%edx
80106653:	72 bb                	jb     80106610 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106655:	c7 04 24 a0 81 11 80 	movl   $0x801181a0,(%esp)
8010665c:	e8 ba ea ff ff       	call   8010511b <release>
  return 0;
80106661:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106666:	c9                   	leave  
80106667:	c3                   	ret    

80106668 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106668:	55                   	push   %ebp
80106669:	89 e5                	mov    %esp,%ebp
8010666b:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010666e:	c7 04 24 a0 81 11 80 	movl   $0x801181a0,(%esp)
80106675:	e8 3f ea ff ff       	call   801050b9 <acquire>
  xticks = ticks;
8010667a:	a1 e0 89 11 80       	mov    0x801189e0,%eax
8010667f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106682:	c7 04 24 a0 81 11 80 	movl   $0x801181a0,(%esp)
80106689:	e8 8d ea ff ff       	call   8010511b <release>
  return xticks;
8010668e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106691:	c9                   	leave  
80106692:	c3                   	ret    

80106693 <sys_sigset>:

int
sys_sigset(void)
{
80106693:	55                   	push   %ebp
80106694:	89 e5                	mov    %esp,%ebp
80106696:	83 ec 28             	sub    $0x28,%esp
  sig_handler new_handler;

  if(argptr(0, (char**)&new_handler, sizeof(sig_handler)) < 0)
80106699:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801066a0:	00 
801066a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801066a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066af:	e8 c9 ef ff ff       	call   8010567d <argptr>
801066b4:	85 c0                	test   %eax,%eax
801066b6:	79 07                	jns    801066bf <sys_sigset+0x2c>
    return -1;
801066b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066bd:	eb 0b                	jmp    801066ca <sys_sigset+0x37>
  return (int) sigset(new_handler);
801066bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c2:	89 04 24             	mov    %eax,(%esp)
801066c5:	e8 13 e8 ff ff       	call   80104edd <sigset>
}
801066ca:	c9                   	leave  
801066cb:	c3                   	ret    

801066cc <sys_sigsend>:

int
sys_sigsend(void)
{
801066cc:	55                   	push   %ebp
801066cd:	89 e5                	mov    %esp,%ebp
801066cf:	83 ec 28             	sub    $0x28,%esp
  int dest_pid;
  int value;

  if(argint(0, &dest_pid) < 0 || argint(0, &value) < 0)
801066d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801066d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066e0:	e8 6a ef ff ff       	call   8010564f <argint>
801066e5:	85 c0                	test   %eax,%eax
801066e7:	78 17                	js     80106700 <sys_sigsend+0x34>
801066e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801066f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066f7:	e8 53 ef ff ff       	call   8010564f <argint>
801066fc:	85 c0                	test   %eax,%eax
801066fe:	79 07                	jns    80106707 <sys_sigsend+0x3b>
    return -1;
80106700:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106705:	eb 12                	jmp    80106719 <sys_sigsend+0x4d>

  return sigsend(dest_pid, value);
80106707:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010670a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106711:	89 04 24             	mov    %eax,(%esp)
80106714:	e8 ed e7 ff ff       	call   80104f06 <sigsend>
80106719:	c9                   	leave  
8010671a:	c3                   	ret    

8010671b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010671b:	55                   	push   %ebp
8010671c:	89 e5                	mov    %esp,%ebp
8010671e:	83 ec 08             	sub    $0x8,%esp
80106721:	8b 55 08             	mov    0x8(%ebp),%edx
80106724:	8b 45 0c             	mov    0xc(%ebp),%eax
80106727:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010672b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010672e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106732:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106736:	ee                   	out    %al,(%dx)
}
80106737:	c9                   	leave  
80106738:	c3                   	ret    

80106739 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106739:	55                   	push   %ebp
8010673a:	89 e5                	mov    %esp,%ebp
8010673c:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010673f:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106746:	00 
80106747:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010674e:	e8 c8 ff ff ff       	call   8010671b <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106753:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010675a:	00 
8010675b:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106762:	e8 b4 ff ff ff       	call   8010671b <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106767:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010676e:	00 
8010676f:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106776:	e8 a0 ff ff ff       	call   8010671b <outb>
  picenable(IRQ_TIMER);
8010677b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106782:	e8 3d d6 ff ff       	call   80103dc4 <picenable>
}
80106787:	c9                   	leave  
80106788:	c3                   	ret    

80106789 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106789:	1e                   	push   %ds
  pushl %es
8010678a:	06                   	push   %es
  pushl %fs
8010678b:	0f a0                	push   %fs
  pushl %gs
8010678d:	0f a8                	push   %gs
  pushal
8010678f:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106790:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106794:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106796:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106798:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010679c:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010679e:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801067a0:	54                   	push   %esp
  call trap
801067a1:	e8 d8 01 00 00       	call   8010697e <trap>
  addl $4, %esp
801067a6:	83 c4 04             	add    $0x4,%esp

801067a9 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801067a9:	61                   	popa   
  popl %gs
801067aa:	0f a9                	pop    %gs
  popl %fs
801067ac:	0f a1                	pop    %fs
  popl %es
801067ae:	07                   	pop    %es
  popl %ds
801067af:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801067b0:	83 c4 08             	add    $0x8,%esp
  iret
801067b3:	cf                   	iret   

801067b4 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801067b4:	55                   	push   %ebp
801067b5:	89 e5                	mov    %esp,%ebp
801067b7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801067ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801067bd:	83 e8 01             	sub    $0x1,%eax
801067c0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801067c4:	8b 45 08             	mov    0x8(%ebp),%eax
801067c7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801067cb:	8b 45 08             	mov    0x8(%ebp),%eax
801067ce:	c1 e8 10             	shr    $0x10,%eax
801067d1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801067d5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067d8:	0f 01 18             	lidtl  (%eax)
}
801067db:	c9                   	leave  
801067dc:	c3                   	ret    

801067dd <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801067dd:	55                   	push   %ebp
801067de:	89 e5                	mov    %esp,%ebp
801067e0:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067e3:	0f 20 d0             	mov    %cr2,%eax
801067e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801067e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801067ec:	c9                   	leave  
801067ed:	c3                   	ret    

801067ee <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067ee:	55                   	push   %ebp
801067ef:	89 e5                	mov    %esp,%ebp
801067f1:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801067f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067fb:	e9 c3 00 00 00       	jmp    801068c3 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106803:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
8010680a:	89 c2                	mov    %eax,%edx
8010680c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680f:	66 89 14 c5 e0 81 11 	mov    %dx,-0x7fee7e20(,%eax,8)
80106816:	80 
80106817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681a:	66 c7 04 c5 e2 81 11 	movw   $0x8,-0x7fee7e1e(,%eax,8)
80106821:	80 08 00 
80106824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106827:	0f b6 14 c5 e4 81 11 	movzbl -0x7fee7e1c(,%eax,8),%edx
8010682e:	80 
8010682f:	83 e2 e0             	and    $0xffffffe0,%edx
80106832:	88 14 c5 e4 81 11 80 	mov    %dl,-0x7fee7e1c(,%eax,8)
80106839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683c:	0f b6 14 c5 e4 81 11 	movzbl -0x7fee7e1c(,%eax,8),%edx
80106843:	80 
80106844:	83 e2 1f             	and    $0x1f,%edx
80106847:	88 14 c5 e4 81 11 80 	mov    %dl,-0x7fee7e1c(,%eax,8)
8010684e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106851:	0f b6 14 c5 e5 81 11 	movzbl -0x7fee7e1b(,%eax,8),%edx
80106858:	80 
80106859:	83 e2 f0             	and    $0xfffffff0,%edx
8010685c:	83 ca 0e             	or     $0xe,%edx
8010685f:	88 14 c5 e5 81 11 80 	mov    %dl,-0x7fee7e1b(,%eax,8)
80106866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106869:	0f b6 14 c5 e5 81 11 	movzbl -0x7fee7e1b(,%eax,8),%edx
80106870:	80 
80106871:	83 e2 ef             	and    $0xffffffef,%edx
80106874:	88 14 c5 e5 81 11 80 	mov    %dl,-0x7fee7e1b(,%eax,8)
8010687b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010687e:	0f b6 14 c5 e5 81 11 	movzbl -0x7fee7e1b(,%eax,8),%edx
80106885:	80 
80106886:	83 e2 9f             	and    $0xffffff9f,%edx
80106889:	88 14 c5 e5 81 11 80 	mov    %dl,-0x7fee7e1b(,%eax,8)
80106890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106893:	0f b6 14 c5 e5 81 11 	movzbl -0x7fee7e1b(,%eax,8),%edx
8010689a:	80 
8010689b:	83 ca 80             	or     $0xffffff80,%edx
8010689e:	88 14 c5 e5 81 11 80 	mov    %dl,-0x7fee7e1b(,%eax,8)
801068a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a8:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801068af:	c1 e8 10             	shr    $0x10,%eax
801068b2:	89 c2                	mov    %eax,%edx
801068b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b7:	66 89 14 c5 e6 81 11 	mov    %dx,-0x7fee7e1a(,%eax,8)
801068be:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801068bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801068c3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801068ca:	0f 8e 30 ff ff ff    	jle    80106800 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801068d0:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
801068d5:	66 a3 e0 83 11 80    	mov    %ax,0x801183e0
801068db:	66 c7 05 e2 83 11 80 	movw   $0x8,0x801183e2
801068e2:	08 00 
801068e4:	0f b6 05 e4 83 11 80 	movzbl 0x801183e4,%eax
801068eb:	83 e0 e0             	and    $0xffffffe0,%eax
801068ee:	a2 e4 83 11 80       	mov    %al,0x801183e4
801068f3:	0f b6 05 e4 83 11 80 	movzbl 0x801183e4,%eax
801068fa:	83 e0 1f             	and    $0x1f,%eax
801068fd:	a2 e4 83 11 80       	mov    %al,0x801183e4
80106902:	0f b6 05 e5 83 11 80 	movzbl 0x801183e5,%eax
80106909:	83 c8 0f             	or     $0xf,%eax
8010690c:	a2 e5 83 11 80       	mov    %al,0x801183e5
80106911:	0f b6 05 e5 83 11 80 	movzbl 0x801183e5,%eax
80106918:	83 e0 ef             	and    $0xffffffef,%eax
8010691b:	a2 e5 83 11 80       	mov    %al,0x801183e5
80106920:	0f b6 05 e5 83 11 80 	movzbl 0x801183e5,%eax
80106927:	83 c8 60             	or     $0x60,%eax
8010692a:	a2 e5 83 11 80       	mov    %al,0x801183e5
8010692f:	0f b6 05 e5 83 11 80 	movzbl 0x801183e5,%eax
80106936:	83 c8 80             	or     $0xffffff80,%eax
80106939:	a2 e5 83 11 80       	mov    %al,0x801183e5
8010693e:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106943:	c1 e8 10             	shr    $0x10,%eax
80106946:	66 a3 e6 83 11 80    	mov    %ax,0x801183e6
  
  initlock(&tickslock, "time");
8010694c:	c7 44 24 04 7c 8b 10 	movl   $0x80108b7c,0x4(%esp)
80106953:	80 
80106954:	c7 04 24 a0 81 11 80 	movl   $0x801181a0,(%esp)
8010695b:	e8 38 e7 ff ff       	call   80105098 <initlock>
}
80106960:	c9                   	leave  
80106961:	c3                   	ret    

80106962 <idtinit>:

void
idtinit(void)
{
80106962:	55                   	push   %ebp
80106963:	89 e5                	mov    %esp,%ebp
80106965:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106968:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010696f:	00 
80106970:	c7 04 24 e0 81 11 80 	movl   $0x801181e0,(%esp)
80106977:	e8 38 fe ff ff       	call   801067b4 <lidt>
}
8010697c:	c9                   	leave  
8010697d:	c3                   	ret    

8010697e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010697e:	55                   	push   %ebp
8010697f:	89 e5                	mov    %esp,%ebp
80106981:	57                   	push   %edi
80106982:	56                   	push   %esi
80106983:	53                   	push   %ebx
80106984:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106987:	8b 45 08             	mov    0x8(%ebp),%eax
8010698a:	8b 40 30             	mov    0x30(%eax),%eax
8010698d:	83 f8 40             	cmp    $0x40,%eax
80106990:	75 3f                	jne    801069d1 <trap+0x53>
    if(proc->killed)
80106992:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106998:	8b 40 24             	mov    0x24(%eax),%eax
8010699b:	85 c0                	test   %eax,%eax
8010699d:	74 05                	je     801069a4 <trap+0x26>
      exit();
8010699f:	e8 50 de ff ff       	call   801047f4 <exit>
    proc->tf = tf;
801069a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069aa:	8b 55 08             	mov    0x8(%ebp),%edx
801069ad:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801069b0:	e8 61 ed ff ff       	call   80105716 <syscall>
    if(proc->killed)
801069b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069bb:	8b 40 24             	mov    0x24(%eax),%eax
801069be:	85 c0                	test   %eax,%eax
801069c0:	74 0a                	je     801069cc <trap+0x4e>
      exit();
801069c2:	e8 2d de ff ff       	call   801047f4 <exit>
    return;
801069c7:	e9 2d 02 00 00       	jmp    80106bf9 <trap+0x27b>
801069cc:	e9 28 02 00 00       	jmp    80106bf9 <trap+0x27b>
  }

  switch(tf->trapno){
801069d1:	8b 45 08             	mov    0x8(%ebp),%eax
801069d4:	8b 40 30             	mov    0x30(%eax),%eax
801069d7:	83 e8 20             	sub    $0x20,%eax
801069da:	83 f8 1f             	cmp    $0x1f,%eax
801069dd:	0f 87 bc 00 00 00    	ja     80106a9f <trap+0x121>
801069e3:	8b 04 85 24 8c 10 80 	mov    -0x7fef73dc(,%eax,4),%eax
801069ea:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801069ec:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069f2:	0f b6 00             	movzbl (%eax),%eax
801069f5:	84 c0                	test   %al,%al
801069f7:	75 31                	jne    80106a2a <trap+0xac>
      acquire(&tickslock);
801069f9:	c7 04 24 a0 81 11 80 	movl   $0x801181a0,(%esp)
80106a00:	e8 b4 e6 ff ff       	call   801050b9 <acquire>
      ticks++;
80106a05:	a1 e0 89 11 80       	mov    0x801189e0,%eax
80106a0a:	83 c0 01             	add    $0x1,%eax
80106a0d:	a3 e0 89 11 80       	mov    %eax,0x801189e0
      wakeup(&ticks);
80106a12:	c7 04 24 e0 89 11 80 	movl   $0x801189e0,(%esp)
80106a19:	e8 15 e3 ff ff       	call   80104d33 <wakeup>
      release(&tickslock);
80106a1e:	c7 04 24 a0 81 11 80 	movl   $0x801181a0,(%esp)
80106a25:	e8 f1 e6 ff ff       	call   8010511b <release>
    }
    lapiceoi();
80106a2a:	e8 b1 c4 ff ff       	call   80102ee0 <lapiceoi>
    break;
80106a2f:	e9 41 01 00 00       	jmp    80106b75 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a34:	e8 b5 bc ff ff       	call   801026ee <ideintr>
    lapiceoi();
80106a39:	e8 a2 c4 ff ff       	call   80102ee0 <lapiceoi>
    break;
80106a3e:	e9 32 01 00 00       	jmp    80106b75 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a43:	e8 67 c2 ff ff       	call   80102caf <kbdintr>
    lapiceoi();
80106a48:	e8 93 c4 ff ff       	call   80102ee0 <lapiceoi>
    break;
80106a4d:	e9 23 01 00 00       	jmp    80106b75 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a52:	e8 97 03 00 00       	call   80106dee <uartintr>
    lapiceoi();
80106a57:	e8 84 c4 ff ff       	call   80102ee0 <lapiceoi>
    break;
80106a5c:	e9 14 01 00 00       	jmp    80106b75 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a61:	8b 45 08             	mov    0x8(%ebp),%eax
80106a64:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106a67:	8b 45 08             	mov    0x8(%ebp),%eax
80106a6a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a6e:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106a71:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a77:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a7a:	0f b6 c0             	movzbl %al,%eax
80106a7d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a81:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a85:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a89:	c7 04 24 84 8b 10 80 	movl   $0x80108b84,(%esp)
80106a90:	e8 0b 99 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106a95:	e8 46 c4 ff ff       	call   80102ee0 <lapiceoi>
    break;
80106a9a:	e9 d6 00 00 00       	jmp    80106b75 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aa5:	85 c0                	test   %eax,%eax
80106aa7:	74 11                	je     80106aba <trap+0x13c>
80106aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80106aac:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ab0:	0f b7 c0             	movzwl %ax,%eax
80106ab3:	83 e0 03             	and    $0x3,%eax
80106ab6:	85 c0                	test   %eax,%eax
80106ab8:	75 46                	jne    80106b00 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106aba:	e8 1e fd ff ff       	call   801067dd <rcr2>
80106abf:	8b 55 08             	mov    0x8(%ebp),%edx
80106ac2:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106ac5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106acc:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106acf:	0f b6 ca             	movzbl %dl,%ecx
80106ad2:	8b 55 08             	mov    0x8(%ebp),%edx
80106ad5:	8b 52 30             	mov    0x30(%edx),%edx
80106ad8:	89 44 24 10          	mov    %eax,0x10(%esp)
80106adc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106ae0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106ae4:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ae8:	c7 04 24 a8 8b 10 80 	movl   $0x80108ba8,(%esp)
80106aef:	e8 ac 98 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106af4:	c7 04 24 da 8b 10 80 	movl   $0x80108bda,(%esp)
80106afb:	e8 3a 9a ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b00:	e8 d8 fc ff ff       	call   801067dd <rcr2>
80106b05:	89 c2                	mov    %eax,%edx
80106b07:	8b 45 08             	mov    0x8(%ebp),%eax
80106b0a:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b0d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b13:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b16:	0f b6 f0             	movzbl %al,%esi
80106b19:	8b 45 08             	mov    0x8(%ebp),%eax
80106b1c:	8b 58 34             	mov    0x34(%eax),%ebx
80106b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80106b22:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b25:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b2b:	83 c0 6c             	add    $0x6c,%eax
80106b2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b37:	8b 40 10             	mov    0x10(%eax),%eax
80106b3a:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106b3e:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106b42:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b46:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b4a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b4e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106b51:	89 74 24 08          	mov    %esi,0x8(%esp)
80106b55:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b59:	c7 04 24 e0 8b 10 80 	movl   $0x80108be0,(%esp)
80106b60:	e8 3b 98 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106b65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b6b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b72:	eb 01                	jmp    80106b75 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106b74:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b7b:	85 c0                	test   %eax,%eax
80106b7d:	74 24                	je     80106ba3 <trap+0x225>
80106b7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b85:	8b 40 24             	mov    0x24(%eax),%eax
80106b88:	85 c0                	test   %eax,%eax
80106b8a:	74 17                	je     80106ba3 <trap+0x225>
80106b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b93:	0f b7 c0             	movzwl %ax,%eax
80106b96:	83 e0 03             	and    $0x3,%eax
80106b99:	83 f8 03             	cmp    $0x3,%eax
80106b9c:	75 05                	jne    80106ba3 <trap+0x225>
    exit();
80106b9e:	e8 51 dc ff ff       	call   801047f4 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106ba3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ba9:	85 c0                	test   %eax,%eax
80106bab:	74 1e                	je     80106bcb <trap+0x24d>
80106bad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bb3:	8b 40 0c             	mov    0xc(%eax),%eax
80106bb6:	83 f8 04             	cmp    $0x4,%eax
80106bb9:	75 10                	jne    80106bcb <trap+0x24d>
80106bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80106bbe:	8b 40 30             	mov    0x30(%eax),%eax
80106bc1:	83 f8 20             	cmp    $0x20,%eax
80106bc4:	75 05                	jne    80106bcb <trap+0x24d>
    yield();
80106bc6:	e8 2f e0 ff ff       	call   80104bfa <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106bcb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bd1:	85 c0                	test   %eax,%eax
80106bd3:	74 24                	je     80106bf9 <trap+0x27b>
80106bd5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bdb:	8b 40 24             	mov    0x24(%eax),%eax
80106bde:	85 c0                	test   %eax,%eax
80106be0:	74 17                	je     80106bf9 <trap+0x27b>
80106be2:	8b 45 08             	mov    0x8(%ebp),%eax
80106be5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106be9:	0f b7 c0             	movzwl %ax,%eax
80106bec:	83 e0 03             	and    $0x3,%eax
80106bef:	83 f8 03             	cmp    $0x3,%eax
80106bf2:	75 05                	jne    80106bf9 <trap+0x27b>
    exit();
80106bf4:	e8 fb db ff ff       	call   801047f4 <exit>
}
80106bf9:	83 c4 3c             	add    $0x3c,%esp
80106bfc:	5b                   	pop    %ebx
80106bfd:	5e                   	pop    %esi
80106bfe:	5f                   	pop    %edi
80106bff:	5d                   	pop    %ebp
80106c00:	c3                   	ret    

80106c01 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106c01:	55                   	push   %ebp
80106c02:	89 e5                	mov    %esp,%ebp
80106c04:	83 ec 14             	sub    $0x14,%esp
80106c07:	8b 45 08             	mov    0x8(%ebp),%eax
80106c0a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c0e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106c12:	89 c2                	mov    %eax,%edx
80106c14:	ec                   	in     (%dx),%al
80106c15:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106c18:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106c1c:	c9                   	leave  
80106c1d:	c3                   	ret    

80106c1e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c1e:	55                   	push   %ebp
80106c1f:	89 e5                	mov    %esp,%ebp
80106c21:	83 ec 08             	sub    $0x8,%esp
80106c24:	8b 55 08             	mov    0x8(%ebp),%edx
80106c27:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c2a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c2e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c31:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c35:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c39:	ee                   	out    %al,(%dx)
}
80106c3a:	c9                   	leave  
80106c3b:	c3                   	ret    

80106c3c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c3c:	55                   	push   %ebp
80106c3d:	89 e5                	mov    %esp,%ebp
80106c3f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c42:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c49:	00 
80106c4a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c51:	e8 c8 ff ff ff       	call   80106c1e <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c56:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106c5d:	00 
80106c5e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c65:	e8 b4 ff ff ff       	call   80106c1e <outb>
  outb(COM1+0, 115200/9600);
80106c6a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106c71:	00 
80106c72:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c79:	e8 a0 ff ff ff       	call   80106c1e <outb>
  outb(COM1+1, 0);
80106c7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c85:	00 
80106c86:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c8d:	e8 8c ff ff ff       	call   80106c1e <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c92:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c99:	00 
80106c9a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106ca1:	e8 78 ff ff ff       	call   80106c1e <outb>
  outb(COM1+4, 0);
80106ca6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cad:	00 
80106cae:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106cb5:	e8 64 ff ff ff       	call   80106c1e <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106cba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106cc1:	00 
80106cc2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106cc9:	e8 50 ff ff ff       	call   80106c1e <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106cce:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106cd5:	e8 27 ff ff ff       	call   80106c01 <inb>
80106cda:	3c ff                	cmp    $0xff,%al
80106cdc:	75 02                	jne    80106ce0 <uartinit+0xa4>
    return;
80106cde:	eb 6a                	jmp    80106d4a <uartinit+0x10e>
  uart = 1;
80106ce0:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106ce7:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106cea:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106cf1:	e8 0b ff ff ff       	call   80106c01 <inb>
  inb(COM1+0);
80106cf6:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cfd:	e8 ff fe ff ff       	call   80106c01 <inb>
  picenable(IRQ_COM1);
80106d02:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d09:	e8 b6 d0 ff ff       	call   80103dc4 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106d0e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d15:	00 
80106d16:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d1d:	e8 4b bc ff ff       	call   8010296d <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d22:	c7 45 f4 a4 8c 10 80 	movl   $0x80108ca4,-0xc(%ebp)
80106d29:	eb 15                	jmp    80106d40 <uartinit+0x104>
    uartputc(*p);
80106d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d2e:	0f b6 00             	movzbl (%eax),%eax
80106d31:	0f be c0             	movsbl %al,%eax
80106d34:	89 04 24             	mov    %eax,(%esp)
80106d37:	e8 10 00 00 00       	call   80106d4c <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d3c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d43:	0f b6 00             	movzbl (%eax),%eax
80106d46:	84 c0                	test   %al,%al
80106d48:	75 e1                	jne    80106d2b <uartinit+0xef>
    uartputc(*p);
}
80106d4a:	c9                   	leave  
80106d4b:	c3                   	ret    

80106d4c <uartputc>:

void
uartputc(int c)
{
80106d4c:	55                   	push   %ebp
80106d4d:	89 e5                	mov    %esp,%ebp
80106d4f:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106d52:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106d57:	85 c0                	test   %eax,%eax
80106d59:	75 02                	jne    80106d5d <uartputc+0x11>
    return;
80106d5b:	eb 4b                	jmp    80106da8 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d64:	eb 10                	jmp    80106d76 <uartputc+0x2a>
    microdelay(10);
80106d66:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106d6d:	e8 93 c1 ff ff       	call   80102f05 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d72:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d76:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d7a:	7f 16                	jg     80106d92 <uartputc+0x46>
80106d7c:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d83:	e8 79 fe ff ff       	call   80106c01 <inb>
80106d88:	0f b6 c0             	movzbl %al,%eax
80106d8b:	83 e0 20             	and    $0x20,%eax
80106d8e:	85 c0                	test   %eax,%eax
80106d90:	74 d4                	je     80106d66 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106d92:	8b 45 08             	mov    0x8(%ebp),%eax
80106d95:	0f b6 c0             	movzbl %al,%eax
80106d98:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d9c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106da3:	e8 76 fe ff ff       	call   80106c1e <outb>
}
80106da8:	c9                   	leave  
80106da9:	c3                   	ret    

80106daa <uartgetc>:

static int
uartgetc(void)
{
80106daa:	55                   	push   %ebp
80106dab:	89 e5                	mov    %esp,%ebp
80106dad:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106db0:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106db5:	85 c0                	test   %eax,%eax
80106db7:	75 07                	jne    80106dc0 <uartgetc+0x16>
    return -1;
80106db9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dbe:	eb 2c                	jmp    80106dec <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106dc0:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dc7:	e8 35 fe ff ff       	call   80106c01 <inb>
80106dcc:	0f b6 c0             	movzbl %al,%eax
80106dcf:	83 e0 01             	and    $0x1,%eax
80106dd2:	85 c0                	test   %eax,%eax
80106dd4:	75 07                	jne    80106ddd <uartgetc+0x33>
    return -1;
80106dd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ddb:	eb 0f                	jmp    80106dec <uartgetc+0x42>
  return inb(COM1+0);
80106ddd:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106de4:	e8 18 fe ff ff       	call   80106c01 <inb>
80106de9:	0f b6 c0             	movzbl %al,%eax
}
80106dec:	c9                   	leave  
80106ded:	c3                   	ret    

80106dee <uartintr>:

void
uartintr(void)
{
80106dee:	55                   	push   %ebp
80106def:	89 e5                	mov    %esp,%ebp
80106df1:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106df4:	c7 04 24 aa 6d 10 80 	movl   $0x80106daa,(%esp)
80106dfb:	e8 ad 99 ff ff       	call   801007ad <consoleintr>
}
80106e00:	c9                   	leave  
80106e01:	c3                   	ret    

80106e02 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e02:	6a 00                	push   $0x0
  pushl $0
80106e04:	6a 00                	push   $0x0
  jmp alltraps
80106e06:	e9 7e f9 ff ff       	jmp    80106789 <alltraps>

80106e0b <vector1>:
.globl vector1
vector1:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $1
80106e0d:	6a 01                	push   $0x1
  jmp alltraps
80106e0f:	e9 75 f9 ff ff       	jmp    80106789 <alltraps>

80106e14 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $2
80106e16:	6a 02                	push   $0x2
  jmp alltraps
80106e18:	e9 6c f9 ff ff       	jmp    80106789 <alltraps>

80106e1d <vector3>:
.globl vector3
vector3:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $3
80106e1f:	6a 03                	push   $0x3
  jmp alltraps
80106e21:	e9 63 f9 ff ff       	jmp    80106789 <alltraps>

80106e26 <vector4>:
.globl vector4
vector4:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $4
80106e28:	6a 04                	push   $0x4
  jmp alltraps
80106e2a:	e9 5a f9 ff ff       	jmp    80106789 <alltraps>

80106e2f <vector5>:
.globl vector5
vector5:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $5
80106e31:	6a 05                	push   $0x5
  jmp alltraps
80106e33:	e9 51 f9 ff ff       	jmp    80106789 <alltraps>

80106e38 <vector6>:
.globl vector6
vector6:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $6
80106e3a:	6a 06                	push   $0x6
  jmp alltraps
80106e3c:	e9 48 f9 ff ff       	jmp    80106789 <alltraps>

80106e41 <vector7>:
.globl vector7
vector7:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $7
80106e43:	6a 07                	push   $0x7
  jmp alltraps
80106e45:	e9 3f f9 ff ff       	jmp    80106789 <alltraps>

80106e4a <vector8>:
.globl vector8
vector8:
  pushl $8
80106e4a:	6a 08                	push   $0x8
  jmp alltraps
80106e4c:	e9 38 f9 ff ff       	jmp    80106789 <alltraps>

80106e51 <vector9>:
.globl vector9
vector9:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $9
80106e53:	6a 09                	push   $0x9
  jmp alltraps
80106e55:	e9 2f f9 ff ff       	jmp    80106789 <alltraps>

80106e5a <vector10>:
.globl vector10
vector10:
  pushl $10
80106e5a:	6a 0a                	push   $0xa
  jmp alltraps
80106e5c:	e9 28 f9 ff ff       	jmp    80106789 <alltraps>

80106e61 <vector11>:
.globl vector11
vector11:
  pushl $11
80106e61:	6a 0b                	push   $0xb
  jmp alltraps
80106e63:	e9 21 f9 ff ff       	jmp    80106789 <alltraps>

80106e68 <vector12>:
.globl vector12
vector12:
  pushl $12
80106e68:	6a 0c                	push   $0xc
  jmp alltraps
80106e6a:	e9 1a f9 ff ff       	jmp    80106789 <alltraps>

80106e6f <vector13>:
.globl vector13
vector13:
  pushl $13
80106e6f:	6a 0d                	push   $0xd
  jmp alltraps
80106e71:	e9 13 f9 ff ff       	jmp    80106789 <alltraps>

80106e76 <vector14>:
.globl vector14
vector14:
  pushl $14
80106e76:	6a 0e                	push   $0xe
  jmp alltraps
80106e78:	e9 0c f9 ff ff       	jmp    80106789 <alltraps>

80106e7d <vector15>:
.globl vector15
vector15:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $15
80106e7f:	6a 0f                	push   $0xf
  jmp alltraps
80106e81:	e9 03 f9 ff ff       	jmp    80106789 <alltraps>

80106e86 <vector16>:
.globl vector16
vector16:
  pushl $0
80106e86:	6a 00                	push   $0x0
  pushl $16
80106e88:	6a 10                	push   $0x10
  jmp alltraps
80106e8a:	e9 fa f8 ff ff       	jmp    80106789 <alltraps>

80106e8f <vector17>:
.globl vector17
vector17:
  pushl $17
80106e8f:	6a 11                	push   $0x11
  jmp alltraps
80106e91:	e9 f3 f8 ff ff       	jmp    80106789 <alltraps>

80106e96 <vector18>:
.globl vector18
vector18:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $18
80106e98:	6a 12                	push   $0x12
  jmp alltraps
80106e9a:	e9 ea f8 ff ff       	jmp    80106789 <alltraps>

80106e9f <vector19>:
.globl vector19
vector19:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $19
80106ea1:	6a 13                	push   $0x13
  jmp alltraps
80106ea3:	e9 e1 f8 ff ff       	jmp    80106789 <alltraps>

80106ea8 <vector20>:
.globl vector20
vector20:
  pushl $0
80106ea8:	6a 00                	push   $0x0
  pushl $20
80106eaa:	6a 14                	push   $0x14
  jmp alltraps
80106eac:	e9 d8 f8 ff ff       	jmp    80106789 <alltraps>

80106eb1 <vector21>:
.globl vector21
vector21:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $21
80106eb3:	6a 15                	push   $0x15
  jmp alltraps
80106eb5:	e9 cf f8 ff ff       	jmp    80106789 <alltraps>

80106eba <vector22>:
.globl vector22
vector22:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $22
80106ebc:	6a 16                	push   $0x16
  jmp alltraps
80106ebe:	e9 c6 f8 ff ff       	jmp    80106789 <alltraps>

80106ec3 <vector23>:
.globl vector23
vector23:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $23
80106ec5:	6a 17                	push   $0x17
  jmp alltraps
80106ec7:	e9 bd f8 ff ff       	jmp    80106789 <alltraps>

80106ecc <vector24>:
.globl vector24
vector24:
  pushl $0
80106ecc:	6a 00                	push   $0x0
  pushl $24
80106ece:	6a 18                	push   $0x18
  jmp alltraps
80106ed0:	e9 b4 f8 ff ff       	jmp    80106789 <alltraps>

80106ed5 <vector25>:
.globl vector25
vector25:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $25
80106ed7:	6a 19                	push   $0x19
  jmp alltraps
80106ed9:	e9 ab f8 ff ff       	jmp    80106789 <alltraps>

80106ede <vector26>:
.globl vector26
vector26:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $26
80106ee0:	6a 1a                	push   $0x1a
  jmp alltraps
80106ee2:	e9 a2 f8 ff ff       	jmp    80106789 <alltraps>

80106ee7 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $27
80106ee9:	6a 1b                	push   $0x1b
  jmp alltraps
80106eeb:	e9 99 f8 ff ff       	jmp    80106789 <alltraps>

80106ef0 <vector28>:
.globl vector28
vector28:
  pushl $0
80106ef0:	6a 00                	push   $0x0
  pushl $28
80106ef2:	6a 1c                	push   $0x1c
  jmp alltraps
80106ef4:	e9 90 f8 ff ff       	jmp    80106789 <alltraps>

80106ef9 <vector29>:
.globl vector29
vector29:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $29
80106efb:	6a 1d                	push   $0x1d
  jmp alltraps
80106efd:	e9 87 f8 ff ff       	jmp    80106789 <alltraps>

80106f02 <vector30>:
.globl vector30
vector30:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $30
80106f04:	6a 1e                	push   $0x1e
  jmp alltraps
80106f06:	e9 7e f8 ff ff       	jmp    80106789 <alltraps>

80106f0b <vector31>:
.globl vector31
vector31:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $31
80106f0d:	6a 1f                	push   $0x1f
  jmp alltraps
80106f0f:	e9 75 f8 ff ff       	jmp    80106789 <alltraps>

80106f14 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f14:	6a 00                	push   $0x0
  pushl $32
80106f16:	6a 20                	push   $0x20
  jmp alltraps
80106f18:	e9 6c f8 ff ff       	jmp    80106789 <alltraps>

80106f1d <vector33>:
.globl vector33
vector33:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $33
80106f1f:	6a 21                	push   $0x21
  jmp alltraps
80106f21:	e9 63 f8 ff ff       	jmp    80106789 <alltraps>

80106f26 <vector34>:
.globl vector34
vector34:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $34
80106f28:	6a 22                	push   $0x22
  jmp alltraps
80106f2a:	e9 5a f8 ff ff       	jmp    80106789 <alltraps>

80106f2f <vector35>:
.globl vector35
vector35:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $35
80106f31:	6a 23                	push   $0x23
  jmp alltraps
80106f33:	e9 51 f8 ff ff       	jmp    80106789 <alltraps>

80106f38 <vector36>:
.globl vector36
vector36:
  pushl $0
80106f38:	6a 00                	push   $0x0
  pushl $36
80106f3a:	6a 24                	push   $0x24
  jmp alltraps
80106f3c:	e9 48 f8 ff ff       	jmp    80106789 <alltraps>

80106f41 <vector37>:
.globl vector37
vector37:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $37
80106f43:	6a 25                	push   $0x25
  jmp alltraps
80106f45:	e9 3f f8 ff ff       	jmp    80106789 <alltraps>

80106f4a <vector38>:
.globl vector38
vector38:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $38
80106f4c:	6a 26                	push   $0x26
  jmp alltraps
80106f4e:	e9 36 f8 ff ff       	jmp    80106789 <alltraps>

80106f53 <vector39>:
.globl vector39
vector39:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $39
80106f55:	6a 27                	push   $0x27
  jmp alltraps
80106f57:	e9 2d f8 ff ff       	jmp    80106789 <alltraps>

80106f5c <vector40>:
.globl vector40
vector40:
  pushl $0
80106f5c:	6a 00                	push   $0x0
  pushl $40
80106f5e:	6a 28                	push   $0x28
  jmp alltraps
80106f60:	e9 24 f8 ff ff       	jmp    80106789 <alltraps>

80106f65 <vector41>:
.globl vector41
vector41:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $41
80106f67:	6a 29                	push   $0x29
  jmp alltraps
80106f69:	e9 1b f8 ff ff       	jmp    80106789 <alltraps>

80106f6e <vector42>:
.globl vector42
vector42:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $42
80106f70:	6a 2a                	push   $0x2a
  jmp alltraps
80106f72:	e9 12 f8 ff ff       	jmp    80106789 <alltraps>

80106f77 <vector43>:
.globl vector43
vector43:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $43
80106f79:	6a 2b                	push   $0x2b
  jmp alltraps
80106f7b:	e9 09 f8 ff ff       	jmp    80106789 <alltraps>

80106f80 <vector44>:
.globl vector44
vector44:
  pushl $0
80106f80:	6a 00                	push   $0x0
  pushl $44
80106f82:	6a 2c                	push   $0x2c
  jmp alltraps
80106f84:	e9 00 f8 ff ff       	jmp    80106789 <alltraps>

80106f89 <vector45>:
.globl vector45
vector45:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $45
80106f8b:	6a 2d                	push   $0x2d
  jmp alltraps
80106f8d:	e9 f7 f7 ff ff       	jmp    80106789 <alltraps>

80106f92 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $46
80106f94:	6a 2e                	push   $0x2e
  jmp alltraps
80106f96:	e9 ee f7 ff ff       	jmp    80106789 <alltraps>

80106f9b <vector47>:
.globl vector47
vector47:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $47
80106f9d:	6a 2f                	push   $0x2f
  jmp alltraps
80106f9f:	e9 e5 f7 ff ff       	jmp    80106789 <alltraps>

80106fa4 <vector48>:
.globl vector48
vector48:
  pushl $0
80106fa4:	6a 00                	push   $0x0
  pushl $48
80106fa6:	6a 30                	push   $0x30
  jmp alltraps
80106fa8:	e9 dc f7 ff ff       	jmp    80106789 <alltraps>

80106fad <vector49>:
.globl vector49
vector49:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $49
80106faf:	6a 31                	push   $0x31
  jmp alltraps
80106fb1:	e9 d3 f7 ff ff       	jmp    80106789 <alltraps>

80106fb6 <vector50>:
.globl vector50
vector50:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $50
80106fb8:	6a 32                	push   $0x32
  jmp alltraps
80106fba:	e9 ca f7 ff ff       	jmp    80106789 <alltraps>

80106fbf <vector51>:
.globl vector51
vector51:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $51
80106fc1:	6a 33                	push   $0x33
  jmp alltraps
80106fc3:	e9 c1 f7 ff ff       	jmp    80106789 <alltraps>

80106fc8 <vector52>:
.globl vector52
vector52:
  pushl $0
80106fc8:	6a 00                	push   $0x0
  pushl $52
80106fca:	6a 34                	push   $0x34
  jmp alltraps
80106fcc:	e9 b8 f7 ff ff       	jmp    80106789 <alltraps>

80106fd1 <vector53>:
.globl vector53
vector53:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $53
80106fd3:	6a 35                	push   $0x35
  jmp alltraps
80106fd5:	e9 af f7 ff ff       	jmp    80106789 <alltraps>

80106fda <vector54>:
.globl vector54
vector54:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $54
80106fdc:	6a 36                	push   $0x36
  jmp alltraps
80106fde:	e9 a6 f7 ff ff       	jmp    80106789 <alltraps>

80106fe3 <vector55>:
.globl vector55
vector55:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $55
80106fe5:	6a 37                	push   $0x37
  jmp alltraps
80106fe7:	e9 9d f7 ff ff       	jmp    80106789 <alltraps>

80106fec <vector56>:
.globl vector56
vector56:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $56
80106fee:	6a 38                	push   $0x38
  jmp alltraps
80106ff0:	e9 94 f7 ff ff       	jmp    80106789 <alltraps>

80106ff5 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $57
80106ff7:	6a 39                	push   $0x39
  jmp alltraps
80106ff9:	e9 8b f7 ff ff       	jmp    80106789 <alltraps>

80106ffe <vector58>:
.globl vector58
vector58:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $58
80107000:	6a 3a                	push   $0x3a
  jmp alltraps
80107002:	e9 82 f7 ff ff       	jmp    80106789 <alltraps>

80107007 <vector59>:
.globl vector59
vector59:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $59
80107009:	6a 3b                	push   $0x3b
  jmp alltraps
8010700b:	e9 79 f7 ff ff       	jmp    80106789 <alltraps>

80107010 <vector60>:
.globl vector60
vector60:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $60
80107012:	6a 3c                	push   $0x3c
  jmp alltraps
80107014:	e9 70 f7 ff ff       	jmp    80106789 <alltraps>

80107019 <vector61>:
.globl vector61
vector61:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $61
8010701b:	6a 3d                	push   $0x3d
  jmp alltraps
8010701d:	e9 67 f7 ff ff       	jmp    80106789 <alltraps>

80107022 <vector62>:
.globl vector62
vector62:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $62
80107024:	6a 3e                	push   $0x3e
  jmp alltraps
80107026:	e9 5e f7 ff ff       	jmp    80106789 <alltraps>

8010702b <vector63>:
.globl vector63
vector63:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $63
8010702d:	6a 3f                	push   $0x3f
  jmp alltraps
8010702f:	e9 55 f7 ff ff       	jmp    80106789 <alltraps>

80107034 <vector64>:
.globl vector64
vector64:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $64
80107036:	6a 40                	push   $0x40
  jmp alltraps
80107038:	e9 4c f7 ff ff       	jmp    80106789 <alltraps>

8010703d <vector65>:
.globl vector65
vector65:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $65
8010703f:	6a 41                	push   $0x41
  jmp alltraps
80107041:	e9 43 f7 ff ff       	jmp    80106789 <alltraps>

80107046 <vector66>:
.globl vector66
vector66:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $66
80107048:	6a 42                	push   $0x42
  jmp alltraps
8010704a:	e9 3a f7 ff ff       	jmp    80106789 <alltraps>

8010704f <vector67>:
.globl vector67
vector67:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $67
80107051:	6a 43                	push   $0x43
  jmp alltraps
80107053:	e9 31 f7 ff ff       	jmp    80106789 <alltraps>

80107058 <vector68>:
.globl vector68
vector68:
  pushl $0
80107058:	6a 00                	push   $0x0
  pushl $68
8010705a:	6a 44                	push   $0x44
  jmp alltraps
8010705c:	e9 28 f7 ff ff       	jmp    80106789 <alltraps>

80107061 <vector69>:
.globl vector69
vector69:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $69
80107063:	6a 45                	push   $0x45
  jmp alltraps
80107065:	e9 1f f7 ff ff       	jmp    80106789 <alltraps>

8010706a <vector70>:
.globl vector70
vector70:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $70
8010706c:	6a 46                	push   $0x46
  jmp alltraps
8010706e:	e9 16 f7 ff ff       	jmp    80106789 <alltraps>

80107073 <vector71>:
.globl vector71
vector71:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $71
80107075:	6a 47                	push   $0x47
  jmp alltraps
80107077:	e9 0d f7 ff ff       	jmp    80106789 <alltraps>

8010707c <vector72>:
.globl vector72
vector72:
  pushl $0
8010707c:	6a 00                	push   $0x0
  pushl $72
8010707e:	6a 48                	push   $0x48
  jmp alltraps
80107080:	e9 04 f7 ff ff       	jmp    80106789 <alltraps>

80107085 <vector73>:
.globl vector73
vector73:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $73
80107087:	6a 49                	push   $0x49
  jmp alltraps
80107089:	e9 fb f6 ff ff       	jmp    80106789 <alltraps>

8010708e <vector74>:
.globl vector74
vector74:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $74
80107090:	6a 4a                	push   $0x4a
  jmp alltraps
80107092:	e9 f2 f6 ff ff       	jmp    80106789 <alltraps>

80107097 <vector75>:
.globl vector75
vector75:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $75
80107099:	6a 4b                	push   $0x4b
  jmp alltraps
8010709b:	e9 e9 f6 ff ff       	jmp    80106789 <alltraps>

801070a0 <vector76>:
.globl vector76
vector76:
  pushl $0
801070a0:	6a 00                	push   $0x0
  pushl $76
801070a2:	6a 4c                	push   $0x4c
  jmp alltraps
801070a4:	e9 e0 f6 ff ff       	jmp    80106789 <alltraps>

801070a9 <vector77>:
.globl vector77
vector77:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $77
801070ab:	6a 4d                	push   $0x4d
  jmp alltraps
801070ad:	e9 d7 f6 ff ff       	jmp    80106789 <alltraps>

801070b2 <vector78>:
.globl vector78
vector78:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $78
801070b4:	6a 4e                	push   $0x4e
  jmp alltraps
801070b6:	e9 ce f6 ff ff       	jmp    80106789 <alltraps>

801070bb <vector79>:
.globl vector79
vector79:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $79
801070bd:	6a 4f                	push   $0x4f
  jmp alltraps
801070bf:	e9 c5 f6 ff ff       	jmp    80106789 <alltraps>

801070c4 <vector80>:
.globl vector80
vector80:
  pushl $0
801070c4:	6a 00                	push   $0x0
  pushl $80
801070c6:	6a 50                	push   $0x50
  jmp alltraps
801070c8:	e9 bc f6 ff ff       	jmp    80106789 <alltraps>

801070cd <vector81>:
.globl vector81
vector81:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $81
801070cf:	6a 51                	push   $0x51
  jmp alltraps
801070d1:	e9 b3 f6 ff ff       	jmp    80106789 <alltraps>

801070d6 <vector82>:
.globl vector82
vector82:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $82
801070d8:	6a 52                	push   $0x52
  jmp alltraps
801070da:	e9 aa f6 ff ff       	jmp    80106789 <alltraps>

801070df <vector83>:
.globl vector83
vector83:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $83
801070e1:	6a 53                	push   $0x53
  jmp alltraps
801070e3:	e9 a1 f6 ff ff       	jmp    80106789 <alltraps>

801070e8 <vector84>:
.globl vector84
vector84:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $84
801070ea:	6a 54                	push   $0x54
  jmp alltraps
801070ec:	e9 98 f6 ff ff       	jmp    80106789 <alltraps>

801070f1 <vector85>:
.globl vector85
vector85:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $85
801070f3:	6a 55                	push   $0x55
  jmp alltraps
801070f5:	e9 8f f6 ff ff       	jmp    80106789 <alltraps>

801070fa <vector86>:
.globl vector86
vector86:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $86
801070fc:	6a 56                	push   $0x56
  jmp alltraps
801070fe:	e9 86 f6 ff ff       	jmp    80106789 <alltraps>

80107103 <vector87>:
.globl vector87
vector87:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $87
80107105:	6a 57                	push   $0x57
  jmp alltraps
80107107:	e9 7d f6 ff ff       	jmp    80106789 <alltraps>

8010710c <vector88>:
.globl vector88
vector88:
  pushl $0
8010710c:	6a 00                	push   $0x0
  pushl $88
8010710e:	6a 58                	push   $0x58
  jmp alltraps
80107110:	e9 74 f6 ff ff       	jmp    80106789 <alltraps>

80107115 <vector89>:
.globl vector89
vector89:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $89
80107117:	6a 59                	push   $0x59
  jmp alltraps
80107119:	e9 6b f6 ff ff       	jmp    80106789 <alltraps>

8010711e <vector90>:
.globl vector90
vector90:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $90
80107120:	6a 5a                	push   $0x5a
  jmp alltraps
80107122:	e9 62 f6 ff ff       	jmp    80106789 <alltraps>

80107127 <vector91>:
.globl vector91
vector91:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $91
80107129:	6a 5b                	push   $0x5b
  jmp alltraps
8010712b:	e9 59 f6 ff ff       	jmp    80106789 <alltraps>

80107130 <vector92>:
.globl vector92
vector92:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $92
80107132:	6a 5c                	push   $0x5c
  jmp alltraps
80107134:	e9 50 f6 ff ff       	jmp    80106789 <alltraps>

80107139 <vector93>:
.globl vector93
vector93:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $93
8010713b:	6a 5d                	push   $0x5d
  jmp alltraps
8010713d:	e9 47 f6 ff ff       	jmp    80106789 <alltraps>

80107142 <vector94>:
.globl vector94
vector94:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $94
80107144:	6a 5e                	push   $0x5e
  jmp alltraps
80107146:	e9 3e f6 ff ff       	jmp    80106789 <alltraps>

8010714b <vector95>:
.globl vector95
vector95:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $95
8010714d:	6a 5f                	push   $0x5f
  jmp alltraps
8010714f:	e9 35 f6 ff ff       	jmp    80106789 <alltraps>

80107154 <vector96>:
.globl vector96
vector96:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $96
80107156:	6a 60                	push   $0x60
  jmp alltraps
80107158:	e9 2c f6 ff ff       	jmp    80106789 <alltraps>

8010715d <vector97>:
.globl vector97
vector97:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $97
8010715f:	6a 61                	push   $0x61
  jmp alltraps
80107161:	e9 23 f6 ff ff       	jmp    80106789 <alltraps>

80107166 <vector98>:
.globl vector98
vector98:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $98
80107168:	6a 62                	push   $0x62
  jmp alltraps
8010716a:	e9 1a f6 ff ff       	jmp    80106789 <alltraps>

8010716f <vector99>:
.globl vector99
vector99:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $99
80107171:	6a 63                	push   $0x63
  jmp alltraps
80107173:	e9 11 f6 ff ff       	jmp    80106789 <alltraps>

80107178 <vector100>:
.globl vector100
vector100:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $100
8010717a:	6a 64                	push   $0x64
  jmp alltraps
8010717c:	e9 08 f6 ff ff       	jmp    80106789 <alltraps>

80107181 <vector101>:
.globl vector101
vector101:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $101
80107183:	6a 65                	push   $0x65
  jmp alltraps
80107185:	e9 ff f5 ff ff       	jmp    80106789 <alltraps>

8010718a <vector102>:
.globl vector102
vector102:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $102
8010718c:	6a 66                	push   $0x66
  jmp alltraps
8010718e:	e9 f6 f5 ff ff       	jmp    80106789 <alltraps>

80107193 <vector103>:
.globl vector103
vector103:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $103
80107195:	6a 67                	push   $0x67
  jmp alltraps
80107197:	e9 ed f5 ff ff       	jmp    80106789 <alltraps>

8010719c <vector104>:
.globl vector104
vector104:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $104
8010719e:	6a 68                	push   $0x68
  jmp alltraps
801071a0:	e9 e4 f5 ff ff       	jmp    80106789 <alltraps>

801071a5 <vector105>:
.globl vector105
vector105:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $105
801071a7:	6a 69                	push   $0x69
  jmp alltraps
801071a9:	e9 db f5 ff ff       	jmp    80106789 <alltraps>

801071ae <vector106>:
.globl vector106
vector106:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $106
801071b0:	6a 6a                	push   $0x6a
  jmp alltraps
801071b2:	e9 d2 f5 ff ff       	jmp    80106789 <alltraps>

801071b7 <vector107>:
.globl vector107
vector107:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $107
801071b9:	6a 6b                	push   $0x6b
  jmp alltraps
801071bb:	e9 c9 f5 ff ff       	jmp    80106789 <alltraps>

801071c0 <vector108>:
.globl vector108
vector108:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $108
801071c2:	6a 6c                	push   $0x6c
  jmp alltraps
801071c4:	e9 c0 f5 ff ff       	jmp    80106789 <alltraps>

801071c9 <vector109>:
.globl vector109
vector109:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $109
801071cb:	6a 6d                	push   $0x6d
  jmp alltraps
801071cd:	e9 b7 f5 ff ff       	jmp    80106789 <alltraps>

801071d2 <vector110>:
.globl vector110
vector110:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $110
801071d4:	6a 6e                	push   $0x6e
  jmp alltraps
801071d6:	e9 ae f5 ff ff       	jmp    80106789 <alltraps>

801071db <vector111>:
.globl vector111
vector111:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $111
801071dd:	6a 6f                	push   $0x6f
  jmp alltraps
801071df:	e9 a5 f5 ff ff       	jmp    80106789 <alltraps>

801071e4 <vector112>:
.globl vector112
vector112:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $112
801071e6:	6a 70                	push   $0x70
  jmp alltraps
801071e8:	e9 9c f5 ff ff       	jmp    80106789 <alltraps>

801071ed <vector113>:
.globl vector113
vector113:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $113
801071ef:	6a 71                	push   $0x71
  jmp alltraps
801071f1:	e9 93 f5 ff ff       	jmp    80106789 <alltraps>

801071f6 <vector114>:
.globl vector114
vector114:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $114
801071f8:	6a 72                	push   $0x72
  jmp alltraps
801071fa:	e9 8a f5 ff ff       	jmp    80106789 <alltraps>

801071ff <vector115>:
.globl vector115
vector115:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $115
80107201:	6a 73                	push   $0x73
  jmp alltraps
80107203:	e9 81 f5 ff ff       	jmp    80106789 <alltraps>

80107208 <vector116>:
.globl vector116
vector116:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $116
8010720a:	6a 74                	push   $0x74
  jmp alltraps
8010720c:	e9 78 f5 ff ff       	jmp    80106789 <alltraps>

80107211 <vector117>:
.globl vector117
vector117:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $117
80107213:	6a 75                	push   $0x75
  jmp alltraps
80107215:	e9 6f f5 ff ff       	jmp    80106789 <alltraps>

8010721a <vector118>:
.globl vector118
vector118:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $118
8010721c:	6a 76                	push   $0x76
  jmp alltraps
8010721e:	e9 66 f5 ff ff       	jmp    80106789 <alltraps>

80107223 <vector119>:
.globl vector119
vector119:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $119
80107225:	6a 77                	push   $0x77
  jmp alltraps
80107227:	e9 5d f5 ff ff       	jmp    80106789 <alltraps>

8010722c <vector120>:
.globl vector120
vector120:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $120
8010722e:	6a 78                	push   $0x78
  jmp alltraps
80107230:	e9 54 f5 ff ff       	jmp    80106789 <alltraps>

80107235 <vector121>:
.globl vector121
vector121:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $121
80107237:	6a 79                	push   $0x79
  jmp alltraps
80107239:	e9 4b f5 ff ff       	jmp    80106789 <alltraps>

8010723e <vector122>:
.globl vector122
vector122:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $122
80107240:	6a 7a                	push   $0x7a
  jmp alltraps
80107242:	e9 42 f5 ff ff       	jmp    80106789 <alltraps>

80107247 <vector123>:
.globl vector123
vector123:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $123
80107249:	6a 7b                	push   $0x7b
  jmp alltraps
8010724b:	e9 39 f5 ff ff       	jmp    80106789 <alltraps>

80107250 <vector124>:
.globl vector124
vector124:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $124
80107252:	6a 7c                	push   $0x7c
  jmp alltraps
80107254:	e9 30 f5 ff ff       	jmp    80106789 <alltraps>

80107259 <vector125>:
.globl vector125
vector125:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $125
8010725b:	6a 7d                	push   $0x7d
  jmp alltraps
8010725d:	e9 27 f5 ff ff       	jmp    80106789 <alltraps>

80107262 <vector126>:
.globl vector126
vector126:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $126
80107264:	6a 7e                	push   $0x7e
  jmp alltraps
80107266:	e9 1e f5 ff ff       	jmp    80106789 <alltraps>

8010726b <vector127>:
.globl vector127
vector127:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $127
8010726d:	6a 7f                	push   $0x7f
  jmp alltraps
8010726f:	e9 15 f5 ff ff       	jmp    80106789 <alltraps>

80107274 <vector128>:
.globl vector128
vector128:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $128
80107276:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010727b:	e9 09 f5 ff ff       	jmp    80106789 <alltraps>

80107280 <vector129>:
.globl vector129
vector129:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $129
80107282:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107287:	e9 fd f4 ff ff       	jmp    80106789 <alltraps>

8010728c <vector130>:
.globl vector130
vector130:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $130
8010728e:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107293:	e9 f1 f4 ff ff       	jmp    80106789 <alltraps>

80107298 <vector131>:
.globl vector131
vector131:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $131
8010729a:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010729f:	e9 e5 f4 ff ff       	jmp    80106789 <alltraps>

801072a4 <vector132>:
.globl vector132
vector132:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $132
801072a6:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801072ab:	e9 d9 f4 ff ff       	jmp    80106789 <alltraps>

801072b0 <vector133>:
.globl vector133
vector133:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $133
801072b2:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801072b7:	e9 cd f4 ff ff       	jmp    80106789 <alltraps>

801072bc <vector134>:
.globl vector134
vector134:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $134
801072be:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801072c3:	e9 c1 f4 ff ff       	jmp    80106789 <alltraps>

801072c8 <vector135>:
.globl vector135
vector135:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $135
801072ca:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801072cf:	e9 b5 f4 ff ff       	jmp    80106789 <alltraps>

801072d4 <vector136>:
.globl vector136
vector136:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $136
801072d6:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801072db:	e9 a9 f4 ff ff       	jmp    80106789 <alltraps>

801072e0 <vector137>:
.globl vector137
vector137:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $137
801072e2:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072e7:	e9 9d f4 ff ff       	jmp    80106789 <alltraps>

801072ec <vector138>:
.globl vector138
vector138:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $138
801072ee:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801072f3:	e9 91 f4 ff ff       	jmp    80106789 <alltraps>

801072f8 <vector139>:
.globl vector139
vector139:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $139
801072fa:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072ff:	e9 85 f4 ff ff       	jmp    80106789 <alltraps>

80107304 <vector140>:
.globl vector140
vector140:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $140
80107306:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010730b:	e9 79 f4 ff ff       	jmp    80106789 <alltraps>

80107310 <vector141>:
.globl vector141
vector141:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $141
80107312:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107317:	e9 6d f4 ff ff       	jmp    80106789 <alltraps>

8010731c <vector142>:
.globl vector142
vector142:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $142
8010731e:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107323:	e9 61 f4 ff ff       	jmp    80106789 <alltraps>

80107328 <vector143>:
.globl vector143
vector143:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $143
8010732a:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010732f:	e9 55 f4 ff ff       	jmp    80106789 <alltraps>

80107334 <vector144>:
.globl vector144
vector144:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $144
80107336:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010733b:	e9 49 f4 ff ff       	jmp    80106789 <alltraps>

80107340 <vector145>:
.globl vector145
vector145:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $145
80107342:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107347:	e9 3d f4 ff ff       	jmp    80106789 <alltraps>

8010734c <vector146>:
.globl vector146
vector146:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $146
8010734e:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107353:	e9 31 f4 ff ff       	jmp    80106789 <alltraps>

80107358 <vector147>:
.globl vector147
vector147:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $147
8010735a:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010735f:	e9 25 f4 ff ff       	jmp    80106789 <alltraps>

80107364 <vector148>:
.globl vector148
vector148:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $148
80107366:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010736b:	e9 19 f4 ff ff       	jmp    80106789 <alltraps>

80107370 <vector149>:
.globl vector149
vector149:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $149
80107372:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107377:	e9 0d f4 ff ff       	jmp    80106789 <alltraps>

8010737c <vector150>:
.globl vector150
vector150:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $150
8010737e:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107383:	e9 01 f4 ff ff       	jmp    80106789 <alltraps>

80107388 <vector151>:
.globl vector151
vector151:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $151
8010738a:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010738f:	e9 f5 f3 ff ff       	jmp    80106789 <alltraps>

80107394 <vector152>:
.globl vector152
vector152:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $152
80107396:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010739b:	e9 e9 f3 ff ff       	jmp    80106789 <alltraps>

801073a0 <vector153>:
.globl vector153
vector153:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $153
801073a2:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801073a7:	e9 dd f3 ff ff       	jmp    80106789 <alltraps>

801073ac <vector154>:
.globl vector154
vector154:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $154
801073ae:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801073b3:	e9 d1 f3 ff ff       	jmp    80106789 <alltraps>

801073b8 <vector155>:
.globl vector155
vector155:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $155
801073ba:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801073bf:	e9 c5 f3 ff ff       	jmp    80106789 <alltraps>

801073c4 <vector156>:
.globl vector156
vector156:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $156
801073c6:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801073cb:	e9 b9 f3 ff ff       	jmp    80106789 <alltraps>

801073d0 <vector157>:
.globl vector157
vector157:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $157
801073d2:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801073d7:	e9 ad f3 ff ff       	jmp    80106789 <alltraps>

801073dc <vector158>:
.globl vector158
vector158:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $158
801073de:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801073e3:	e9 a1 f3 ff ff       	jmp    80106789 <alltraps>

801073e8 <vector159>:
.globl vector159
vector159:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $159
801073ea:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801073ef:	e9 95 f3 ff ff       	jmp    80106789 <alltraps>

801073f4 <vector160>:
.globl vector160
vector160:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $160
801073f6:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073fb:	e9 89 f3 ff ff       	jmp    80106789 <alltraps>

80107400 <vector161>:
.globl vector161
vector161:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $161
80107402:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107407:	e9 7d f3 ff ff       	jmp    80106789 <alltraps>

8010740c <vector162>:
.globl vector162
vector162:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $162
8010740e:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107413:	e9 71 f3 ff ff       	jmp    80106789 <alltraps>

80107418 <vector163>:
.globl vector163
vector163:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $163
8010741a:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010741f:	e9 65 f3 ff ff       	jmp    80106789 <alltraps>

80107424 <vector164>:
.globl vector164
vector164:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $164
80107426:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010742b:	e9 59 f3 ff ff       	jmp    80106789 <alltraps>

80107430 <vector165>:
.globl vector165
vector165:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $165
80107432:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107437:	e9 4d f3 ff ff       	jmp    80106789 <alltraps>

8010743c <vector166>:
.globl vector166
vector166:
  pushl $0
8010743c:	6a 00                	push   $0x0
  pushl $166
8010743e:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107443:	e9 41 f3 ff ff       	jmp    80106789 <alltraps>

80107448 <vector167>:
.globl vector167
vector167:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $167
8010744a:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010744f:	e9 35 f3 ff ff       	jmp    80106789 <alltraps>

80107454 <vector168>:
.globl vector168
vector168:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $168
80107456:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010745b:	e9 29 f3 ff ff       	jmp    80106789 <alltraps>

80107460 <vector169>:
.globl vector169
vector169:
  pushl $0
80107460:	6a 00                	push   $0x0
  pushl $169
80107462:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107467:	e9 1d f3 ff ff       	jmp    80106789 <alltraps>

8010746c <vector170>:
.globl vector170
vector170:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $170
8010746e:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107473:	e9 11 f3 ff ff       	jmp    80106789 <alltraps>

80107478 <vector171>:
.globl vector171
vector171:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $171
8010747a:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010747f:	e9 05 f3 ff ff       	jmp    80106789 <alltraps>

80107484 <vector172>:
.globl vector172
vector172:
  pushl $0
80107484:	6a 00                	push   $0x0
  pushl $172
80107486:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010748b:	e9 f9 f2 ff ff       	jmp    80106789 <alltraps>

80107490 <vector173>:
.globl vector173
vector173:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $173
80107492:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107497:	e9 ed f2 ff ff       	jmp    80106789 <alltraps>

8010749c <vector174>:
.globl vector174
vector174:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $174
8010749e:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801074a3:	e9 e1 f2 ff ff       	jmp    80106789 <alltraps>

801074a8 <vector175>:
.globl vector175
vector175:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $175
801074aa:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801074af:	e9 d5 f2 ff ff       	jmp    80106789 <alltraps>

801074b4 <vector176>:
.globl vector176
vector176:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $176
801074b6:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801074bb:	e9 c9 f2 ff ff       	jmp    80106789 <alltraps>

801074c0 <vector177>:
.globl vector177
vector177:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $177
801074c2:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801074c7:	e9 bd f2 ff ff       	jmp    80106789 <alltraps>

801074cc <vector178>:
.globl vector178
vector178:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $178
801074ce:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801074d3:	e9 b1 f2 ff ff       	jmp    80106789 <alltraps>

801074d8 <vector179>:
.globl vector179
vector179:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $179
801074da:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801074df:	e9 a5 f2 ff ff       	jmp    80106789 <alltraps>

801074e4 <vector180>:
.globl vector180
vector180:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $180
801074e6:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074eb:	e9 99 f2 ff ff       	jmp    80106789 <alltraps>

801074f0 <vector181>:
.globl vector181
vector181:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $181
801074f2:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801074f7:	e9 8d f2 ff ff       	jmp    80106789 <alltraps>

801074fc <vector182>:
.globl vector182
vector182:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $182
801074fe:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107503:	e9 81 f2 ff ff       	jmp    80106789 <alltraps>

80107508 <vector183>:
.globl vector183
vector183:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $183
8010750a:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010750f:	e9 75 f2 ff ff       	jmp    80106789 <alltraps>

80107514 <vector184>:
.globl vector184
vector184:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $184
80107516:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010751b:	e9 69 f2 ff ff       	jmp    80106789 <alltraps>

80107520 <vector185>:
.globl vector185
vector185:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $185
80107522:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107527:	e9 5d f2 ff ff       	jmp    80106789 <alltraps>

8010752c <vector186>:
.globl vector186
vector186:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $186
8010752e:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107533:	e9 51 f2 ff ff       	jmp    80106789 <alltraps>

80107538 <vector187>:
.globl vector187
vector187:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $187
8010753a:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010753f:	e9 45 f2 ff ff       	jmp    80106789 <alltraps>

80107544 <vector188>:
.globl vector188
vector188:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $188
80107546:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010754b:	e9 39 f2 ff ff       	jmp    80106789 <alltraps>

80107550 <vector189>:
.globl vector189
vector189:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $189
80107552:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107557:	e9 2d f2 ff ff       	jmp    80106789 <alltraps>

8010755c <vector190>:
.globl vector190
vector190:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $190
8010755e:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107563:	e9 21 f2 ff ff       	jmp    80106789 <alltraps>

80107568 <vector191>:
.globl vector191
vector191:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $191
8010756a:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010756f:	e9 15 f2 ff ff       	jmp    80106789 <alltraps>

80107574 <vector192>:
.globl vector192
vector192:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $192
80107576:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010757b:	e9 09 f2 ff ff       	jmp    80106789 <alltraps>

80107580 <vector193>:
.globl vector193
vector193:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $193
80107582:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107587:	e9 fd f1 ff ff       	jmp    80106789 <alltraps>

8010758c <vector194>:
.globl vector194
vector194:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $194
8010758e:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107593:	e9 f1 f1 ff ff       	jmp    80106789 <alltraps>

80107598 <vector195>:
.globl vector195
vector195:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $195
8010759a:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010759f:	e9 e5 f1 ff ff       	jmp    80106789 <alltraps>

801075a4 <vector196>:
.globl vector196
vector196:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $196
801075a6:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801075ab:	e9 d9 f1 ff ff       	jmp    80106789 <alltraps>

801075b0 <vector197>:
.globl vector197
vector197:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $197
801075b2:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801075b7:	e9 cd f1 ff ff       	jmp    80106789 <alltraps>

801075bc <vector198>:
.globl vector198
vector198:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $198
801075be:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801075c3:	e9 c1 f1 ff ff       	jmp    80106789 <alltraps>

801075c8 <vector199>:
.globl vector199
vector199:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $199
801075ca:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801075cf:	e9 b5 f1 ff ff       	jmp    80106789 <alltraps>

801075d4 <vector200>:
.globl vector200
vector200:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $200
801075d6:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801075db:	e9 a9 f1 ff ff       	jmp    80106789 <alltraps>

801075e0 <vector201>:
.globl vector201
vector201:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $201
801075e2:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075e7:	e9 9d f1 ff ff       	jmp    80106789 <alltraps>

801075ec <vector202>:
.globl vector202
vector202:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $202
801075ee:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801075f3:	e9 91 f1 ff ff       	jmp    80106789 <alltraps>

801075f8 <vector203>:
.globl vector203
vector203:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $203
801075fa:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075ff:	e9 85 f1 ff ff       	jmp    80106789 <alltraps>

80107604 <vector204>:
.globl vector204
vector204:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $204
80107606:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010760b:	e9 79 f1 ff ff       	jmp    80106789 <alltraps>

80107610 <vector205>:
.globl vector205
vector205:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $205
80107612:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107617:	e9 6d f1 ff ff       	jmp    80106789 <alltraps>

8010761c <vector206>:
.globl vector206
vector206:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $206
8010761e:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107623:	e9 61 f1 ff ff       	jmp    80106789 <alltraps>

80107628 <vector207>:
.globl vector207
vector207:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $207
8010762a:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010762f:	e9 55 f1 ff ff       	jmp    80106789 <alltraps>

80107634 <vector208>:
.globl vector208
vector208:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $208
80107636:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010763b:	e9 49 f1 ff ff       	jmp    80106789 <alltraps>

80107640 <vector209>:
.globl vector209
vector209:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $209
80107642:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107647:	e9 3d f1 ff ff       	jmp    80106789 <alltraps>

8010764c <vector210>:
.globl vector210
vector210:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $210
8010764e:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107653:	e9 31 f1 ff ff       	jmp    80106789 <alltraps>

80107658 <vector211>:
.globl vector211
vector211:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $211
8010765a:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010765f:	e9 25 f1 ff ff       	jmp    80106789 <alltraps>

80107664 <vector212>:
.globl vector212
vector212:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $212
80107666:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010766b:	e9 19 f1 ff ff       	jmp    80106789 <alltraps>

80107670 <vector213>:
.globl vector213
vector213:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $213
80107672:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107677:	e9 0d f1 ff ff       	jmp    80106789 <alltraps>

8010767c <vector214>:
.globl vector214
vector214:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $214
8010767e:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107683:	e9 01 f1 ff ff       	jmp    80106789 <alltraps>

80107688 <vector215>:
.globl vector215
vector215:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $215
8010768a:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010768f:	e9 f5 f0 ff ff       	jmp    80106789 <alltraps>

80107694 <vector216>:
.globl vector216
vector216:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $216
80107696:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010769b:	e9 e9 f0 ff ff       	jmp    80106789 <alltraps>

801076a0 <vector217>:
.globl vector217
vector217:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $217
801076a2:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801076a7:	e9 dd f0 ff ff       	jmp    80106789 <alltraps>

801076ac <vector218>:
.globl vector218
vector218:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $218
801076ae:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801076b3:	e9 d1 f0 ff ff       	jmp    80106789 <alltraps>

801076b8 <vector219>:
.globl vector219
vector219:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $219
801076ba:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801076bf:	e9 c5 f0 ff ff       	jmp    80106789 <alltraps>

801076c4 <vector220>:
.globl vector220
vector220:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $220
801076c6:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801076cb:	e9 b9 f0 ff ff       	jmp    80106789 <alltraps>

801076d0 <vector221>:
.globl vector221
vector221:
  pushl $0
801076d0:	6a 00                	push   $0x0
  pushl $221
801076d2:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801076d7:	e9 ad f0 ff ff       	jmp    80106789 <alltraps>

801076dc <vector222>:
.globl vector222
vector222:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $222
801076de:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801076e3:	e9 a1 f0 ff ff       	jmp    80106789 <alltraps>

801076e8 <vector223>:
.globl vector223
vector223:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $223
801076ea:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801076ef:	e9 95 f0 ff ff       	jmp    80106789 <alltraps>

801076f4 <vector224>:
.globl vector224
vector224:
  pushl $0
801076f4:	6a 00                	push   $0x0
  pushl $224
801076f6:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076fb:	e9 89 f0 ff ff       	jmp    80106789 <alltraps>

80107700 <vector225>:
.globl vector225
vector225:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $225
80107702:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107707:	e9 7d f0 ff ff       	jmp    80106789 <alltraps>

8010770c <vector226>:
.globl vector226
vector226:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $226
8010770e:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107713:	e9 71 f0 ff ff       	jmp    80106789 <alltraps>

80107718 <vector227>:
.globl vector227
vector227:
  pushl $0
80107718:	6a 00                	push   $0x0
  pushl $227
8010771a:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010771f:	e9 65 f0 ff ff       	jmp    80106789 <alltraps>

80107724 <vector228>:
.globl vector228
vector228:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $228
80107726:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010772b:	e9 59 f0 ff ff       	jmp    80106789 <alltraps>

80107730 <vector229>:
.globl vector229
vector229:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $229
80107732:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107737:	e9 4d f0 ff ff       	jmp    80106789 <alltraps>

8010773c <vector230>:
.globl vector230
vector230:
  pushl $0
8010773c:	6a 00                	push   $0x0
  pushl $230
8010773e:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107743:	e9 41 f0 ff ff       	jmp    80106789 <alltraps>

80107748 <vector231>:
.globl vector231
vector231:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $231
8010774a:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010774f:	e9 35 f0 ff ff       	jmp    80106789 <alltraps>

80107754 <vector232>:
.globl vector232
vector232:
  pushl $0
80107754:	6a 00                	push   $0x0
  pushl $232
80107756:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010775b:	e9 29 f0 ff ff       	jmp    80106789 <alltraps>

80107760 <vector233>:
.globl vector233
vector233:
  pushl $0
80107760:	6a 00                	push   $0x0
  pushl $233
80107762:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107767:	e9 1d f0 ff ff       	jmp    80106789 <alltraps>

8010776c <vector234>:
.globl vector234
vector234:
  pushl $0
8010776c:	6a 00                	push   $0x0
  pushl $234
8010776e:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107773:	e9 11 f0 ff ff       	jmp    80106789 <alltraps>

80107778 <vector235>:
.globl vector235
vector235:
  pushl $0
80107778:	6a 00                	push   $0x0
  pushl $235
8010777a:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010777f:	e9 05 f0 ff ff       	jmp    80106789 <alltraps>

80107784 <vector236>:
.globl vector236
vector236:
  pushl $0
80107784:	6a 00                	push   $0x0
  pushl $236
80107786:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010778b:	e9 f9 ef ff ff       	jmp    80106789 <alltraps>

80107790 <vector237>:
.globl vector237
vector237:
  pushl $0
80107790:	6a 00                	push   $0x0
  pushl $237
80107792:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107797:	e9 ed ef ff ff       	jmp    80106789 <alltraps>

8010779c <vector238>:
.globl vector238
vector238:
  pushl $0
8010779c:	6a 00                	push   $0x0
  pushl $238
8010779e:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801077a3:	e9 e1 ef ff ff       	jmp    80106789 <alltraps>

801077a8 <vector239>:
.globl vector239
vector239:
  pushl $0
801077a8:	6a 00                	push   $0x0
  pushl $239
801077aa:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801077af:	e9 d5 ef ff ff       	jmp    80106789 <alltraps>

801077b4 <vector240>:
.globl vector240
vector240:
  pushl $0
801077b4:	6a 00                	push   $0x0
  pushl $240
801077b6:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801077bb:	e9 c9 ef ff ff       	jmp    80106789 <alltraps>

801077c0 <vector241>:
.globl vector241
vector241:
  pushl $0
801077c0:	6a 00                	push   $0x0
  pushl $241
801077c2:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801077c7:	e9 bd ef ff ff       	jmp    80106789 <alltraps>

801077cc <vector242>:
.globl vector242
vector242:
  pushl $0
801077cc:	6a 00                	push   $0x0
  pushl $242
801077ce:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801077d3:	e9 b1 ef ff ff       	jmp    80106789 <alltraps>

801077d8 <vector243>:
.globl vector243
vector243:
  pushl $0
801077d8:	6a 00                	push   $0x0
  pushl $243
801077da:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801077df:	e9 a5 ef ff ff       	jmp    80106789 <alltraps>

801077e4 <vector244>:
.globl vector244
vector244:
  pushl $0
801077e4:	6a 00                	push   $0x0
  pushl $244
801077e6:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077eb:	e9 99 ef ff ff       	jmp    80106789 <alltraps>

801077f0 <vector245>:
.globl vector245
vector245:
  pushl $0
801077f0:	6a 00                	push   $0x0
  pushl $245
801077f2:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801077f7:	e9 8d ef ff ff       	jmp    80106789 <alltraps>

801077fc <vector246>:
.globl vector246
vector246:
  pushl $0
801077fc:	6a 00                	push   $0x0
  pushl $246
801077fe:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107803:	e9 81 ef ff ff       	jmp    80106789 <alltraps>

80107808 <vector247>:
.globl vector247
vector247:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $247
8010780a:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010780f:	e9 75 ef ff ff       	jmp    80106789 <alltraps>

80107814 <vector248>:
.globl vector248
vector248:
  pushl $0
80107814:	6a 00                	push   $0x0
  pushl $248
80107816:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010781b:	e9 69 ef ff ff       	jmp    80106789 <alltraps>

80107820 <vector249>:
.globl vector249
vector249:
  pushl $0
80107820:	6a 00                	push   $0x0
  pushl $249
80107822:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107827:	e9 5d ef ff ff       	jmp    80106789 <alltraps>

8010782c <vector250>:
.globl vector250
vector250:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $250
8010782e:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107833:	e9 51 ef ff ff       	jmp    80106789 <alltraps>

80107838 <vector251>:
.globl vector251
vector251:
  pushl $0
80107838:	6a 00                	push   $0x0
  pushl $251
8010783a:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010783f:	e9 45 ef ff ff       	jmp    80106789 <alltraps>

80107844 <vector252>:
.globl vector252
vector252:
  pushl $0
80107844:	6a 00                	push   $0x0
  pushl $252
80107846:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010784b:	e9 39 ef ff ff       	jmp    80106789 <alltraps>

80107850 <vector253>:
.globl vector253
vector253:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $253
80107852:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107857:	e9 2d ef ff ff       	jmp    80106789 <alltraps>

8010785c <vector254>:
.globl vector254
vector254:
  pushl $0
8010785c:	6a 00                	push   $0x0
  pushl $254
8010785e:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107863:	e9 21 ef ff ff       	jmp    80106789 <alltraps>

80107868 <vector255>:
.globl vector255
vector255:
  pushl $0
80107868:	6a 00                	push   $0x0
  pushl $255
8010786a:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010786f:	e9 15 ef ff ff       	jmp    80106789 <alltraps>

80107874 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107874:	55                   	push   %ebp
80107875:	89 e5                	mov    %esp,%ebp
80107877:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010787a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010787d:	83 e8 01             	sub    $0x1,%eax
80107880:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107884:	8b 45 08             	mov    0x8(%ebp),%eax
80107887:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010788b:	8b 45 08             	mov    0x8(%ebp),%eax
8010788e:	c1 e8 10             	shr    $0x10,%eax
80107891:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107895:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107898:	0f 01 10             	lgdtl  (%eax)
}
8010789b:	c9                   	leave  
8010789c:	c3                   	ret    

8010789d <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010789d:	55                   	push   %ebp
8010789e:	89 e5                	mov    %esp,%ebp
801078a0:	83 ec 04             	sub    $0x4,%esp
801078a3:	8b 45 08             	mov    0x8(%ebp),%eax
801078a6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801078aa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078ae:	0f 00 d8             	ltr    %ax
}
801078b1:	c9                   	leave  
801078b2:	c3                   	ret    

801078b3 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801078b3:	55                   	push   %ebp
801078b4:	89 e5                	mov    %esp,%ebp
801078b6:	83 ec 04             	sub    $0x4,%esp
801078b9:	8b 45 08             	mov    0x8(%ebp),%eax
801078bc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801078c0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078c4:	8e e8                	mov    %eax,%gs
}
801078c6:	c9                   	leave  
801078c7:	c3                   	ret    

801078c8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801078c8:	55                   	push   %ebp
801078c9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801078cb:	8b 45 08             	mov    0x8(%ebp),%eax
801078ce:	0f 22 d8             	mov    %eax,%cr3
}
801078d1:	5d                   	pop    %ebp
801078d2:	c3                   	ret    

801078d3 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801078d3:	55                   	push   %ebp
801078d4:	89 e5                	mov    %esp,%ebp
801078d6:	8b 45 08             	mov    0x8(%ebp),%eax
801078d9:	05 00 00 00 80       	add    $0x80000000,%eax
801078de:	5d                   	pop    %ebp
801078df:	c3                   	ret    

801078e0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801078e0:	55                   	push   %ebp
801078e1:	89 e5                	mov    %esp,%ebp
801078e3:	8b 45 08             	mov    0x8(%ebp),%eax
801078e6:	05 00 00 00 80       	add    $0x80000000,%eax
801078eb:	5d                   	pop    %ebp
801078ec:	c3                   	ret    

801078ed <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801078ed:	55                   	push   %ebp
801078ee:	89 e5                	mov    %esp,%ebp
801078f0:	53                   	push   %ebx
801078f1:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801078f4:	e8 8f b5 ff ff       	call   80102e88 <cpunum>
801078f9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801078ff:	05 60 23 11 80       	add    $0x80112360,%eax
80107904:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107913:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107923:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107927:	83 e2 f0             	and    $0xfffffff0,%edx
8010792a:	83 ca 0a             	or     $0xa,%edx
8010792d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107933:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107937:	83 ca 10             	or     $0x10,%edx
8010793a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010793d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107940:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107944:	83 e2 9f             	and    $0xffffff9f,%edx
80107947:	88 50 7d             	mov    %dl,0x7d(%eax)
8010794a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107951:	83 ca 80             	or     $0xffffff80,%edx
80107954:	88 50 7d             	mov    %dl,0x7d(%eax)
80107957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010795e:	83 ca 0f             	or     $0xf,%edx
80107961:	88 50 7e             	mov    %dl,0x7e(%eax)
80107964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107967:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010796b:	83 e2 ef             	and    $0xffffffef,%edx
8010796e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107974:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107978:	83 e2 df             	and    $0xffffffdf,%edx
8010797b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010797e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107981:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107985:	83 ca 40             	or     $0x40,%edx
80107988:	88 50 7e             	mov    %dl,0x7e(%eax)
8010798b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107992:	83 ca 80             	or     $0xffffff80,%edx
80107995:	88 50 7e             	mov    %dl,0x7e(%eax)
80107998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010799f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a2:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801079a9:	ff ff 
801079ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ae:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801079b5:	00 00 
801079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ba:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801079c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079cb:	83 e2 f0             	and    $0xfffffff0,%edx
801079ce:	83 ca 02             	or     $0x2,%edx
801079d1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079da:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079e1:	83 ca 10             	or     $0x10,%edx
801079e4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ed:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079f4:	83 e2 9f             	and    $0xffffff9f,%edx
801079f7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a00:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a07:	83 ca 80             	or     $0xffffff80,%edx
80107a0a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a13:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a1a:	83 ca 0f             	or     $0xf,%edx
80107a1d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a26:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a2d:	83 e2 ef             	and    $0xffffffef,%edx
80107a30:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a39:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a40:	83 e2 df             	and    $0xffffffdf,%edx
80107a43:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a53:	83 ca 40             	or     $0x40,%edx
80107a56:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a66:	83 ca 80             	or     $0xffffff80,%edx
80107a69:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a83:	ff ff 
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a8f:	00 00 
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107aa5:	83 e2 f0             	and    $0xfffffff0,%edx
80107aa8:	83 ca 0a             	or     $0xa,%edx
80107aab:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107abb:	83 ca 10             	or     $0x10,%edx
80107abe:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ace:	83 ca 60             	or     $0x60,%edx
80107ad1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ada:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ae1:	83 ca 80             	or     $0xffffff80,%edx
80107ae4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aed:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107af4:	83 ca 0f             	or     $0xf,%edx
80107af7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b07:	83 e2 ef             	and    $0xffffffef,%edx
80107b0a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b13:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b1a:	83 e2 df             	and    $0xffffffdf,%edx
80107b1d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b26:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b2d:	83 ca 40             	or     $0x40,%edx
80107b30:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b40:	83 ca 80             	or     $0xffffff80,%edx
80107b43:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b56:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107b5d:	ff ff 
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107b69:	00 00 
80107b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b78:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b7f:	83 e2 f0             	and    $0xfffffff0,%edx
80107b82:	83 ca 02             	or     $0x2,%edx
80107b85:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b95:	83 ca 10             	or     $0x10,%edx
80107b98:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ba8:	83 ca 60             	or     $0x60,%edx
80107bab:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bbb:	83 ca 80             	or     $0xffffff80,%edx
80107bbe:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bce:	83 ca 0f             	or     $0xf,%edx
80107bd1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bda:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107be1:	83 e2 ef             	and    $0xffffffef,%edx
80107be4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bed:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bf4:	83 e2 df             	and    $0xffffffdf,%edx
80107bf7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c00:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c07:	83 ca 40             	or     $0x40,%edx
80107c0a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c1a:	83 ca 80             	or     $0xffffff80,%edx
80107c1d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c30:	05 b4 00 00 00       	add    $0xb4,%eax
80107c35:	89 c3                	mov    %eax,%ebx
80107c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3a:	05 b4 00 00 00       	add    $0xb4,%eax
80107c3f:	c1 e8 10             	shr    $0x10,%eax
80107c42:	89 c1                	mov    %eax,%ecx
80107c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c47:	05 b4 00 00 00       	add    $0xb4,%eax
80107c4c:	c1 e8 18             	shr    $0x18,%eax
80107c4f:	89 c2                	mov    %eax,%edx
80107c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c54:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107c5b:	00 00 
80107c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c60:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6a:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c73:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c7a:	83 e1 f0             	and    $0xfffffff0,%ecx
80107c7d:	83 c9 02             	or     $0x2,%ecx
80107c80:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c89:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c90:	83 c9 10             	or     $0x10,%ecx
80107c93:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9c:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ca3:	83 e1 9f             	and    $0xffffff9f,%ecx
80107ca6:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caf:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cb6:	83 c9 80             	or     $0xffffff80,%ecx
80107cb9:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cc9:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ccc:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd5:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cdc:	83 e1 ef             	and    $0xffffffef,%ecx
80107cdf:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce8:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cef:	83 e1 df             	and    $0xffffffdf,%ecx
80107cf2:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfb:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d02:	83 c9 40             	or     $0x40,%ecx
80107d05:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d15:	83 c9 80             	or     $0xffffff80,%ecx
80107d18:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2a:	83 c0 70             	add    $0x70,%eax
80107d2d:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107d34:	00 
80107d35:	89 04 24             	mov    %eax,(%esp)
80107d38:	e8 37 fb ff ff       	call   80107874 <lgdt>
  loadgs(SEG_KCPU << 3);
80107d3d:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107d44:	e8 6a fb ff ff       	call   801078b3 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4c:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107d52:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107d59:	00 00 00 00 
}
80107d5d:	83 c4 24             	add    $0x24,%esp
80107d60:	5b                   	pop    %ebx
80107d61:	5d                   	pop    %ebp
80107d62:	c3                   	ret    

80107d63 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107d63:	55                   	push   %ebp
80107d64:	89 e5                	mov    %esp,%ebp
80107d66:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107d69:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d6c:	c1 e8 16             	shr    $0x16,%eax
80107d6f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d76:	8b 45 08             	mov    0x8(%ebp),%eax
80107d79:	01 d0                	add    %edx,%eax
80107d7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d81:	8b 00                	mov    (%eax),%eax
80107d83:	83 e0 01             	and    $0x1,%eax
80107d86:	85 c0                	test   %eax,%eax
80107d88:	74 17                	je     80107da1 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d8d:	8b 00                	mov    (%eax),%eax
80107d8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d94:	89 04 24             	mov    %eax,(%esp)
80107d97:	e8 44 fb ff ff       	call   801078e0 <p2v>
80107d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d9f:	eb 4b                	jmp    80107dec <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107da1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107da5:	74 0e                	je     80107db5 <walkpgdir+0x52>
80107da7:	e8 46 ad ff ff       	call   80102af2 <kalloc>
80107dac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107daf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107db3:	75 07                	jne    80107dbc <walkpgdir+0x59>
      return 0;
80107db5:	b8 00 00 00 00       	mov    $0x0,%eax
80107dba:	eb 47                	jmp    80107e03 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107dbc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107dc3:	00 
80107dc4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107dcb:	00 
80107dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcf:	89 04 24             	mov    %eax,(%esp)
80107dd2:	e8 36 d5 ff ff       	call   8010530d <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dda:	89 04 24             	mov    %eax,(%esp)
80107ddd:	e8 f1 fa ff ff       	call   801078d3 <v2p>
80107de2:	83 c8 07             	or     $0x7,%eax
80107de5:	89 c2                	mov    %eax,%edx
80107de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dea:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107dec:	8b 45 0c             	mov    0xc(%ebp),%eax
80107def:	c1 e8 0c             	shr    $0xc,%eax
80107df2:	25 ff 03 00 00       	and    $0x3ff,%eax
80107df7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e01:	01 d0                	add    %edx,%eax
}
80107e03:	c9                   	leave  
80107e04:	c3                   	ret    

80107e05 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107e05:	55                   	push   %ebp
80107e06:	89 e5                	mov    %esp,%ebp
80107e08:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e16:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e19:	8b 45 10             	mov    0x10(%ebp),%eax
80107e1c:	01 d0                	add    %edx,%eax
80107e1e:	83 e8 01             	sub    $0x1,%eax
80107e21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e29:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107e30:	00 
80107e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e34:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e38:	8b 45 08             	mov    0x8(%ebp),%eax
80107e3b:	89 04 24             	mov    %eax,(%esp)
80107e3e:	e8 20 ff ff ff       	call   80107d63 <walkpgdir>
80107e43:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e46:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e4a:	75 07                	jne    80107e53 <mappages+0x4e>
      return -1;
80107e4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e51:	eb 48                	jmp    80107e9b <mappages+0x96>
    if(*pte & PTE_P)
80107e53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e56:	8b 00                	mov    (%eax),%eax
80107e58:	83 e0 01             	and    $0x1,%eax
80107e5b:	85 c0                	test   %eax,%eax
80107e5d:	74 0c                	je     80107e6b <mappages+0x66>
      panic("remap");
80107e5f:	c7 04 24 ac 8c 10 80 	movl   $0x80108cac,(%esp)
80107e66:	e8 cf 86 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107e6b:	8b 45 18             	mov    0x18(%ebp),%eax
80107e6e:	0b 45 14             	or     0x14(%ebp),%eax
80107e71:	83 c8 01             	or     $0x1,%eax
80107e74:	89 c2                	mov    %eax,%edx
80107e76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e79:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107e81:	75 08                	jne    80107e8b <mappages+0x86>
      break;
80107e83:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107e84:	b8 00 00 00 00       	mov    $0x0,%eax
80107e89:	eb 10                	jmp    80107e9b <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107e8b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107e92:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107e99:	eb 8e                	jmp    80107e29 <mappages+0x24>
  return 0;
}
80107e9b:	c9                   	leave  
80107e9c:	c3                   	ret    

80107e9d <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107e9d:	55                   	push   %ebp
80107e9e:	89 e5                	mov    %esp,%ebp
80107ea0:	53                   	push   %ebx
80107ea1:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ea4:	e8 49 ac ff ff       	call   80102af2 <kalloc>
80107ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107eac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107eb0:	75 0a                	jne    80107ebc <setupkvm+0x1f>
    return 0;
80107eb2:	b8 00 00 00 00       	mov    $0x0,%eax
80107eb7:	e9 98 00 00 00       	jmp    80107f54 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107ebc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ec3:	00 
80107ec4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ecb:	00 
80107ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ecf:	89 04 24             	mov    %eax,(%esp)
80107ed2:	e8 36 d4 ff ff       	call   8010530d <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107ed7:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107ede:	e8 fd f9 ff ff       	call   801078e0 <p2v>
80107ee3:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107ee8:	76 0c                	jbe    80107ef6 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107eea:	c7 04 24 b2 8c 10 80 	movl   $0x80108cb2,(%esp)
80107ef1:	e8 44 86 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ef6:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107efd:	eb 49                	jmp    80107f48 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f02:	8b 48 0c             	mov    0xc(%eax),%ecx
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	8b 50 04             	mov    0x4(%eax),%edx
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	8b 58 08             	mov    0x8(%eax),%ebx
80107f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f14:	8b 40 04             	mov    0x4(%eax),%eax
80107f17:	29 c3                	sub    %eax,%ebx
80107f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1c:	8b 00                	mov    (%eax),%eax
80107f1e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107f22:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f26:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f31:	89 04 24             	mov    %eax,(%esp)
80107f34:	e8 cc fe ff ff       	call   80107e05 <mappages>
80107f39:	85 c0                	test   %eax,%eax
80107f3b:	79 07                	jns    80107f44 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107f3d:	b8 00 00 00 00       	mov    $0x0,%eax
80107f42:	eb 10                	jmp    80107f54 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f44:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f48:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107f4f:	72 ae                	jb     80107eff <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f54:	83 c4 34             	add    $0x34,%esp
80107f57:	5b                   	pop    %ebx
80107f58:	5d                   	pop    %ebp
80107f59:	c3                   	ret    

80107f5a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f5a:	55                   	push   %ebp
80107f5b:	89 e5                	mov    %esp,%ebp
80107f5d:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107f60:	e8 38 ff ff ff       	call   80107e9d <setupkvm>
80107f65:	a3 38 8a 11 80       	mov    %eax,0x80118a38
  switchkvm();
80107f6a:	e8 02 00 00 00       	call   80107f71 <switchkvm>
}
80107f6f:	c9                   	leave  
80107f70:	c3                   	ret    

80107f71 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107f71:	55                   	push   %ebp
80107f72:	89 e5                	mov    %esp,%ebp
80107f74:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107f77:	a1 38 8a 11 80       	mov    0x80118a38,%eax
80107f7c:	89 04 24             	mov    %eax,(%esp)
80107f7f:	e8 4f f9 ff ff       	call   801078d3 <v2p>
80107f84:	89 04 24             	mov    %eax,(%esp)
80107f87:	e8 3c f9 ff ff       	call   801078c8 <lcr3>
}
80107f8c:	c9                   	leave  
80107f8d:	c3                   	ret    

80107f8e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107f8e:	55                   	push   %ebp
80107f8f:	89 e5                	mov    %esp,%ebp
80107f91:	53                   	push   %ebx
80107f92:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107f95:	e8 73 d2 ff ff       	call   8010520d <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107f9a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fa0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fa7:	83 c2 08             	add    $0x8,%edx
80107faa:	89 d3                	mov    %edx,%ebx
80107fac:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fb3:	83 c2 08             	add    $0x8,%edx
80107fb6:	c1 ea 10             	shr    $0x10,%edx
80107fb9:	89 d1                	mov    %edx,%ecx
80107fbb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fc2:	83 c2 08             	add    $0x8,%edx
80107fc5:	c1 ea 18             	shr    $0x18,%edx
80107fc8:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107fcf:	67 00 
80107fd1:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107fd8:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107fde:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107fe5:	83 e1 f0             	and    $0xfffffff0,%ecx
80107fe8:	83 c9 09             	or     $0x9,%ecx
80107feb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ff1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ff8:	83 c9 10             	or     $0x10,%ecx
80107ffb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108001:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108008:	83 e1 9f             	and    $0xffffff9f,%ecx
8010800b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108011:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108018:	83 c9 80             	or     $0xffffff80,%ecx
8010801b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108021:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108028:	83 e1 f0             	and    $0xfffffff0,%ecx
8010802b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108031:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108038:	83 e1 ef             	and    $0xffffffef,%ecx
8010803b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108041:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108048:	83 e1 df             	and    $0xffffffdf,%ecx
8010804b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108051:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108058:	83 c9 40             	or     $0x40,%ecx
8010805b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108061:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108068:	83 e1 7f             	and    $0x7f,%ecx
8010806b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108071:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108077:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010807d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108084:	83 e2 ef             	and    $0xffffffef,%edx
80108087:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
8010808d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108093:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108099:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010809f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801080a6:	8b 52 08             	mov    0x8(%edx),%edx
801080a9:	81 c2 00 10 00 00    	add    $0x1000,%edx
801080af:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801080b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801080b9:	e8 df f7 ff ff       	call   8010789d <ltr>
  if(p->pgdir == 0)
801080be:	8b 45 08             	mov    0x8(%ebp),%eax
801080c1:	8b 40 04             	mov    0x4(%eax),%eax
801080c4:	85 c0                	test   %eax,%eax
801080c6:	75 0c                	jne    801080d4 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801080c8:	c7 04 24 c3 8c 10 80 	movl   $0x80108cc3,(%esp)
801080cf:	e8 66 84 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801080d4:	8b 45 08             	mov    0x8(%ebp),%eax
801080d7:	8b 40 04             	mov    0x4(%eax),%eax
801080da:	89 04 24             	mov    %eax,(%esp)
801080dd:	e8 f1 f7 ff ff       	call   801078d3 <v2p>
801080e2:	89 04 24             	mov    %eax,(%esp)
801080e5:	e8 de f7 ff ff       	call   801078c8 <lcr3>
  popcli();
801080ea:	e8 62 d1 ff ff       	call   80105251 <popcli>
}
801080ef:	83 c4 14             	add    $0x14,%esp
801080f2:	5b                   	pop    %ebx
801080f3:	5d                   	pop    %ebp
801080f4:	c3                   	ret    

801080f5 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801080f5:	55                   	push   %ebp
801080f6:	89 e5                	mov    %esp,%ebp
801080f8:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801080fb:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108102:	76 0c                	jbe    80108110 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108104:	c7 04 24 d7 8c 10 80 	movl   $0x80108cd7,(%esp)
8010810b:	e8 2a 84 ff ff       	call   8010053a <panic>
  mem = kalloc();
80108110:	e8 dd a9 ff ff       	call   80102af2 <kalloc>
80108115:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108118:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010811f:	00 
80108120:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108127:	00 
80108128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812b:	89 04 24             	mov    %eax,(%esp)
8010812e:	e8 da d1 ff ff       	call   8010530d <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108136:	89 04 24             	mov    %eax,(%esp)
80108139:	e8 95 f7 ff ff       	call   801078d3 <v2p>
8010813e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108145:	00 
80108146:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010814a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108151:	00 
80108152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108159:	00 
8010815a:	8b 45 08             	mov    0x8(%ebp),%eax
8010815d:	89 04 24             	mov    %eax,(%esp)
80108160:	e8 a0 fc ff ff       	call   80107e05 <mappages>
  memmove(mem, init, sz);
80108165:	8b 45 10             	mov    0x10(%ebp),%eax
80108168:	89 44 24 08          	mov    %eax,0x8(%esp)
8010816c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010816f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108176:	89 04 24             	mov    %eax,(%esp)
80108179:	e8 5e d2 ff ff       	call   801053dc <memmove>
}
8010817e:	c9                   	leave  
8010817f:	c3                   	ret    

80108180 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108180:	55                   	push   %ebp
80108181:	89 e5                	mov    %esp,%ebp
80108183:	53                   	push   %ebx
80108184:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108187:	8b 45 0c             	mov    0xc(%ebp),%eax
8010818a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010818f:	85 c0                	test   %eax,%eax
80108191:	74 0c                	je     8010819f <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108193:	c7 04 24 f4 8c 10 80 	movl   $0x80108cf4,(%esp)
8010819a:	e8 9b 83 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010819f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081a6:	e9 a9 00 00 00       	jmp    80108254 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801081ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ae:	8b 55 0c             	mov    0xc(%ebp),%edx
801081b1:	01 d0                	add    %edx,%eax
801081b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081ba:	00 
801081bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801081bf:	8b 45 08             	mov    0x8(%ebp),%eax
801081c2:	89 04 24             	mov    %eax,(%esp)
801081c5:	e8 99 fb ff ff       	call   80107d63 <walkpgdir>
801081ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081cd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081d1:	75 0c                	jne    801081df <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801081d3:	c7 04 24 17 8d 10 80 	movl   $0x80108d17,(%esp)
801081da:	e8 5b 83 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801081df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081e2:	8b 00                	mov    (%eax),%eax
801081e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801081ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ef:	8b 55 18             	mov    0x18(%ebp),%edx
801081f2:	29 c2                	sub    %eax,%edx
801081f4:	89 d0                	mov    %edx,%eax
801081f6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801081fb:	77 0f                	ja     8010820c <loaduvm+0x8c>
      n = sz - i;
801081fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108200:	8b 55 18             	mov    0x18(%ebp),%edx
80108203:	29 c2                	sub    %eax,%edx
80108205:	89 d0                	mov    %edx,%eax
80108207:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010820a:	eb 07                	jmp    80108213 <loaduvm+0x93>
    else
      n = PGSIZE;
8010820c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108216:	8b 55 14             	mov    0x14(%ebp),%edx
80108219:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010821c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010821f:	89 04 24             	mov    %eax,(%esp)
80108222:	e8 b9 f6 ff ff       	call   801078e0 <p2v>
80108227:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010822a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010822e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108232:	89 44 24 04          	mov    %eax,0x4(%esp)
80108236:	8b 45 10             	mov    0x10(%ebp),%eax
80108239:	89 04 24             	mov    %eax,(%esp)
8010823c:	e8 37 9b ff ff       	call   80101d78 <readi>
80108241:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108244:	74 07                	je     8010824d <loaduvm+0xcd>
      return -1;
80108246:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010824b:	eb 18                	jmp    80108265 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010824d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108257:	3b 45 18             	cmp    0x18(%ebp),%eax
8010825a:	0f 82 4b ff ff ff    	jb     801081ab <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108260:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108265:	83 c4 24             	add    $0x24,%esp
80108268:	5b                   	pop    %ebx
80108269:	5d                   	pop    %ebp
8010826a:	c3                   	ret    

8010826b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010826b:	55                   	push   %ebp
8010826c:	89 e5                	mov    %esp,%ebp
8010826e:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108271:	8b 45 10             	mov    0x10(%ebp),%eax
80108274:	85 c0                	test   %eax,%eax
80108276:	79 0a                	jns    80108282 <allocuvm+0x17>
    return 0;
80108278:	b8 00 00 00 00       	mov    $0x0,%eax
8010827d:	e9 c1 00 00 00       	jmp    80108343 <allocuvm+0xd8>
  if(newsz < oldsz)
80108282:	8b 45 10             	mov    0x10(%ebp),%eax
80108285:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108288:	73 08                	jae    80108292 <allocuvm+0x27>
    return oldsz;
8010828a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010828d:	e9 b1 00 00 00       	jmp    80108343 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108292:	8b 45 0c             	mov    0xc(%ebp),%eax
80108295:	05 ff 0f 00 00       	add    $0xfff,%eax
8010829a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010829f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801082a2:	e9 8d 00 00 00       	jmp    80108334 <allocuvm+0xc9>
    mem = kalloc();
801082a7:	e8 46 a8 ff ff       	call   80102af2 <kalloc>
801082ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082b3:	75 2c                	jne    801082e1 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801082b5:	c7 04 24 35 8d 10 80 	movl   $0x80108d35,(%esp)
801082bc:	e8 df 80 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801082c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801082c4:	89 44 24 08          	mov    %eax,0x8(%esp)
801082c8:	8b 45 10             	mov    0x10(%ebp),%eax
801082cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801082cf:	8b 45 08             	mov    0x8(%ebp),%eax
801082d2:	89 04 24             	mov    %eax,(%esp)
801082d5:	e8 6b 00 00 00       	call   80108345 <deallocuvm>
      return 0;
801082da:	b8 00 00 00 00       	mov    $0x0,%eax
801082df:	eb 62                	jmp    80108343 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801082e1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082e8:	00 
801082e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082f0:	00 
801082f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f4:	89 04 24             	mov    %eax,(%esp)
801082f7:	e8 11 d0 ff ff       	call   8010530d <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ff:	89 04 24             	mov    %eax,(%esp)
80108302:	e8 cc f5 ff ff       	call   801078d3 <v2p>
80108307:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010830a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108311:	00 
80108312:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108316:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010831d:	00 
8010831e:	89 54 24 04          	mov    %edx,0x4(%esp)
80108322:	8b 45 08             	mov    0x8(%ebp),%eax
80108325:	89 04 24             	mov    %eax,(%esp)
80108328:	e8 d8 fa ff ff       	call   80107e05 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010832d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108337:	3b 45 10             	cmp    0x10(%ebp),%eax
8010833a:	0f 82 67 ff ff ff    	jb     801082a7 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108340:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108343:	c9                   	leave  
80108344:	c3                   	ret    

80108345 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108345:	55                   	push   %ebp
80108346:	89 e5                	mov    %esp,%ebp
80108348:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010834b:	8b 45 10             	mov    0x10(%ebp),%eax
8010834e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108351:	72 08                	jb     8010835b <deallocuvm+0x16>
    return oldsz;
80108353:	8b 45 0c             	mov    0xc(%ebp),%eax
80108356:	e9 a4 00 00 00       	jmp    801083ff <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010835b:	8b 45 10             	mov    0x10(%ebp),%eax
8010835e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108363:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108368:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010836b:	e9 80 00 00 00       	jmp    801083f0 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108373:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010837a:	00 
8010837b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010837f:	8b 45 08             	mov    0x8(%ebp),%eax
80108382:	89 04 24             	mov    %eax,(%esp)
80108385:	e8 d9 f9 ff ff       	call   80107d63 <walkpgdir>
8010838a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010838d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108391:	75 09                	jne    8010839c <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108393:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010839a:	eb 4d                	jmp    801083e9 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
8010839c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010839f:	8b 00                	mov    (%eax),%eax
801083a1:	83 e0 01             	and    $0x1,%eax
801083a4:	85 c0                	test   %eax,%eax
801083a6:	74 41                	je     801083e9 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801083a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ab:	8b 00                	mov    (%eax),%eax
801083ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801083b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083b9:	75 0c                	jne    801083c7 <deallocuvm+0x82>
        panic("kfree");
801083bb:	c7 04 24 4d 8d 10 80 	movl   $0x80108d4d,(%esp)
801083c2:	e8 73 81 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
801083c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ca:	89 04 24             	mov    %eax,(%esp)
801083cd:	e8 0e f5 ff ff       	call   801078e0 <p2v>
801083d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801083d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083d8:	89 04 24             	mov    %eax,(%esp)
801083db:	e8 79 a6 ff ff       	call   80102a59 <kfree>
      *pte = 0;
801083e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801083e9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083f6:	0f 82 74 ff ff ff    	jb     80108370 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801083fc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083ff:	c9                   	leave  
80108400:	c3                   	ret    

80108401 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108401:	55                   	push   %ebp
80108402:	89 e5                	mov    %esp,%ebp
80108404:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108407:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010840b:	75 0c                	jne    80108419 <freevm+0x18>
    panic("freevm: no pgdir");
8010840d:	c7 04 24 53 8d 10 80 	movl   $0x80108d53,(%esp)
80108414:	e8 21 81 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108419:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108420:	00 
80108421:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108428:	80 
80108429:	8b 45 08             	mov    0x8(%ebp),%eax
8010842c:	89 04 24             	mov    %eax,(%esp)
8010842f:	e8 11 ff ff ff       	call   80108345 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108434:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010843b:	eb 48                	jmp    80108485 <freevm+0x84>
    if(pgdir[i] & PTE_P){
8010843d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108440:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108447:	8b 45 08             	mov    0x8(%ebp),%eax
8010844a:	01 d0                	add    %edx,%eax
8010844c:	8b 00                	mov    (%eax),%eax
8010844e:	83 e0 01             	and    $0x1,%eax
80108451:	85 c0                	test   %eax,%eax
80108453:	74 2c                	je     80108481 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108458:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010845f:	8b 45 08             	mov    0x8(%ebp),%eax
80108462:	01 d0                	add    %edx,%eax
80108464:	8b 00                	mov    (%eax),%eax
80108466:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010846b:	89 04 24             	mov    %eax,(%esp)
8010846e:	e8 6d f4 ff ff       	call   801078e0 <p2v>
80108473:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108476:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108479:	89 04 24             	mov    %eax,(%esp)
8010847c:	e8 d8 a5 ff ff       	call   80102a59 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108481:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108485:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010848c:	76 af                	jbe    8010843d <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010848e:	8b 45 08             	mov    0x8(%ebp),%eax
80108491:	89 04 24             	mov    %eax,(%esp)
80108494:	e8 c0 a5 ff ff       	call   80102a59 <kfree>
}
80108499:	c9                   	leave  
8010849a:	c3                   	ret    

8010849b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010849b:	55                   	push   %ebp
8010849c:	89 e5                	mov    %esp,%ebp
8010849e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084a8:	00 
801084a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801084b0:	8b 45 08             	mov    0x8(%ebp),%eax
801084b3:	89 04 24             	mov    %eax,(%esp)
801084b6:	e8 a8 f8 ff ff       	call   80107d63 <walkpgdir>
801084bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801084be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801084c2:	75 0c                	jne    801084d0 <clearpteu+0x35>
    panic("clearpteu");
801084c4:	c7 04 24 64 8d 10 80 	movl   $0x80108d64,(%esp)
801084cb:	e8 6a 80 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
801084d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d3:	8b 00                	mov    (%eax),%eax
801084d5:	83 e0 fb             	and    $0xfffffffb,%eax
801084d8:	89 c2                	mov    %eax,%edx
801084da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084dd:	89 10                	mov    %edx,(%eax)
}
801084df:	c9                   	leave  
801084e0:	c3                   	ret    

801084e1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801084e1:	55                   	push   %ebp
801084e2:	89 e5                	mov    %esp,%ebp
801084e4:	53                   	push   %ebx
801084e5:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801084e8:	e8 b0 f9 ff ff       	call   80107e9d <setupkvm>
801084ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084f4:	75 0a                	jne    80108500 <copyuvm+0x1f>
    return 0;
801084f6:	b8 00 00 00 00       	mov    $0x0,%eax
801084fb:	e9 fd 00 00 00       	jmp    801085fd <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108500:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108507:	e9 d0 00 00 00       	jmp    801085dc <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010850c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108516:	00 
80108517:	89 44 24 04          	mov    %eax,0x4(%esp)
8010851b:	8b 45 08             	mov    0x8(%ebp),%eax
8010851e:	89 04 24             	mov    %eax,(%esp)
80108521:	e8 3d f8 ff ff       	call   80107d63 <walkpgdir>
80108526:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108529:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010852d:	75 0c                	jne    8010853b <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010852f:	c7 04 24 6e 8d 10 80 	movl   $0x80108d6e,(%esp)
80108536:	e8 ff 7f ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
8010853b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010853e:	8b 00                	mov    (%eax),%eax
80108540:	83 e0 01             	and    $0x1,%eax
80108543:	85 c0                	test   %eax,%eax
80108545:	75 0c                	jne    80108553 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108547:	c7 04 24 88 8d 10 80 	movl   $0x80108d88,(%esp)
8010854e:	e8 e7 7f ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108553:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108556:	8b 00                	mov    (%eax),%eax
80108558:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010855d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108560:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108563:	8b 00                	mov    (%eax),%eax
80108565:	25 ff 0f 00 00       	and    $0xfff,%eax
8010856a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010856d:	e8 80 a5 ff ff       	call   80102af2 <kalloc>
80108572:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108575:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108579:	75 02                	jne    8010857d <copyuvm+0x9c>
      goto bad;
8010857b:	eb 70                	jmp    801085ed <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010857d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108580:	89 04 24             	mov    %eax,(%esp)
80108583:	e8 58 f3 ff ff       	call   801078e0 <p2v>
80108588:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010858f:	00 
80108590:	89 44 24 04          	mov    %eax,0x4(%esp)
80108594:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108597:	89 04 24             	mov    %eax,(%esp)
8010859a:	e8 3d ce ff ff       	call   801053dc <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010859f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801085a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801085a5:	89 04 24             	mov    %eax,(%esp)
801085a8:	e8 26 f3 ff ff       	call   801078d3 <v2p>
801085ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085b0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801085b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
801085b8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085bf:	00 
801085c0:	89 54 24 04          	mov    %edx,0x4(%esp)
801085c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c7:	89 04 24             	mov    %eax,(%esp)
801085ca:	e8 36 f8 ff ff       	call   80107e05 <mappages>
801085cf:	85 c0                	test   %eax,%eax
801085d1:	79 02                	jns    801085d5 <copyuvm+0xf4>
      goto bad;
801085d3:	eb 18                	jmp    801085ed <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801085d5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085df:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085e2:	0f 82 24 ff ff ff    	jb     8010850c <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801085e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085eb:	eb 10                	jmp    801085fd <copyuvm+0x11c>

bad:
  freevm(d);
801085ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f0:	89 04 24             	mov    %eax,(%esp)
801085f3:	e8 09 fe ff ff       	call   80108401 <freevm>
  return 0;
801085f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085fd:	83 c4 44             	add    $0x44,%esp
80108600:	5b                   	pop    %ebx
80108601:	5d                   	pop    %ebp
80108602:	c3                   	ret    

80108603 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108603:	55                   	push   %ebp
80108604:	89 e5                	mov    %esp,%ebp
80108606:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108609:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108610:	00 
80108611:	8b 45 0c             	mov    0xc(%ebp),%eax
80108614:	89 44 24 04          	mov    %eax,0x4(%esp)
80108618:	8b 45 08             	mov    0x8(%ebp),%eax
8010861b:	89 04 24             	mov    %eax,(%esp)
8010861e:	e8 40 f7 ff ff       	call   80107d63 <walkpgdir>
80108623:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108629:	8b 00                	mov    (%eax),%eax
8010862b:	83 e0 01             	and    $0x1,%eax
8010862e:	85 c0                	test   %eax,%eax
80108630:	75 07                	jne    80108639 <uva2ka+0x36>
    return 0;
80108632:	b8 00 00 00 00       	mov    $0x0,%eax
80108637:	eb 25                	jmp    8010865e <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863c:	8b 00                	mov    (%eax),%eax
8010863e:	83 e0 04             	and    $0x4,%eax
80108641:	85 c0                	test   %eax,%eax
80108643:	75 07                	jne    8010864c <uva2ka+0x49>
    return 0;
80108645:	b8 00 00 00 00       	mov    $0x0,%eax
8010864a:	eb 12                	jmp    8010865e <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
8010864c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864f:	8b 00                	mov    (%eax),%eax
80108651:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108656:	89 04 24             	mov    %eax,(%esp)
80108659:	e8 82 f2 ff ff       	call   801078e0 <p2v>
}
8010865e:	c9                   	leave  
8010865f:	c3                   	ret    

80108660 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108660:	55                   	push   %ebp
80108661:	89 e5                	mov    %esp,%ebp
80108663:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108666:	8b 45 10             	mov    0x10(%ebp),%eax
80108669:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010866c:	e9 87 00 00 00       	jmp    801086f8 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108671:	8b 45 0c             	mov    0xc(%ebp),%eax
80108674:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108679:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010867c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010867f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108683:	8b 45 08             	mov    0x8(%ebp),%eax
80108686:	89 04 24             	mov    %eax,(%esp)
80108689:	e8 75 ff ff ff       	call   80108603 <uva2ka>
8010868e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108691:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108695:	75 07                	jne    8010869e <copyout+0x3e>
      return -1;
80108697:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010869c:	eb 69                	jmp    80108707 <copyout+0xa7>
    n = PGSIZE - (va - va0);
8010869e:	8b 45 0c             	mov    0xc(%ebp),%eax
801086a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801086a4:	29 c2                	sub    %eax,%edx
801086a6:	89 d0                	mov    %edx,%eax
801086a8:	05 00 10 00 00       	add    $0x1000,%eax
801086ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801086b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086b3:	3b 45 14             	cmp    0x14(%ebp),%eax
801086b6:	76 06                	jbe    801086be <copyout+0x5e>
      n = len;
801086b8:	8b 45 14             	mov    0x14(%ebp),%eax
801086bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801086be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801086c4:	29 c2                	sub    %eax,%edx
801086c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086c9:	01 c2                	add    %eax,%edx
801086cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086ce:	89 44 24 08          	mov    %eax,0x8(%esp)
801086d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801086d9:	89 14 24             	mov    %edx,(%esp)
801086dc:	e8 fb cc ff ff       	call   801053dc <memmove>
    len -= n;
801086e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086e4:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801086e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086ea:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801086ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f0:	05 00 10 00 00       	add    $0x1000,%eax
801086f5:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801086f8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801086fc:	0f 85 6f ff ff ff    	jne    80108671 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108702:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108707:	c9                   	leave  
80108708:	c3                   	ret    
