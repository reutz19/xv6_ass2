
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
8010002d:	b8 17 37 10 80       	mov    $0x80103717,%eax
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
8010003a:	c7 44 24 04 8c 84 10 	movl   $0x8010848c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 52 4e 00 00       	call   80104ea0 <initlock>

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
801000bd:	e8 ff 4d 00 00       	call   80104ec1 <acquire>

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
80100104:	e8 1a 4e 00 00       	call   80104f23 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 ca 4a 00 00       	call   80104bee <sleep>
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
8010017c:	e8 a2 4d 00 00       	call   80104f23 <release>
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
80100198:	c7 04 24 93 84 10 80 	movl   $0x80108493,(%esp)
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
801001d3:	e8 c9 25 00 00       	call   801027a1 <iderw>
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
801001ef:	c7 04 24 a4 84 10 80 	movl   $0x801084a4,(%esp)
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
80100210:	e8 8c 25 00 00       	call   801027a1 <iderw>
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
80100229:	c7 04 24 ab 84 10 80 	movl   $0x801084ab,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 80 4c 00 00       	call   80104ec1 <acquire>

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
8010029d:	e8 24 4a 00 00       	call   80104cc6 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 75 4c 00 00       	call   80104f23 <release>
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
801003bb:	e8 01 4b 00 00       	call   80104ec1 <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 b2 84 10 80 	movl   $0x801084b2,(%esp)
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
801004b0:	c7 45 ec bb 84 10 80 	movl   $0x801084bb,-0x14(%ebp)
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
80100533:	e8 eb 49 00 00       	call   80104f23 <release>
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
8010055f:	c7 04 24 c2 84 10 80 	movl   $0x801084c2,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 d1 84 10 80 	movl   $0x801084d1,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 de 49 00 00       	call   80104f72 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 d3 84 10 80 	movl   $0x801084d3,(%esp)
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
801006b2:	e8 2d 4b 00 00       	call   801051e4 <memmove>
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
801006e1:	e8 2f 4a 00 00       	call   80105115 <memset>
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
80100776:	e8 51 63 00 00       	call   80106acc <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 45 63 00 00       	call   80106acc <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 39 63 00 00       	call   80106acc <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 2c 63 00 00       	call   80106acc <uartputc>
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
801007ba:	e8 02 47 00 00       	call   80104ec1 <acquire>
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
801007ea:	e8 7a 45 00 00       	call   80104d69 <procdump>
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
801008f3:	e8 ce 43 00 00       	call   80104cc6 <wakeup>
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
80100914:	e8 0a 46 00 00       	call   80104f23 <release>
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
80100927:	e8 7d 10 00 00       	call   801019a9 <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100939:	e8 83 45 00 00       	call   80104ec1 <acquire>
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
80100959:	e8 c5 45 00 00       	call   80104f23 <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 f2 0e 00 00       	call   8010185b <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 80 07 11 	movl   $0x80110780,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
80100982:	e8 67 42 00 00       	call   80104bee <sleep>

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
801009fe:	e8 20 45 00 00       	call   80104f23 <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 4d 0e 00 00       	call   8010185b <ilock>

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
80100a26:	e8 7e 0f 00 00       	call   801019a9 <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a32:	e8 8a 44 00 00       	call   80104ec1 <acquire>
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
80100a6c:	e8 b2 44 00 00       	call   80104f23 <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 df 0d 00 00       	call   8010185b <ilock>

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
80100a87:	c7 44 24 04 d7 84 10 	movl   $0x801084d7,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a96:	e8 05 44 00 00       	call   80104ea0 <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 df 84 10 	movl   $0x801084df,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100aaa:	e8 f1 43 00 00       	call   80104ea0 <initlock>

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
80100ad4:	e8 db 32 00 00       	call   80103db4 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 70 1e 00 00       	call   8010295d <ioapicenable>
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
80100af8:	e8 13 29 00 00       	call   80103410 <begin_op>
  if((ip = namei(path)) == 0){
80100afd:	8b 45 08             	mov    0x8(%ebp),%eax
80100b00:	89 04 24             	mov    %eax,(%esp)
80100b03:	e8 fe 18 00 00       	call   80102406 <namei>
80100b08:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b0b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b0f:	75 0f                	jne    80100b20 <exec+0x31>
    end_op();
80100b11:	e8 7e 29 00 00       	call   80103494 <end_op>
    return -1;
80100b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1b:	e9 e8 03 00 00       	jmp    80100f08 <exec+0x419>
  }
  ilock(ip);
80100b20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b23:	89 04 24             	mov    %eax,(%esp)
80100b26:	e8 30 0d 00 00       	call   8010185b <ilock>
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
80100b52:	e8 11 12 00 00       	call   80101d68 <readi>
80100b57:	83 f8 33             	cmp    $0x33,%eax
80100b5a:	77 05                	ja     80100b61 <exec+0x72>
    goto bad;
80100b5c:	e9 7b 03 00 00       	jmp    80100edc <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100b61:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b67:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b6c:	74 05                	je     80100b73 <exec+0x84>
    goto bad;
80100b6e:	e9 69 03 00 00       	jmp    80100edc <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100b73:	e8 a5 70 00 00       	call   80107c1d <setupkvm>
80100b78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b7b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b7f:	75 05                	jne    80100b86 <exec+0x97>
    goto bad;
80100b81:	e9 56 03 00 00       	jmp    80100edc <exec+0x3ed>

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
80100bc1:	e8 a2 11 00 00       	call   80101d68 <readi>
80100bc6:	83 f8 20             	cmp    $0x20,%eax
80100bc9:	74 05                	je     80100bd0 <exec+0xe1>
      goto bad;
80100bcb:	e9 0c 03 00 00       	jmp    80100edc <exec+0x3ed>
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
80100bf0:	e9 e7 02 00 00       	jmp    80100edc <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf5:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfb:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c01:	01 d0                	add    %edx,%eax
80100c03:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c11:	89 04 24             	mov    %eax,(%esp)
80100c14:	e8 d2 73 00 00       	call   80107feb <allocuvm>
80100c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c20:	75 05                	jne    80100c27 <exec+0x138>
      goto bad;
80100c22:	e9 b5 02 00 00       	jmp    80100edc <exec+0x3ed>
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
80100c52:	e8 a9 72 00 00       	call   80107f00 <loaduvm>
80100c57:	85 c0                	test   %eax,%eax
80100c59:	79 05                	jns    80100c60 <exec+0x171>
      goto bad;
80100c5b:	e9 7c 02 00 00       	jmp    80100edc <exec+0x3ed>
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
80100c86:	e8 54 0e 00 00       	call   80101adf <iunlockput>
  end_op();
80100c8b:	e8 04 28 00 00       	call   80103494 <end_op>
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
80100cc0:	e8 26 73 00 00       	call   80107feb <allocuvm>
80100cc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ccc:	75 05                	jne    80100cd3 <exec+0x1e4>
    goto bad;
80100cce:	e9 09 02 00 00       	jmp    80100edc <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce2:	89 04 24             	mov    %eax,(%esp)
80100ce5:	e8 31 75 00 00       	call   8010821b <clearpteu>
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
80100d02:	e9 d5 01 00 00       	jmp    80100edc <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d14:	01 d0                	add    %edx,%eax
80100d16:	8b 00                	mov    (%eax),%eax
80100d18:	89 04 24             	mov    %eax,(%esp)
80100d1b:	e8 5f 46 00 00       	call   8010537f <strlen>
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
80100d44:	e8 36 46 00 00       	call   8010537f <strlen>
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
80100d74:	e8 67 76 00 00       	call   801083e0 <copyout>
80100d79:	85 c0                	test   %eax,%eax
80100d7b:	79 05                	jns    80100d82 <exec+0x293>
      goto bad;
80100d7d:	e9 5a 01 00 00       	jmp    80100edc <exec+0x3ed>
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
80100e1b:	e8 c0 75 00 00       	call   801083e0 <copyout>
80100e20:	85 c0                	test   %eax,%eax
80100e22:	79 05                	jns    80100e29 <exec+0x33a>
    goto bad;
80100e24:	e9 b3 00 00 00       	jmp    80100edc <exec+0x3ed>

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
80100e73:	e8 bd 44 00 00       	call   80105335 <safestrcpy>

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
  switchuvm(proc);
80100ebc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec2:	89 04 24             	mov    %eax,(%esp)
80100ec5:	e8 44 6e 00 00       	call   80107d0e <switchuvm>
  freevm(oldpgdir);
80100eca:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ecd:	89 04 24             	mov    %eax,(%esp)
80100ed0:	e8 ac 72 00 00       	call   80108181 <freevm>
  return 0;
80100ed5:	b8 00 00 00 00       	mov    $0x0,%eax
80100eda:	eb 2c                	jmp    80100f08 <exec+0x419>

 bad:
  if(pgdir)
80100edc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ee0:	74 0b                	je     80100eed <exec+0x3fe>
    freevm(pgdir);
80100ee2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ee5:	89 04 24             	mov    %eax,(%esp)
80100ee8:	e8 94 72 00 00       	call   80108181 <freevm>
  if(ip){
80100eed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ef1:	74 10                	je     80100f03 <exec+0x414>
    iunlockput(ip);
80100ef3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ef6:	89 04 24             	mov    %eax,(%esp)
80100ef9:	e8 e1 0b 00 00       	call   80101adf <iunlockput>
    end_op();
80100efe:	e8 91 25 00 00       	call   80103494 <end_op>
  }
  return -1;
80100f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f08:	c9                   	leave  
80100f09:	c3                   	ret    

80100f0a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f0a:	55                   	push   %ebp
80100f0b:	89 e5                	mov    %esp,%ebp
80100f0d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f10:	c7 44 24 04 e5 84 10 	movl   $0x801084e5,0x4(%esp)
80100f17:	80 
80100f18:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f1f:	e8 7c 3f 00 00       	call   80104ea0 <initlock>
}
80100f24:	c9                   	leave  
80100f25:	c3                   	ret    

80100f26 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f26:	55                   	push   %ebp
80100f27:	89 e5                	mov    %esp,%ebp
80100f29:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f2c:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f33:	e8 89 3f 00 00       	call   80104ec1 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f38:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f3f:	eb 29                	jmp    80100f6a <filealloc+0x44>
    if(f->ref == 0){
80100f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f44:	8b 40 04             	mov    0x4(%eax),%eax
80100f47:	85 c0                	test   %eax,%eax
80100f49:	75 1b                	jne    80100f66 <filealloc+0x40>
      f->ref = 1;
80100f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f4e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f55:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f5c:	e8 c2 3f 00 00       	call   80104f23 <release>
      return f;
80100f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f64:	eb 1e                	jmp    80100f84 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f66:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f6a:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
80100f71:	72 ce                	jb     80100f41 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f73:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f7a:	e8 a4 3f 00 00       	call   80104f23 <release>
  return 0;
80100f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f84:	c9                   	leave  
80100f85:	c3                   	ret    

80100f86 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f86:	55                   	push   %ebp
80100f87:	89 e5                	mov    %esp,%ebp
80100f89:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f8c:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f93:	e8 29 3f 00 00       	call   80104ec1 <acquire>
  if(f->ref < 1)
80100f98:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9b:	8b 40 04             	mov    0x4(%eax),%eax
80100f9e:	85 c0                	test   %eax,%eax
80100fa0:	7f 0c                	jg     80100fae <filedup+0x28>
    panic("filedup");
80100fa2:	c7 04 24 ec 84 10 80 	movl   $0x801084ec,(%esp)
80100fa9:	e8 8c f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fae:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb1:	8b 40 04             	mov    0x4(%eax),%eax
80100fb4:	8d 50 01             	lea    0x1(%eax),%edx
80100fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fba:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbd:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fc4:	e8 5a 3f 00 00       	call   80104f23 <release>
  return f;
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fcc:	c9                   	leave  
80100fcd:	c3                   	ret    

80100fce <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fce:	55                   	push   %ebp
80100fcf:	89 e5                	mov    %esp,%ebp
80100fd1:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fd4:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fdb:	e8 e1 3e 00 00       	call   80104ec1 <acquire>
  if(f->ref < 1)
80100fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe3:	8b 40 04             	mov    0x4(%eax),%eax
80100fe6:	85 c0                	test   %eax,%eax
80100fe8:	7f 0c                	jg     80100ff6 <fileclose+0x28>
    panic("fileclose");
80100fea:	c7 04 24 f4 84 10 80 	movl   $0x801084f4,(%esp)
80100ff1:	e8 44 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80100ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff9:	8b 40 04             	mov    0x4(%eax),%eax
80100ffc:	8d 50 ff             	lea    -0x1(%eax),%edx
80100fff:	8b 45 08             	mov    0x8(%ebp),%eax
80101002:	89 50 04             	mov    %edx,0x4(%eax)
80101005:	8b 45 08             	mov    0x8(%ebp),%eax
80101008:	8b 40 04             	mov    0x4(%eax),%eax
8010100b:	85 c0                	test   %eax,%eax
8010100d:	7e 11                	jle    80101020 <fileclose+0x52>
    release(&ftable.lock);
8010100f:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101016:	e8 08 3f 00 00       	call   80104f23 <release>
8010101b:	e9 82 00 00 00       	jmp    801010a2 <fileclose+0xd4>
    return;
  }
  ff = *f;
80101020:	8b 45 08             	mov    0x8(%ebp),%eax
80101023:	8b 10                	mov    (%eax),%edx
80101025:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101028:	8b 50 04             	mov    0x4(%eax),%edx
8010102b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010102e:	8b 50 08             	mov    0x8(%eax),%edx
80101031:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101034:	8b 50 0c             	mov    0xc(%eax),%edx
80101037:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010103a:	8b 50 10             	mov    0x10(%eax),%edx
8010103d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101040:	8b 40 14             	mov    0x14(%eax),%eax
80101043:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101046:	8b 45 08             	mov    0x8(%ebp),%eax
80101049:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101050:	8b 45 08             	mov    0x8(%ebp),%eax
80101053:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101059:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101060:	e8 be 3e 00 00       	call   80104f23 <release>
  
  if(ff.type == FD_PIPE)
80101065:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101068:	83 f8 01             	cmp    $0x1,%eax
8010106b:	75 18                	jne    80101085 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010106d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101071:	0f be d0             	movsbl %al,%edx
80101074:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101077:	89 54 24 04          	mov    %edx,0x4(%esp)
8010107b:	89 04 24             	mov    %eax,(%esp)
8010107e:	e8 e1 2f 00 00       	call   80104064 <pipeclose>
80101083:	eb 1d                	jmp    801010a2 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101085:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101088:	83 f8 02             	cmp    $0x2,%eax
8010108b:	75 15                	jne    801010a2 <fileclose+0xd4>
    begin_op();
8010108d:	e8 7e 23 00 00       	call   80103410 <begin_op>
    iput(ff.ip);
80101092:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101095:	89 04 24             	mov    %eax,(%esp)
80101098:	e8 71 09 00 00       	call   80101a0e <iput>
    end_op();
8010109d:	e8 f2 23 00 00       	call   80103494 <end_op>
  }
}
801010a2:	c9                   	leave  
801010a3:	c3                   	ret    

801010a4 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010a4:	55                   	push   %ebp
801010a5:	89 e5                	mov    %esp,%ebp
801010a7:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010aa:	8b 45 08             	mov    0x8(%ebp),%eax
801010ad:	8b 00                	mov    (%eax),%eax
801010af:	83 f8 02             	cmp    $0x2,%eax
801010b2:	75 38                	jne    801010ec <filestat+0x48>
    ilock(f->ip);
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 10             	mov    0x10(%eax),%eax
801010ba:	89 04 24             	mov    %eax,(%esp)
801010bd:	e8 99 07 00 00       	call   8010185b <ilock>
    stati(f->ip, st);
801010c2:	8b 45 08             	mov    0x8(%ebp),%eax
801010c5:	8b 40 10             	mov    0x10(%eax),%eax
801010c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801010cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801010cf:	89 04 24             	mov    %eax,(%esp)
801010d2:	e8 4c 0c 00 00       	call   80101d23 <stati>
    iunlock(f->ip);
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 10             	mov    0x10(%eax),%eax
801010dd:	89 04 24             	mov    %eax,(%esp)
801010e0:	e8 c4 08 00 00       	call   801019a9 <iunlock>
    return 0;
801010e5:	b8 00 00 00 00       	mov    $0x0,%eax
801010ea:	eb 05                	jmp    801010f1 <filestat+0x4d>
  }
  return -1;
801010ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010f1:	c9                   	leave  
801010f2:	c3                   	ret    

801010f3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010f3:	55                   	push   %ebp
801010f4:	89 e5                	mov    %esp,%ebp
801010f6:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010f9:	8b 45 08             	mov    0x8(%ebp),%eax
801010fc:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101100:	84 c0                	test   %al,%al
80101102:	75 0a                	jne    8010110e <fileread+0x1b>
    return -1;
80101104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101109:	e9 9f 00 00 00       	jmp    801011ad <fileread+0xba>
  if(f->type == FD_PIPE)
8010110e:	8b 45 08             	mov    0x8(%ebp),%eax
80101111:	8b 00                	mov    (%eax),%eax
80101113:	83 f8 01             	cmp    $0x1,%eax
80101116:	75 1e                	jne    80101136 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101118:	8b 45 08             	mov    0x8(%ebp),%eax
8010111b:	8b 40 0c             	mov    0xc(%eax),%eax
8010111e:	8b 55 10             	mov    0x10(%ebp),%edx
80101121:	89 54 24 08          	mov    %edx,0x8(%esp)
80101125:	8b 55 0c             	mov    0xc(%ebp),%edx
80101128:	89 54 24 04          	mov    %edx,0x4(%esp)
8010112c:	89 04 24             	mov    %eax,(%esp)
8010112f:	e8 b1 30 00 00       	call   801041e5 <piperead>
80101134:	eb 77                	jmp    801011ad <fileread+0xba>
  if(f->type == FD_INODE){
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 00                	mov    (%eax),%eax
8010113b:	83 f8 02             	cmp    $0x2,%eax
8010113e:	75 61                	jne    801011a1 <fileread+0xae>
    ilock(f->ip);
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 40 10             	mov    0x10(%eax),%eax
80101146:	89 04 24             	mov    %eax,(%esp)
80101149:	e8 0d 07 00 00       	call   8010185b <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010114e:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
80101154:	8b 50 14             	mov    0x14(%eax),%edx
80101157:	8b 45 08             	mov    0x8(%ebp),%eax
8010115a:	8b 40 10             	mov    0x10(%eax),%eax
8010115d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101161:	89 54 24 08          	mov    %edx,0x8(%esp)
80101165:	8b 55 0c             	mov    0xc(%ebp),%edx
80101168:	89 54 24 04          	mov    %edx,0x4(%esp)
8010116c:	89 04 24             	mov    %eax,(%esp)
8010116f:	e8 f4 0b 00 00       	call   80101d68 <readi>
80101174:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101177:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010117b:	7e 11                	jle    8010118e <fileread+0x9b>
      f->off += r;
8010117d:	8b 45 08             	mov    0x8(%ebp),%eax
80101180:	8b 50 14             	mov    0x14(%eax),%edx
80101183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101186:	01 c2                	add    %eax,%edx
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010118e:	8b 45 08             	mov    0x8(%ebp),%eax
80101191:	8b 40 10             	mov    0x10(%eax),%eax
80101194:	89 04 24             	mov    %eax,(%esp)
80101197:	e8 0d 08 00 00       	call   801019a9 <iunlock>
    return r;
8010119c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010119f:	eb 0c                	jmp    801011ad <fileread+0xba>
  }
  panic("fileread");
801011a1:	c7 04 24 fe 84 10 80 	movl   $0x801084fe,(%esp)
801011a8:	e8 8d f3 ff ff       	call   8010053a <panic>
}
801011ad:	c9                   	leave  
801011ae:	c3                   	ret    

801011af <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011af:	55                   	push   %ebp
801011b0:	89 e5                	mov    %esp,%ebp
801011b2:	53                   	push   %ebx
801011b3:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011bd:	84 c0                	test   %al,%al
801011bf:	75 0a                	jne    801011cb <filewrite+0x1c>
    return -1;
801011c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011c6:	e9 20 01 00 00       	jmp    801012eb <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011cb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ce:	8b 00                	mov    (%eax),%eax
801011d0:	83 f8 01             	cmp    $0x1,%eax
801011d3:	75 21                	jne    801011f6 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011d5:	8b 45 08             	mov    0x8(%ebp),%eax
801011d8:	8b 40 0c             	mov    0xc(%eax),%eax
801011db:	8b 55 10             	mov    0x10(%ebp),%edx
801011de:	89 54 24 08          	mov    %edx,0x8(%esp)
801011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801011e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801011e9:	89 04 24             	mov    %eax,(%esp)
801011ec:	e8 05 2f 00 00       	call   801040f6 <pipewrite>
801011f1:	e9 f5 00 00 00       	jmp    801012eb <filewrite+0x13c>
  if(f->type == FD_INODE){
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 00                	mov    (%eax),%eax
801011fb:	83 f8 02             	cmp    $0x2,%eax
801011fe:	0f 85 db 00 00 00    	jne    801012df <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101204:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010120b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101212:	e9 a8 00 00 00       	jmp    801012bf <filewrite+0x110>
      int n1 = n - i;
80101217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121a:	8b 55 10             	mov    0x10(%ebp),%edx
8010121d:	29 c2                	sub    %eax,%edx
8010121f:	89 d0                	mov    %edx,%eax
80101221:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101224:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101227:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010122a:	7e 06                	jle    80101232 <filewrite+0x83>
        n1 = max;
8010122c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010122f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101232:	e8 d9 21 00 00       	call   80103410 <begin_op>
      ilock(f->ip);
80101237:	8b 45 08             	mov    0x8(%ebp),%eax
8010123a:	8b 40 10             	mov    0x10(%eax),%eax
8010123d:	89 04 24             	mov    %eax,(%esp)
80101240:	e8 16 06 00 00       	call   8010185b <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101245:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 50 14             	mov    0x14(%eax),%edx
8010124e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101251:	8b 45 0c             	mov    0xc(%ebp),%eax
80101254:	01 c3                	add    %eax,%ebx
80101256:	8b 45 08             	mov    0x8(%ebp),%eax
80101259:	8b 40 10             	mov    0x10(%eax),%eax
8010125c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101260:	89 54 24 08          	mov    %edx,0x8(%esp)
80101264:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101268:	89 04 24             	mov    %eax,(%esp)
8010126b:	e8 5c 0c 00 00       	call   80101ecc <writei>
80101270:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101273:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101277:	7e 11                	jle    8010128a <filewrite+0xdb>
        f->off += r;
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 50 14             	mov    0x14(%eax),%edx
8010127f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101282:	01 c2                	add    %eax,%edx
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	8b 40 10             	mov    0x10(%eax),%eax
80101290:	89 04 24             	mov    %eax,(%esp)
80101293:	e8 11 07 00 00       	call   801019a9 <iunlock>
      end_op();
80101298:	e8 f7 21 00 00       	call   80103494 <end_op>

      if(r < 0)
8010129d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012a1:	79 02                	jns    801012a5 <filewrite+0xf6>
        break;
801012a3:	eb 26                	jmp    801012cb <filewrite+0x11c>
      if(r != n1)
801012a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012a8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012ab:	74 0c                	je     801012b9 <filewrite+0x10a>
        panic("short filewrite");
801012ad:	c7 04 24 07 85 10 80 	movl   $0x80108507,(%esp)
801012b4:	e8 81 f2 ff ff       	call   8010053a <panic>
      i += r;
801012b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012bc:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c2:	3b 45 10             	cmp    0x10(%ebp),%eax
801012c5:	0f 8c 4c ff ff ff    	jl     80101217 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ce:	3b 45 10             	cmp    0x10(%ebp),%eax
801012d1:	75 05                	jne    801012d8 <filewrite+0x129>
801012d3:	8b 45 10             	mov    0x10(%ebp),%eax
801012d6:	eb 05                	jmp    801012dd <filewrite+0x12e>
801012d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012dd:	eb 0c                	jmp    801012eb <filewrite+0x13c>
  }
  panic("filewrite");
801012df:	c7 04 24 17 85 10 80 	movl   $0x80108517,(%esp)
801012e6:	e8 4f f2 ff ff       	call   8010053a <panic>
}
801012eb:	83 c4 24             	add    $0x24,%esp
801012ee:	5b                   	pop    %ebx
801012ef:	5d                   	pop    %ebp
801012f0:	c3                   	ret    

801012f1 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012f1:	55                   	push   %ebp
801012f2:	89 e5                	mov    %esp,%ebp
801012f4:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101301:	00 
80101302:	89 04 24             	mov    %eax,(%esp)
80101305:	e8 9c ee ff ff       	call   801001a6 <bread>
8010130a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010130d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101310:	83 c0 18             	add    $0x18,%eax
80101313:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010131a:	00 
8010131b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010131f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101322:	89 04 24             	mov    %eax,(%esp)
80101325:	e8 ba 3e 00 00       	call   801051e4 <memmove>
  brelse(bp);
8010132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132d:	89 04 24             	mov    %eax,(%esp)
80101330:	e8 e2 ee ff ff       	call   80100217 <brelse>
}
80101335:	c9                   	leave  
80101336:	c3                   	ret    

80101337 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101337:	55                   	push   %ebp
80101338:	89 e5                	mov    %esp,%ebp
8010133a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010133d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	89 54 24 04          	mov    %edx,0x4(%esp)
80101347:	89 04 24             	mov    %eax,(%esp)
8010134a:	e8 57 ee ff ff       	call   801001a6 <bread>
8010134f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101355:	83 c0 18             	add    $0x18,%eax
80101358:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010135f:	00 
80101360:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101367:	00 
80101368:	89 04 24             	mov    %eax,(%esp)
8010136b:	e8 a5 3d 00 00       	call   80105115 <memset>
  log_write(bp);
80101370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101373:	89 04 24             	mov    %eax,(%esp)
80101376:	e8 a0 22 00 00       	call   8010361b <log_write>
  brelse(bp);
8010137b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137e:	89 04 24             	mov    %eax,(%esp)
80101381:	e8 91 ee ff ff       	call   80100217 <brelse>
}
80101386:	c9                   	leave  
80101387:	c3                   	ret    

80101388 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101388:	55                   	push   %ebp
80101389:	89 e5                	mov    %esp,%ebp
8010138b:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010138e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101395:	8b 45 08             	mov    0x8(%ebp),%eax
80101398:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010139b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010139f:	89 04 24             	mov    %eax,(%esp)
801013a2:	e8 4a ff ff ff       	call   801012f1 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013ae:	e9 07 01 00 00       	jmp    801014ba <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013bc:	85 c0                	test   %eax,%eax
801013be:	0f 48 c2             	cmovs  %edx,%eax
801013c1:	c1 f8 0c             	sar    $0xc,%eax
801013c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013c7:	c1 ea 03             	shr    $0x3,%edx
801013ca:	01 d0                	add    %edx,%eax
801013cc:	83 c0 03             	add    $0x3,%eax
801013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801013d3:	8b 45 08             	mov    0x8(%ebp),%eax
801013d6:	89 04 24             	mov    %eax,(%esp)
801013d9:	e8 c8 ed ff ff       	call   801001a6 <bread>
801013de:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013e8:	e9 9d 00 00 00       	jmp    8010148a <balloc+0x102>
      m = 1 << (bi % 8);
801013ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f0:	99                   	cltd   
801013f1:	c1 ea 1d             	shr    $0x1d,%edx
801013f4:	01 d0                	add    %edx,%eax
801013f6:	83 e0 07             	and    $0x7,%eax
801013f9:	29 d0                	sub    %edx,%eax
801013fb:	ba 01 00 00 00       	mov    $0x1,%edx
80101400:	89 c1                	mov    %eax,%ecx
80101402:	d3 e2                	shl    %cl,%edx
80101404:	89 d0                	mov    %edx,%eax
80101406:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010140c:	8d 50 07             	lea    0x7(%eax),%edx
8010140f:	85 c0                	test   %eax,%eax
80101411:	0f 48 c2             	cmovs  %edx,%eax
80101414:	c1 f8 03             	sar    $0x3,%eax
80101417:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010141a:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010141f:	0f b6 c0             	movzbl %al,%eax
80101422:	23 45 e8             	and    -0x18(%ebp),%eax
80101425:	85 c0                	test   %eax,%eax
80101427:	75 5d                	jne    80101486 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142c:	8d 50 07             	lea    0x7(%eax),%edx
8010142f:	85 c0                	test   %eax,%eax
80101431:	0f 48 c2             	cmovs  %edx,%eax
80101434:	c1 f8 03             	sar    $0x3,%eax
80101437:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010143a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010143f:	89 d1                	mov    %edx,%ecx
80101441:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101444:	09 ca                	or     %ecx,%edx
80101446:	89 d1                	mov    %edx,%ecx
80101448:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010144b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010144f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101452:	89 04 24             	mov    %eax,(%esp)
80101455:	e8 c1 21 00 00       	call   8010361b <log_write>
        brelse(bp);
8010145a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010145d:	89 04 24             	mov    %eax,(%esp)
80101460:	e8 b2 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101465:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101468:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010146b:	01 c2                	add    %eax,%edx
8010146d:	8b 45 08             	mov    0x8(%ebp),%eax
80101470:	89 54 24 04          	mov    %edx,0x4(%esp)
80101474:	89 04 24             	mov    %eax,(%esp)
80101477:	e8 bb fe ff ff       	call   80101337 <bzero>
        return b + bi;
8010147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010147f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101482:	01 d0                	add    %edx,%eax
80101484:	eb 4e                	jmp    801014d4 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101486:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010148a:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101491:	7f 15                	jg     801014a8 <balloc+0x120>
80101493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101496:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101499:	01 d0                	add    %edx,%eax
8010149b:	89 c2                	mov    %eax,%edx
8010149d:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014a0:	39 c2                	cmp    %eax,%edx
801014a2:	0f 82 45 ff ff ff    	jb     801013ed <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014ab:	89 04 24             	mov    %eax,(%esp)
801014ae:	e8 64 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014b3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014c0:	39 c2                	cmp    %eax,%edx
801014c2:	0f 82 eb fe ff ff    	jb     801013b3 <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014c8:	c7 04 24 21 85 10 80 	movl   $0x80108521,(%esp)
801014cf:	e8 66 f0 ff ff       	call   8010053a <panic>
}
801014d4:	c9                   	leave  
801014d5:	c3                   	ret    

801014d6 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014d6:	55                   	push   %ebp
801014d7:	89 e5                	mov    %esp,%ebp
801014d9:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014dc:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014df:	89 44 24 04          	mov    %eax,0x4(%esp)
801014e3:	8b 45 08             	mov    0x8(%ebp),%eax
801014e6:	89 04 24             	mov    %eax,(%esp)
801014e9:	e8 03 fe ff ff       	call   801012f1 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f1:	c1 e8 0c             	shr    $0xc,%eax
801014f4:	89 c2                	mov    %eax,%edx
801014f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014f9:	c1 e8 03             	shr    $0x3,%eax
801014fc:	01 d0                	add    %edx,%eax
801014fe:	8d 50 03             	lea    0x3(%eax),%edx
80101501:	8b 45 08             	mov    0x8(%ebp),%eax
80101504:	89 54 24 04          	mov    %edx,0x4(%esp)
80101508:	89 04 24             	mov    %eax,(%esp)
8010150b:	e8 96 ec ff ff       	call   801001a6 <bread>
80101510:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101513:	8b 45 0c             	mov    0xc(%ebp),%eax
80101516:	25 ff 0f 00 00       	and    $0xfff,%eax
8010151b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101521:	99                   	cltd   
80101522:	c1 ea 1d             	shr    $0x1d,%edx
80101525:	01 d0                	add    %edx,%eax
80101527:	83 e0 07             	and    $0x7,%eax
8010152a:	29 d0                	sub    %edx,%eax
8010152c:	ba 01 00 00 00       	mov    $0x1,%edx
80101531:	89 c1                	mov    %eax,%ecx
80101533:	d3 e2                	shl    %cl,%edx
80101535:	89 d0                	mov    %edx,%eax
80101537:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	8d 50 07             	lea    0x7(%eax),%edx
80101540:	85 c0                	test   %eax,%eax
80101542:	0f 48 c2             	cmovs  %edx,%eax
80101545:	c1 f8 03             	sar    $0x3,%eax
80101548:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010154b:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101550:	0f b6 c0             	movzbl %al,%eax
80101553:	23 45 ec             	and    -0x14(%ebp),%eax
80101556:	85 c0                	test   %eax,%eax
80101558:	75 0c                	jne    80101566 <bfree+0x90>
    panic("freeing free block");
8010155a:	c7 04 24 37 85 10 80 	movl   $0x80108537,(%esp)
80101561:	e8 d4 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101569:	8d 50 07             	lea    0x7(%eax),%edx
8010156c:	85 c0                	test   %eax,%eax
8010156e:	0f 48 c2             	cmovs  %edx,%eax
80101571:	c1 f8 03             	sar    $0x3,%eax
80101574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101577:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010157c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010157f:	f7 d1                	not    %ecx
80101581:	21 ca                	and    %ecx,%edx
80101583:	89 d1                	mov    %edx,%ecx
80101585:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101588:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010158c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 84 20 00 00       	call   8010361b <log_write>
  brelse(bp);
80101597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159a:	89 04 24             	mov    %eax,(%esp)
8010159d:	e8 75 ec ff ff       	call   80100217 <brelse>
}
801015a2:	c9                   	leave  
801015a3:	c3                   	ret    

801015a4 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015a4:	55                   	push   %ebp
801015a5:	89 e5                	mov    %esp,%ebp
801015a7:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015aa:	c7 44 24 04 4a 85 10 	movl   $0x8010854a,0x4(%esp)
801015b1:	80 
801015b2:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801015b9:	e8 e2 38 00 00       	call   80104ea0 <initlock>
}
801015be:	c9                   	leave  
801015bf:	c3                   	ret    

801015c0 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015c0:	55                   	push   %ebp
801015c1:	89 e5                	mov    %esp,%ebp
801015c3:	83 ec 38             	sub    $0x38,%esp
801015c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c9:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015cd:	8b 45 08             	mov    0x8(%ebp),%eax
801015d0:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801015d7:	89 04 24             	mov    %eax,(%esp)
801015da:	e8 12 fd ff ff       	call   801012f1 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015df:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015e6:	e9 98 00 00 00       	jmp    80101683 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ee:	c1 e8 03             	shr    $0x3,%eax
801015f1:	83 c0 02             	add    $0x2,%eax
801015f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801015f8:	8b 45 08             	mov    0x8(%ebp),%eax
801015fb:	89 04 24             	mov    %eax,(%esp)
801015fe:	e8 a3 eb ff ff       	call   801001a6 <bread>
80101603:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101606:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101609:	8d 50 18             	lea    0x18(%eax),%edx
8010160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160f:	83 e0 07             	and    $0x7,%eax
80101612:	c1 e0 06             	shl    $0x6,%eax
80101615:	01 d0                	add    %edx,%eax
80101617:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010161a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010161d:	0f b7 00             	movzwl (%eax),%eax
80101620:	66 85 c0             	test   %ax,%ax
80101623:	75 4f                	jne    80101674 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101625:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010162c:	00 
8010162d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101634:	00 
80101635:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101638:	89 04 24             	mov    %eax,(%esp)
8010163b:	e8 d5 3a 00 00       	call   80105115 <memset>
      dip->type = type;
80101640:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101643:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101647:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164d:	89 04 24             	mov    %eax,(%esp)
80101650:	e8 c6 1f 00 00       	call   8010361b <log_write>
      brelse(bp);
80101655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101658:	89 04 24             	mov    %eax,(%esp)
8010165b:	e8 b7 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101663:	89 44 24 04          	mov    %eax,0x4(%esp)
80101667:	8b 45 08             	mov    0x8(%ebp),%eax
8010166a:	89 04 24             	mov    %eax,(%esp)
8010166d:	e8 e5 00 00 00       	call   80101757 <iget>
80101672:	eb 29                	jmp    8010169d <ialloc+0xdd>
    }
    brelse(bp);
80101674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101677:	89 04 24             	mov    %eax,(%esp)
8010167a:	e8 98 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010167f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101683:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101686:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101689:	39 c2                	cmp    %eax,%edx
8010168b:	0f 82 5a ff ff ff    	jb     801015eb <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101691:	c7 04 24 51 85 10 80 	movl   $0x80108551,(%esp)
80101698:	e8 9d ee ff ff       	call   8010053a <panic>
}
8010169d:	c9                   	leave  
8010169e:	c3                   	ret    

8010169f <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010169f:	55                   	push   %ebp
801016a0:	89 e5                	mov    %esp,%ebp
801016a2:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016a5:	8b 45 08             	mov    0x8(%ebp),%eax
801016a8:	8b 40 04             	mov    0x4(%eax),%eax
801016ab:	c1 e8 03             	shr    $0x3,%eax
801016ae:	8d 50 02             	lea    0x2(%eax),%edx
801016b1:	8b 45 08             	mov    0x8(%ebp),%eax
801016b4:	8b 00                	mov    (%eax),%eax
801016b6:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ba:	89 04 24             	mov    %eax,(%esp)
801016bd:	e8 e4 ea ff ff       	call   801001a6 <bread>
801016c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c8:	8d 50 18             	lea    0x18(%eax),%edx
801016cb:	8b 45 08             	mov    0x8(%ebp),%eax
801016ce:	8b 40 04             	mov    0x4(%eax),%eax
801016d1:	83 e0 07             	and    $0x7,%eax
801016d4:	c1 e0 06             	shl    $0x6,%eax
801016d7:	01 d0                	add    %edx,%eax
801016d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016dc:	8b 45 08             	mov    0x8(%ebp),%eax
801016df:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e6:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016e9:	8b 45 08             	mov    0x8(%ebp),%eax
801016ec:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f3:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801016f7:	8b 45 08             	mov    0x8(%ebp),%eax
801016fa:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101701:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101705:	8b 45 08             	mov    0x8(%ebp),%eax
80101708:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170f:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101713:	8b 45 08             	mov    0x8(%ebp),%eax
80101716:	8b 50 18             	mov    0x18(%eax),%edx
80101719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010171f:	8b 45 08             	mov    0x8(%ebp),%eax
80101722:	8d 50 1c             	lea    0x1c(%eax),%edx
80101725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101728:	83 c0 0c             	add    $0xc,%eax
8010172b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101732:	00 
80101733:	89 54 24 04          	mov    %edx,0x4(%esp)
80101737:	89 04 24             	mov    %eax,(%esp)
8010173a:	e8 a5 3a 00 00       	call   801051e4 <memmove>
  log_write(bp);
8010173f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101742:	89 04 24             	mov    %eax,(%esp)
80101745:	e8 d1 1e 00 00       	call   8010361b <log_write>
  brelse(bp);
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	89 04 24             	mov    %eax,(%esp)
80101750:	e8 c2 ea ff ff       	call   80100217 <brelse>
}
80101755:	c9                   	leave  
80101756:	c3                   	ret    

80101757 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101757:	55                   	push   %ebp
80101758:	89 e5                	mov    %esp,%ebp
8010175a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010175d:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101764:	e8 58 37 00 00       	call   80104ec1 <acquire>

  // Is the inode already cached?
  empty = 0;
80101769:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101770:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
80101777:	eb 59                	jmp    801017d2 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177c:	8b 40 08             	mov    0x8(%eax),%eax
8010177f:	85 c0                	test   %eax,%eax
80101781:	7e 35                	jle    801017b8 <iget+0x61>
80101783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101786:	8b 00                	mov    (%eax),%eax
80101788:	3b 45 08             	cmp    0x8(%ebp),%eax
8010178b:	75 2b                	jne    801017b8 <iget+0x61>
8010178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101790:	8b 40 04             	mov    0x4(%eax),%eax
80101793:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101796:	75 20                	jne    801017b8 <iget+0x61>
      ip->ref++;
80101798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179b:	8b 40 08             	mov    0x8(%eax),%eax
8010179e:	8d 50 01             	lea    0x1(%eax),%edx
801017a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a4:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017a7:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801017ae:	e8 70 37 00 00       	call   80104f23 <release>
      return ip;
801017b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b6:	eb 6f                	jmp    80101827 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017bc:	75 10                	jne    801017ce <iget+0x77>
801017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c1:	8b 40 08             	mov    0x8(%eax),%eax
801017c4:	85 c0                	test   %eax,%eax
801017c6:	75 06                	jne    801017ce <iget+0x77>
      empty = ip;
801017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ce:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017d2:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
801017d9:	72 9e                	jb     80101779 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017df:	75 0c                	jne    801017ed <iget+0x96>
    panic("iget: no inodes");
801017e1:	c7 04 24 63 85 10 80 	movl   $0x80108563,(%esp)
801017e8:	e8 4d ed ff ff       	call   8010053a <panic>

  ip = empty;
801017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	8b 55 08             	mov    0x8(%ebp),%edx
801017f9:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80101801:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101807:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010180e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101811:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101818:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010181f:	e8 ff 36 00 00       	call   80104f23 <release>

  return ip;
80101824:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101827:	c9                   	leave  
80101828:	c3                   	ret    

80101829 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101829:	55                   	push   %ebp
8010182a:	89 e5                	mov    %esp,%ebp
8010182c:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010182f:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101836:	e8 86 36 00 00       	call   80104ec1 <acquire>
  ip->ref++;
8010183b:	8b 45 08             	mov    0x8(%ebp),%eax
8010183e:	8b 40 08             	mov    0x8(%eax),%eax
80101841:	8d 50 01             	lea    0x1(%eax),%edx
80101844:	8b 45 08             	mov    0x8(%ebp),%eax
80101847:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010184a:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101851:	e8 cd 36 00 00       	call   80104f23 <release>
  return ip;
80101856:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101859:	c9                   	leave  
8010185a:	c3                   	ret    

8010185b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010185b:	55                   	push   %ebp
8010185c:	89 e5                	mov    %esp,%ebp
8010185e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101861:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101865:	74 0a                	je     80101871 <ilock+0x16>
80101867:	8b 45 08             	mov    0x8(%ebp),%eax
8010186a:	8b 40 08             	mov    0x8(%eax),%eax
8010186d:	85 c0                	test   %eax,%eax
8010186f:	7f 0c                	jg     8010187d <ilock+0x22>
    panic("ilock");
80101871:	c7 04 24 73 85 10 80 	movl   $0x80108573,(%esp)
80101878:	e8 bd ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010187d:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101884:	e8 38 36 00 00       	call   80104ec1 <acquire>
  while(ip->flags & I_BUSY)
80101889:	eb 13                	jmp    8010189e <ilock+0x43>
    sleep(ip, &icache.lock);
8010188b:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
80101892:	80 
80101893:	8b 45 08             	mov    0x8(%ebp),%eax
80101896:	89 04 24             	mov    %eax,(%esp)
80101899:	e8 50 33 00 00       	call   80104bee <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010189e:	8b 45 08             	mov    0x8(%ebp),%eax
801018a1:	8b 40 0c             	mov    0xc(%eax),%eax
801018a4:	83 e0 01             	and    $0x1,%eax
801018a7:	85 c0                	test   %eax,%eax
801018a9:	75 e0                	jne    8010188b <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018ab:	8b 45 08             	mov    0x8(%ebp),%eax
801018ae:	8b 40 0c             	mov    0xc(%eax),%eax
801018b1:	83 c8 01             	or     $0x1,%eax
801018b4:	89 c2                	mov    %eax,%edx
801018b6:	8b 45 08             	mov    0x8(%ebp),%eax
801018b9:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018bc:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801018c3:	e8 5b 36 00 00       	call   80104f23 <release>

  if(!(ip->flags & I_VALID)){
801018c8:	8b 45 08             	mov    0x8(%ebp),%eax
801018cb:	8b 40 0c             	mov    0xc(%eax),%eax
801018ce:	83 e0 02             	and    $0x2,%eax
801018d1:	85 c0                	test   %eax,%eax
801018d3:	0f 85 ce 00 00 00    	jne    801019a7 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018d9:	8b 45 08             	mov    0x8(%ebp),%eax
801018dc:	8b 40 04             	mov    0x4(%eax),%eax
801018df:	c1 e8 03             	shr    $0x3,%eax
801018e2:	8d 50 02             	lea    0x2(%eax),%edx
801018e5:	8b 45 08             	mov    0x8(%ebp),%eax
801018e8:	8b 00                	mov    (%eax),%eax
801018ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801018ee:	89 04 24             	mov    %eax,(%esp)
801018f1:	e8 b0 e8 ff ff       	call   801001a6 <bread>
801018f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fc:	8d 50 18             	lea    0x18(%eax),%edx
801018ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101902:	8b 40 04             	mov    0x4(%eax),%eax
80101905:	83 e0 07             	and    $0x7,%eax
80101908:	c1 e0 06             	shl    $0x6,%eax
8010190b:	01 d0                	add    %edx,%eax
8010190d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101913:	0f b7 10             	movzwl (%eax),%edx
80101916:	8b 45 08             	mov    0x8(%ebp),%eax
80101919:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101920:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010192b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192e:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101932:	8b 45 08             	mov    0x8(%ebp),%eax
80101935:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101939:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101940:	8b 45 08             	mov    0x8(%ebp),%eax
80101943:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101947:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194a:	8b 50 08             	mov    0x8(%eax),%edx
8010194d:	8b 45 08             	mov    0x8(%ebp),%eax
80101950:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101956:	8d 50 0c             	lea    0xc(%eax),%edx
80101959:	8b 45 08             	mov    0x8(%ebp),%eax
8010195c:	83 c0 1c             	add    $0x1c,%eax
8010195f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101966:	00 
80101967:	89 54 24 04          	mov    %edx,0x4(%esp)
8010196b:	89 04 24             	mov    %eax,(%esp)
8010196e:	e8 71 38 00 00       	call   801051e4 <memmove>
    brelse(bp);
80101973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101976:	89 04 24             	mov    %eax,(%esp)
80101979:	e8 99 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 0c             	mov    0xc(%eax),%eax
80101984:	83 c8 02             	or     $0x2,%eax
80101987:	89 c2                	mov    %eax,%edx
80101989:	8b 45 08             	mov    0x8(%ebp),%eax
8010198c:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010198f:	8b 45 08             	mov    0x8(%ebp),%eax
80101992:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101996:	66 85 c0             	test   %ax,%ax
80101999:	75 0c                	jne    801019a7 <ilock+0x14c>
      panic("ilock: no type");
8010199b:	c7 04 24 79 85 10 80 	movl   $0x80108579,(%esp)
801019a2:	e8 93 eb ff ff       	call   8010053a <panic>
  }
}
801019a7:	c9                   	leave  
801019a8:	c3                   	ret    

801019a9 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019a9:	55                   	push   %ebp
801019aa:	89 e5                	mov    %esp,%ebp
801019ac:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019b3:	74 17                	je     801019cc <iunlock+0x23>
801019b5:	8b 45 08             	mov    0x8(%ebp),%eax
801019b8:	8b 40 0c             	mov    0xc(%eax),%eax
801019bb:	83 e0 01             	and    $0x1,%eax
801019be:	85 c0                	test   %eax,%eax
801019c0:	74 0a                	je     801019cc <iunlock+0x23>
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8b 40 08             	mov    0x8(%eax),%eax
801019c8:	85 c0                	test   %eax,%eax
801019ca:	7f 0c                	jg     801019d8 <iunlock+0x2f>
    panic("iunlock");
801019cc:	c7 04 24 88 85 10 80 	movl   $0x80108588,(%esp)
801019d3:	e8 62 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019d8:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801019df:	e8 dd 34 00 00       	call   80104ec1 <acquire>
  ip->flags &= ~I_BUSY;
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	8b 40 0c             	mov    0xc(%eax),%eax
801019ea:	83 e0 fe             	and    $0xfffffffe,%eax
801019ed:	89 c2                	mov    %eax,%edx
801019ef:	8b 45 08             	mov    0x8(%ebp),%eax
801019f2:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801019f5:	8b 45 08             	mov    0x8(%ebp),%eax
801019f8:	89 04 24             	mov    %eax,(%esp)
801019fb:	e8 c6 32 00 00       	call   80104cc6 <wakeup>
  release(&icache.lock);
80101a00:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a07:	e8 17 35 00 00       	call   80104f23 <release>
}
80101a0c:	c9                   	leave  
80101a0d:	c3                   	ret    

80101a0e <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a0e:	55                   	push   %ebp
80101a0f:	89 e5                	mov    %esp,%ebp
80101a11:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a14:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a1b:	e8 a1 34 00 00       	call   80104ec1 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 40 08             	mov    0x8(%eax),%eax
80101a26:	83 f8 01             	cmp    $0x1,%eax
80101a29:	0f 85 93 00 00 00    	jne    80101ac2 <iput+0xb4>
80101a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a32:	8b 40 0c             	mov    0xc(%eax),%eax
80101a35:	83 e0 02             	and    $0x2,%eax
80101a38:	85 c0                	test   %eax,%eax
80101a3a:	0f 84 82 00 00 00    	je     80101ac2 <iput+0xb4>
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a47:	66 85 c0             	test   %ax,%ax
80101a4a:	75 76                	jne    80101ac2 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a52:	83 e0 01             	and    $0x1,%eax
80101a55:	85 c0                	test   %eax,%eax
80101a57:	74 0c                	je     80101a65 <iput+0x57>
      panic("iput busy");
80101a59:	c7 04 24 90 85 10 80 	movl   $0x80108590,(%esp)
80101a60:	e8 d5 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a65:	8b 45 08             	mov    0x8(%ebp),%eax
80101a68:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6b:	83 c8 01             	or     $0x1,%eax
80101a6e:	89 c2                	mov    %eax,%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a76:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a7d:	e8 a1 34 00 00       	call   80104f23 <release>
    itrunc(ip);
80101a82:	8b 45 08             	mov    0x8(%ebp),%eax
80101a85:	89 04 24             	mov    %eax,(%esp)
80101a88:	e8 7d 01 00 00       	call   80101c0a <itrunc>
    ip->type = 0;
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101a96:	8b 45 08             	mov    0x8(%ebp),%eax
80101a99:	89 04 24             	mov    %eax,(%esp)
80101a9c:	e8 fe fb ff ff       	call   8010169f <iupdate>
    acquire(&icache.lock);
80101aa1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101aa8:	e8 14 34 00 00       	call   80104ec1 <acquire>
    ip->flags = 0;
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	89 04 24             	mov    %eax,(%esp)
80101abd:	e8 04 32 00 00       	call   80104cc6 <wakeup>
  }
  ip->ref--;
80101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac5:	8b 40 08             	mov    0x8(%eax),%eax
80101ac8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ad1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101ad8:	e8 46 34 00 00       	call   80104f23 <release>
}
80101add:	c9                   	leave  
80101ade:	c3                   	ret    

80101adf <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101adf:	55                   	push   %ebp
80101ae0:	89 e5                	mov    %esp,%ebp
80101ae2:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	89 04 24             	mov    %eax,(%esp)
80101aeb:	e8 b9 fe ff ff       	call   801019a9 <iunlock>
  iput(ip);
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	89 04 24             	mov    %eax,(%esp)
80101af6:	e8 13 ff ff ff       	call   80101a0e <iput>
}
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	53                   	push   %ebx
80101b01:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b04:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b08:	77 3e                	ja     80101b48 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b10:	83 c2 04             	add    $0x4,%edx
80101b13:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b1e:	75 20                	jne    80101b40 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	8b 00                	mov    (%eax),%eax
80101b25:	89 04 24             	mov    %eax,(%esp)
80101b28:	e8 5b f8 ff ff       	call   80101388 <balloc>
80101b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b36:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b3c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b43:	e9 bc 00 00 00       	jmp    80101c04 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b48:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b4c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b50:	0f 87 a2 00 00 00    	ja     80101bf8 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b56:	8b 45 08             	mov    0x8(%ebp),%eax
80101b59:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b63:	75 19                	jne    80101b7e <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	8b 00                	mov    (%eax),%eax
80101b6a:	89 04 24             	mov    %eax,(%esp)
80101b6d:	e8 16 f8 ff ff       	call   80101388 <balloc>
80101b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b7b:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 00                	mov    (%eax),%eax
80101b83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b86:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b8a:	89 04 24             	mov    %eax,(%esp)
80101b8d:	e8 14 e6 ff ff       	call   801001a6 <bread>
80101b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b98:	83 c0 18             	add    $0x18,%eax
80101b9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ba1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bab:	01 d0                	add    %edx,%eax
80101bad:	8b 00                	mov    (%eax),%eax
80101baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bb6:	75 30                	jne    80101be8 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bc5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	8b 00                	mov    (%eax),%eax
80101bcd:	89 04 24             	mov    %eax,(%esp)
80101bd0:	e8 b3 f7 ff ff       	call   80101388 <balloc>
80101bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bdb:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be0:	89 04 24             	mov    %eax,(%esp)
80101be3:	e8 33 1a 00 00       	call   8010361b <log_write>
    }
    brelse(bp);
80101be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101beb:	89 04 24             	mov    %eax,(%esp)
80101bee:	e8 24 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf6:	eb 0c                	jmp    80101c04 <bmap+0x107>
  }

  panic("bmap: out of range");
80101bf8:	c7 04 24 9a 85 10 80 	movl   $0x8010859a,(%esp)
80101bff:	e8 36 e9 ff ff       	call   8010053a <panic>
}
80101c04:	83 c4 24             	add    $0x24,%esp
80101c07:	5b                   	pop    %ebx
80101c08:	5d                   	pop    %ebp
80101c09:	c3                   	ret    

80101c0a <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c0a:	55                   	push   %ebp
80101c0b:	89 e5                	mov    %esp,%ebp
80101c0d:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c17:	eb 44                	jmp    80101c5d <itrunc+0x53>
    if(ip->addrs[i]){
80101c19:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c1f:	83 c2 04             	add    $0x4,%edx
80101c22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c26:	85 c0                	test   %eax,%eax
80101c28:	74 2f                	je     80101c59 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c30:	83 c2 04             	add    $0x4,%edx
80101c33:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 00                	mov    (%eax),%eax
80101c3c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c40:	89 04 24             	mov    %eax,(%esp)
80101c43:	e8 8e f8 ff ff       	call   801014d6 <bfree>
      ip->addrs[i] = 0;
80101c48:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c4e:	83 c2 04             	add    $0x4,%edx
80101c51:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c58:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c5d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c61:	7e b6                	jle    80101c19 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c69:	85 c0                	test   %eax,%eax
80101c6b:	0f 84 9b 00 00 00    	je     80101d0c <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c71:	8b 45 08             	mov    0x8(%ebp),%eax
80101c74:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	8b 00                	mov    (%eax),%eax
80101c7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c80:	89 04 24             	mov    %eax,(%esp)
80101c83:	e8 1e e5 ff ff       	call   801001a6 <bread>
80101c88:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c8e:	83 c0 18             	add    $0x18,%eax
80101c91:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c94:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c9b:	eb 3b                	jmp    80101cd8 <itrunc+0xce>
      if(a[j])
80101c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ca7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101caa:	01 d0                	add    %edx,%eax
80101cac:	8b 00                	mov    (%eax),%eax
80101cae:	85 c0                	test   %eax,%eax
80101cb0:	74 22                	je     80101cd4 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cbf:	01 d0                	add    %edx,%eax
80101cc1:	8b 10                	mov    (%eax),%edx
80101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc6:	8b 00                	mov    (%eax),%eax
80101cc8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ccc:	89 04 24             	mov    %eax,(%esp)
80101ccf:	e8 02 f8 ff ff       	call   801014d6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cd4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cdb:	83 f8 7f             	cmp    $0x7f,%eax
80101cde:	76 bd                	jbe    80101c9d <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce3:	89 04 24             	mov    %eax,(%esp)
80101ce6:	e8 2c e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cee:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf4:	8b 00                	mov    (%eax),%eax
80101cf6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cfa:	89 04 24             	mov    %eax,(%esp)
80101cfd:	e8 d4 f7 ff ff       	call   801014d6 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	89 04 24             	mov    %eax,(%esp)
80101d1c:	e8 7e f9 ff ff       	call   8010169f <iupdate>
}
80101d21:	c9                   	leave  
80101d22:	c3                   	ret    

80101d23 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d23:	55                   	push   %ebp
80101d24:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	8b 00                	mov    (%eax),%eax
80101d2b:	89 c2                	mov    %eax,%edx
80101d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d30:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d33:	8b 45 08             	mov    0x8(%ebp),%eax
80101d36:	8b 50 04             	mov    0x4(%eax),%edx
80101d39:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d3c:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d42:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d46:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d49:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d53:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d56:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	8b 50 18             	mov    0x18(%eax),%edx
80101d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d63:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d66:	5d                   	pop    %ebp
80101d67:	c3                   	ret    

80101d68 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d71:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d75:	66 83 f8 03          	cmp    $0x3,%ax
80101d79:	75 60                	jne    80101ddb <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d82:	66 85 c0             	test   %ax,%ax
80101d85:	78 20                	js     80101da7 <readi+0x3f>
80101d87:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d8e:	66 83 f8 09          	cmp    $0x9,%ax
80101d92:	7f 13                	jg     80101da7 <readi+0x3f>
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d9b:	98                   	cwtl   
80101d9c:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101da3:	85 c0                	test   %eax,%eax
80101da5:	75 0a                	jne    80101db1 <readi+0x49>
      return -1;
80101da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dac:	e9 19 01 00 00       	jmp    80101eca <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101db1:	8b 45 08             	mov    0x8(%ebp),%eax
80101db4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101db8:	98                   	cwtl   
80101db9:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101dc0:	8b 55 14             	mov    0x14(%ebp),%edx
80101dc3:	89 54 24 08          	mov    %edx,0x8(%esp)
80101dc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dca:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dce:	8b 55 08             	mov    0x8(%ebp),%edx
80101dd1:	89 14 24             	mov    %edx,(%esp)
80101dd4:	ff d0                	call   *%eax
80101dd6:	e9 ef 00 00 00       	jmp    80101eca <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dde:	8b 40 18             	mov    0x18(%eax),%eax
80101de1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de4:	72 0d                	jb     80101df3 <readi+0x8b>
80101de6:	8b 45 14             	mov    0x14(%ebp),%eax
80101de9:	8b 55 10             	mov    0x10(%ebp),%edx
80101dec:	01 d0                	add    %edx,%eax
80101dee:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df1:	73 0a                	jae    80101dfd <readi+0x95>
    return -1;
80101df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101df8:	e9 cd 00 00 00       	jmp    80101eca <readi+0x162>
  if(off + n > ip->size)
80101dfd:	8b 45 14             	mov    0x14(%ebp),%eax
80101e00:	8b 55 10             	mov    0x10(%ebp),%edx
80101e03:	01 c2                	add    %eax,%edx
80101e05:	8b 45 08             	mov    0x8(%ebp),%eax
80101e08:	8b 40 18             	mov    0x18(%eax),%eax
80101e0b:	39 c2                	cmp    %eax,%edx
80101e0d:	76 0c                	jbe    80101e1b <readi+0xb3>
    n = ip->size - off;
80101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e12:	8b 40 18             	mov    0x18(%eax),%eax
80101e15:	2b 45 10             	sub    0x10(%ebp),%eax
80101e18:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e22:	e9 94 00 00 00       	jmp    80101ebb <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e27:	8b 45 10             	mov    0x10(%ebp),%eax
80101e2a:	c1 e8 09             	shr    $0x9,%eax
80101e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e31:	8b 45 08             	mov    0x8(%ebp),%eax
80101e34:	89 04 24             	mov    %eax,(%esp)
80101e37:	e8 c1 fc ff ff       	call   80101afd <bmap>
80101e3c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3f:	8b 12                	mov    (%edx),%edx
80101e41:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e45:	89 14 24             	mov    %edx,(%esp)
80101e48:	e8 59 e3 ff ff       	call   801001a6 <bread>
80101e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e50:	8b 45 10             	mov    0x10(%ebp),%eax
80101e53:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e58:	89 c2                	mov    %eax,%edx
80101e5a:	b8 00 02 00 00       	mov    $0x200,%eax
80101e5f:	29 d0                	sub    %edx,%eax
80101e61:	89 c2                	mov    %eax,%edx
80101e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e66:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e69:	29 c1                	sub    %eax,%ecx
80101e6b:	89 c8                	mov    %ecx,%eax
80101e6d:	39 c2                	cmp    %eax,%edx
80101e6f:	0f 46 c2             	cmovbe %edx,%eax
80101e72:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e75:	8b 45 10             	mov    0x10(%ebp),%eax
80101e78:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e7d:	8d 50 10             	lea    0x10(%eax),%edx
80101e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e83:	01 d0                	add    %edx,%eax
80101e85:	8d 50 08             	lea    0x8(%eax),%edx
80101e88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e8b:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e96:	89 04 24             	mov    %eax,(%esp)
80101e99:	e8 46 33 00 00       	call   801051e4 <memmove>
    brelse(bp);
80101e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea1:	89 04 24             	mov    %eax,(%esp)
80101ea4:	e8 6e e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eac:	01 45 f4             	add    %eax,-0xc(%ebp)
80101eaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb2:	01 45 10             	add    %eax,0x10(%ebp)
80101eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb8:	01 45 0c             	add    %eax,0xc(%ebp)
80101ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ebe:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ec1:	0f 82 60 ff ff ff    	jb     80101e27 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ec7:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101eca:	c9                   	leave  
80101ecb:	c3                   	ret    

80101ecc <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ecc:	55                   	push   %ebp
80101ecd:	89 e5                	mov    %esp,%ebp
80101ecf:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ed9:	66 83 f8 03          	cmp    $0x3,%ax
80101edd:	75 60                	jne    80101f3f <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee6:	66 85 c0             	test   %ax,%ax
80101ee9:	78 20                	js     80101f0b <writei+0x3f>
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef2:	66 83 f8 09          	cmp    $0x9,%ax
80101ef6:	7f 13                	jg     80101f0b <writei+0x3f>
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eff:	98                   	cwtl   
80101f00:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f07:	85 c0                	test   %eax,%eax
80101f09:	75 0a                	jne    80101f15 <writei+0x49>
      return -1;
80101f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f10:	e9 44 01 00 00       	jmp    80102059 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1c:	98                   	cwtl   
80101f1d:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f24:	8b 55 14             	mov    0x14(%ebp),%edx
80101f27:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f2e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f32:	8b 55 08             	mov    0x8(%ebp),%edx
80101f35:	89 14 24             	mov    %edx,(%esp)
80101f38:	ff d0                	call   *%eax
80101f3a:	e9 1a 01 00 00       	jmp    80102059 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f42:	8b 40 18             	mov    0x18(%eax),%eax
80101f45:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f48:	72 0d                	jb     80101f57 <writei+0x8b>
80101f4a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f4d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f50:	01 d0                	add    %edx,%eax
80101f52:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f55:	73 0a                	jae    80101f61 <writei+0x95>
    return -1;
80101f57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f5c:	e9 f8 00 00 00       	jmp    80102059 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f61:	8b 45 14             	mov    0x14(%ebp),%eax
80101f64:	8b 55 10             	mov    0x10(%ebp),%edx
80101f67:	01 d0                	add    %edx,%eax
80101f69:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f6e:	76 0a                	jbe    80101f7a <writei+0xae>
    return -1;
80101f70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f75:	e9 df 00 00 00       	jmp    80102059 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f81:	e9 9f 00 00 00       	jmp    80102025 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f86:	8b 45 10             	mov    0x10(%ebp),%eax
80101f89:	c1 e8 09             	shr    $0x9,%eax
80101f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f90:	8b 45 08             	mov    0x8(%ebp),%eax
80101f93:	89 04 24             	mov    %eax,(%esp)
80101f96:	e8 62 fb ff ff       	call   80101afd <bmap>
80101f9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9e:	8b 12                	mov    (%edx),%edx
80101fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fa4:	89 14 24             	mov    %edx,(%esp)
80101fa7:	e8 fa e1 ff ff       	call   801001a6 <bread>
80101fac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101faf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fb7:	89 c2                	mov    %eax,%edx
80101fb9:	b8 00 02 00 00       	mov    $0x200,%eax
80101fbe:	29 d0                	sub    %edx,%eax
80101fc0:	89 c2                	mov    %eax,%edx
80101fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc5:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fc8:	29 c1                	sub    %eax,%ecx
80101fca:	89 c8                	mov    %ecx,%eax
80101fcc:	39 c2                	cmp    %eax,%edx
80101fce:	0f 46 c2             	cmovbe %edx,%eax
80101fd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fd4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdc:	8d 50 10             	lea    0x10(%eax),%edx
80101fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe2:	01 d0                	add    %edx,%eax
80101fe4:	8d 50 08             	lea    0x8(%eax),%edx
80101fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fea:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ff5:	89 14 24             	mov    %edx,(%esp)
80101ff8:	e8 e7 31 00 00       	call   801051e4 <memmove>
    log_write(bp);
80101ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102000:	89 04 24             	mov    %eax,(%esp)
80102003:	e8 13 16 00 00       	call   8010361b <log_write>
    brelse(bp);
80102008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200b:	89 04 24             	mov    %eax,(%esp)
8010200e:	e8 04 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102013:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102016:	01 45 f4             	add    %eax,-0xc(%ebp)
80102019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201c:	01 45 10             	add    %eax,0x10(%ebp)
8010201f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102022:	01 45 0c             	add    %eax,0xc(%ebp)
80102025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102028:	3b 45 14             	cmp    0x14(%ebp),%eax
8010202b:	0f 82 55 ff ff ff    	jb     80101f86 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102031:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102035:	74 1f                	je     80102056 <writei+0x18a>
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	8b 40 18             	mov    0x18(%eax),%eax
8010203d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102040:	73 14                	jae    80102056 <writei+0x18a>
    ip->size = off;
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	8b 55 10             	mov    0x10(%ebp),%edx
80102048:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	89 04 24             	mov    %eax,(%esp)
80102051:	e8 49 f6 ff ff       	call   8010169f <iupdate>
  }
  return n;
80102056:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102059:	c9                   	leave  
8010205a:	c3                   	ret    

8010205b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010205b:	55                   	push   %ebp
8010205c:	89 e5                	mov    %esp,%ebp
8010205e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102061:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102068:	00 
80102069:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102070:	8b 45 08             	mov    0x8(%ebp),%eax
80102073:	89 04 24             	mov    %eax,(%esp)
80102076:	e8 0c 32 00 00       	call   80105287 <strncmp>
}
8010207b:	c9                   	leave  
8010207c:	c3                   	ret    

8010207d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010207d:	55                   	push   %ebp
8010207e:	89 e5                	mov    %esp,%ebp
80102080:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010208a:	66 83 f8 01          	cmp    $0x1,%ax
8010208e:	74 0c                	je     8010209c <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102090:	c7 04 24 ad 85 10 80 	movl   $0x801085ad,(%esp)
80102097:	e8 9e e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010209c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020a3:	e9 88 00 00 00       	jmp    80102130 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020a8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020af:	00 
801020b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801020b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801020be:	8b 45 08             	mov    0x8(%ebp),%eax
801020c1:	89 04 24             	mov    %eax,(%esp)
801020c4:	e8 9f fc ff ff       	call   80101d68 <readi>
801020c9:	83 f8 10             	cmp    $0x10,%eax
801020cc:	74 0c                	je     801020da <dirlookup+0x5d>
      panic("dirlink read");
801020ce:	c7 04 24 bf 85 10 80 	movl   $0x801085bf,(%esp)
801020d5:	e8 60 e4 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801020da:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020de:	66 85 c0             	test   %ax,%ax
801020e1:	75 02                	jne    801020e5 <dirlookup+0x68>
      continue;
801020e3:	eb 47                	jmp    8010212c <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
801020e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020e8:	83 c0 02             	add    $0x2,%eax
801020eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801020f2:	89 04 24             	mov    %eax,(%esp)
801020f5:	e8 61 ff ff ff       	call   8010205b <namecmp>
801020fa:	85 c0                	test   %eax,%eax
801020fc:	75 2e                	jne    8010212c <dirlookup+0xaf>
      // entry matches path element
      if(poff)
801020fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102102:	74 08                	je     8010210c <dirlookup+0x8f>
        *poff = off;
80102104:	8b 45 10             	mov    0x10(%ebp),%eax
80102107:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010210a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010210c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102110:	0f b7 c0             	movzwl %ax,%eax
80102113:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102116:	8b 45 08             	mov    0x8(%ebp),%eax
80102119:	8b 00                	mov    (%eax),%eax
8010211b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010211e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102122:	89 04 24             	mov    %eax,(%esp)
80102125:	e8 2d f6 ff ff       	call   80101757 <iget>
8010212a:	eb 18                	jmp    80102144 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010212c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102130:	8b 45 08             	mov    0x8(%ebp),%eax
80102133:	8b 40 18             	mov    0x18(%eax),%eax
80102136:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102139:	0f 87 69 ff ff ff    	ja     801020a8 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010213f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102144:	c9                   	leave  
80102145:	c3                   	ret    

80102146 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102146:	55                   	push   %ebp
80102147:	89 e5                	mov    %esp,%ebp
80102149:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010214c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102153:	00 
80102154:	8b 45 0c             	mov    0xc(%ebp),%eax
80102157:	89 44 24 04          	mov    %eax,0x4(%esp)
8010215b:	8b 45 08             	mov    0x8(%ebp),%eax
8010215e:	89 04 24             	mov    %eax,(%esp)
80102161:	e8 17 ff ff ff       	call   8010207d <dirlookup>
80102166:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102169:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010216d:	74 15                	je     80102184 <dirlink+0x3e>
    iput(ip);
8010216f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102172:	89 04 24             	mov    %eax,(%esp)
80102175:	e8 94 f8 ff ff       	call   80101a0e <iput>
    return -1;
8010217a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010217f:	e9 b7 00 00 00       	jmp    8010223b <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010218b:	eb 46                	jmp    801021d3 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010218d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102190:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102197:	00 
80102198:	89 44 24 08          	mov    %eax,0x8(%esp)
8010219c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010219f:	89 44 24 04          	mov    %eax,0x4(%esp)
801021a3:	8b 45 08             	mov    0x8(%ebp),%eax
801021a6:	89 04 24             	mov    %eax,(%esp)
801021a9:	e8 ba fb ff ff       	call   80101d68 <readi>
801021ae:	83 f8 10             	cmp    $0x10,%eax
801021b1:	74 0c                	je     801021bf <dirlink+0x79>
      panic("dirlink read");
801021b3:	c7 04 24 bf 85 10 80 	movl   $0x801085bf,(%esp)
801021ba:	e8 7b e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801021bf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021c3:	66 85 c0             	test   %ax,%ax
801021c6:	75 02                	jne    801021ca <dirlink+0x84>
      break;
801021c8:	eb 16                	jmp    801021e0 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021cd:	83 c0 10             	add    $0x10,%eax
801021d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021d6:	8b 45 08             	mov    0x8(%ebp),%eax
801021d9:	8b 40 18             	mov    0x18(%eax),%eax
801021dc:	39 c2                	cmp    %eax,%edx
801021de:	72 ad                	jb     8010218d <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801021e0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021e7:	00 
801021e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801021eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021f2:	83 c0 02             	add    $0x2,%eax
801021f5:	89 04 24             	mov    %eax,(%esp)
801021f8:	e8 e0 30 00 00       	call   801052dd <strncpy>
  de.inum = inum;
801021fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102200:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102207:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010220e:	00 
8010220f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102213:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102216:	89 44 24 04          	mov    %eax,0x4(%esp)
8010221a:	8b 45 08             	mov    0x8(%ebp),%eax
8010221d:	89 04 24             	mov    %eax,(%esp)
80102220:	e8 a7 fc ff ff       	call   80101ecc <writei>
80102225:	83 f8 10             	cmp    $0x10,%eax
80102228:	74 0c                	je     80102236 <dirlink+0xf0>
    panic("dirlink");
8010222a:	c7 04 24 cc 85 10 80 	movl   $0x801085cc,(%esp)
80102231:	e8 04 e3 ff ff       	call   8010053a <panic>
  
  return 0;
80102236:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010223b:	c9                   	leave  
8010223c:	c3                   	ret    

8010223d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010223d:	55                   	push   %ebp
8010223e:	89 e5                	mov    %esp,%ebp
80102240:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102243:	eb 04                	jmp    80102249 <skipelem+0xc>
    path++;
80102245:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102249:	8b 45 08             	mov    0x8(%ebp),%eax
8010224c:	0f b6 00             	movzbl (%eax),%eax
8010224f:	3c 2f                	cmp    $0x2f,%al
80102251:	74 f2                	je     80102245 <skipelem+0x8>
    path++;
  if(*path == 0)
80102253:	8b 45 08             	mov    0x8(%ebp),%eax
80102256:	0f b6 00             	movzbl (%eax),%eax
80102259:	84 c0                	test   %al,%al
8010225b:	75 0a                	jne    80102267 <skipelem+0x2a>
    return 0;
8010225d:	b8 00 00 00 00       	mov    $0x0,%eax
80102262:	e9 86 00 00 00       	jmp    801022ed <skipelem+0xb0>
  s = path;
80102267:	8b 45 08             	mov    0x8(%ebp),%eax
8010226a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010226d:	eb 04                	jmp    80102273 <skipelem+0x36>
    path++;
8010226f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102273:	8b 45 08             	mov    0x8(%ebp),%eax
80102276:	0f b6 00             	movzbl (%eax),%eax
80102279:	3c 2f                	cmp    $0x2f,%al
8010227b:	74 0a                	je     80102287 <skipelem+0x4a>
8010227d:	8b 45 08             	mov    0x8(%ebp),%eax
80102280:	0f b6 00             	movzbl (%eax),%eax
80102283:	84 c0                	test   %al,%al
80102285:	75 e8                	jne    8010226f <skipelem+0x32>
    path++;
  len = path - s;
80102287:	8b 55 08             	mov    0x8(%ebp),%edx
8010228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010228d:	29 c2                	sub    %eax,%edx
8010228f:	89 d0                	mov    %edx,%eax
80102291:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102294:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102298:	7e 1c                	jle    801022b6 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
8010229a:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022a1:	00 
801022a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801022ac:	89 04 24             	mov    %eax,(%esp)
801022af:	e8 30 2f 00 00       	call   801051e4 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022b4:	eb 2a                	jmp    801022e0 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801022bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801022c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801022c7:	89 04 24             	mov    %eax,(%esp)
801022ca:	e8 15 2f 00 00       	call   801051e4 <memmove>
    name[len] = 0;
801022cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d5:	01 d0                	add    %edx,%eax
801022d7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022da:	eb 04                	jmp    801022e0 <skipelem+0xa3>
    path++;
801022dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022e0:	8b 45 08             	mov    0x8(%ebp),%eax
801022e3:	0f b6 00             	movzbl (%eax),%eax
801022e6:	3c 2f                	cmp    $0x2f,%al
801022e8:	74 f2                	je     801022dc <skipelem+0x9f>
    path++;
  return path;
801022ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022ed:	c9                   	leave  
801022ee:	c3                   	ret    

801022ef <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022ef:	55                   	push   %ebp
801022f0:	89 e5                	mov    %esp,%ebp
801022f2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801022f5:	8b 45 08             	mov    0x8(%ebp),%eax
801022f8:	0f b6 00             	movzbl (%eax),%eax
801022fb:	3c 2f                	cmp    $0x2f,%al
801022fd:	75 1c                	jne    8010231b <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
801022ff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102306:	00 
80102307:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010230e:	e8 44 f4 ff ff       	call   80101757 <iget>
80102313:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102316:	e9 af 00 00 00       	jmp    801023ca <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010231b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102321:	8b 40 68             	mov    0x68(%eax),%eax
80102324:	89 04 24             	mov    %eax,(%esp)
80102327:	e8 fd f4 ff ff       	call   80101829 <idup>
8010232c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010232f:	e9 96 00 00 00       	jmp    801023ca <namex+0xdb>
    ilock(ip);
80102334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102337:	89 04 24             	mov    %eax,(%esp)
8010233a:	e8 1c f5 ff ff       	call   8010185b <ilock>
    if(ip->type != T_DIR){
8010233f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102342:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102346:	66 83 f8 01          	cmp    $0x1,%ax
8010234a:	74 15                	je     80102361 <namex+0x72>
      iunlockput(ip);
8010234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234f:	89 04 24             	mov    %eax,(%esp)
80102352:	e8 88 f7 ff ff       	call   80101adf <iunlockput>
      return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
8010235c:	e9 a3 00 00 00       	jmp    80102404 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102361:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102365:	74 1d                	je     80102384 <namex+0x95>
80102367:	8b 45 08             	mov    0x8(%ebp),%eax
8010236a:	0f b6 00             	movzbl (%eax),%eax
8010236d:	84 c0                	test   %al,%al
8010236f:	75 13                	jne    80102384 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102374:	89 04 24             	mov    %eax,(%esp)
80102377:	e8 2d f6 ff ff       	call   801019a9 <iunlock>
      return ip;
8010237c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237f:	e9 80 00 00 00       	jmp    80102404 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102384:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010238b:	00 
8010238c:	8b 45 10             	mov    0x10(%ebp),%eax
8010238f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	89 04 24             	mov    %eax,(%esp)
80102399:	e8 df fc ff ff       	call   8010207d <dirlookup>
8010239e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023a5:	75 12                	jne    801023b9 <namex+0xca>
      iunlockput(ip);
801023a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023aa:	89 04 24             	mov    %eax,(%esp)
801023ad:	e8 2d f7 ff ff       	call   80101adf <iunlockput>
      return 0;
801023b2:	b8 00 00 00 00       	mov    $0x0,%eax
801023b7:	eb 4b                	jmp    80102404 <namex+0x115>
    }
    iunlockput(ip);
801023b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bc:	89 04 24             	mov    %eax,(%esp)
801023bf:	e8 1b f7 ff ff       	call   80101adf <iunlockput>
    ip = next;
801023c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023ca:	8b 45 10             	mov    0x10(%ebp),%eax
801023cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801023d1:	8b 45 08             	mov    0x8(%ebp),%eax
801023d4:	89 04 24             	mov    %eax,(%esp)
801023d7:	e8 61 fe ff ff       	call   8010223d <skipelem>
801023dc:	89 45 08             	mov    %eax,0x8(%ebp)
801023df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023e3:	0f 85 4b ff ff ff    	jne    80102334 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023ed:	74 12                	je     80102401 <namex+0x112>
    iput(ip);
801023ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f2:	89 04 24             	mov    %eax,(%esp)
801023f5:	e8 14 f6 ff ff       	call   80101a0e <iput>
    return 0;
801023fa:	b8 00 00 00 00       	mov    $0x0,%eax
801023ff:	eb 03                	jmp    80102404 <namex+0x115>
  }
  return ip;
80102401:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102404:	c9                   	leave  
80102405:	c3                   	ret    

80102406 <namei>:

struct inode*
namei(char *path)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010240c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010240f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010241a:	00 
8010241b:	8b 45 08             	mov    0x8(%ebp),%eax
8010241e:	89 04 24             	mov    %eax,(%esp)
80102421:	e8 c9 fe ff ff       	call   801022ef <namex>
}
80102426:	c9                   	leave  
80102427:	c3                   	ret    

80102428 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102428:	55                   	push   %ebp
80102429:	89 e5                	mov    %esp,%ebp
8010242b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010242e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102431:	89 44 24 08          	mov    %eax,0x8(%esp)
80102435:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010243c:	00 
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	89 04 24             	mov    %eax,(%esp)
80102443:	e8 a7 fe ff ff       	call   801022ef <namex>
}
80102448:	c9                   	leave  
80102449:	c3                   	ret    

8010244a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010244a:	55                   	push   %ebp
8010244b:	89 e5                	mov    %esp,%ebp
8010244d:	83 ec 14             	sub    $0x14,%esp
80102450:	8b 45 08             	mov    0x8(%ebp),%eax
80102453:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102457:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010245b:	89 c2                	mov    %eax,%edx
8010245d:	ec                   	in     (%dx),%al
8010245e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102461:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102465:	c9                   	leave  
80102466:	c3                   	ret    

80102467 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102467:	55                   	push   %ebp
80102468:	89 e5                	mov    %esp,%ebp
8010246a:	57                   	push   %edi
8010246b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010246c:	8b 55 08             	mov    0x8(%ebp),%edx
8010246f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102472:	8b 45 10             	mov    0x10(%ebp),%eax
80102475:	89 cb                	mov    %ecx,%ebx
80102477:	89 df                	mov    %ebx,%edi
80102479:	89 c1                	mov    %eax,%ecx
8010247b:	fc                   	cld    
8010247c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010247e:	89 c8                	mov    %ecx,%eax
80102480:	89 fb                	mov    %edi,%ebx
80102482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102485:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102488:	5b                   	pop    %ebx
80102489:	5f                   	pop    %edi
8010248a:	5d                   	pop    %ebp
8010248b:	c3                   	ret    

8010248c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010248c:	55                   	push   %ebp
8010248d:	89 e5                	mov    %esp,%ebp
8010248f:	83 ec 08             	sub    $0x8,%esp
80102492:	8b 55 08             	mov    0x8(%ebp),%edx
80102495:	8b 45 0c             	mov    0xc(%ebp),%eax
80102498:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010249c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010249f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024a3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024a7:	ee                   	out    %al,(%dx)
}
801024a8:	c9                   	leave  
801024a9:	c3                   	ret    

801024aa <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024aa:	55                   	push   %ebp
801024ab:	89 e5                	mov    %esp,%ebp
801024ad:	56                   	push   %esi
801024ae:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024af:	8b 55 08             	mov    0x8(%ebp),%edx
801024b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024b5:	8b 45 10             	mov    0x10(%ebp),%eax
801024b8:	89 cb                	mov    %ecx,%ebx
801024ba:	89 de                	mov    %ebx,%esi
801024bc:	89 c1                	mov    %eax,%ecx
801024be:	fc                   	cld    
801024bf:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024c1:	89 c8                	mov    %ecx,%eax
801024c3:	89 f3                	mov    %esi,%ebx
801024c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024c8:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024cb:	5b                   	pop    %ebx
801024cc:	5e                   	pop    %esi
801024cd:	5d                   	pop    %ebp
801024ce:	c3                   	ret    

801024cf <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024cf:	55                   	push   %ebp
801024d0:	89 e5                	mov    %esp,%ebp
801024d2:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024d5:	90                   	nop
801024d6:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024dd:	e8 68 ff ff ff       	call   8010244a <inb>
801024e2:	0f b6 c0             	movzbl %al,%eax
801024e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024eb:	25 c0 00 00 00       	and    $0xc0,%eax
801024f0:	83 f8 40             	cmp    $0x40,%eax
801024f3:	75 e1                	jne    801024d6 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801024f5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f9:	74 11                	je     8010250c <idewait+0x3d>
801024fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024fe:	83 e0 21             	and    $0x21,%eax
80102501:	85 c0                	test   %eax,%eax
80102503:	74 07                	je     8010250c <idewait+0x3d>
    return -1;
80102505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010250a:	eb 05                	jmp    80102511 <idewait+0x42>
  return 0;
8010250c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102511:	c9                   	leave  
80102512:	c3                   	ret    

80102513 <ideinit>:

void
ideinit(void)
{
80102513:	55                   	push   %ebp
80102514:	89 e5                	mov    %esp,%ebp
80102516:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102519:	c7 44 24 04 d4 85 10 	movl   $0x801085d4,0x4(%esp)
80102520:	80 
80102521:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102528:	e8 73 29 00 00       	call   80104ea0 <initlock>
  picenable(IRQ_IDE);
8010252d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102534:	e8 7b 18 00 00       	call   80103db4 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102539:	a1 40 29 11 80       	mov    0x80112940,%eax
8010253e:	83 e8 01             	sub    $0x1,%eax
80102541:	89 44 24 04          	mov    %eax,0x4(%esp)
80102545:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010254c:	e8 0c 04 00 00       	call   8010295d <ioapicenable>
  idewait(0);
80102551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102558:	e8 72 ff ff ff       	call   801024cf <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010255d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102564:	00 
80102565:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010256c:	e8 1b ff ff ff       	call   8010248c <outb>
  for(i=0; i<1000; i++){
80102571:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102578:	eb 20                	jmp    8010259a <ideinit+0x87>
    if(inb(0x1f7) != 0){
8010257a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102581:	e8 c4 fe ff ff       	call   8010244a <inb>
80102586:	84 c0                	test   %al,%al
80102588:	74 0c                	je     80102596 <ideinit+0x83>
      havedisk1 = 1;
8010258a:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102591:	00 00 00 
      break;
80102594:	eb 0d                	jmp    801025a3 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102596:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010259a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025a1:	7e d7                	jle    8010257a <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025a3:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025aa:	00 
801025ab:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025b2:	e8 d5 fe ff ff       	call   8010248c <outb>
}
801025b7:	c9                   	leave  
801025b8:	c3                   	ret    

801025b9 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025b9:	55                   	push   %ebp
801025ba:	89 e5                	mov    %esp,%ebp
801025bc:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c3:	75 0c                	jne    801025d1 <idestart+0x18>
    panic("idestart");
801025c5:	c7 04 24 d8 85 10 80 	movl   $0x801085d8,(%esp)
801025cc:	e8 69 df ff ff       	call   8010053a <panic>

  idewait(0);
801025d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025d8:	e8 f2 fe ff ff       	call   801024cf <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025e4:	00 
801025e5:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025ec:	e8 9b fe ff ff       	call   8010248c <outb>
  outb(0x1f2, 1);  // number of sectors
801025f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025f8:	00 
801025f9:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102600:	e8 87 fe ff ff       	call   8010248c <outb>
  outb(0x1f3, b->sector & 0xff);
80102605:	8b 45 08             	mov    0x8(%ebp),%eax
80102608:	8b 40 08             	mov    0x8(%eax),%eax
8010260b:	0f b6 c0             	movzbl %al,%eax
8010260e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102612:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102619:	e8 6e fe ff ff       	call   8010248c <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010261e:	8b 45 08             	mov    0x8(%ebp),%eax
80102621:	8b 40 08             	mov    0x8(%eax),%eax
80102624:	c1 e8 08             	shr    $0x8,%eax
80102627:	0f b6 c0             	movzbl %al,%eax
8010262a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010262e:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102635:	e8 52 fe ff ff       	call   8010248c <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
8010263a:	8b 45 08             	mov    0x8(%ebp),%eax
8010263d:	8b 40 08             	mov    0x8(%eax),%eax
80102640:	c1 e8 10             	shr    $0x10,%eax
80102643:	0f b6 c0             	movzbl %al,%eax
80102646:	89 44 24 04          	mov    %eax,0x4(%esp)
8010264a:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102651:	e8 36 fe ff ff       	call   8010248c <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102656:	8b 45 08             	mov    0x8(%ebp),%eax
80102659:	8b 40 04             	mov    0x4(%eax),%eax
8010265c:	83 e0 01             	and    $0x1,%eax
8010265f:	c1 e0 04             	shl    $0x4,%eax
80102662:	89 c2                	mov    %eax,%edx
80102664:	8b 45 08             	mov    0x8(%ebp),%eax
80102667:	8b 40 08             	mov    0x8(%eax),%eax
8010266a:	c1 e8 18             	shr    $0x18,%eax
8010266d:	83 e0 0f             	and    $0xf,%eax
80102670:	09 d0                	or     %edx,%eax
80102672:	83 c8 e0             	or     $0xffffffe0,%eax
80102675:	0f b6 c0             	movzbl %al,%eax
80102678:	89 44 24 04          	mov    %eax,0x4(%esp)
8010267c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102683:	e8 04 fe ff ff       	call   8010248c <outb>
  if(b->flags & B_DIRTY){
80102688:	8b 45 08             	mov    0x8(%ebp),%eax
8010268b:	8b 00                	mov    (%eax),%eax
8010268d:	83 e0 04             	and    $0x4,%eax
80102690:	85 c0                	test   %eax,%eax
80102692:	74 34                	je     801026c8 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102694:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010269b:	00 
8010269c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026a3:	e8 e4 fd ff ff       	call   8010248c <outb>
    outsl(0x1f0, b->data, 512/4);
801026a8:	8b 45 08             	mov    0x8(%ebp),%eax
801026ab:	83 c0 18             	add    $0x18,%eax
801026ae:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026b5:	00 
801026b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ba:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026c1:	e8 e4 fd ff ff       	call   801024aa <outsl>
801026c6:	eb 14                	jmp    801026dc <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026c8:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026cf:	00 
801026d0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026d7:	e8 b0 fd ff ff       	call   8010248c <outb>
  }
}
801026dc:	c9                   	leave  
801026dd:	c3                   	ret    

801026de <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026de:	55                   	push   %ebp
801026df:	89 e5                	mov    %esp,%ebp
801026e1:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026e4:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801026eb:	e8 d1 27 00 00       	call   80104ec1 <acquire>
  if((b = idequeue) == 0){
801026f0:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801026f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026fc:	75 11                	jne    8010270f <ideintr+0x31>
    release(&idelock);
801026fe:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102705:	e8 19 28 00 00       	call   80104f23 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010270a:	e9 90 00 00 00       	jmp    8010279f <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010270f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102712:	8b 40 14             	mov    0x14(%eax),%eax
80102715:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	8b 00                	mov    (%eax),%eax
8010271f:	83 e0 04             	and    $0x4,%eax
80102722:	85 c0                	test   %eax,%eax
80102724:	75 2e                	jne    80102754 <ideintr+0x76>
80102726:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010272d:	e8 9d fd ff ff       	call   801024cf <idewait>
80102732:	85 c0                	test   %eax,%eax
80102734:	78 1e                	js     80102754 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102739:	83 c0 18             	add    $0x18,%eax
8010273c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102743:	00 
80102744:	89 44 24 04          	mov    %eax,0x4(%esp)
80102748:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010274f:	e8 13 fd ff ff       	call   80102467 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102757:	8b 00                	mov    (%eax),%eax
80102759:	83 c8 02             	or     $0x2,%eax
8010275c:	89 c2                	mov    %eax,%edx
8010275e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102761:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102766:	8b 00                	mov    (%eax),%eax
80102768:	83 e0 fb             	and    $0xfffffffb,%eax
8010276b:	89 c2                	mov    %eax,%edx
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102770:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102775:	89 04 24             	mov    %eax,(%esp)
80102778:	e8 49 25 00 00       	call   80104cc6 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010277d:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102782:	85 c0                	test   %eax,%eax
80102784:	74 0d                	je     80102793 <ideintr+0xb5>
    idestart(idequeue);
80102786:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010278b:	89 04 24             	mov    %eax,(%esp)
8010278e:	e8 26 fe ff ff       	call   801025b9 <idestart>

  release(&idelock);
80102793:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010279a:	e8 84 27 00 00       	call   80104f23 <release>
}
8010279f:	c9                   	leave  
801027a0:	c3                   	ret    

801027a1 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027a1:	55                   	push   %ebp
801027a2:	89 e5                	mov    %esp,%ebp
801027a4:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027a7:	8b 45 08             	mov    0x8(%ebp),%eax
801027aa:	8b 00                	mov    (%eax),%eax
801027ac:	83 e0 01             	and    $0x1,%eax
801027af:	85 c0                	test   %eax,%eax
801027b1:	75 0c                	jne    801027bf <iderw+0x1e>
    panic("iderw: buf not busy");
801027b3:	c7 04 24 e1 85 10 80 	movl   $0x801085e1,(%esp)
801027ba:	e8 7b dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	8b 00                	mov    (%eax),%eax
801027c4:	83 e0 06             	and    $0x6,%eax
801027c7:	83 f8 02             	cmp    $0x2,%eax
801027ca:	75 0c                	jne    801027d8 <iderw+0x37>
    panic("iderw: nothing to do");
801027cc:	c7 04 24 f5 85 10 80 	movl   $0x801085f5,(%esp)
801027d3:	e8 62 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027d8:	8b 45 08             	mov    0x8(%ebp),%eax
801027db:	8b 40 04             	mov    0x4(%eax),%eax
801027de:	85 c0                	test   %eax,%eax
801027e0:	74 15                	je     801027f7 <iderw+0x56>
801027e2:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801027e7:	85 c0                	test   %eax,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027eb:	c7 04 24 0a 86 10 80 	movl   $0x8010860a,(%esp)
801027f2:	e8 43 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801027f7:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027fe:	e8 be 26 00 00       	call   80104ec1 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010280d:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102814:	eb 0b                	jmp    80102821 <iderw+0x80>
80102816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102819:	8b 00                	mov    (%eax),%eax
8010281b:	83 c0 14             	add    $0x14,%eax
8010281e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102824:	8b 00                	mov    (%eax),%eax
80102826:	85 c0                	test   %eax,%eax
80102828:	75 ec                	jne    80102816 <iderw+0x75>
    ;
  *pp = b;
8010282a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282d:	8b 55 08             	mov    0x8(%ebp),%edx
80102830:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102832:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102837:	3b 45 08             	cmp    0x8(%ebp),%eax
8010283a:	75 0d                	jne    80102849 <iderw+0xa8>
    idestart(b);
8010283c:	8b 45 08             	mov    0x8(%ebp),%eax
8010283f:	89 04 24             	mov    %eax,(%esp)
80102842:	e8 72 fd ff ff       	call   801025b9 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102847:	eb 15                	jmp    8010285e <iderw+0xbd>
80102849:	eb 13                	jmp    8010285e <iderw+0xbd>
    sleep(b, &idelock);
8010284b:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102852:	80 
80102853:	8b 45 08             	mov    0x8(%ebp),%eax
80102856:	89 04 24             	mov    %eax,(%esp)
80102859:	e8 90 23 00 00       	call   80104bee <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010285e:	8b 45 08             	mov    0x8(%ebp),%eax
80102861:	8b 00                	mov    (%eax),%eax
80102863:	83 e0 06             	and    $0x6,%eax
80102866:	83 f8 02             	cmp    $0x2,%eax
80102869:	75 e0                	jne    8010284b <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
8010286b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102872:	e8 ac 26 00 00       	call   80104f23 <release>
}
80102877:	c9                   	leave  
80102878:	c3                   	ret    

80102879 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102879:	55                   	push   %ebp
8010287a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010287c:	a1 14 22 11 80       	mov    0x80112214,%eax
80102881:	8b 55 08             	mov    0x8(%ebp),%edx
80102884:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102886:	a1 14 22 11 80       	mov    0x80112214,%eax
8010288b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010288e:	5d                   	pop    %ebp
8010288f:	c3                   	ret    

80102890 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102890:	55                   	push   %ebp
80102891:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102893:	a1 14 22 11 80       	mov    0x80112214,%eax
80102898:	8b 55 08             	mov    0x8(%ebp),%edx
8010289b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010289d:	a1 14 22 11 80       	mov    0x80112214,%eax
801028a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801028a5:	89 50 10             	mov    %edx,0x10(%eax)
}
801028a8:	5d                   	pop    %ebp
801028a9:	c3                   	ret    

801028aa <ioapicinit>:

void
ioapicinit(void)
{
801028aa:	55                   	push   %ebp
801028ab:	89 e5                	mov    %esp,%ebp
801028ad:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028b0:	a1 44 23 11 80       	mov    0x80112344,%eax
801028b5:	85 c0                	test   %eax,%eax
801028b7:	75 05                	jne    801028be <ioapicinit+0x14>
    return;
801028b9:	e9 9d 00 00 00       	jmp    8010295b <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028be:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
801028c5:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028cf:	e8 a5 ff ff ff       	call   80102879 <ioapicread>
801028d4:	c1 e8 10             	shr    $0x10,%eax
801028d7:	25 ff 00 00 00       	and    $0xff,%eax
801028dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028e6:	e8 8e ff ff ff       	call   80102879 <ioapicread>
801028eb:	c1 e8 18             	shr    $0x18,%eax
801028ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801028f1:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
801028f8:	0f b6 c0             	movzbl %al,%eax
801028fb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801028fe:	74 0c                	je     8010290c <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102900:	c7 04 24 28 86 10 80 	movl   $0x80108628,(%esp)
80102907:	e8 94 da ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010290c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102913:	eb 3e                	jmp    80102953 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102918:	83 c0 20             	add    $0x20,%eax
8010291b:	0d 00 00 01 00       	or     $0x10000,%eax
80102920:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102923:	83 c2 08             	add    $0x8,%edx
80102926:	01 d2                	add    %edx,%edx
80102928:	89 44 24 04          	mov    %eax,0x4(%esp)
8010292c:	89 14 24             	mov    %edx,(%esp)
8010292f:	e8 5c ff ff ff       	call   80102890 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102937:	83 c0 08             	add    $0x8,%eax
8010293a:	01 c0                	add    %eax,%eax
8010293c:	83 c0 01             	add    $0x1,%eax
8010293f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102946:	00 
80102947:	89 04 24             	mov    %eax,(%esp)
8010294a:	e8 41 ff ff ff       	call   80102890 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010294f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102959:	7e ba                	jle    80102915 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010295b:	c9                   	leave  
8010295c:	c3                   	ret    

8010295d <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010295d:	55                   	push   %ebp
8010295e:	89 e5                	mov    %esp,%ebp
80102960:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102963:	a1 44 23 11 80       	mov    0x80112344,%eax
80102968:	85 c0                	test   %eax,%eax
8010296a:	75 02                	jne    8010296e <ioapicenable+0x11>
    return;
8010296c:	eb 37                	jmp    801029a5 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010296e:	8b 45 08             	mov    0x8(%ebp),%eax
80102971:	83 c0 20             	add    $0x20,%eax
80102974:	8b 55 08             	mov    0x8(%ebp),%edx
80102977:	83 c2 08             	add    $0x8,%edx
8010297a:	01 d2                	add    %edx,%edx
8010297c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102980:	89 14 24             	mov    %edx,(%esp)
80102983:	e8 08 ff ff ff       	call   80102890 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102988:	8b 45 0c             	mov    0xc(%ebp),%eax
8010298b:	c1 e0 18             	shl    $0x18,%eax
8010298e:	8b 55 08             	mov    0x8(%ebp),%edx
80102991:	83 c2 08             	add    $0x8,%edx
80102994:	01 d2                	add    %edx,%edx
80102996:	83 c2 01             	add    $0x1,%edx
80102999:	89 44 24 04          	mov    %eax,0x4(%esp)
8010299d:	89 14 24             	mov    %edx,(%esp)
801029a0:	e8 eb fe ff ff       	call   80102890 <ioapicwrite>
}
801029a5:	c9                   	leave  
801029a6:	c3                   	ret    

801029a7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029a7:	55                   	push   %ebp
801029a8:	89 e5                	mov    %esp,%ebp
801029aa:	8b 45 08             	mov    0x8(%ebp),%eax
801029ad:	05 00 00 00 80       	add    $0x80000000,%eax
801029b2:	5d                   	pop    %ebp
801029b3:	c3                   	ret    

801029b4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029b4:	55                   	push   %ebp
801029b5:	89 e5                	mov    %esp,%ebp
801029b7:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029ba:	c7 44 24 04 5a 86 10 	movl   $0x8010865a,0x4(%esp)
801029c1:	80 
801029c2:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
801029c9:	e8 d2 24 00 00       	call   80104ea0 <initlock>
  kmem.use_lock = 0;
801029ce:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
801029d5:	00 00 00 
  freerange(vstart, vend);
801029d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029db:	89 44 24 04          	mov    %eax,0x4(%esp)
801029df:	8b 45 08             	mov    0x8(%ebp),%eax
801029e2:	89 04 24             	mov    %eax,(%esp)
801029e5:	e8 26 00 00 00       	call   80102a10 <freerange>
}
801029ea:	c9                   	leave  
801029eb:	c3                   	ret    

801029ec <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801029ec:	55                   	push   %ebp
801029ed:	89 e5                	mov    %esp,%ebp
801029ef:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801029f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801029f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f9:	8b 45 08             	mov    0x8(%ebp),%eax
801029fc:	89 04 24             	mov    %eax,(%esp)
801029ff:	e8 0c 00 00 00       	call   80102a10 <freerange>
  kmem.use_lock = 1;
80102a04:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102a0b:	00 00 00 
}
80102a0e:	c9                   	leave  
80102a0f:	c3                   	ret    

80102a10 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a10:	55                   	push   %ebp
80102a11:	89 e5                	mov    %esp,%ebp
80102a13:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a16:	8b 45 08             	mov    0x8(%ebp),%eax
80102a19:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a26:	eb 12                	jmp    80102a3a <freerange+0x2a>
    kfree(p);
80102a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2b:	89 04 24             	mov    %eax,(%esp)
80102a2e:	e8 16 00 00 00       	call   80102a49 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a33:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3d:	05 00 10 00 00       	add    $0x1000,%eax
80102a42:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a45:	76 e1                	jbe    80102a28 <freerange+0x18>
    kfree(p);
}
80102a47:	c9                   	leave  
80102a48:	c3                   	ret    

80102a49 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a49:	55                   	push   %ebp
80102a4a:	89 e5                	mov    %esp,%ebp
80102a4c:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a52:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a57:	85 c0                	test   %eax,%eax
80102a59:	75 1b                	jne    80102a76 <kfree+0x2d>
80102a5b:	81 7d 08 3c 51 11 80 	cmpl   $0x8011513c,0x8(%ebp)
80102a62:	72 12                	jb     80102a76 <kfree+0x2d>
80102a64:	8b 45 08             	mov    0x8(%ebp),%eax
80102a67:	89 04 24             	mov    %eax,(%esp)
80102a6a:	e8 38 ff ff ff       	call   801029a7 <v2p>
80102a6f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a74:	76 0c                	jbe    80102a82 <kfree+0x39>
    panic("kfree");
80102a76:	c7 04 24 5f 86 10 80 	movl   $0x8010865f,(%esp)
80102a7d:	e8 b8 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a82:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a89:	00 
80102a8a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a91:	00 
80102a92:	8b 45 08             	mov    0x8(%ebp),%eax
80102a95:	89 04 24             	mov    %eax,(%esp)
80102a98:	e8 78 26 00 00       	call   80105115 <memset>

  if(kmem.use_lock)
80102a9d:	a1 54 22 11 80       	mov    0x80112254,%eax
80102aa2:	85 c0                	test   %eax,%eax
80102aa4:	74 0c                	je     80102ab2 <kfree+0x69>
    acquire(&kmem.lock);
80102aa6:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102aad:	e8 0f 24 00 00       	call   80104ec1 <acquire>
  r = (struct run*)v;
80102ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ab8:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac1:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac6:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102acb:	a1 54 22 11 80       	mov    0x80112254,%eax
80102ad0:	85 c0                	test   %eax,%eax
80102ad2:	74 0c                	je     80102ae0 <kfree+0x97>
    release(&kmem.lock);
80102ad4:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102adb:	e8 43 24 00 00       	call   80104f23 <release>
}
80102ae0:	c9                   	leave  
80102ae1:	c3                   	ret    

80102ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ae2:	55                   	push   %ebp
80102ae3:	89 e5                	mov    %esp,%ebp
80102ae5:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102ae8:	a1 54 22 11 80       	mov    0x80112254,%eax
80102aed:	85 c0                	test   %eax,%eax
80102aef:	74 0c                	je     80102afd <kalloc+0x1b>
    acquire(&kmem.lock);
80102af1:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102af8:	e8 c4 23 00 00       	call   80104ec1 <acquire>
  r = kmem.freelist;
80102afd:	a1 58 22 11 80       	mov    0x80112258,%eax
80102b02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b09:	74 0a                	je     80102b15 <kalloc+0x33>
    kmem.freelist = r->next;
80102b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0e:	8b 00                	mov    (%eax),%eax
80102b10:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102b15:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b1a:	85 c0                	test   %eax,%eax
80102b1c:	74 0c                	je     80102b2a <kalloc+0x48>
    release(&kmem.lock);
80102b1e:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b25:	e8 f9 23 00 00       	call   80104f23 <release>
  return (char*)r;
80102b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b2d:	c9                   	leave  
80102b2e:	c3                   	ret    

80102b2f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b2f:	55                   	push   %ebp
80102b30:	89 e5                	mov    %esp,%ebp
80102b32:	83 ec 14             	sub    $0x14,%esp
80102b35:	8b 45 08             	mov    0x8(%ebp),%eax
80102b38:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b3c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102b40:	89 c2                	mov    %eax,%edx
80102b42:	ec                   	in     (%dx),%al
80102b43:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102b46:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b4a:	c9                   	leave  
80102b4b:	c3                   	ret    

80102b4c <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b4c:	55                   	push   %ebp
80102b4d:	89 e5                	mov    %esp,%ebp
80102b4f:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b52:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b59:	e8 d1 ff ff ff       	call   80102b2f <inb>
80102b5e:	0f b6 c0             	movzbl %al,%eax
80102b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b67:	83 e0 01             	and    $0x1,%eax
80102b6a:	85 c0                	test   %eax,%eax
80102b6c:	75 0a                	jne    80102b78 <kbdgetc+0x2c>
    return -1;
80102b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b73:	e9 25 01 00 00       	jmp    80102c9d <kbdgetc+0x151>
  data = inb(KBDATAP);
80102b78:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b7f:	e8 ab ff ff ff       	call   80102b2f <inb>
80102b84:	0f b6 c0             	movzbl %al,%eax
80102b87:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102b8a:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102b91:	75 17                	jne    80102baa <kbdgetc+0x5e>
    shift |= E0ESC;
80102b93:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102b98:	83 c8 40             	or     $0x40,%eax
80102b9b:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102ba0:	b8 00 00 00 00       	mov    $0x0,%eax
80102ba5:	e9 f3 00 00 00       	jmp    80102c9d <kbdgetc+0x151>
  } else if(data & 0x80){
80102baa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bad:	25 80 00 00 00       	and    $0x80,%eax
80102bb2:	85 c0                	test   %eax,%eax
80102bb4:	74 45                	je     80102bfb <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bb6:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bbb:	83 e0 40             	and    $0x40,%eax
80102bbe:	85 c0                	test   %eax,%eax
80102bc0:	75 08                	jne    80102bca <kbdgetc+0x7e>
80102bc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bc5:	83 e0 7f             	and    $0x7f,%eax
80102bc8:	eb 03                	jmp    80102bcd <kbdgetc+0x81>
80102bca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bcd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102bd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bd3:	05 20 90 10 80       	add    $0x80109020,%eax
80102bd8:	0f b6 00             	movzbl (%eax),%eax
80102bdb:	83 c8 40             	or     $0x40,%eax
80102bde:	0f b6 c0             	movzbl %al,%eax
80102be1:	f7 d0                	not    %eax
80102be3:	89 c2                	mov    %eax,%edx
80102be5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bea:	21 d0                	and    %edx,%eax
80102bec:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102bf1:	b8 00 00 00 00       	mov    $0x0,%eax
80102bf6:	e9 a2 00 00 00       	jmp    80102c9d <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102bfb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c00:	83 e0 40             	and    $0x40,%eax
80102c03:	85 c0                	test   %eax,%eax
80102c05:	74 14                	je     80102c1b <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c07:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c0e:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c13:	83 e0 bf             	and    $0xffffffbf,%eax
80102c16:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c1e:	05 20 90 10 80       	add    $0x80109020,%eax
80102c23:	0f b6 00             	movzbl (%eax),%eax
80102c26:	0f b6 d0             	movzbl %al,%edx
80102c29:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c2e:	09 d0                	or     %edx,%eax
80102c30:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102c35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c38:	05 20 91 10 80       	add    $0x80109120,%eax
80102c3d:	0f b6 00             	movzbl (%eax),%eax
80102c40:	0f b6 d0             	movzbl %al,%edx
80102c43:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c48:	31 d0                	xor    %edx,%eax
80102c4a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c4f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c54:	83 e0 03             	and    $0x3,%eax
80102c57:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102c5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c61:	01 d0                	add    %edx,%eax
80102c63:	0f b6 00             	movzbl (%eax),%eax
80102c66:	0f b6 c0             	movzbl %al,%eax
80102c69:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c6c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c71:	83 e0 08             	and    $0x8,%eax
80102c74:	85 c0                	test   %eax,%eax
80102c76:	74 22                	je     80102c9a <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102c78:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c7c:	76 0c                	jbe    80102c8a <kbdgetc+0x13e>
80102c7e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102c82:	77 06                	ja     80102c8a <kbdgetc+0x13e>
      c += 'A' - 'a';
80102c84:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102c88:	eb 10                	jmp    80102c9a <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102c8a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102c8e:	76 0a                	jbe    80102c9a <kbdgetc+0x14e>
80102c90:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102c94:	77 04                	ja     80102c9a <kbdgetc+0x14e>
      c += 'a' - 'A';
80102c96:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102c9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102c9d:	c9                   	leave  
80102c9e:	c3                   	ret    

80102c9f <kbdintr>:

void
kbdintr(void)
{
80102c9f:	55                   	push   %ebp
80102ca0:	89 e5                	mov    %esp,%ebp
80102ca2:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102ca5:	c7 04 24 4c 2b 10 80 	movl   $0x80102b4c,(%esp)
80102cac:	e8 fc da ff ff       	call   801007ad <consoleintr>
}
80102cb1:	c9                   	leave  
80102cb2:	c3                   	ret    

80102cb3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cb3:	55                   	push   %ebp
80102cb4:	89 e5                	mov    %esp,%ebp
80102cb6:	83 ec 14             	sub    $0x14,%esp
80102cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102cbc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cc0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cc4:	89 c2                	mov    %eax,%edx
80102cc6:	ec                   	in     (%dx),%al
80102cc7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cca:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cce:	c9                   	leave  
80102ccf:	c3                   	ret    

80102cd0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102cd0:	55                   	push   %ebp
80102cd1:	89 e5                	mov    %esp,%ebp
80102cd3:	83 ec 08             	sub    $0x8,%esp
80102cd6:	8b 55 08             	mov    0x8(%ebp),%edx
80102cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cdc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ce0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ce3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ce7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ceb:	ee                   	out    %al,(%dx)
}
80102cec:	c9                   	leave  
80102ced:	c3                   	ret    

80102cee <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cee:	55                   	push   %ebp
80102cef:	89 e5                	mov    %esp,%ebp
80102cf1:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102cf4:	9c                   	pushf  
80102cf5:	58                   	pop    %eax
80102cf6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102cf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102cfc:	c9                   	leave  
80102cfd:	c3                   	ret    

80102cfe <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102cfe:	55                   	push   %ebp
80102cff:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d01:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d06:	8b 55 08             	mov    0x8(%ebp),%edx
80102d09:	c1 e2 02             	shl    $0x2,%edx
80102d0c:	01 c2                	add    %eax,%edx
80102d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d11:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d13:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d18:	83 c0 20             	add    $0x20,%eax
80102d1b:	8b 00                	mov    (%eax),%eax
}
80102d1d:	5d                   	pop    %ebp
80102d1e:	c3                   	ret    

80102d1f <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d1f:	55                   	push   %ebp
80102d20:	89 e5                	mov    %esp,%ebp
80102d22:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d25:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d2a:	85 c0                	test   %eax,%eax
80102d2c:	75 05                	jne    80102d33 <lapicinit+0x14>
    return;
80102d2e:	e9 43 01 00 00       	jmp    80102e76 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d33:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d3a:	00 
80102d3b:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d42:	e8 b7 ff ff ff       	call   80102cfe <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d47:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d4e:	00 
80102d4f:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d56:	e8 a3 ff ff ff       	call   80102cfe <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d5b:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d62:	00 
80102d63:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d6a:	e8 8f ff ff ff       	call   80102cfe <lapicw>
  lapicw(TICR, 10000000); 
80102d6f:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d76:	00 
80102d77:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d7e:	e8 7b ff ff ff       	call   80102cfe <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d83:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d8a:	00 
80102d8b:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d92:	e8 67 ff ff ff       	call   80102cfe <lapicw>
  lapicw(LINT1, MASKED);
80102d97:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d9e:	00 
80102d9f:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102da6:	e8 53 ff ff ff       	call   80102cfe <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102dab:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102db0:	83 c0 30             	add    $0x30,%eax
80102db3:	8b 00                	mov    (%eax),%eax
80102db5:	c1 e8 10             	shr    $0x10,%eax
80102db8:	0f b6 c0             	movzbl %al,%eax
80102dbb:	83 f8 03             	cmp    $0x3,%eax
80102dbe:	76 14                	jbe    80102dd4 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102dc0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dc7:	00 
80102dc8:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102dcf:	e8 2a ff ff ff       	call   80102cfe <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102dd4:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102ddb:	00 
80102ddc:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102de3:	e8 16 ff ff ff       	call   80102cfe <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102de8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102def:	00 
80102df0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102df7:	e8 02 ff ff ff       	call   80102cfe <lapicw>
  lapicw(ESR, 0);
80102dfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e03:	00 
80102e04:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e0b:	e8 ee fe ff ff       	call   80102cfe <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e17:	00 
80102e18:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e1f:	e8 da fe ff ff       	call   80102cfe <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e2b:	00 
80102e2c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e33:	e8 c6 fe ff ff       	call   80102cfe <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e38:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e3f:	00 
80102e40:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e47:	e8 b2 fe ff ff       	call   80102cfe <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e4c:	90                   	nop
80102e4d:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e52:	05 00 03 00 00       	add    $0x300,%eax
80102e57:	8b 00                	mov    (%eax),%eax
80102e59:	25 00 10 00 00       	and    $0x1000,%eax
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	75 eb                	jne    80102e4d <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e69:	00 
80102e6a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e71:	e8 88 fe ff ff       	call   80102cfe <lapicw>
}
80102e76:	c9                   	leave  
80102e77:	c3                   	ret    

80102e78 <cpunum>:

int
cpunum(void)
{
80102e78:	55                   	push   %ebp
80102e79:	89 e5                	mov    %esp,%ebp
80102e7b:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e7e:	e8 6b fe ff ff       	call   80102cee <readeflags>
80102e83:	25 00 02 00 00       	and    $0x200,%eax
80102e88:	85 c0                	test   %eax,%eax
80102e8a:	74 25                	je     80102eb1 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102e8c:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102e91:	8d 50 01             	lea    0x1(%eax),%edx
80102e94:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102e9a:	85 c0                	test   %eax,%eax
80102e9c:	75 13                	jne    80102eb1 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102e9e:	8b 45 04             	mov    0x4(%ebp),%eax
80102ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ea5:	c7 04 24 68 86 10 80 	movl   $0x80108668,(%esp)
80102eac:	e8 ef d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102eb1:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102eb6:	85 c0                	test   %eax,%eax
80102eb8:	74 0f                	je     80102ec9 <cpunum+0x51>
    return lapic[ID]>>24;
80102eba:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ebf:	83 c0 20             	add    $0x20,%eax
80102ec2:	8b 00                	mov    (%eax),%eax
80102ec4:	c1 e8 18             	shr    $0x18,%eax
80102ec7:	eb 05                	jmp    80102ece <cpunum+0x56>
  return 0;
80102ec9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102ece:	c9                   	leave  
80102ecf:	c3                   	ret    

80102ed0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ed0:	55                   	push   %ebp
80102ed1:	89 e5                	mov    %esp,%ebp
80102ed3:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ed6:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102edb:	85 c0                	test   %eax,%eax
80102edd:	74 14                	je     80102ef3 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102edf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee6:	00 
80102ee7:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102eee:	e8 0b fe ff ff       	call   80102cfe <lapicw>
}
80102ef3:	c9                   	leave  
80102ef4:	c3                   	ret    

80102ef5 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102ef5:	55                   	push   %ebp
80102ef6:	89 e5                	mov    %esp,%ebp
}
80102ef8:	5d                   	pop    %ebp
80102ef9:	c3                   	ret    

80102efa <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102efa:	55                   	push   %ebp
80102efb:	89 e5                	mov    %esp,%ebp
80102efd:	83 ec 1c             	sub    $0x1c,%esp
80102f00:	8b 45 08             	mov    0x8(%ebp),%eax
80102f03:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f06:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f0d:	00 
80102f0e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f15:	e8 b6 fd ff ff       	call   80102cd0 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f1a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f21:	00 
80102f22:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f29:	e8 a2 fd ff ff       	call   80102cd0 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f2e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f35:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f38:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f40:	8d 50 02             	lea    0x2(%eax),%edx
80102f43:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f46:	c1 e8 04             	shr    $0x4,%eax
80102f49:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f4c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f50:	c1 e0 18             	shl    $0x18,%eax
80102f53:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f57:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f5e:	e8 9b fd ff ff       	call   80102cfe <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f63:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f6a:	00 
80102f6b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f72:	e8 87 fd ff ff       	call   80102cfe <lapicw>
  microdelay(200);
80102f77:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f7e:	e8 72 ff ff ff       	call   80102ef5 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f83:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f8a:	00 
80102f8b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f92:	e8 67 fd ff ff       	call   80102cfe <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102f97:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102f9e:	e8 52 ff ff ff       	call   80102ef5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fa3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102faa:	eb 40                	jmp    80102fec <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fac:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fb0:	c1 e0 18             	shl    $0x18,%eax
80102fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fb7:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fbe:	e8 3b fd ff ff       	call   80102cfe <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc6:	c1 e8 0c             	shr    $0xc,%eax
80102fc9:	80 cc 06             	or     $0x6,%ah
80102fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fd0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fd7:	e8 22 fd ff ff       	call   80102cfe <lapicw>
    microdelay(200);
80102fdc:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fe3:	e8 0d ff ff ff       	call   80102ef5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fe8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102fec:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102ff0:	7e ba                	jle    80102fac <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102ff2:	c9                   	leave  
80102ff3:	c3                   	ret    

80102ff4 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102ff4:	55                   	push   %ebp
80102ff5:	89 e5                	mov    %esp,%ebp
80102ff7:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80102ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80102ffd:	0f b6 c0             	movzbl %al,%eax
80103000:	89 44 24 04          	mov    %eax,0x4(%esp)
80103004:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010300b:	e8 c0 fc ff ff       	call   80102cd0 <outb>
  microdelay(200);
80103010:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103017:	e8 d9 fe ff ff       	call   80102ef5 <microdelay>

  return inb(CMOS_RETURN);
8010301c:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103023:	e8 8b fc ff ff       	call   80102cb3 <inb>
80103028:	0f b6 c0             	movzbl %al,%eax
}
8010302b:	c9                   	leave  
8010302c:	c3                   	ret    

8010302d <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010302d:	55                   	push   %ebp
8010302e:	89 e5                	mov    %esp,%ebp
80103030:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103033:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010303a:	e8 b5 ff ff ff       	call   80102ff4 <cmos_read>
8010303f:	8b 55 08             	mov    0x8(%ebp),%edx
80103042:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103044:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010304b:	e8 a4 ff ff ff       	call   80102ff4 <cmos_read>
80103050:	8b 55 08             	mov    0x8(%ebp),%edx
80103053:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103056:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010305d:	e8 92 ff ff ff       	call   80102ff4 <cmos_read>
80103062:	8b 55 08             	mov    0x8(%ebp),%edx
80103065:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103068:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010306f:	e8 80 ff ff ff       	call   80102ff4 <cmos_read>
80103074:	8b 55 08             	mov    0x8(%ebp),%edx
80103077:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010307a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103081:	e8 6e ff ff ff       	call   80102ff4 <cmos_read>
80103086:	8b 55 08             	mov    0x8(%ebp),%edx
80103089:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010308c:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103093:	e8 5c ff ff ff       	call   80102ff4 <cmos_read>
80103098:	8b 55 08             	mov    0x8(%ebp),%edx
8010309b:	89 42 14             	mov    %eax,0x14(%edx)
}
8010309e:	c9                   	leave  
8010309f:	c3                   	ret    

801030a0 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801030a0:	55                   	push   %ebp
801030a1:	89 e5                	mov    %esp,%ebp
801030a3:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801030a6:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801030ad:	e8 42 ff ff ff       	call   80102ff4 <cmos_read>
801030b2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801030b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b8:	83 e0 04             	and    $0x4,%eax
801030bb:	85 c0                	test   %eax,%eax
801030bd:	0f 94 c0             	sete   %al
801030c0:	0f b6 c0             	movzbl %al,%eax
801030c3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801030c6:	8d 45 d8             	lea    -0x28(%ebp),%eax
801030c9:	89 04 24             	mov    %eax,(%esp)
801030cc:	e8 5c ff ff ff       	call   8010302d <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801030d1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801030d8:	e8 17 ff ff ff       	call   80102ff4 <cmos_read>
801030dd:	25 80 00 00 00       	and    $0x80,%eax
801030e2:	85 c0                	test   %eax,%eax
801030e4:	74 02                	je     801030e8 <cmostime+0x48>
        continue;
801030e6:	eb 36                	jmp    8010311e <cmostime+0x7e>
    fill_rtcdate(&t2);
801030e8:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030eb:	89 04 24             	mov    %eax,(%esp)
801030ee:	e8 3a ff ff ff       	call   8010302d <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801030f3:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801030fa:	00 
801030fb:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103102:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103105:	89 04 24             	mov    %eax,(%esp)
80103108:	e8 7f 20 00 00       	call   8010518c <memcmp>
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 0d                	jne    8010311e <cmostime+0x7e>
      break;
80103111:	90                   	nop
  }

  // convert
  if (bcd) {
80103112:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103116:	0f 84 ac 00 00 00    	je     801031c8 <cmostime+0x128>
8010311c:	eb 02                	jmp    80103120 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010311e:	eb a6                	jmp    801030c6 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103120:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103123:	c1 e8 04             	shr    $0x4,%eax
80103126:	89 c2                	mov    %eax,%edx
80103128:	89 d0                	mov    %edx,%eax
8010312a:	c1 e0 02             	shl    $0x2,%eax
8010312d:	01 d0                	add    %edx,%eax
8010312f:	01 c0                	add    %eax,%eax
80103131:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103134:	83 e2 0f             	and    $0xf,%edx
80103137:	01 d0                	add    %edx,%eax
80103139:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010313c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010313f:	c1 e8 04             	shr    $0x4,%eax
80103142:	89 c2                	mov    %eax,%edx
80103144:	89 d0                	mov    %edx,%eax
80103146:	c1 e0 02             	shl    $0x2,%eax
80103149:	01 d0                	add    %edx,%eax
8010314b:	01 c0                	add    %eax,%eax
8010314d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103150:	83 e2 0f             	and    $0xf,%edx
80103153:	01 d0                	add    %edx,%eax
80103155:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103158:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010315b:	c1 e8 04             	shr    $0x4,%eax
8010315e:	89 c2                	mov    %eax,%edx
80103160:	89 d0                	mov    %edx,%eax
80103162:	c1 e0 02             	shl    $0x2,%eax
80103165:	01 d0                	add    %edx,%eax
80103167:	01 c0                	add    %eax,%eax
80103169:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010316c:	83 e2 0f             	and    $0xf,%edx
8010316f:	01 d0                	add    %edx,%eax
80103171:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103174:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103177:	c1 e8 04             	shr    $0x4,%eax
8010317a:	89 c2                	mov    %eax,%edx
8010317c:	89 d0                	mov    %edx,%eax
8010317e:	c1 e0 02             	shl    $0x2,%eax
80103181:	01 d0                	add    %edx,%eax
80103183:	01 c0                	add    %eax,%eax
80103185:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103188:	83 e2 0f             	and    $0xf,%edx
8010318b:	01 d0                	add    %edx,%eax
8010318d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103190:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103193:	c1 e8 04             	shr    $0x4,%eax
80103196:	89 c2                	mov    %eax,%edx
80103198:	89 d0                	mov    %edx,%eax
8010319a:	c1 e0 02             	shl    $0x2,%eax
8010319d:	01 d0                	add    %edx,%eax
8010319f:	01 c0                	add    %eax,%eax
801031a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031a4:	83 e2 0f             	and    $0xf,%edx
801031a7:	01 d0                	add    %edx,%eax
801031a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801031ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031af:	c1 e8 04             	shr    $0x4,%eax
801031b2:	89 c2                	mov    %eax,%edx
801031b4:	89 d0                	mov    %edx,%eax
801031b6:	c1 e0 02             	shl    $0x2,%eax
801031b9:	01 d0                	add    %edx,%eax
801031bb:	01 c0                	add    %eax,%eax
801031bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031c0:	83 e2 0f             	and    $0xf,%edx
801031c3:	01 d0                	add    %edx,%eax
801031c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801031c8:	8b 45 08             	mov    0x8(%ebp),%eax
801031cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031ce:	89 10                	mov    %edx,(%eax)
801031d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031d3:	89 50 04             	mov    %edx,0x4(%eax)
801031d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031d9:	89 50 08             	mov    %edx,0x8(%eax)
801031dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031df:	89 50 0c             	mov    %edx,0xc(%eax)
801031e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031e5:	89 50 10             	mov    %edx,0x10(%eax)
801031e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031eb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801031ee:	8b 45 08             	mov    0x8(%ebp),%eax
801031f1:	8b 40 14             	mov    0x14(%eax),%eax
801031f4:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801031fa:	8b 45 08             	mov    0x8(%ebp),%eax
801031fd:	89 50 14             	mov    %edx,0x14(%eax)
}
80103200:	c9                   	leave  
80103201:	c3                   	ret    

80103202 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103202:	55                   	push   %ebp
80103203:	89 e5                	mov    %esp,%ebp
80103205:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103208:	c7 44 24 04 94 86 10 	movl   $0x80108694,0x4(%esp)
8010320f:	80 
80103210:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103217:	e8 84 1c 00 00       	call   80104ea0 <initlock>
  readsb(ROOTDEV, &sb);
8010321c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010321f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103223:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010322a:	e8 c2 e0 ff ff       	call   801012f1 <readsb>
  log.start = sb.size - sb.nlog;
8010322f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103235:	29 c2                	sub    %eax,%edx
80103237:	89 d0                	mov    %edx,%eax
80103239:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
8010323e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103241:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = ROOTDEV;
80103246:	c7 05 a4 22 11 80 01 	movl   $0x1,0x801122a4
8010324d:	00 00 00 
  recover_from_log();
80103250:	e8 9a 01 00 00       	call   801033ef <recover_from_log>
}
80103255:	c9                   	leave  
80103256:	c3                   	ret    

80103257 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103257:	55                   	push   %ebp
80103258:	89 e5                	mov    %esp,%ebp
8010325a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010325d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103264:	e9 8c 00 00 00       	jmp    801032f5 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103269:	8b 15 94 22 11 80    	mov    0x80112294,%edx
8010326f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103272:	01 d0                	add    %edx,%eax
80103274:	83 c0 01             	add    $0x1,%eax
80103277:	89 c2                	mov    %eax,%edx
80103279:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010327e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103282:	89 04 24             	mov    %eax,(%esp)
80103285:	e8 1c cf ff ff       	call   801001a6 <bread>
8010328a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010328d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103290:	83 c0 10             	add    $0x10,%eax
80103293:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
8010329a:	89 c2                	mov    %eax,%edx
8010329c:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801032a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801032a5:	89 04 24             	mov    %eax,(%esp)
801032a8:	e8 f9 ce ff ff       	call   801001a6 <bread>
801032ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801032b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032b3:	8d 50 18             	lea    0x18(%eax),%edx
801032b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032b9:	83 c0 18             	add    $0x18,%eax
801032bc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801032c3:	00 
801032c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801032c8:	89 04 24             	mov    %eax,(%esp)
801032cb:	e8 14 1f 00 00       	call   801051e4 <memmove>
    bwrite(dbuf);  // write dst to disk
801032d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d3:	89 04 24             	mov    %eax,(%esp)
801032d6:	e8 02 cf ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801032db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032de:	89 04 24             	mov    %eax,(%esp)
801032e1:	e8 31 cf ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801032e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e9:	89 04 24             	mov    %eax,(%esp)
801032ec:	e8 26 cf ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f5:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801032fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801032fd:	0f 8f 66 ff ff ff    	jg     80103269 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103303:	c9                   	leave  
80103304:	c3                   	ret    

80103305 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103305:	55                   	push   %ebp
80103306:	89 e5                	mov    %esp,%ebp
80103308:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010330b:	a1 94 22 11 80       	mov    0x80112294,%eax
80103310:	89 c2                	mov    %eax,%edx
80103312:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103317:	89 54 24 04          	mov    %edx,0x4(%esp)
8010331b:	89 04 24             	mov    %eax,(%esp)
8010331e:	e8 83 ce ff ff       	call   801001a6 <bread>
80103323:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103329:	83 c0 18             	add    $0x18,%eax
8010332c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010332f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103332:	8b 00                	mov    (%eax),%eax
80103334:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
80103339:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103340:	eb 1b                	jmp    8010335d <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103342:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103345:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103348:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010334c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010334f:	83 c2 10             	add    $0x10,%edx
80103352:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103359:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010335d:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103362:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103365:	7f db                	jg     80103342 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103367:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010336a:	89 04 24             	mov    %eax,(%esp)
8010336d:	e8 a5 ce ff ff       	call   80100217 <brelse>
}
80103372:	c9                   	leave  
80103373:	c3                   	ret    

80103374 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103374:	55                   	push   %ebp
80103375:	89 e5                	mov    %esp,%ebp
80103377:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010337a:	a1 94 22 11 80       	mov    0x80112294,%eax
8010337f:	89 c2                	mov    %eax,%edx
80103381:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103386:	89 54 24 04          	mov    %edx,0x4(%esp)
8010338a:	89 04 24             	mov    %eax,(%esp)
8010338d:	e8 14 ce ff ff       	call   801001a6 <bread>
80103392:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103398:	83 c0 18             	add    $0x18,%eax
8010339b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010339e:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
801033a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033b0:	eb 1b                	jmp    801033cd <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b5:	83 c0 10             	add    $0x10,%eax
801033b8:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
801033bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033c5:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801033c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033cd:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801033d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033d5:	7f db                	jg     801033b2 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801033d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033da:	89 04 24             	mov    %eax,(%esp)
801033dd:	e8 fb cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
801033e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e5:	89 04 24             	mov    %eax,(%esp)
801033e8:	e8 2a ce ff ff       	call   80100217 <brelse>
}
801033ed:	c9                   	leave  
801033ee:	c3                   	ret    

801033ef <recover_from_log>:

static void
recover_from_log(void)
{
801033ef:	55                   	push   %ebp
801033f0:	89 e5                	mov    %esp,%ebp
801033f2:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801033f5:	e8 0b ff ff ff       	call   80103305 <read_head>
  install_trans(); // if committed, copy from log to disk
801033fa:	e8 58 fe ff ff       	call   80103257 <install_trans>
  log.lh.n = 0;
801033ff:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103406:	00 00 00 
  write_head(); // clear the log
80103409:	e8 66 ff ff ff       	call   80103374 <write_head>
}
8010340e:	c9                   	leave  
8010340f:	c3                   	ret    

80103410 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103410:	55                   	push   %ebp
80103411:	89 e5                	mov    %esp,%ebp
80103413:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103416:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010341d:	e8 9f 1a 00 00       	call   80104ec1 <acquire>
  while(1){
    if(log.committing){
80103422:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103427:	85 c0                	test   %eax,%eax
80103429:	74 16                	je     80103441 <begin_op+0x31>
      sleep(&log, &log.lock);
8010342b:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103432:	80 
80103433:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010343a:	e8 af 17 00 00       	call   80104bee <sleep>
8010343f:	eb 4f                	jmp    80103490 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103441:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103447:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010344c:	8d 50 01             	lea    0x1(%eax),%edx
8010344f:	89 d0                	mov    %edx,%eax
80103451:	c1 e0 02             	shl    $0x2,%eax
80103454:	01 d0                	add    %edx,%eax
80103456:	01 c0                	add    %eax,%eax
80103458:	01 c8                	add    %ecx,%eax
8010345a:	83 f8 1e             	cmp    $0x1e,%eax
8010345d:	7e 16                	jle    80103475 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010345f:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103466:	80 
80103467:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010346e:	e8 7b 17 00 00       	call   80104bee <sleep>
80103473:	eb 1b                	jmp    80103490 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103475:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010347a:	83 c0 01             	add    $0x1,%eax
8010347d:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
80103482:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103489:	e8 95 1a 00 00       	call   80104f23 <release>
      break;
8010348e:	eb 02                	jmp    80103492 <begin_op+0x82>
    }
  }
80103490:	eb 90                	jmp    80103422 <begin_op+0x12>
}
80103492:	c9                   	leave  
80103493:	c3                   	ret    

80103494 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103494:	55                   	push   %ebp
80103495:	89 e5                	mov    %esp,%ebp
80103497:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010349a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801034a1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034a8:	e8 14 1a 00 00       	call   80104ec1 <acquire>
  log.outstanding -= 1;
801034ad:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034b2:	83 e8 01             	sub    $0x1,%eax
801034b5:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
801034ba:	a1 a0 22 11 80       	mov    0x801122a0,%eax
801034bf:	85 c0                	test   %eax,%eax
801034c1:	74 0c                	je     801034cf <end_op+0x3b>
    panic("log.committing");
801034c3:	c7 04 24 98 86 10 80 	movl   $0x80108698,(%esp)
801034ca:	e8 6b d0 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
801034cf:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034d4:	85 c0                	test   %eax,%eax
801034d6:	75 13                	jne    801034eb <end_op+0x57>
    do_commit = 1;
801034d8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801034df:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
801034e6:	00 00 00 
801034e9:	eb 0c                	jmp    801034f7 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801034eb:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034f2:	e8 cf 17 00 00       	call   80104cc6 <wakeup>
  }
  release(&log.lock);
801034f7:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034fe:	e8 20 1a 00 00       	call   80104f23 <release>

  if(do_commit){
80103503:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103507:	74 33                	je     8010353c <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103509:	e8 de 00 00 00       	call   801035ec <commit>
    acquire(&log.lock);
8010350e:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103515:	e8 a7 19 00 00       	call   80104ec1 <acquire>
    log.committing = 0;
8010351a:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
80103521:	00 00 00 
    wakeup(&log);
80103524:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010352b:	e8 96 17 00 00       	call   80104cc6 <wakeup>
    release(&log.lock);
80103530:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103537:	e8 e7 19 00 00       	call   80104f23 <release>
  }
}
8010353c:	c9                   	leave  
8010353d:	c3                   	ret    

8010353e <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010353e:	55                   	push   %ebp
8010353f:	89 e5                	mov    %esp,%ebp
80103541:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103544:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010354b:	e9 8c 00 00 00       	jmp    801035dc <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103550:	8b 15 94 22 11 80    	mov    0x80112294,%edx
80103556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103559:	01 d0                	add    %edx,%eax
8010355b:	83 c0 01             	add    $0x1,%eax
8010355e:	89 c2                	mov    %eax,%edx
80103560:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103565:	89 54 24 04          	mov    %edx,0x4(%esp)
80103569:	89 04 24             	mov    %eax,(%esp)
8010356c:	e8 35 cc ff ff       	call   801001a6 <bread>
80103571:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103577:	83 c0 10             	add    $0x10,%eax
8010357a:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103581:	89 c2                	mov    %eax,%edx
80103583:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103588:	89 54 24 04          	mov    %edx,0x4(%esp)
8010358c:	89 04 24             	mov    %eax,(%esp)
8010358f:	e8 12 cc ff ff       	call   801001a6 <bread>
80103594:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103597:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010359a:	8d 50 18             	lea    0x18(%eax),%edx
8010359d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035a0:	83 c0 18             	add    $0x18,%eax
801035a3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801035aa:	00 
801035ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801035af:	89 04 24             	mov    %eax,(%esp)
801035b2:	e8 2d 1c 00 00       	call   801051e4 <memmove>
    bwrite(to);  // write the log
801035b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ba:	89 04 24             	mov    %eax,(%esp)
801035bd:	e8 1b cc ff ff       	call   801001dd <bwrite>
    brelse(from); 
801035c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c5:	89 04 24             	mov    %eax,(%esp)
801035c8:	e8 4a cc ff ff       	call   80100217 <brelse>
    brelse(to);
801035cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d0:	89 04 24             	mov    %eax,(%esp)
801035d3:	e8 3f cc ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035dc:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801035e1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035e4:	0f 8f 66 ff ff ff    	jg     80103550 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801035ea:	c9                   	leave  
801035eb:	c3                   	ret    

801035ec <commit>:

static void
commit()
{
801035ec:	55                   	push   %ebp
801035ed:	89 e5                	mov    %esp,%ebp
801035ef:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801035f2:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801035f7:	85 c0                	test   %eax,%eax
801035f9:	7e 1e                	jle    80103619 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801035fb:	e8 3e ff ff ff       	call   8010353e <write_log>
    write_head();    // Write header to disk -- the real commit
80103600:	e8 6f fd ff ff       	call   80103374 <write_head>
    install_trans(); // Now install writes to home locations
80103605:	e8 4d fc ff ff       	call   80103257 <install_trans>
    log.lh.n = 0; 
8010360a:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103611:	00 00 00 
    write_head();    // Erase the transaction from the log
80103614:	e8 5b fd ff ff       	call   80103374 <write_head>
  }
}
80103619:	c9                   	leave  
8010361a:	c3                   	ret    

8010361b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010361b:	55                   	push   %ebp
8010361c:	89 e5                	mov    %esp,%ebp
8010361e:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103621:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103626:	83 f8 1d             	cmp    $0x1d,%eax
80103629:	7f 12                	jg     8010363d <log_write+0x22>
8010362b:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103630:	8b 15 98 22 11 80    	mov    0x80112298,%edx
80103636:	83 ea 01             	sub    $0x1,%edx
80103639:	39 d0                	cmp    %edx,%eax
8010363b:	7c 0c                	jl     80103649 <log_write+0x2e>
    panic("too big a transaction");
8010363d:	c7 04 24 a7 86 10 80 	movl   $0x801086a7,(%esp)
80103644:	e8 f1 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103649:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010364e:	85 c0                	test   %eax,%eax
80103650:	7f 0c                	jg     8010365e <log_write+0x43>
    panic("log_write outside of trans");
80103652:	c7 04 24 bd 86 10 80 	movl   $0x801086bd,(%esp)
80103659:	e8 dc ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010365e:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103665:	e8 57 18 00 00       	call   80104ec1 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010366a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103671:	eb 1f                	jmp    80103692 <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103676:	83 c0 10             	add    $0x10,%eax
80103679:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103680:	89 c2                	mov    %eax,%edx
80103682:	8b 45 08             	mov    0x8(%ebp),%eax
80103685:	8b 40 08             	mov    0x8(%eax),%eax
80103688:	39 c2                	cmp    %eax,%edx
8010368a:	75 02                	jne    8010368e <log_write+0x73>
      break;
8010368c:	eb 0e                	jmp    8010369c <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010368e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103692:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103697:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010369a:	7f d7                	jg     80103673 <log_write+0x58>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
8010369c:	8b 45 08             	mov    0x8(%ebp),%eax
8010369f:	8b 40 08             	mov    0x8(%eax),%eax
801036a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036a5:	83 c2 10             	add    $0x10,%edx
801036a8:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
  if (i == log.lh.n)
801036af:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036b4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036b7:	75 0d                	jne    801036c6 <log_write+0xab>
    log.lh.n++;
801036b9:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036be:	83 c0 01             	add    $0x1,%eax
801036c1:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	8b 00                	mov    (%eax),%eax
801036cb:	83 c8 04             	or     $0x4,%eax
801036ce:	89 c2                	mov    %eax,%edx
801036d0:	8b 45 08             	mov    0x8(%ebp),%eax
801036d3:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801036d5:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036dc:	e8 42 18 00 00       	call   80104f23 <release>
}
801036e1:	c9                   	leave  
801036e2:	c3                   	ret    

801036e3 <v2p>:
801036e3:	55                   	push   %ebp
801036e4:	89 e5                	mov    %esp,%ebp
801036e6:	8b 45 08             	mov    0x8(%ebp),%eax
801036e9:	05 00 00 00 80       	add    $0x80000000,%eax
801036ee:	5d                   	pop    %ebp
801036ef:	c3                   	ret    

801036f0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	8b 45 08             	mov    0x8(%ebp),%eax
801036f6:	05 00 00 00 80       	add    $0x80000000,%eax
801036fb:	5d                   	pop    %ebp
801036fc:	c3                   	ret    

801036fd <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801036fd:	55                   	push   %ebp
801036fe:	89 e5                	mov    %esp,%ebp
80103700:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103703:	8b 55 08             	mov    0x8(%ebp),%edx
80103706:	8b 45 0c             	mov    0xc(%ebp),%eax
80103709:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010370c:	f0 87 02             	lock xchg %eax,(%edx)
8010370f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103712:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103715:	c9                   	leave  
80103716:	c3                   	ret    

80103717 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103717:	55                   	push   %ebp
80103718:	89 e5                	mov    %esp,%ebp
8010371a:	83 e4 f0             	and    $0xfffffff0,%esp
8010371d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103720:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103727:	80 
80103728:	c7 04 24 3c 51 11 80 	movl   $0x8011513c,(%esp)
8010372f:	e8 80 f2 ff ff       	call   801029b4 <kinit1>
  kvmalloc();      // kernel page table
80103734:	e8 a1 45 00 00       	call   80107cda <kvmalloc>
  mpinit();        // collect info about this machine
80103739:	e8 46 04 00 00       	call   80103b84 <mpinit>
  lapicinit();
8010373e:	e8 dc f5 ff ff       	call   80102d1f <lapicinit>
  seginit();       // set up segments
80103743:	e8 25 3f 00 00       	call   8010766d <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103748:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010374e:	0f b6 00             	movzbl (%eax),%eax
80103751:	0f b6 c0             	movzbl %al,%eax
80103754:	89 44 24 04          	mov    %eax,0x4(%esp)
80103758:	c7 04 24 d8 86 10 80 	movl   $0x801086d8,(%esp)
8010375f:	e8 3c cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103764:	e8 79 06 00 00       	call   80103de2 <picinit>
  ioapicinit();    // another interrupt controller
80103769:	e8 3c f1 ff ff       	call   801028aa <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010376e:	e8 0e d3 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103773:	e8 44 32 00 00       	call   801069bc <uartinit>
  pinit();         // process table
80103778:	e8 a3 0b 00 00       	call   80104320 <pinit>
  tvinit();        // trap vectors
8010377d:	e8 ec 2d 00 00       	call   8010656e <tvinit>
  binit();         // buffer cache
80103782:	e8 ad c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103787:	e8 7e d7 ff ff       	call   80100f0a <fileinit>
  iinit();         // inode cache
8010378c:	e8 13 de ff ff       	call   801015a4 <iinit>
  ideinit();       // disk
80103791:	e8 7d ed ff ff       	call   80102513 <ideinit>
  if(!ismp)
80103796:	a1 44 23 11 80       	mov    0x80112344,%eax
8010379b:	85 c0                	test   %eax,%eax
8010379d:	75 05                	jne    801037a4 <main+0x8d>
    timerinit();   // uniprocessor timer
8010379f:	e8 15 2d 00 00       	call   801064b9 <timerinit>
  startothers();   // start other processors
801037a4:	e8 7f 00 00 00       	call   80103828 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037a9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037b0:	8e 
801037b1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037b8:	e8 2f f2 ff ff       	call   801029ec <kinit2>
  userinit();      // first user process
801037bd:	e8 91 0c 00 00       	call   80104453 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037c2:	e8 1a 00 00 00       	call   801037e1 <mpmain>

801037c7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037c7:	55                   	push   %ebp
801037c8:	89 e5                	mov    %esp,%ebp
801037ca:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801037cd:	e8 1f 45 00 00       	call   80107cf1 <switchkvm>
  seginit();
801037d2:	e8 96 3e 00 00       	call   8010766d <seginit>
  lapicinit();
801037d7:	e8 43 f5 ff ff       	call   80102d1f <lapicinit>
  mpmain();
801037dc:	e8 00 00 00 00       	call   801037e1 <mpmain>

801037e1 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037e1:	55                   	push   %ebp
801037e2:	89 e5                	mov    %esp,%ebp
801037e4:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801037e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037ed:	0f b6 00             	movzbl (%eax),%eax
801037f0:	0f b6 c0             	movzbl %al,%eax
801037f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801037f7:	c7 04 24 ef 86 10 80 	movl   $0x801086ef,(%esp)
801037fe:	e8 9d cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103803:	e8 da 2e 00 00       	call   801066e2 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103808:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010380e:	05 a8 00 00 00       	add    $0xa8,%eax
80103813:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010381a:	00 
8010381b:	89 04 24             	mov    %eax,(%esp)
8010381e:	e8 da fe ff ff       	call   801036fd <xchg>
  scheduler();     // start running processes
80103823:	e8 08 12 00 00       	call   80104a30 <scheduler>

80103828 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103828:	55                   	push   %ebp
80103829:	89 e5                	mov    %esp,%ebp
8010382b:	53                   	push   %ebx
8010382c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010382f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103836:	e8 b5 fe ff ff       	call   801036f0 <p2v>
8010383b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010383e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103843:	89 44 24 08          	mov    %eax,0x8(%esp)
80103847:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010384e:	80 
8010384f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103852:	89 04 24             	mov    %eax,(%esp)
80103855:	e8 8a 19 00 00       	call   801051e4 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010385a:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
80103861:	e9 85 00 00 00       	jmp    801038eb <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103866:	e8 0d f6 ff ff       	call   80102e78 <cpunum>
8010386b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103871:	05 60 23 11 80       	add    $0x80112360,%eax
80103876:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103879:	75 02                	jne    8010387d <startothers+0x55>
      continue;
8010387b:	eb 67                	jmp    801038e4 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010387d:	e8 60 f2 ff ff       	call   80102ae2 <kalloc>
80103882:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103888:	83 e8 04             	sub    $0x4,%eax
8010388b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010388e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103894:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103899:	83 e8 08             	sub    $0x8,%eax
8010389c:	c7 00 c7 37 10 80    	movl   $0x801037c7,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a5:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038a8:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801038af:	e8 2f fe ff ff       	call   801036e3 <v2p>
801038b4:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b9:	89 04 24             	mov    %eax,(%esp)
801038bc:	e8 22 fe ff ff       	call   801036e3 <v2p>
801038c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038c4:	0f b6 12             	movzbl (%edx),%edx
801038c7:	0f b6 d2             	movzbl %dl,%edx
801038ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801038ce:	89 14 24             	mov    %edx,(%esp)
801038d1:	e8 24 f6 ff ff       	call   80102efa <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038d6:	90                   	nop
801038d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038da:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	74 f3                	je     801038d7 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038e4:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801038eb:	a1 40 29 11 80       	mov    0x80112940,%eax
801038f0:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038f6:	05 60 23 11 80       	add    $0x80112360,%eax
801038fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038fe:	0f 87 62 ff ff ff    	ja     80103866 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103904:	83 c4 24             	add    $0x24,%esp
80103907:	5b                   	pop    %ebx
80103908:	5d                   	pop    %ebp
80103909:	c3                   	ret    

8010390a <p2v>:
8010390a:	55                   	push   %ebp
8010390b:	89 e5                	mov    %esp,%ebp
8010390d:	8b 45 08             	mov    0x8(%ebp),%eax
80103910:	05 00 00 00 80       	add    $0x80000000,%eax
80103915:	5d                   	pop    %ebp
80103916:	c3                   	ret    

80103917 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103917:	55                   	push   %ebp
80103918:	89 e5                	mov    %esp,%ebp
8010391a:	83 ec 14             	sub    $0x14,%esp
8010391d:	8b 45 08             	mov    0x8(%ebp),%eax
80103920:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103924:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103928:	89 c2                	mov    %eax,%edx
8010392a:	ec                   	in     (%dx),%al
8010392b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010392e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103932:	c9                   	leave  
80103933:	c3                   	ret    

80103934 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103934:	55                   	push   %ebp
80103935:	89 e5                	mov    %esp,%ebp
80103937:	83 ec 08             	sub    $0x8,%esp
8010393a:	8b 55 08             	mov    0x8(%ebp),%edx
8010393d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103940:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103944:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103947:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010394b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010394f:	ee                   	out    %al,(%dx)
}
80103950:	c9                   	leave  
80103951:	c3                   	ret    

80103952 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103952:	55                   	push   %ebp
80103953:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103955:	a1 44 b6 10 80       	mov    0x8010b644,%eax
8010395a:	89 c2                	mov    %eax,%edx
8010395c:	b8 60 23 11 80       	mov    $0x80112360,%eax
80103961:	29 c2                	sub    %eax,%edx
80103963:	89 d0                	mov    %edx,%eax
80103965:	c1 f8 02             	sar    $0x2,%eax
80103968:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010396e:	5d                   	pop    %ebp
8010396f:	c3                   	ret    

80103970 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103976:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010397d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103984:	eb 15                	jmp    8010399b <sum+0x2b>
    sum += addr[i];
80103986:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103989:	8b 45 08             	mov    0x8(%ebp),%eax
8010398c:	01 d0                	add    %edx,%eax
8010398e:	0f b6 00             	movzbl (%eax),%eax
80103991:	0f b6 c0             	movzbl %al,%eax
80103994:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103997:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010399b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010399e:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039a1:	7c e3                	jl     80103986 <sum+0x16>
    sum += addr[i];
  return sum;
801039a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039a6:	c9                   	leave  
801039a7:	c3                   	ret    

801039a8 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039a8:	55                   	push   %ebp
801039a9:	89 e5                	mov    %esp,%ebp
801039ab:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039ae:	8b 45 08             	mov    0x8(%ebp),%eax
801039b1:	89 04 24             	mov    %eax,(%esp)
801039b4:	e8 51 ff ff ff       	call   8010390a <p2v>
801039b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801039bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039c2:	01 d0                	add    %edx,%eax
801039c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039cd:	eb 3f                	jmp    80103a0e <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039cf:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039d6:	00 
801039d7:	c7 44 24 04 00 87 10 	movl   $0x80108700,0x4(%esp)
801039de:	80 
801039df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e2:	89 04 24             	mov    %eax,(%esp)
801039e5:	e8 a2 17 00 00       	call   8010518c <memcmp>
801039ea:	85 c0                	test   %eax,%eax
801039ec:	75 1c                	jne    80103a0a <mpsearch1+0x62>
801039ee:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801039f5:	00 
801039f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f9:	89 04 24             	mov    %eax,(%esp)
801039fc:	e8 6f ff ff ff       	call   80103970 <sum>
80103a01:	84 c0                	test   %al,%al
80103a03:	75 05                	jne    80103a0a <mpsearch1+0x62>
      return (struct mp*)p;
80103a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a08:	eb 11                	jmp    80103a1b <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a0a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a11:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a14:	72 b9                	jb     801039cf <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a16:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a1b:	c9                   	leave  
80103a1c:	c3                   	ret    

80103a1d <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a1d:	55                   	push   %ebp
80103a1e:	89 e5                	mov    %esp,%ebp
80103a20:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a23:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2d:	83 c0 0f             	add    $0xf,%eax
80103a30:	0f b6 00             	movzbl (%eax),%eax
80103a33:	0f b6 c0             	movzbl %al,%eax
80103a36:	c1 e0 08             	shl    $0x8,%eax
80103a39:	89 c2                	mov    %eax,%edx
80103a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3e:	83 c0 0e             	add    $0xe,%eax
80103a41:	0f b6 00             	movzbl (%eax),%eax
80103a44:	0f b6 c0             	movzbl %al,%eax
80103a47:	09 d0                	or     %edx,%eax
80103a49:	c1 e0 04             	shl    $0x4,%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a4f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a53:	74 21                	je     80103a76 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a55:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a5c:	00 
80103a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a60:	89 04 24             	mov    %eax,(%esp)
80103a63:	e8 40 ff ff ff       	call   801039a8 <mpsearch1>
80103a68:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a6b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a6f:	74 50                	je     80103ac1 <mpsearch+0xa4>
      return mp;
80103a71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a74:	eb 5f                	jmp    80103ad5 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a79:	83 c0 14             	add    $0x14,%eax
80103a7c:	0f b6 00             	movzbl (%eax),%eax
80103a7f:	0f b6 c0             	movzbl %al,%eax
80103a82:	c1 e0 08             	shl    $0x8,%eax
80103a85:	89 c2                	mov    %eax,%edx
80103a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8a:	83 c0 13             	add    $0x13,%eax
80103a8d:	0f b6 00             	movzbl (%eax),%eax
80103a90:	0f b6 c0             	movzbl %al,%eax
80103a93:	09 d0                	or     %edx,%eax
80103a95:	c1 e0 0a             	shl    $0xa,%eax
80103a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a9e:	2d 00 04 00 00       	sub    $0x400,%eax
80103aa3:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103aaa:	00 
80103aab:	89 04 24             	mov    %eax,(%esp)
80103aae:	e8 f5 fe ff ff       	call   801039a8 <mpsearch1>
80103ab3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ab6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aba:	74 05                	je     80103ac1 <mpsearch+0xa4>
      return mp;
80103abc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103abf:	eb 14                	jmp    80103ad5 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ac1:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ac8:	00 
80103ac9:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ad0:	e8 d3 fe ff ff       	call   801039a8 <mpsearch1>
}
80103ad5:	c9                   	leave  
80103ad6:	c3                   	ret    

80103ad7 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ad7:	55                   	push   %ebp
80103ad8:	89 e5                	mov    %esp,%ebp
80103ada:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103add:	e8 3b ff ff ff       	call   80103a1d <mpsearch>
80103ae2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ae5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ae9:	74 0a                	je     80103af5 <mpconfig+0x1e>
80103aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aee:	8b 40 04             	mov    0x4(%eax),%eax
80103af1:	85 c0                	test   %eax,%eax
80103af3:	75 0a                	jne    80103aff <mpconfig+0x28>
    return 0;
80103af5:	b8 00 00 00 00       	mov    $0x0,%eax
80103afa:	e9 83 00 00 00       	jmp    80103b82 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b02:	8b 40 04             	mov    0x4(%eax),%eax
80103b05:	89 04 24             	mov    %eax,(%esp)
80103b08:	e8 fd fd ff ff       	call   8010390a <p2v>
80103b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b10:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b17:	00 
80103b18:	c7 44 24 04 05 87 10 	movl   $0x80108705,0x4(%esp)
80103b1f:	80 
80103b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b23:	89 04 24             	mov    %eax,(%esp)
80103b26:	e8 61 16 00 00       	call   8010518c <memcmp>
80103b2b:	85 c0                	test   %eax,%eax
80103b2d:	74 07                	je     80103b36 <mpconfig+0x5f>
    return 0;
80103b2f:	b8 00 00 00 00       	mov    $0x0,%eax
80103b34:	eb 4c                	jmp    80103b82 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b39:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b3d:	3c 01                	cmp    $0x1,%al
80103b3f:	74 12                	je     80103b53 <mpconfig+0x7c>
80103b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b44:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b48:	3c 04                	cmp    $0x4,%al
80103b4a:	74 07                	je     80103b53 <mpconfig+0x7c>
    return 0;
80103b4c:	b8 00 00 00 00       	mov    $0x0,%eax
80103b51:	eb 2f                	jmp    80103b82 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b56:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b5a:	0f b7 c0             	movzwl %ax,%eax
80103b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b64:	89 04 24             	mov    %eax,(%esp)
80103b67:	e8 04 fe ff ff       	call   80103970 <sum>
80103b6c:	84 c0                	test   %al,%al
80103b6e:	74 07                	je     80103b77 <mpconfig+0xa0>
    return 0;
80103b70:	b8 00 00 00 00       	mov    $0x0,%eax
80103b75:	eb 0b                	jmp    80103b82 <mpconfig+0xab>
  *pmp = mp;
80103b77:	8b 45 08             	mov    0x8(%ebp),%eax
80103b7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7d:	89 10                	mov    %edx,(%eax)
  return conf;
80103b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b82:	c9                   	leave  
80103b83:	c3                   	ret    

80103b84 <mpinit>:

void
mpinit(void)
{
80103b84:	55                   	push   %ebp
80103b85:	89 e5                	mov    %esp,%ebp
80103b87:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103b8a:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103b91:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103b94:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103b97:	89 04 24             	mov    %eax,(%esp)
80103b9a:	e8 38 ff ff ff       	call   80103ad7 <mpconfig>
80103b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ba2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ba6:	75 05                	jne    80103bad <mpinit+0x29>
    return;
80103ba8:	e9 9c 01 00 00       	jmp    80103d49 <mpinit+0x1c5>
  ismp = 1;
80103bad:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103bb4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bba:	8b 40 24             	mov    0x24(%eax),%eax
80103bbd:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc5:	83 c0 2c             	add    $0x2c,%eax
80103bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bce:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bd2:	0f b7 d0             	movzwl %ax,%edx
80103bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd8:	01 d0                	add    %edx,%eax
80103bda:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bdd:	e9 f4 00 00 00       	jmp    80103cd6 <mpinit+0x152>
    switch(*p){
80103be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be5:	0f b6 00             	movzbl (%eax),%eax
80103be8:	0f b6 c0             	movzbl %al,%eax
80103beb:	83 f8 04             	cmp    $0x4,%eax
80103bee:	0f 87 bf 00 00 00    	ja     80103cb3 <mpinit+0x12f>
80103bf4:	8b 04 85 48 87 10 80 	mov    -0x7fef78b8(,%eax,4),%eax
80103bfb:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c06:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c0a:	0f b6 d0             	movzbl %al,%edx
80103c0d:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c12:	39 c2                	cmp    %eax,%edx
80103c14:	74 2d                	je     80103c43 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c16:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c19:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c1d:	0f b6 d0             	movzbl %al,%edx
80103c20:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c25:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c29:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c2d:	c7 04 24 0a 87 10 80 	movl   $0x8010870a,(%esp)
80103c34:	e8 67 c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c39:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103c40:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c43:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c46:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c4a:	0f b6 c0             	movzbl %al,%eax
80103c4d:	83 e0 02             	and    $0x2,%eax
80103c50:	85 c0                	test   %eax,%eax
80103c52:	74 15                	je     80103c69 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103c54:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c59:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c5f:	05 60 23 11 80       	add    $0x80112360,%eax
80103c64:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103c69:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103c6f:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c74:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103c7a:	81 c2 60 23 11 80    	add    $0x80112360,%edx
80103c80:	88 02                	mov    %al,(%edx)
      ncpu++;
80103c82:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c87:	83 c0 01             	add    $0x1,%eax
80103c8a:	a3 40 29 11 80       	mov    %eax,0x80112940
      p += sizeof(struct mpproc);
80103c8f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c93:	eb 41                	jmp    80103cd6 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103c9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c9e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ca2:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103ca7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cab:	eb 29                	jmp    80103cd6 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cad:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cb1:	eb 23                	jmp    80103cd6 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	0f b6 00             	movzbl (%eax),%eax
80103cb9:	0f b6 c0             	movzbl %al,%eax
80103cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cc0:	c7 04 24 28 87 10 80 	movl   $0x80108728,(%esp)
80103cc7:	e8 d4 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103ccc:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103cd3:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cdc:	0f 82 00 ff ff ff    	jb     80103be2 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103ce2:	a1 44 23 11 80       	mov    0x80112344,%eax
80103ce7:	85 c0                	test   %eax,%eax
80103ce9:	75 1d                	jne    80103d08 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103ceb:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103cf2:	00 00 00 
    lapic = 0;
80103cf5:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103cfc:	00 00 00 
    ioapicid = 0;
80103cff:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103d06:	eb 41                	jmp    80103d49 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d08:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d0b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d0f:	84 c0                	test   %al,%al
80103d11:	74 36                	je     80103d49 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d13:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d1a:	00 
80103d1b:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d22:	e8 0d fc ff ff       	call   80103934 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d27:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d2e:	e8 e4 fb ff ff       	call   80103917 <inb>
80103d33:	83 c8 01             	or     $0x1,%eax
80103d36:	0f b6 c0             	movzbl %al,%eax
80103d39:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d3d:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d44:	e8 eb fb ff ff       	call   80103934 <outb>
  }
}
80103d49:	c9                   	leave  
80103d4a:	c3                   	ret    

80103d4b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d4b:	55                   	push   %ebp
80103d4c:	89 e5                	mov    %esp,%ebp
80103d4e:	83 ec 08             	sub    $0x8,%esp
80103d51:	8b 55 08             	mov    0x8(%ebp),%edx
80103d54:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d57:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d5b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d5e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d62:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d66:	ee                   	out    %al,(%dx)
}
80103d67:	c9                   	leave  
80103d68:	c3                   	ret    

80103d69 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d69:	55                   	push   %ebp
80103d6a:	89 e5                	mov    %esp,%ebp
80103d6c:	83 ec 0c             	sub    $0xc,%esp
80103d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d72:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d76:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d7a:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103d80:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d84:	0f b6 c0             	movzbl %al,%eax
80103d87:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d8b:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d92:	e8 b4 ff ff ff       	call   80103d4b <outb>
  outb(IO_PIC2+1, mask >> 8);
80103d97:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d9b:	66 c1 e8 08          	shr    $0x8,%ax
80103d9f:	0f b6 c0             	movzbl %al,%eax
80103da2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103da6:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dad:	e8 99 ff ff ff       	call   80103d4b <outb>
}
80103db2:	c9                   	leave  
80103db3:	c3                   	ret    

80103db4 <picenable>:

void
picenable(int irq)
{
80103db4:	55                   	push   %ebp
80103db5:	89 e5                	mov    %esp,%ebp
80103db7:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103dba:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbd:	ba 01 00 00 00       	mov    $0x1,%edx
80103dc2:	89 c1                	mov    %eax,%ecx
80103dc4:	d3 e2                	shl    %cl,%edx
80103dc6:	89 d0                	mov    %edx,%eax
80103dc8:	f7 d0                	not    %eax
80103dca:	89 c2                	mov    %eax,%edx
80103dcc:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103dd3:	21 d0                	and    %edx,%eax
80103dd5:	0f b7 c0             	movzwl %ax,%eax
80103dd8:	89 04 24             	mov    %eax,(%esp)
80103ddb:	e8 89 ff ff ff       	call   80103d69 <picsetmask>
}
80103de0:	c9                   	leave  
80103de1:	c3                   	ret    

80103de2 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103de2:	55                   	push   %ebp
80103de3:	89 e5                	mov    %esp,%ebp
80103de5:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103de8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103def:	00 
80103df0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103df7:	e8 4f ff ff ff       	call   80103d4b <outb>
  outb(IO_PIC2+1, 0xFF);
80103dfc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e03:	00 
80103e04:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e0b:	e8 3b ff ff ff       	call   80103d4b <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e10:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e17:	00 
80103e18:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e1f:	e8 27 ff ff ff       	call   80103d4b <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e24:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e2b:	00 
80103e2c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e33:	e8 13 ff ff ff       	call   80103d4b <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e38:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e3f:	00 
80103e40:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e47:	e8 ff fe ff ff       	call   80103d4b <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e4c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e53:	00 
80103e54:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e5b:	e8 eb fe ff ff       	call   80103d4b <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e60:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e67:	00 
80103e68:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e6f:	e8 d7 fe ff ff       	call   80103d4b <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e74:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e7b:	00 
80103e7c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e83:	e8 c3 fe ff ff       	call   80103d4b <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103e88:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103e8f:	00 
80103e90:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e97:	e8 af fe ff ff       	call   80103d4b <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103e9c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ea3:	00 
80103ea4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eab:	e8 9b fe ff ff       	call   80103d4b <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103eb0:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103eb7:	00 
80103eb8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ebf:	e8 87 fe ff ff       	call   80103d4b <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ec4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ecb:	00 
80103ecc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ed3:	e8 73 fe ff ff       	call   80103d4b <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ed8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103edf:	00 
80103ee0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ee7:	e8 5f fe ff ff       	call   80103d4b <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103eec:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ef3:	00 
80103ef4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103efb:	e8 4b fe ff ff       	call   80103d4b <outb>

  if(irqmask != 0xFFFF)
80103f00:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f07:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f0b:	74 12                	je     80103f1f <picinit+0x13d>
    picsetmask(irqmask);
80103f0d:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f14:	0f b7 c0             	movzwl %ax,%eax
80103f17:	89 04 24             	mov    %eax,(%esp)
80103f1a:	e8 4a fe ff ff       	call   80103d69 <picsetmask>
}
80103f1f:	c9                   	leave  
80103f20:	c3                   	ret    

80103f21 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f21:	55                   	push   %ebp
80103f22:	89 e5                	mov    %esp,%ebp
80103f24:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f3a:	8b 10                	mov    (%eax),%edx
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f41:	e8 e0 cf ff ff       	call   80100f26 <filealloc>
80103f46:	8b 55 08             	mov    0x8(%ebp),%edx
80103f49:	89 02                	mov    %eax,(%edx)
80103f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4e:	8b 00                	mov    (%eax),%eax
80103f50:	85 c0                	test   %eax,%eax
80103f52:	0f 84 c8 00 00 00    	je     80104020 <pipealloc+0xff>
80103f58:	e8 c9 cf ff ff       	call   80100f26 <filealloc>
80103f5d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f60:	89 02                	mov    %eax,(%edx)
80103f62:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f65:	8b 00                	mov    (%eax),%eax
80103f67:	85 c0                	test   %eax,%eax
80103f69:	0f 84 b1 00 00 00    	je     80104020 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f6f:	e8 6e eb ff ff       	call   80102ae2 <kalloc>
80103f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f7b:	75 05                	jne    80103f82 <pipealloc+0x61>
    goto bad;
80103f7d:	e9 9e 00 00 00       	jmp    80104020 <pipealloc+0xff>
  p->readopen = 1;
80103f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f85:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f8c:	00 00 00 
  p->writeopen = 1;
80103f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f92:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f99:	00 00 00 
  p->nwrite = 0;
80103f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fa6:	00 00 00 
  p->nread = 0;
80103fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fac:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fb3:	00 00 00 
  initlock(&p->lock, "pipe");
80103fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb9:	c7 44 24 04 5c 87 10 	movl   $0x8010875c,0x4(%esp)
80103fc0:	80 
80103fc1:	89 04 24             	mov    %eax,(%esp)
80103fc4:	e8 d7 0e 00 00       	call   80104ea0 <initlock>
  (*f0)->type = FD_PIPE;
80103fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcc:	8b 00                	mov    (%eax),%eax
80103fce:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd7:	8b 00                	mov    (%eax),%eax
80103fd9:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe0:	8b 00                	mov    (%eax),%eax
80103fe2:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe9:	8b 00                	mov    (%eax),%eax
80103feb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fee:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff4:	8b 00                	mov    (%eax),%eax
80103ff6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fff:	8b 00                	mov    (%eax),%eax
80104001:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104005:	8b 45 0c             	mov    0xc(%ebp),%eax
80104008:	8b 00                	mov    (%eax),%eax
8010400a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010400e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104011:	8b 00                	mov    (%eax),%eax
80104013:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104016:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104019:	b8 00 00 00 00       	mov    $0x0,%eax
8010401e:	eb 42                	jmp    80104062 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104020:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104024:	74 0b                	je     80104031 <pipealloc+0x110>
    kfree((char*)p);
80104026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104029:	89 04 24             	mov    %eax,(%esp)
8010402c:	e8 18 ea ff ff       	call   80102a49 <kfree>
  if(*f0)
80104031:	8b 45 08             	mov    0x8(%ebp),%eax
80104034:	8b 00                	mov    (%eax),%eax
80104036:	85 c0                	test   %eax,%eax
80104038:	74 0d                	je     80104047 <pipealloc+0x126>
    fileclose(*f0);
8010403a:	8b 45 08             	mov    0x8(%ebp),%eax
8010403d:	8b 00                	mov    (%eax),%eax
8010403f:	89 04 24             	mov    %eax,(%esp)
80104042:	e8 87 cf ff ff       	call   80100fce <fileclose>
  if(*f1)
80104047:	8b 45 0c             	mov    0xc(%ebp),%eax
8010404a:	8b 00                	mov    (%eax),%eax
8010404c:	85 c0                	test   %eax,%eax
8010404e:	74 0d                	je     8010405d <pipealloc+0x13c>
    fileclose(*f1);
80104050:	8b 45 0c             	mov    0xc(%ebp),%eax
80104053:	8b 00                	mov    (%eax),%eax
80104055:	89 04 24             	mov    %eax,(%esp)
80104058:	e8 71 cf ff ff       	call   80100fce <fileclose>
  return -1;
8010405d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104062:	c9                   	leave  
80104063:	c3                   	ret    

80104064 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104064:	55                   	push   %ebp
80104065:	89 e5                	mov    %esp,%ebp
80104067:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
8010406a:	8b 45 08             	mov    0x8(%ebp),%eax
8010406d:	89 04 24             	mov    %eax,(%esp)
80104070:	e8 4c 0e 00 00       	call   80104ec1 <acquire>
  if(writable){
80104075:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104079:	74 1f                	je     8010409a <pipeclose+0x36>
    p->writeopen = 0;
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104085:	00 00 00 
    wakeup(&p->nread);
80104088:	8b 45 08             	mov    0x8(%ebp),%eax
8010408b:	05 34 02 00 00       	add    $0x234,%eax
80104090:	89 04 24             	mov    %eax,(%esp)
80104093:	e8 2e 0c 00 00       	call   80104cc6 <wakeup>
80104098:	eb 1d                	jmp    801040b7 <pipeclose+0x53>
  } else {
    p->readopen = 0;
8010409a:	8b 45 08             	mov    0x8(%ebp),%eax
8010409d:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040a4:	00 00 00 
    wakeup(&p->nwrite);
801040a7:	8b 45 08             	mov    0x8(%ebp),%eax
801040aa:	05 38 02 00 00       	add    $0x238,%eax
801040af:	89 04 24             	mov    %eax,(%esp)
801040b2:	e8 0f 0c 00 00       	call   80104cc6 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040b7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ba:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040c0:	85 c0                	test   %eax,%eax
801040c2:	75 25                	jne    801040e9 <pipeclose+0x85>
801040c4:	8b 45 08             	mov    0x8(%ebp),%eax
801040c7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040cd:	85 c0                	test   %eax,%eax
801040cf:	75 18                	jne    801040e9 <pipeclose+0x85>
    release(&p->lock);
801040d1:	8b 45 08             	mov    0x8(%ebp),%eax
801040d4:	89 04 24             	mov    %eax,(%esp)
801040d7:	e8 47 0e 00 00       	call   80104f23 <release>
    kfree((char*)p);
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	89 04 24             	mov    %eax,(%esp)
801040e2:	e8 62 e9 ff ff       	call   80102a49 <kfree>
801040e7:	eb 0b                	jmp    801040f4 <pipeclose+0x90>
  } else
    release(&p->lock);
801040e9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ec:	89 04 24             	mov    %eax,(%esp)
801040ef:	e8 2f 0e 00 00       	call   80104f23 <release>
}
801040f4:	c9                   	leave  
801040f5:	c3                   	ret    

801040f6 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801040f6:	55                   	push   %ebp
801040f7:	89 e5                	mov    %esp,%ebp
801040f9:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801040fc:	8b 45 08             	mov    0x8(%ebp),%eax
801040ff:	89 04 24             	mov    %eax,(%esp)
80104102:	e8 ba 0d 00 00       	call   80104ec1 <acquire>
  for(i = 0; i < n; i++){
80104107:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010410e:	e9 a6 00 00 00       	jmp    801041b9 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104113:	eb 57                	jmp    8010416c <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80104115:	8b 45 08             	mov    0x8(%ebp),%eax
80104118:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010411e:	85 c0                	test   %eax,%eax
80104120:	74 0d                	je     8010412f <pipewrite+0x39>
80104122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104128:	8b 40 24             	mov    0x24(%eax),%eax
8010412b:	85 c0                	test   %eax,%eax
8010412d:	74 15                	je     80104144 <pipewrite+0x4e>
        release(&p->lock);
8010412f:	8b 45 08             	mov    0x8(%ebp),%eax
80104132:	89 04 24             	mov    %eax,(%esp)
80104135:	e8 e9 0d 00 00       	call   80104f23 <release>
        return -1;
8010413a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010413f:	e9 9f 00 00 00       	jmp    801041e3 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	05 34 02 00 00       	add    $0x234,%eax
8010414c:	89 04 24             	mov    %eax,(%esp)
8010414f:	e8 72 0b 00 00       	call   80104cc6 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104154:	8b 45 08             	mov    0x8(%ebp),%eax
80104157:	8b 55 08             	mov    0x8(%ebp),%edx
8010415a:	81 c2 38 02 00 00    	add    $0x238,%edx
80104160:	89 44 24 04          	mov    %eax,0x4(%esp)
80104164:	89 14 24             	mov    %edx,(%esp)
80104167:	e8 82 0a 00 00       	call   80104bee <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104175:	8b 45 08             	mov    0x8(%ebp),%eax
80104178:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010417e:	05 00 02 00 00       	add    $0x200,%eax
80104183:	39 c2                	cmp    %eax,%edx
80104185:	74 8e                	je     80104115 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104187:	8b 45 08             	mov    0x8(%ebp),%eax
8010418a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104190:	8d 48 01             	lea    0x1(%eax),%ecx
80104193:	8b 55 08             	mov    0x8(%ebp),%edx
80104196:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010419c:	25 ff 01 00 00       	and    $0x1ff,%eax
801041a1:	89 c1                	mov    %eax,%ecx
801041a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801041a9:	01 d0                	add    %edx,%eax
801041ab:	0f b6 10             	movzbl (%eax),%edx
801041ae:	8b 45 08             	mov    0x8(%ebp),%eax
801041b1:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801041bf:	0f 8c 4e ff ff ff    	jl     80104113 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041c5:	8b 45 08             	mov    0x8(%ebp),%eax
801041c8:	05 34 02 00 00       	add    $0x234,%eax
801041cd:	89 04 24             	mov    %eax,(%esp)
801041d0:	e8 f1 0a 00 00       	call   80104cc6 <wakeup>
  release(&p->lock);
801041d5:	8b 45 08             	mov    0x8(%ebp),%eax
801041d8:	89 04 24             	mov    %eax,(%esp)
801041db:	e8 43 0d 00 00       	call   80104f23 <release>
  return n;
801041e0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041e3:	c9                   	leave  
801041e4:	c3                   	ret    

801041e5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041e5:	55                   	push   %ebp
801041e6:	89 e5                	mov    %esp,%ebp
801041e8:	53                   	push   %ebx
801041e9:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041ec:	8b 45 08             	mov    0x8(%ebp),%eax
801041ef:	89 04 24             	mov    %eax,(%esp)
801041f2:	e8 ca 0c 00 00       	call   80104ec1 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041f7:	eb 3a                	jmp    80104233 <piperead+0x4e>
    if(proc->killed){
801041f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041ff:	8b 40 24             	mov    0x24(%eax),%eax
80104202:	85 c0                	test   %eax,%eax
80104204:	74 15                	je     8010421b <piperead+0x36>
      release(&p->lock);
80104206:	8b 45 08             	mov    0x8(%ebp),%eax
80104209:	89 04 24             	mov    %eax,(%esp)
8010420c:	e8 12 0d 00 00       	call   80104f23 <release>
      return -1;
80104211:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104216:	e9 b5 00 00 00       	jmp    801042d0 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010421b:	8b 45 08             	mov    0x8(%ebp),%eax
8010421e:	8b 55 08             	mov    0x8(%ebp),%edx
80104221:	81 c2 34 02 00 00    	add    $0x234,%edx
80104227:	89 44 24 04          	mov    %eax,0x4(%esp)
8010422b:	89 14 24             	mov    %edx,(%esp)
8010422e:	e8 bb 09 00 00       	call   80104bee <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104233:	8b 45 08             	mov    0x8(%ebp),%eax
80104236:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010423c:	8b 45 08             	mov    0x8(%ebp),%eax
8010423f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104245:	39 c2                	cmp    %eax,%edx
80104247:	75 0d                	jne    80104256 <piperead+0x71>
80104249:	8b 45 08             	mov    0x8(%ebp),%eax
8010424c:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104252:	85 c0                	test   %eax,%eax
80104254:	75 a3                	jne    801041f9 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104256:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010425d:	eb 4b                	jmp    801042aa <piperead+0xc5>
    if(p->nread == p->nwrite)
8010425f:	8b 45 08             	mov    0x8(%ebp),%eax
80104262:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104268:	8b 45 08             	mov    0x8(%ebp),%eax
8010426b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104271:	39 c2                	cmp    %eax,%edx
80104273:	75 02                	jne    80104277 <piperead+0x92>
      break;
80104275:	eb 3b                	jmp    801042b2 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104277:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010427a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010427d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104280:	8b 45 08             	mov    0x8(%ebp),%eax
80104283:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104289:	8d 48 01             	lea    0x1(%eax),%ecx
8010428c:	8b 55 08             	mov    0x8(%ebp),%edx
8010428f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104295:	25 ff 01 00 00       	and    $0x1ff,%eax
8010429a:	89 c2                	mov    %eax,%edx
8010429c:	8b 45 08             	mov    0x8(%ebp),%eax
8010429f:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801042a4:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ad:	3b 45 10             	cmp    0x10(%ebp),%eax
801042b0:	7c ad                	jl     8010425f <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042b2:	8b 45 08             	mov    0x8(%ebp),%eax
801042b5:	05 38 02 00 00       	add    $0x238,%eax
801042ba:	89 04 24             	mov    %eax,(%esp)
801042bd:	e8 04 0a 00 00       	call   80104cc6 <wakeup>
  release(&p->lock);
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	89 04 24             	mov    %eax,(%esp)
801042c8:	e8 56 0c 00 00       	call   80104f23 <release>
  return i;
801042cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042d0:	83 c4 24             	add    $0x24,%esp
801042d3:	5b                   	pop    %ebx
801042d4:	5d                   	pop    %ebp
801042d5:	c3                   	ret    

801042d6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042d6:	55                   	push   %ebp
801042d7:	89 e5                	mov    %esp,%ebp
801042d9:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042dc:	9c                   	pushf  
801042dd:	58                   	pop    %eax
801042de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801042e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801042e4:	c9                   	leave  
801042e5:	c3                   	ret    

801042e6 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042e6:	55                   	push   %ebp
801042e7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042e9:	fb                   	sti    
}
801042ea:	5d                   	pop    %ebp
801042eb:	c3                   	ret    

801042ec <cas>:
  asm volatile("movl %0,%%cr3" : : "r" (val));
}

static inline int 
cas(volatile int *addr, int expected, int newval)
{
801042ec:	55                   	push   %ebp
801042ed:	89 e5                	mov    %esp,%ebp
801042ef:	56                   	push   %esi
801042f0:	53                   	push   %ebx
801042f1:	83 ec 10             	sub    $0x10,%esp
	int result = 0;
801042f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	
    asm volatile(
801042fb:	8b 55 08             	mov    0x8(%ebp),%edx
801042fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104301:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104304:	8b 75 08             	mov    0x8(%ebp),%esi
80104307:	89 cb                	mov    %ecx,%ebx
80104309:	f0 0f b1 1a          	lock cmpxchg %ebx,(%edx)
8010430d:	0f 94 c0             	sete   %al
80104310:	0f b6 c0             	movzbl %al,%eax
80104313:	89 45 f4             	mov    %eax,-0xc(%ebp)
        "movzx %%al, %1\n\t" 		// store result of comparison in 'result'
        : "+m" (*addr), "=r" (result)
        : "a" (expected), "b" (newval)
        : "cc");

    return result;
80104316:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104319:	83 c4 10             	add    $0x10,%esp
8010431c:	5b                   	pop    %ebx
8010431d:	5e                   	pop    %esi
8010431e:	5d                   	pop    %ebp
8010431f:	c3                   	ret    

80104320 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104320:	55                   	push   %ebp
80104321:	89 e5                	mov    %esp,%ebp
80104323:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104326:	c7 44 24 04 61 87 10 	movl   $0x80108761,0x4(%esp)
8010432d:	80 
8010432e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104335:	e8 66 0b 00 00       	call   80104ea0 <initlock>
}
8010433a:	c9                   	leave  
8010433b:	c3                   	ret    

8010433c <allocpid>:

int 
allocpid(void) 
{
8010433c:	55                   	push   %ebp
8010433d:	89 e5                	mov    %esp,%ebp
8010433f:	83 ec 1c             	sub    $0x1c,%esp
  //acquire(&ptable.lock);
  //pid = nextpid++;
  //release(&ptable.lock);

  do{
    pid = nextpid;
80104342:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104347:	89 45 fc             	mov    %eax,-0x4(%ebp)
  } while(!cas(&nextpid, pid, pid+1));
8010434a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010434d:	83 c0 01             	add    $0x1,%eax
80104350:	89 44 24 08          	mov    %eax,0x8(%esp)
80104354:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104357:	89 44 24 04          	mov    %eax,0x4(%esp)
8010435b:	c7 04 24 04 b0 10 80 	movl   $0x8010b004,(%esp)
80104362:	e8 85 ff ff ff       	call   801042ec <cas>
80104367:	85 c0                	test   %eax,%eax
80104369:	74 d7                	je     80104342 <allocpid+0x6>
  return pid + 1;
8010436b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010436e:	83 c0 01             	add    $0x1,%eax
}
80104371:	c9                   	leave  
80104372:	c3                   	ret    

80104373 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104373:	55                   	push   %ebp
80104374:	89 e5                	mov    %esp,%ebp
80104376:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  //acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104379:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104380:	eb 49                	jmp    801043cb <allocproc+0x58>
    //if(p->state == UNUSED)
    if(cas(&p->state, UNUSED, EMBRYO))
80104382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104385:	83 c0 0c             	add    $0xc,%eax
80104388:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010438f:	00 
80104390:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104397:	00 
80104398:	89 04 24             	mov    %eax,(%esp)
8010439b:	e8 4c ff ff ff       	call   801042ec <cas>
801043a0:	85 c0                	test   %eax,%eax
801043a2:	74 23                	je     801043c7 <allocproc+0x54>
      goto found;
801043a4:	90                   	nop

found:
  //p->state = EMBRYO;  
  //release(&ptable.lock);

  p->pid = allocpid();
801043a5:	e8 92 ff ff ff       	call   8010433c <allocpid>
801043aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ad:	89 42 10             	mov    %eax,0x10(%edx)

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043b0:	e8 2d e7 ff ff       	call   80102ae2 <kalloc>
801043b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b8:	89 42 08             	mov    %eax,0x8(%edx)
801043bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043be:	8b 40 08             	mov    0x8(%eax),%eax
801043c1:	85 c0                	test   %eax,%eax
801043c3:	75 27                	jne    801043ec <allocproc+0x79>
801043c5:	eb 14                	jmp    801043db <allocproc+0x68>
{
  struct proc *p;
  char *sp;

  //acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043c7:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801043cb:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
801043d2:	72 ae                	jb     80104382 <allocproc+0xf>
    //if(p->state == UNUSED)
    if(cas(&p->state, UNUSED, EMBRYO))
      goto found;
  //release(&ptable.lock);
  return 0;
801043d4:	b8 00 00 00 00       	mov    $0x0,%eax
801043d9:	eb 76                	jmp    80104451 <allocproc+0xde>

  p->pid = allocpid();

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043de:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043e5:	b8 00 00 00 00       	mov    $0x0,%eax
801043ea:	eb 65                	jmp    80104451 <allocproc+0xde>
  }
  sp = p->kstack + KSTACKSIZE;
801043ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ef:	8b 40 08             	mov    0x8(%eax),%eax
801043f2:	05 00 10 00 00       	add    $0x1000,%eax
801043f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043fa:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104401:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104404:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104407:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010440b:	ba 29 65 10 80       	mov    $0x80106529,%edx
80104410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104413:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104415:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010441f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104425:	8b 40 1c             	mov    0x1c(%eax),%eax
80104428:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010442f:	00 
80104430:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104437:	00 
80104438:	89 04 24             	mov    %eax,(%esp)
8010443b:	e8 d5 0c 00 00       	call   80105115 <memset>
  p->context->eip = (uint)forkret;
80104440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104443:	8b 40 1c             	mov    0x1c(%eax),%eax
80104446:	ba c2 4b 10 80       	mov    $0x80104bc2,%edx
8010444b:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010444e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104451:	c9                   	leave  
80104452:	c3                   	ret    

80104453 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104453:	55                   	push   %ebp
80104454:	89 e5                	mov    %esp,%ebp
80104456:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104459:	e8 15 ff ff ff       	call   80104373 <allocproc>
8010445e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
80104469:	e8 af 37 00 00       	call   80107c1d <setupkvm>
8010446e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104471:	89 42 04             	mov    %eax,0x4(%edx)
80104474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104477:	8b 40 04             	mov    0x4(%eax),%eax
8010447a:	85 c0                	test   %eax,%eax
8010447c:	75 0c                	jne    8010448a <userinit+0x37>
    panic("userinit: out of memory?");
8010447e:	c7 04 24 68 87 10 80 	movl   $0x80108768,(%esp)
80104485:	e8 b0 c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010448a:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010448f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104492:	8b 40 04             	mov    0x4(%eax),%eax
80104495:	89 54 24 08          	mov    %edx,0x8(%esp)
80104499:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044a0:	80 
801044a1:	89 04 24             	mov    %eax,(%esp)
801044a4:	e8 cc 39 00 00       	call   80107e75 <inituvm>
  p->sz = PGSIZE;
801044a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ac:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b5:	8b 40 18             	mov    0x18(%eax),%eax
801044b8:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044bf:	00 
801044c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044c7:	00 
801044c8:	89 04 24             	mov    %eax,(%esp)
801044cb:	e8 45 0c 00 00       	call   80105115 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d3:	8b 40 18             	mov    0x18(%eax),%eax
801044d6:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044df:	8b 40 18             	mov    0x18(%eax),%eax
801044e2:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044eb:	8b 40 18             	mov    0x18(%eax),%eax
801044ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f1:	8b 52 18             	mov    0x18(%edx),%edx
801044f4:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044f8:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ff:	8b 40 18             	mov    0x18(%eax),%eax
80104502:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104505:	8b 52 18             	mov    0x18(%edx),%edx
80104508:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010450c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104513:	8b 40 18             	mov    0x18(%eax),%eax
80104516:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010451d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104520:	8b 40 18             	mov    0x18(%eax),%eax
80104523:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010452a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452d:	8b 40 18             	mov    0x18(%eax),%eax
80104530:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453a:	83 c0 6c             	add    $0x6c,%eax
8010453d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104544:	00 
80104545:	c7 44 24 04 81 87 10 	movl   $0x80108781,0x4(%esp)
8010454c:	80 
8010454d:	89 04 24             	mov    %eax,(%esp)
80104550:	e8 e0 0d 00 00       	call   80105335 <safestrcpy>
  p->cwd = namei("/");
80104555:	c7 04 24 8a 87 10 80 	movl   $0x8010878a,(%esp)
8010455c:	e8 a5 de ff ff       	call   80102406 <namei>
80104561:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104564:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104571:	c9                   	leave  
80104572:	c3                   	ret    

80104573 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104573:	55                   	push   %ebp
80104574:	89 e5                	mov    %esp,%ebp
80104576:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104579:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010457f:	8b 00                	mov    (%eax),%eax
80104581:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104584:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104588:	7e 34                	jle    801045be <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010458a:	8b 55 08             	mov    0x8(%ebp),%edx
8010458d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104590:	01 c2                	add    %eax,%edx
80104592:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104598:	8b 40 04             	mov    0x4(%eax),%eax
8010459b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010459f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801045a6:	89 04 24             	mov    %eax,(%esp)
801045a9:	e8 3d 3a 00 00       	call   80107feb <allocuvm>
801045ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045b5:	75 41                	jne    801045f8 <growproc+0x85>
      return -1;
801045b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045bc:	eb 58                	jmp    80104616 <growproc+0xa3>
  } else if(n < 0){
801045be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045c2:	79 34                	jns    801045f8 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045c4:	8b 55 08             	mov    0x8(%ebp),%edx
801045c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ca:	01 c2                	add    %eax,%edx
801045cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d2:	8b 40 04             	mov    0x4(%eax),%eax
801045d5:	89 54 24 08          	mov    %edx,0x8(%esp)
801045d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801045e0:	89 04 24             	mov    %eax,(%esp)
801045e3:	e8 dd 3a 00 00       	call   801080c5 <deallocuvm>
801045e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045ef:	75 07                	jne    801045f8 <growproc+0x85>
      return -1;
801045f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045f6:	eb 1e                	jmp    80104616 <growproc+0xa3>
  }
  proc->sz = sz;
801045f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104601:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104603:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104609:	89 04 24             	mov    %eax,(%esp)
8010460c:	e8 fd 36 00 00       	call   80107d0e <switchuvm>
  return 0;
80104611:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104616:	c9                   	leave  
80104617:	c3                   	ret    

80104618 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104618:	55                   	push   %ebp
80104619:	89 e5                	mov    %esp,%ebp
8010461b:	57                   	push   %edi
8010461c:	56                   	push   %esi
8010461d:	53                   	push   %ebx
8010461e:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104621:	e8 4d fd ff ff       	call   80104373 <allocproc>
80104626:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104629:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010462d:	75 0a                	jne    80104639 <fork+0x21>
    return -1;
8010462f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104634:	e9 52 01 00 00       	jmp    8010478b <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104639:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463f:	8b 10                	mov    (%eax),%edx
80104641:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104647:	8b 40 04             	mov    0x4(%eax),%eax
8010464a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010464e:	89 04 24             	mov    %eax,(%esp)
80104651:	e8 0b 3c 00 00       	call   80108261 <copyuvm>
80104656:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104659:	89 42 04             	mov    %eax,0x4(%edx)
8010465c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010465f:	8b 40 04             	mov    0x4(%eax),%eax
80104662:	85 c0                	test   %eax,%eax
80104664:	75 2c                	jne    80104692 <fork+0x7a>
    kfree(np->kstack);
80104666:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104669:	8b 40 08             	mov    0x8(%eax),%eax
8010466c:	89 04 24             	mov    %eax,(%esp)
8010466f:	e8 d5 e3 ff ff       	call   80102a49 <kfree>
    np->kstack = 0;
80104674:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104677:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010467e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104681:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104688:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010468d:	e9 f9 00 00 00       	jmp    8010478b <fork+0x173>
  }
  np->sz = proc->sz;
80104692:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104698:	8b 10                	mov    (%eax),%edx
8010469a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469d:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010469f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a9:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046af:	8b 50 18             	mov    0x18(%eax),%edx
801046b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b8:	8b 40 18             	mov    0x18(%eax),%eax
801046bb:	89 c3                	mov    %eax,%ebx
801046bd:	b8 13 00 00 00       	mov    $0x13,%eax
801046c2:	89 d7                	mov    %edx,%edi
801046c4:	89 de                	mov    %ebx,%esi
801046c6:	89 c1                	mov    %eax,%ecx
801046c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046cd:	8b 40 18             	mov    0x18(%eax),%eax
801046d0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046de:	eb 3d                	jmp    8010471d <fork+0x105>
    if(proc->ofile[i])
801046e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046e9:	83 c2 08             	add    $0x8,%edx
801046ec:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046f0:	85 c0                	test   %eax,%eax
801046f2:	74 25                	je     80104719 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801046f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046fd:	83 c2 08             	add    $0x8,%edx
80104700:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104704:	89 04 24             	mov    %eax,(%esp)
80104707:	e8 7a c8 ff ff       	call   80100f86 <filedup>
8010470c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010470f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104712:	83 c1 08             	add    $0x8,%ecx
80104715:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104719:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010471d:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104721:	7e bd                	jle    801046e0 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104723:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104729:	8b 40 68             	mov    0x68(%eax),%eax
8010472c:	89 04 24             	mov    %eax,(%esp)
8010472f:	e8 f5 d0 ff ff       	call   80101829 <idup>
80104734:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104737:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010473a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104740:	8d 50 6c             	lea    0x6c(%eax),%edx
80104743:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104746:	83 c0 6c             	add    $0x6c,%eax
80104749:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104750:	00 
80104751:	89 54 24 04          	mov    %edx,0x4(%esp)
80104755:	89 04 24             	mov    %eax,(%esp)
80104758:	e8 d8 0b 00 00       	call   80105335 <safestrcpy>
 
  pid = np->pid;
8010475d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104760:	8b 40 10             	mov    0x10(%eax),%eax
80104763:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104766:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
8010476d:	e8 4f 07 00 00       	call   80104ec1 <acquire>
  np->state = RUNNABLE;
80104772:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104775:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
8010477c:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104783:	e8 9b 07 00 00       	call   80104f23 <release>
  
  return pid;
80104788:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010478b:	83 c4 2c             	add    $0x2c,%esp
8010478e:	5b                   	pop    %ebx
8010478f:	5e                   	pop    %esi
80104790:	5f                   	pop    %edi
80104791:	5d                   	pop    %ebp
80104792:	c3                   	ret    

80104793 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104793:	55                   	push   %ebp
80104794:	89 e5                	mov    %esp,%ebp
80104796:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104799:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047a0:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047a5:	39 c2                	cmp    %eax,%edx
801047a7:	75 0c                	jne    801047b5 <exit+0x22>
    panic("init exiting");
801047a9:	c7 04 24 8c 87 10 80 	movl   $0x8010878c,(%esp)
801047b0:	e8 85 bd ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047bc:	eb 44                	jmp    80104802 <exit+0x6f>
    if(proc->ofile[fd]){
801047be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047c7:	83 c2 08             	add    $0x8,%edx
801047ca:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047ce:	85 c0                	test   %eax,%eax
801047d0:	74 2c                	je     801047fe <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047db:	83 c2 08             	add    $0x8,%edx
801047de:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047e2:	89 04 24             	mov    %eax,(%esp)
801047e5:	e8 e4 c7 ff ff       	call   80100fce <fileclose>
      proc->ofile[fd] = 0;
801047ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047f3:	83 c2 08             	add    $0x8,%edx
801047f6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801047fd:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047fe:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104802:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104806:	7e b6                	jle    801047be <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104808:	e8 03 ec ff ff       	call   80103410 <begin_op>
  iput(proc->cwd);
8010480d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104813:	8b 40 68             	mov    0x68(%eax),%eax
80104816:	89 04 24             	mov    %eax,(%esp)
80104819:	e8 f0 d1 ff ff       	call   80101a0e <iput>
  end_op();
8010481e:	e8 71 ec ff ff       	call   80103494 <end_op>
  proc->cwd = 0;
80104823:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104829:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104830:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104837:	e8 85 06 00 00       	call   80104ec1 <acquire>

  proc->state = ZOMBIE;
8010483c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104842:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104849:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484f:	8b 40 14             	mov    0x14(%eax),%eax
80104852:	89 04 24             	mov    %eax,(%esp)
80104855:	e8 22 04 00 00       	call   80104c7c <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010485a:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104861:	eb 38                	jmp    8010489b <exit+0x108>
    if(p->parent == proc){
80104863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104866:	8b 50 14             	mov    0x14(%eax),%edx
80104869:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486f:	39 c2                	cmp    %eax,%edx
80104871:	75 24                	jne    80104897 <exit+0x104>
      p->parent = initproc;
80104873:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487c:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010487f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104882:	8b 40 0c             	mov    0xc(%eax),%eax
80104885:	83 f8 05             	cmp    $0x5,%eax
80104888:	75 0d                	jne    80104897 <exit+0x104>
        wakeup1(initproc);
8010488a:	a1 48 b6 10 80       	mov    0x8010b648,%eax
8010488f:	89 04 24             	mov    %eax,(%esp)
80104892:	e8 e5 03 00 00       	call   80104c7c <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104897:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010489b:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
801048a2:	72 bf                	jb     80104863 <exit+0xd0>
    }
  }

  // Jump into the scheduler, never to return.
  
  sched();
801048a4:	e8 35 02 00 00       	call   80104ade <sched>
  panic("zombie exit");
801048a9:	c7 04 24 99 87 10 80 	movl   $0x80108799,(%esp)
801048b0:	e8 85 bc ff ff       	call   8010053a <panic>

801048b5 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048b5:	55                   	push   %ebp
801048b6:	89 e5                	mov    %esp,%ebp
801048b8:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801048bb:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801048c2:	e8 fa 05 00 00       	call   80104ec1 <acquire>
  for(;;){
    proc->chan = (int)proc;
801048c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048cd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048d4:	89 50 20             	mov    %edx,0x20(%eax)
    proc->state = SLEEPING;    
801048d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048dd:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
    // Scan through table looking for zombie children.
    havekids = 0;
801048e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048eb:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801048f2:	e9 81 00 00 00       	jmp    80104978 <wait+0xc3>
      if(p->parent != proc)
801048f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fa:	8b 50 14             	mov    0x14(%eax),%edx
801048fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104903:	39 c2                	cmp    %eax,%edx
80104905:	74 02                	je     80104909 <wait+0x54>
        continue;
80104907:	eb 6b                	jmp    80104974 <wait+0xbf>
      havekids = 1;
80104909:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104913:	8b 40 0c             	mov    0xc(%eax),%eax
80104916:	83 f8 05             	cmp    $0x5,%eax
80104919:	75 59                	jne    80104974 <wait+0xbf>
        // Found one.
        pid = p->pid;
8010491b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491e:	8b 40 10             	mov    0x10(%eax),%eax
80104921:	89 45 ec             	mov    %eax,-0x14(%ebp)
        p->state = UNUSED;
80104924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104927:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010492e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104931:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104945:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)

        proc->chan = 0;
80104949:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494f:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
        proc->state = RUNNING;
80104956:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010495c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        release(&ptable.lock);
80104963:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
8010496a:	e8 b4 05 00 00       	call   80104f23 <release>
        return pid;
8010496f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104972:	eb 5b                	jmp    801049cf <wait+0x11a>
  for(;;){
    proc->chan = (int)proc;
    proc->state = SLEEPING;    
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104974:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104978:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
8010497f:	0f 82 72 ff ff ff    	jb     801048f7 <wait+0x42>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104985:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104989:	74 0d                	je     80104998 <wait+0xe3>
8010498b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104991:	8b 40 24             	mov    0x24(%eax),%eax
80104994:	85 c0                	test   %eax,%eax
80104996:	74 2d                	je     801049c5 <wait+0x110>
      proc->chan = 0;
80104998:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010499e:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      proc->state = RUNNING;      
801049a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ab:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      release(&ptable.lock);
801049b2:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049b9:	e8 65 05 00 00       	call   80104f23 <release>
      return -1;
801049be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049c3:	eb 0a                	jmp    801049cf <wait+0x11a>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sched();
801049c5:	e8 14 01 00 00       	call   80104ade <sched>
  }
801049ca:	e9 f8 fe ff ff       	jmp    801048c7 <wait+0x12>
}
801049cf:	c9                   	leave  
801049d0:	c3                   	ret    

801049d1 <freeproc>:

void 
freeproc(struct proc *p)
{
801049d1:	55                   	push   %ebp
801049d2:	89 e5                	mov    %esp,%ebp
801049d4:	83 ec 18             	sub    $0x18,%esp
  if (!p || p->state != ZOMBIE)
801049d7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801049db:	74 0b                	je     801049e8 <freeproc+0x17>
801049dd:	8b 45 08             	mov    0x8(%ebp),%eax
801049e0:	8b 40 0c             	mov    0xc(%eax),%eax
801049e3:	83 f8 05             	cmp    $0x5,%eax
801049e6:	74 0c                	je     801049f4 <freeproc+0x23>
    panic("freeproc not zombie");
801049e8:	c7 04 24 a5 87 10 80 	movl   $0x801087a5,(%esp)
801049ef:	e8 46 bb ff ff       	call   8010053a <panic>
  kfree(p->kstack);
801049f4:	8b 45 08             	mov    0x8(%ebp),%eax
801049f7:	8b 40 08             	mov    0x8(%eax),%eax
801049fa:	89 04 24             	mov    %eax,(%esp)
801049fd:	e8 47 e0 ff ff       	call   80102a49 <kfree>
  p->kstack = 0;
80104a02:	8b 45 08             	mov    0x8(%ebp),%eax
80104a05:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  freevm(p->pgdir);
80104a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0f:	8b 40 04             	mov    0x4(%eax),%eax
80104a12:	89 04 24             	mov    %eax,(%esp)
80104a15:	e8 67 37 00 00       	call   80108181 <freevm>
  p->killed = 0;
80104a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
  p->chan = 0;
80104a24:	8b 45 08             	mov    0x8(%ebp),%eax
80104a27:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
}
80104a2e:	c9                   	leave  
80104a2f:	c3                   	ret    

80104a30 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a30:	55                   	push   %ebp
80104a31:	89 e5                	mov    %esp,%ebp
80104a33:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a36:	e8 ab f8 ff ff       	call   801042e6 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a3b:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a42:	e8 7a 04 00 00       	call   80104ec1 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a47:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a4e:	eb 74                	jmp    80104ac4 <scheduler+0x94>
      if(p->state != RUNNABLE)
80104a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a53:	8b 40 0c             	mov    0xc(%eax),%eax
80104a56:	83 f8 03             	cmp    $0x3,%eax
80104a59:	74 02                	je     80104a5d <scheduler+0x2d>
        continue;
80104a5b:	eb 63                	jmp    80104ac0 <scheduler+0x90>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a60:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a69:	89 04 24             	mov    %eax,(%esp)
80104a6c:	e8 9d 32 00 00       	call   80107d0e <switchuvm>
      p->state = RUNNING;
80104a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a74:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104a7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a81:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a84:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104a8b:	83 c2 04             	add    $0x4,%edx
80104a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a92:	89 14 24             	mov    %edx,(%esp)
80104a95:	e8 0c 09 00 00       	call   801053a6 <swtch>
      switchkvm();
80104a9a:	e8 52 32 00 00       	call   80107cf1 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104a9f:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104aa6:	00 00 00 00 
      if (p->state == ZOMBIE)
80104aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aad:	8b 40 0c             	mov    0xc(%eax),%eax
80104ab0:	83 f8 05             	cmp    $0x5,%eax
80104ab3:	75 0b                	jne    80104ac0 <scheduler+0x90>
        freeproc(p);
80104ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab8:	89 04 24             	mov    %eax,(%esp)
80104abb:	e8 11 ff ff ff       	call   801049d1 <freeproc>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ac0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ac4:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104acb:	72 83                	jb     80104a50 <scheduler+0x20>
      // It should have changed its p->state before coming back.
      proc = 0;
      if (p->state == ZOMBIE)
        freeproc(p);
    }
    release(&ptable.lock);
80104acd:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ad4:	e8 4a 04 00 00       	call   80104f23 <release>

  }
80104ad9:	e9 58 ff ff ff       	jmp    80104a36 <scheduler+0x6>

80104ade <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ade:	55                   	push   %ebp
80104adf:	89 e5                	mov    %esp,%ebp
80104ae1:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104ae4:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104aeb:	e8 fb 04 00 00       	call   80104feb <holding>
80104af0:	85 c0                	test   %eax,%eax
80104af2:	75 0c                	jne    80104b00 <sched+0x22>
    panic("sched ptable.lock");
80104af4:	c7 04 24 b9 87 10 80 	movl   $0x801087b9,(%esp)
80104afb:	e8 3a ba ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104b00:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b06:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104b0c:	83 f8 01             	cmp    $0x1,%eax
80104b0f:	74 0c                	je     80104b1d <sched+0x3f>
    panic("sched locks");
80104b11:	c7 04 24 cb 87 10 80 	movl   $0x801087cb,(%esp)
80104b18:	e8 1d ba ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104b1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b23:	8b 40 0c             	mov    0xc(%eax),%eax
80104b26:	83 f8 04             	cmp    $0x4,%eax
80104b29:	75 0c                	jne    80104b37 <sched+0x59>
    panic("sched running");
80104b2b:	c7 04 24 d7 87 10 80 	movl   $0x801087d7,(%esp)
80104b32:	e8 03 ba ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104b37:	e8 9a f7 ff ff       	call   801042d6 <readeflags>
80104b3c:	25 00 02 00 00       	and    $0x200,%eax
80104b41:	85 c0                	test   %eax,%eax
80104b43:	74 0c                	je     80104b51 <sched+0x73>
    panic("sched interruptible");
80104b45:	c7 04 24 e5 87 10 80 	movl   $0x801087e5,(%esp)
80104b4c:	e8 e9 b9 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104b51:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b57:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104b60:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b66:	8b 40 04             	mov    0x4(%eax),%eax
80104b69:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b70:	83 c2 1c             	add    $0x1c,%edx
80104b73:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b77:	89 14 24             	mov    %edx,(%esp)
80104b7a:	e8 27 08 00 00       	call   801053a6 <swtch>
  cpu->intena = intena;
80104b7f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b88:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104b8e:	c9                   	leave  
80104b8f:	c3                   	ret    

80104b90 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b90:	55                   	push   %ebp
80104b91:	89 e5                	mov    %esp,%ebp
80104b93:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b96:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b9d:	e8 1f 03 00 00       	call   80104ec1 <acquire>
  proc->state = RUNNABLE;
80104ba2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104baf:	e8 2a ff ff ff       	call   80104ade <sched>
  release(&ptable.lock);
80104bb4:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104bbb:	e8 63 03 00 00       	call   80104f23 <release>
}
80104bc0:	c9                   	leave  
80104bc1:	c3                   	ret    

80104bc2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bc2:	55                   	push   %ebp
80104bc3:	89 e5                	mov    %esp,%ebp
80104bc5:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bc8:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104bcf:	e8 4f 03 00 00       	call   80104f23 <release>

  if (first) {
80104bd4:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104bd9:	85 c0                	test   %eax,%eax
80104bdb:	74 0f                	je     80104bec <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104bdd:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104be4:	00 00 00 
    initlog();
80104be7:	e8 16 e6 ff ff       	call   80103202 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104bec:	c9                   	leave  
80104bed:	c3                   	ret    

80104bee <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bee:	55                   	push   %ebp
80104bef:	89 e5                	mov    %esp,%ebp
80104bf1:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104bf4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bfa:	85 c0                	test   %eax,%eax
80104bfc:	75 0c                	jne    80104c0a <sleep+0x1c>
    panic("sleep");
80104bfe:	c7 04 24 f9 87 10 80 	movl   $0x801087f9,(%esp)
80104c05:	e8 30 b9 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104c0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c0e:	75 0c                	jne    80104c1c <sleep+0x2e>
    panic("sleep without lk");
80104c10:	c7 04 24 ff 87 10 80 	movl   $0x801087ff,(%esp)
80104c17:	e8 1e b9 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c1c:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104c23:	74 17                	je     80104c3c <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c25:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c2c:	e8 90 02 00 00       	call   80104ec1 <acquire>
    release(lk);
80104c31:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c34:	89 04 24             	mov    %eax,(%esp)
80104c37:	e8 e7 02 00 00       	call   80104f23 <release>
  }

  // Go to sleep.
  proc->chan = (int)chan;
80104c3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c42:	8b 55 08             	mov    0x8(%ebp),%edx
80104c45:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104c48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c4e:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)


  sched();
80104c55:	e8 84 fe ff ff       	call   80104ade <sched>

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c5a:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104c61:	74 17                	je     80104c7a <sleep+0x8c>
    release(&ptable.lock);
80104c63:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c6a:	e8 b4 02 00 00       	call   80104f23 <release>
    acquire(lk);
80104c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c72:	89 04 24             	mov    %eax,(%esp)
80104c75:	e8 47 02 00 00       	call   80104ec1 <acquire>
  }
}
80104c7a:	c9                   	leave  
80104c7b:	c3                   	ret    

80104c7c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c7c:	55                   	push   %ebp
80104c7d:	89 e5                	mov    %esp,%ebp
80104c7f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c82:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104c89:	eb 30                	jmp    80104cbb <wakeup1+0x3f>
    if(p->state == SLEEPING && p->chan == (int)chan){
80104c8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c8e:	8b 40 0c             	mov    0xc(%eax),%eax
80104c91:	83 f8 02             	cmp    $0x2,%eax
80104c94:	75 21                	jne    80104cb7 <wakeup1+0x3b>
80104c96:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c99:	8b 50 20             	mov    0x20(%eax),%edx
80104c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9f:	39 c2                	cmp    %eax,%edx
80104ca1:	75 14                	jne    80104cb7 <wakeup1+0x3b>
      // Tidy up.
      p->chan = 0;
80104ca3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ca6:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      p->state = RUNNABLE;
80104cad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cb0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cb7:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104cbb:	81 7d fc 94 48 11 80 	cmpl   $0x80114894,-0x4(%ebp)
80104cc2:	72 c7                	jb     80104c8b <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == (int)chan){
      // Tidy up.
      p->chan = 0;
      p->state = RUNNABLE;
    }
}
80104cc4:	c9                   	leave  
80104cc5:	c3                   	ret    

80104cc6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104cc6:	55                   	push   %ebp
80104cc7:	89 e5                	mov    %esp,%ebp
80104cc9:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104ccc:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104cd3:	e8 e9 01 00 00       	call   80104ec1 <acquire>
  wakeup1(chan);
80104cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdb:	89 04 24             	mov    %eax,(%esp)
80104cde:	e8 99 ff ff ff       	call   80104c7c <wakeup1>
  release(&ptable.lock);
80104ce3:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104cea:	e8 34 02 00 00       	call   80104f23 <release>
}
80104cef:	c9                   	leave  
80104cf0:	c3                   	ret    

80104cf1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104cf1:	55                   	push   %ebp
80104cf2:	89 e5                	mov    %esp,%ebp
80104cf4:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104cf7:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104cfe:	e8 be 01 00 00       	call   80104ec1 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d03:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104d0a:	eb 4d                	jmp    80104d59 <kill+0x68>
    if(p->pid == pid){
80104d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0f:	8b 40 10             	mov    0x10(%eax),%eax
80104d12:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d15:	75 32                	jne    80104d49 <kill+0x58>
      p->killed = 1;
80104d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d1a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d24:	8b 40 0c             	mov    0xc(%eax),%eax
80104d27:	83 f8 02             	cmp    $0x2,%eax
80104d2a:	75 0a                	jne    80104d36 <kill+0x45>
        p->state = RUNNABLE;
80104d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      
      release(&ptable.lock);
80104d36:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d3d:	e8 e1 01 00 00       	call   80104f23 <release>
      return 0;
80104d42:	b8 00 00 00 00       	mov    $0x0,%eax
80104d47:	eb 1e                	jmp    80104d67 <kill+0x76>

      //int pid_test = p->pid;
      //cas(&pid_test, pid_test, 1);
      //cprintf("res = %d,    pid = %d", res, pid_test);
  
    release(&ptable.lock);
80104d49:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d50:	e8 ce 01 00 00       	call   80104f23 <release>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d55:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104d59:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104d60:	72 aa                	jb     80104d0c <kill+0x1b>
      //cprintf("res = %d,    pid = %d", res, pid_test);
  
    release(&ptable.lock);
  }

  return -1;
80104d62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d67:	c9                   	leave  
80104d68:	c3                   	ret    

80104d69 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d69:	55                   	push   %ebp
80104d6a:	89 e5                	mov    %esp,%ebp
80104d6c:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d6f:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104d76:	e9 e0 00 00 00       	jmp    80104e5b <procdump+0xf2>
    if(p->state == UNUSED)
80104d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d7e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d81:	85 c0                	test   %eax,%eax
80104d83:	75 05                	jne    80104d8a <procdump+0x21>
      continue;
80104d85:	e9 cd 00 00 00       	jmp    80104e57 <procdump+0xee>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d8d:	8b 40 0c             	mov    0xc(%eax),%eax
80104d90:	85 c0                	test   %eax,%eax
80104d92:	78 2e                	js     80104dc2 <procdump+0x59>
80104d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d97:	8b 40 0c             	mov    0xc(%eax),%eax
80104d9a:	83 f8 05             	cmp    $0x5,%eax
80104d9d:	77 23                	ja     80104dc2 <procdump+0x59>
80104d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da2:	8b 40 0c             	mov    0xc(%eax),%eax
80104da5:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104dac:	85 c0                	test   %eax,%eax
80104dae:	74 12                	je     80104dc2 <procdump+0x59>
      state = states[p->state];
80104db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db3:	8b 40 0c             	mov    0xc(%eax),%eax
80104db6:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104dbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104dc0:	eb 07                	jmp    80104dc9 <procdump+0x60>
    else
      state = "???";
80104dc2:	c7 45 ec 10 88 10 80 	movl   $0x80108810,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dcc:	8d 50 6c             	lea    0x6c(%eax),%edx
80104dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd2:	8b 40 10             	mov    0x10(%eax),%eax
80104dd5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104dd9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104ddc:	89 54 24 08          	mov    %edx,0x8(%esp)
80104de0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104de4:	c7 04 24 14 88 10 80 	movl   $0x80108814,(%esp)
80104deb:	e8 b0 b5 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104df3:	8b 40 0c             	mov    0xc(%eax),%eax
80104df6:	83 f8 02             	cmp    $0x2,%eax
80104df9:	75 50                	jne    80104e4b <procdump+0xe2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dfe:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e01:	8b 40 0c             	mov    0xc(%eax),%eax
80104e04:	83 c0 08             	add    $0x8,%eax
80104e07:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104e0a:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e0e:	89 04 24             	mov    %eax,(%esp)
80104e11:	e8 5c 01 00 00       	call   80104f72 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104e16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e1d:	eb 1b                	jmp    80104e3a <procdump+0xd1>
        cprintf(" %p", pc[i]);
80104e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e22:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e26:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e2a:	c7 04 24 1d 88 10 80 	movl   $0x8010881d,(%esp)
80104e31:	e8 6a b5 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e36:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e3a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e3e:	7f 0b                	jg     80104e4b <procdump+0xe2>
80104e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e43:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e47:	85 c0                	test   %eax,%eax
80104e49:	75 d4                	jne    80104e1f <procdump+0xb6>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e4b:	c7 04 24 21 88 10 80 	movl   $0x80108821,(%esp)
80104e52:	e8 49 b5 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e57:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104e5b:	81 7d f0 94 48 11 80 	cmpl   $0x80114894,-0x10(%ebp)
80104e62:	0f 82 13 ff ff ff    	jb     80104d7b <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e68:	c9                   	leave  
80104e69:	c3                   	ret    

80104e6a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104e6a:	55                   	push   %ebp
80104e6b:	89 e5                	mov    %esp,%ebp
80104e6d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104e70:	9c                   	pushf  
80104e71:	58                   	pop    %eax
80104e72:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104e75:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e78:	c9                   	leave  
80104e79:	c3                   	ret    

80104e7a <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104e7a:	55                   	push   %ebp
80104e7b:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104e7d:	fa                   	cli    
}
80104e7e:	5d                   	pop    %ebp
80104e7f:	c3                   	ret    

80104e80 <sti>:

static inline void
sti(void)
{
80104e80:	55                   	push   %ebp
80104e81:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104e83:	fb                   	sti    
}
80104e84:	5d                   	pop    %ebp
80104e85:	c3                   	ret    

80104e86 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104e86:	55                   	push   %ebp
80104e87:	89 e5                	mov    %esp,%ebp
80104e89:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e8c:	8b 55 08             	mov    0x8(%ebp),%edx
80104e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e92:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e95:	f0 87 02             	lock xchg %eax,(%edx)
80104e98:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104e9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e9e:	c9                   	leave  
80104e9f:	c3                   	ret    

80104ea0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104ea0:	55                   	push   %ebp
80104ea1:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ea9:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104eac:	8b 45 08             	mov    0x8(%ebp),%eax
80104eaf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ebf:	5d                   	pop    %ebp
80104ec0:	c3                   	ret    

80104ec1 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104ec1:	55                   	push   %ebp
80104ec2:	89 e5                	mov    %esp,%ebp
80104ec4:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ec7:	e8 49 01 00 00       	call   80105015 <pushcli>
  if(holding(lk))
80104ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecf:	89 04 24             	mov    %eax,(%esp)
80104ed2:	e8 14 01 00 00       	call   80104feb <holding>
80104ed7:	85 c0                	test   %eax,%eax
80104ed9:	74 0c                	je     80104ee7 <acquire+0x26>
    panic("acquire");
80104edb:	c7 04 24 4d 88 10 80 	movl   $0x8010884d,(%esp)
80104ee2:	e8 53 b6 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104ee7:	90                   	nop
80104ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80104eeb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104ef2:	00 
80104ef3:	89 04 24             	mov    %eax,(%esp)
80104ef6:	e8 8b ff ff ff       	call   80104e86 <xchg>
80104efb:	85 c0                	test   %eax,%eax
80104efd:	75 e9                	jne    80104ee8 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104eff:	8b 45 08             	mov    0x8(%ebp),%eax
80104f02:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104f09:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0f:	83 c0 0c             	add    $0xc,%eax
80104f12:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f16:	8d 45 08             	lea    0x8(%ebp),%eax
80104f19:	89 04 24             	mov    %eax,(%esp)
80104f1c:	e8 51 00 00 00       	call   80104f72 <getcallerpcs>
}
80104f21:	c9                   	leave  
80104f22:	c3                   	ret    

80104f23 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104f23:	55                   	push   %ebp
80104f24:	89 e5                	mov    %esp,%ebp
80104f26:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104f29:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2c:	89 04 24             	mov    %eax,(%esp)
80104f2f:	e8 b7 00 00 00       	call   80104feb <holding>
80104f34:	85 c0                	test   %eax,%eax
80104f36:	75 0c                	jne    80104f44 <release+0x21>
    panic("release");
80104f38:	c7 04 24 55 88 10 80 	movl   $0x80108855,(%esp)
80104f3f:	e8 f6 b5 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80104f44:	8b 45 08             	mov    0x8(%ebp),%eax
80104f47:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f51:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104f58:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104f62:	00 
80104f63:	89 04 24             	mov    %eax,(%esp)
80104f66:	e8 1b ff ff ff       	call   80104e86 <xchg>

  popcli();
80104f6b:	e8 e9 00 00 00       	call   80105059 <popcli>
}
80104f70:	c9                   	leave  
80104f71:	c3                   	ret    

80104f72 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104f72:	55                   	push   %ebp
80104f73:	89 e5                	mov    %esp,%ebp
80104f75:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104f78:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7b:	83 e8 08             	sub    $0x8,%eax
80104f7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104f81:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104f88:	eb 38                	jmp    80104fc2 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104f8a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104f8e:	74 38                	je     80104fc8 <getcallerpcs+0x56>
80104f90:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104f97:	76 2f                	jbe    80104fc8 <getcallerpcs+0x56>
80104f99:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104f9d:	74 29                	je     80104fc8 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104f9f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fa2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fac:	01 c2                	add    %eax,%edx
80104fae:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb1:	8b 40 04             	mov    0x4(%eax),%eax
80104fb4:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104fb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb9:	8b 00                	mov    (%eax),%eax
80104fbb:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104fbe:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104fc2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104fc6:	7e c2                	jle    80104f8a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104fc8:	eb 19                	jmp    80104fe3 <getcallerpcs+0x71>
    pcs[i] = 0;
80104fca:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fcd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd7:	01 d0                	add    %edx,%eax
80104fd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104fdf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104fe3:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104fe7:	7e e1                	jle    80104fca <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104fe9:	c9                   	leave  
80104fea:	c3                   	ret    

80104feb <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104feb:	55                   	push   %ebp
80104fec:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104fee:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff1:	8b 00                	mov    (%eax),%eax
80104ff3:	85 c0                	test   %eax,%eax
80104ff5:	74 17                	je     8010500e <holding+0x23>
80104ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80104ffa:	8b 50 08             	mov    0x8(%eax),%edx
80104ffd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105003:	39 c2                	cmp    %eax,%edx
80105005:	75 07                	jne    8010500e <holding+0x23>
80105007:	b8 01 00 00 00       	mov    $0x1,%eax
8010500c:	eb 05                	jmp    80105013 <holding+0x28>
8010500e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105013:	5d                   	pop    %ebp
80105014:	c3                   	ret    

80105015 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105015:	55                   	push   %ebp
80105016:	89 e5                	mov    %esp,%ebp
80105018:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010501b:	e8 4a fe ff ff       	call   80104e6a <readeflags>
80105020:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105023:	e8 52 fe ff ff       	call   80104e7a <cli>
  if(cpu->ncli++ == 0)
80105028:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010502f:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105035:	8d 48 01             	lea    0x1(%eax),%ecx
80105038:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010503e:	85 c0                	test   %eax,%eax
80105040:	75 15                	jne    80105057 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105042:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105048:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010504b:	81 e2 00 02 00 00    	and    $0x200,%edx
80105051:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105057:	c9                   	leave  
80105058:	c3                   	ret    

80105059 <popcli>:

void
popcli(void)
{
80105059:	55                   	push   %ebp
8010505a:	89 e5                	mov    %esp,%ebp
8010505c:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010505f:	e8 06 fe ff ff       	call   80104e6a <readeflags>
80105064:	25 00 02 00 00       	and    $0x200,%eax
80105069:	85 c0                	test   %eax,%eax
8010506b:	74 0c                	je     80105079 <popcli+0x20>
    panic("popcli - interruptible");
8010506d:	c7 04 24 5d 88 10 80 	movl   $0x8010885d,(%esp)
80105074:	e8 c1 b4 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105079:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010507f:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105085:	83 ea 01             	sub    $0x1,%edx
80105088:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010508e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105094:	85 c0                	test   %eax,%eax
80105096:	79 0c                	jns    801050a4 <popcli+0x4b>
    panic("popcli");
80105098:	c7 04 24 74 88 10 80 	movl   $0x80108874,(%esp)
8010509f:	e8 96 b4 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
801050a4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050aa:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801050b0:	85 c0                	test   %eax,%eax
801050b2:	75 15                	jne    801050c9 <popcli+0x70>
801050b4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050ba:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801050c0:	85 c0                	test   %eax,%eax
801050c2:	74 05                	je     801050c9 <popcli+0x70>
    sti();
801050c4:	e8 b7 fd ff ff       	call   80104e80 <sti>
}
801050c9:	c9                   	leave  
801050ca:	c3                   	ret    

801050cb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801050cb:	55                   	push   %ebp
801050cc:	89 e5                	mov    %esp,%ebp
801050ce:	57                   	push   %edi
801050cf:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801050d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050d3:	8b 55 10             	mov    0x10(%ebp),%edx
801050d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d9:	89 cb                	mov    %ecx,%ebx
801050db:	89 df                	mov    %ebx,%edi
801050dd:	89 d1                	mov    %edx,%ecx
801050df:	fc                   	cld    
801050e0:	f3 aa                	rep stos %al,%es:(%edi)
801050e2:	89 ca                	mov    %ecx,%edx
801050e4:	89 fb                	mov    %edi,%ebx
801050e6:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050e9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050ec:	5b                   	pop    %ebx
801050ed:	5f                   	pop    %edi
801050ee:	5d                   	pop    %ebp
801050ef:	c3                   	ret    

801050f0 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801050f0:	55                   	push   %ebp
801050f1:	89 e5                	mov    %esp,%ebp
801050f3:	57                   	push   %edi
801050f4:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801050f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050f8:	8b 55 10             	mov    0x10(%ebp),%edx
801050fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fe:	89 cb                	mov    %ecx,%ebx
80105100:	89 df                	mov    %ebx,%edi
80105102:	89 d1                	mov    %edx,%ecx
80105104:	fc                   	cld    
80105105:	f3 ab                	rep stos %eax,%es:(%edi)
80105107:	89 ca                	mov    %ecx,%edx
80105109:	89 fb                	mov    %edi,%ebx
8010510b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010510e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105111:	5b                   	pop    %ebx
80105112:	5f                   	pop    %edi
80105113:	5d                   	pop    %ebp
80105114:	c3                   	ret    

80105115 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105115:	55                   	push   %ebp
80105116:	89 e5                	mov    %esp,%ebp
80105118:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010511b:	8b 45 08             	mov    0x8(%ebp),%eax
8010511e:	83 e0 03             	and    $0x3,%eax
80105121:	85 c0                	test   %eax,%eax
80105123:	75 49                	jne    8010516e <memset+0x59>
80105125:	8b 45 10             	mov    0x10(%ebp),%eax
80105128:	83 e0 03             	and    $0x3,%eax
8010512b:	85 c0                	test   %eax,%eax
8010512d:	75 3f                	jne    8010516e <memset+0x59>
    c &= 0xFF;
8010512f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105136:	8b 45 10             	mov    0x10(%ebp),%eax
80105139:	c1 e8 02             	shr    $0x2,%eax
8010513c:	89 c2                	mov    %eax,%edx
8010513e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105141:	c1 e0 18             	shl    $0x18,%eax
80105144:	89 c1                	mov    %eax,%ecx
80105146:	8b 45 0c             	mov    0xc(%ebp),%eax
80105149:	c1 e0 10             	shl    $0x10,%eax
8010514c:	09 c1                	or     %eax,%ecx
8010514e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105151:	c1 e0 08             	shl    $0x8,%eax
80105154:	09 c8                	or     %ecx,%eax
80105156:	0b 45 0c             	or     0xc(%ebp),%eax
80105159:	89 54 24 08          	mov    %edx,0x8(%esp)
8010515d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105161:	8b 45 08             	mov    0x8(%ebp),%eax
80105164:	89 04 24             	mov    %eax,(%esp)
80105167:	e8 84 ff ff ff       	call   801050f0 <stosl>
8010516c:	eb 19                	jmp    80105187 <memset+0x72>
  } else
    stosb(dst, c, n);
8010516e:	8b 45 10             	mov    0x10(%ebp),%eax
80105171:	89 44 24 08          	mov    %eax,0x8(%esp)
80105175:	8b 45 0c             	mov    0xc(%ebp),%eax
80105178:	89 44 24 04          	mov    %eax,0x4(%esp)
8010517c:	8b 45 08             	mov    0x8(%ebp),%eax
8010517f:	89 04 24             	mov    %eax,(%esp)
80105182:	e8 44 ff ff ff       	call   801050cb <stosb>
  return dst;
80105187:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010518a:	c9                   	leave  
8010518b:	c3                   	ret    

8010518c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010518c:	55                   	push   %ebp
8010518d:	89 e5                	mov    %esp,%ebp
8010518f:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105192:	8b 45 08             	mov    0x8(%ebp),%eax
80105195:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105198:	8b 45 0c             	mov    0xc(%ebp),%eax
8010519b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010519e:	eb 30                	jmp    801051d0 <memcmp+0x44>
    if(*s1 != *s2)
801051a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051a3:	0f b6 10             	movzbl (%eax),%edx
801051a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051a9:	0f b6 00             	movzbl (%eax),%eax
801051ac:	38 c2                	cmp    %al,%dl
801051ae:	74 18                	je     801051c8 <memcmp+0x3c>
      return *s1 - *s2;
801051b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051b3:	0f b6 00             	movzbl (%eax),%eax
801051b6:	0f b6 d0             	movzbl %al,%edx
801051b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051bc:	0f b6 00             	movzbl (%eax),%eax
801051bf:	0f b6 c0             	movzbl %al,%eax
801051c2:	29 c2                	sub    %eax,%edx
801051c4:	89 d0                	mov    %edx,%eax
801051c6:	eb 1a                	jmp    801051e2 <memcmp+0x56>
    s1++, s2++;
801051c8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801051cc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801051d0:	8b 45 10             	mov    0x10(%ebp),%eax
801051d3:	8d 50 ff             	lea    -0x1(%eax),%edx
801051d6:	89 55 10             	mov    %edx,0x10(%ebp)
801051d9:	85 c0                	test   %eax,%eax
801051db:	75 c3                	jne    801051a0 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801051dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051e2:	c9                   	leave  
801051e3:	c3                   	ret    

801051e4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801051e4:	55                   	push   %ebp
801051e5:	89 e5                	mov    %esp,%ebp
801051e7:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801051ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801051f0:	8b 45 08             	mov    0x8(%ebp),%eax
801051f3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801051f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051f9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051fc:	73 3d                	jae    8010523b <memmove+0x57>
801051fe:	8b 45 10             	mov    0x10(%ebp),%eax
80105201:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105204:	01 d0                	add    %edx,%eax
80105206:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105209:	76 30                	jbe    8010523b <memmove+0x57>
    s += n;
8010520b:	8b 45 10             	mov    0x10(%ebp),%eax
8010520e:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105211:	8b 45 10             	mov    0x10(%ebp),%eax
80105214:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105217:	eb 13                	jmp    8010522c <memmove+0x48>
      *--d = *--s;
80105219:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010521d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105221:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105224:	0f b6 10             	movzbl (%eax),%edx
80105227:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010522a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010522c:	8b 45 10             	mov    0x10(%ebp),%eax
8010522f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105232:	89 55 10             	mov    %edx,0x10(%ebp)
80105235:	85 c0                	test   %eax,%eax
80105237:	75 e0                	jne    80105219 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105239:	eb 26                	jmp    80105261 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010523b:	eb 17                	jmp    80105254 <memmove+0x70>
      *d++ = *s++;
8010523d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105240:	8d 50 01             	lea    0x1(%eax),%edx
80105243:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105246:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105249:	8d 4a 01             	lea    0x1(%edx),%ecx
8010524c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010524f:	0f b6 12             	movzbl (%edx),%edx
80105252:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105254:	8b 45 10             	mov    0x10(%ebp),%eax
80105257:	8d 50 ff             	lea    -0x1(%eax),%edx
8010525a:	89 55 10             	mov    %edx,0x10(%ebp)
8010525d:	85 c0                	test   %eax,%eax
8010525f:	75 dc                	jne    8010523d <memmove+0x59>
      *d++ = *s++;

  return dst;
80105261:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105264:	c9                   	leave  
80105265:	c3                   	ret    

80105266 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105266:	55                   	push   %ebp
80105267:	89 e5                	mov    %esp,%ebp
80105269:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010526c:	8b 45 10             	mov    0x10(%ebp),%eax
8010526f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105273:	8b 45 0c             	mov    0xc(%ebp),%eax
80105276:	89 44 24 04          	mov    %eax,0x4(%esp)
8010527a:	8b 45 08             	mov    0x8(%ebp),%eax
8010527d:	89 04 24             	mov    %eax,(%esp)
80105280:	e8 5f ff ff ff       	call   801051e4 <memmove>
}
80105285:	c9                   	leave  
80105286:	c3                   	ret    

80105287 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105287:	55                   	push   %ebp
80105288:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010528a:	eb 0c                	jmp    80105298 <strncmp+0x11>
    n--, p++, q++;
8010528c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105290:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105294:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105298:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010529c:	74 1a                	je     801052b8 <strncmp+0x31>
8010529e:	8b 45 08             	mov    0x8(%ebp),%eax
801052a1:	0f b6 00             	movzbl (%eax),%eax
801052a4:	84 c0                	test   %al,%al
801052a6:	74 10                	je     801052b8 <strncmp+0x31>
801052a8:	8b 45 08             	mov    0x8(%ebp),%eax
801052ab:	0f b6 10             	movzbl (%eax),%edx
801052ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801052b1:	0f b6 00             	movzbl (%eax),%eax
801052b4:	38 c2                	cmp    %al,%dl
801052b6:	74 d4                	je     8010528c <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801052b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052bc:	75 07                	jne    801052c5 <strncmp+0x3e>
    return 0;
801052be:	b8 00 00 00 00       	mov    $0x0,%eax
801052c3:	eb 16                	jmp    801052db <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801052c5:	8b 45 08             	mov    0x8(%ebp),%eax
801052c8:	0f b6 00             	movzbl (%eax),%eax
801052cb:	0f b6 d0             	movzbl %al,%edx
801052ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d1:	0f b6 00             	movzbl (%eax),%eax
801052d4:	0f b6 c0             	movzbl %al,%eax
801052d7:	29 c2                	sub    %eax,%edx
801052d9:	89 d0                	mov    %edx,%eax
}
801052db:	5d                   	pop    %ebp
801052dc:	c3                   	ret    

801052dd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801052dd:	55                   	push   %ebp
801052de:	89 e5                	mov    %esp,%ebp
801052e0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801052e3:	8b 45 08             	mov    0x8(%ebp),%eax
801052e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801052e9:	90                   	nop
801052ea:	8b 45 10             	mov    0x10(%ebp),%eax
801052ed:	8d 50 ff             	lea    -0x1(%eax),%edx
801052f0:	89 55 10             	mov    %edx,0x10(%ebp)
801052f3:	85 c0                	test   %eax,%eax
801052f5:	7e 1e                	jle    80105315 <strncpy+0x38>
801052f7:	8b 45 08             	mov    0x8(%ebp),%eax
801052fa:	8d 50 01             	lea    0x1(%eax),%edx
801052fd:	89 55 08             	mov    %edx,0x8(%ebp)
80105300:	8b 55 0c             	mov    0xc(%ebp),%edx
80105303:	8d 4a 01             	lea    0x1(%edx),%ecx
80105306:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105309:	0f b6 12             	movzbl (%edx),%edx
8010530c:	88 10                	mov    %dl,(%eax)
8010530e:	0f b6 00             	movzbl (%eax),%eax
80105311:	84 c0                	test   %al,%al
80105313:	75 d5                	jne    801052ea <strncpy+0xd>
    ;
  while(n-- > 0)
80105315:	eb 0c                	jmp    80105323 <strncpy+0x46>
    *s++ = 0;
80105317:	8b 45 08             	mov    0x8(%ebp),%eax
8010531a:	8d 50 01             	lea    0x1(%eax),%edx
8010531d:	89 55 08             	mov    %edx,0x8(%ebp)
80105320:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105323:	8b 45 10             	mov    0x10(%ebp),%eax
80105326:	8d 50 ff             	lea    -0x1(%eax),%edx
80105329:	89 55 10             	mov    %edx,0x10(%ebp)
8010532c:	85 c0                	test   %eax,%eax
8010532e:	7f e7                	jg     80105317 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105330:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105333:	c9                   	leave  
80105334:	c3                   	ret    

80105335 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105335:	55                   	push   %ebp
80105336:	89 e5                	mov    %esp,%ebp
80105338:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010533b:	8b 45 08             	mov    0x8(%ebp),%eax
8010533e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105341:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105345:	7f 05                	jg     8010534c <safestrcpy+0x17>
    return os;
80105347:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010534a:	eb 31                	jmp    8010537d <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010534c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105350:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105354:	7e 1e                	jle    80105374 <safestrcpy+0x3f>
80105356:	8b 45 08             	mov    0x8(%ebp),%eax
80105359:	8d 50 01             	lea    0x1(%eax),%edx
8010535c:	89 55 08             	mov    %edx,0x8(%ebp)
8010535f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105362:	8d 4a 01             	lea    0x1(%edx),%ecx
80105365:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105368:	0f b6 12             	movzbl (%edx),%edx
8010536b:	88 10                	mov    %dl,(%eax)
8010536d:	0f b6 00             	movzbl (%eax),%eax
80105370:	84 c0                	test   %al,%al
80105372:	75 d8                	jne    8010534c <safestrcpy+0x17>
    ;
  *s = 0;
80105374:	8b 45 08             	mov    0x8(%ebp),%eax
80105377:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010537a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010537d:	c9                   	leave  
8010537e:	c3                   	ret    

8010537f <strlen>:

int
strlen(const char *s)
{
8010537f:	55                   	push   %ebp
80105380:	89 e5                	mov    %esp,%ebp
80105382:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105385:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010538c:	eb 04                	jmp    80105392 <strlen+0x13>
8010538e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105392:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105395:	8b 45 08             	mov    0x8(%ebp),%eax
80105398:	01 d0                	add    %edx,%eax
8010539a:	0f b6 00             	movzbl (%eax),%eax
8010539d:	84 c0                	test   %al,%al
8010539f:	75 ed                	jne    8010538e <strlen+0xf>
    ;
  return n;
801053a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053a4:	c9                   	leave  
801053a5:	c3                   	ret    

801053a6 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801053a6:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801053aa:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801053ae:	55                   	push   %ebp
  pushl %ebx
801053af:	53                   	push   %ebx
  pushl %esi
801053b0:	56                   	push   %esi
  pushl %edi
801053b1:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801053b2:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801053b4:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801053b6:	5f                   	pop    %edi
  popl %esi
801053b7:	5e                   	pop    %esi
  popl %ebx
801053b8:	5b                   	pop    %ebx
  popl %ebp
801053b9:	5d                   	pop    %ebp
  ret
801053ba:	c3                   	ret    

801053bb <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801053bb:	55                   	push   %ebp
801053bc:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801053be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053c4:	8b 00                	mov    (%eax),%eax
801053c6:	3b 45 08             	cmp    0x8(%ebp),%eax
801053c9:	76 12                	jbe    801053dd <fetchint+0x22>
801053cb:	8b 45 08             	mov    0x8(%ebp),%eax
801053ce:	8d 50 04             	lea    0x4(%eax),%edx
801053d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053d7:	8b 00                	mov    (%eax),%eax
801053d9:	39 c2                	cmp    %eax,%edx
801053db:	76 07                	jbe    801053e4 <fetchint+0x29>
    return -1;
801053dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e2:	eb 0f                	jmp    801053f3 <fetchint+0x38>
  *ip = *(int*)(addr);
801053e4:	8b 45 08             	mov    0x8(%ebp),%eax
801053e7:	8b 10                	mov    (%eax),%edx
801053e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ec:	89 10                	mov    %edx,(%eax)
  return 0;
801053ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053f3:	5d                   	pop    %ebp
801053f4:	c3                   	ret    

801053f5 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801053f5:	55                   	push   %ebp
801053f6:	89 e5                	mov    %esp,%ebp
801053f8:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801053fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105401:	8b 00                	mov    (%eax),%eax
80105403:	3b 45 08             	cmp    0x8(%ebp),%eax
80105406:	77 07                	ja     8010540f <fetchstr+0x1a>
    return -1;
80105408:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010540d:	eb 46                	jmp    80105455 <fetchstr+0x60>
  *pp = (char*)addr;
8010540f:	8b 55 08             	mov    0x8(%ebp),%edx
80105412:	8b 45 0c             	mov    0xc(%ebp),%eax
80105415:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105417:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010541d:	8b 00                	mov    (%eax),%eax
8010541f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105422:	8b 45 0c             	mov    0xc(%ebp),%eax
80105425:	8b 00                	mov    (%eax),%eax
80105427:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010542a:	eb 1c                	jmp    80105448 <fetchstr+0x53>
    if(*s == 0)
8010542c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010542f:	0f b6 00             	movzbl (%eax),%eax
80105432:	84 c0                	test   %al,%al
80105434:	75 0e                	jne    80105444 <fetchstr+0x4f>
      return s - *pp;
80105436:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105439:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543c:	8b 00                	mov    (%eax),%eax
8010543e:	29 c2                	sub    %eax,%edx
80105440:	89 d0                	mov    %edx,%eax
80105442:	eb 11                	jmp    80105455 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105444:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105448:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010544b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010544e:	72 dc                	jb     8010542c <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105450:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105455:	c9                   	leave  
80105456:	c3                   	ret    

80105457 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105457:	55                   	push   %ebp
80105458:	89 e5                	mov    %esp,%ebp
8010545a:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010545d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105463:	8b 40 18             	mov    0x18(%eax),%eax
80105466:	8b 50 44             	mov    0x44(%eax),%edx
80105469:	8b 45 08             	mov    0x8(%ebp),%eax
8010546c:	c1 e0 02             	shl    $0x2,%eax
8010546f:	01 d0                	add    %edx,%eax
80105471:	8d 50 04             	lea    0x4(%eax),%edx
80105474:	8b 45 0c             	mov    0xc(%ebp),%eax
80105477:	89 44 24 04          	mov    %eax,0x4(%esp)
8010547b:	89 14 24             	mov    %edx,(%esp)
8010547e:	e8 38 ff ff ff       	call   801053bb <fetchint>
}
80105483:	c9                   	leave  
80105484:	c3                   	ret    

80105485 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105485:	55                   	push   %ebp
80105486:	89 e5                	mov    %esp,%ebp
80105488:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010548b:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010548e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105492:	8b 45 08             	mov    0x8(%ebp),%eax
80105495:	89 04 24             	mov    %eax,(%esp)
80105498:	e8 ba ff ff ff       	call   80105457 <argint>
8010549d:	85 c0                	test   %eax,%eax
8010549f:	79 07                	jns    801054a8 <argptr+0x23>
    return -1;
801054a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a6:	eb 3d                	jmp    801054e5 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801054a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054ab:	89 c2                	mov    %eax,%edx
801054ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b3:	8b 00                	mov    (%eax),%eax
801054b5:	39 c2                	cmp    %eax,%edx
801054b7:	73 16                	jae    801054cf <argptr+0x4a>
801054b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054bc:	89 c2                	mov    %eax,%edx
801054be:	8b 45 10             	mov    0x10(%ebp),%eax
801054c1:	01 c2                	add    %eax,%edx
801054c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c9:	8b 00                	mov    (%eax),%eax
801054cb:	39 c2                	cmp    %eax,%edx
801054cd:	76 07                	jbe    801054d6 <argptr+0x51>
    return -1;
801054cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054d4:	eb 0f                	jmp    801054e5 <argptr+0x60>
  *pp = (char*)i;
801054d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d9:	89 c2                	mov    %eax,%edx
801054db:	8b 45 0c             	mov    0xc(%ebp),%eax
801054de:	89 10                	mov    %edx,(%eax)
  return 0;
801054e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054e5:	c9                   	leave  
801054e6:	c3                   	ret    

801054e7 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801054e7:	55                   	push   %ebp
801054e8:	89 e5                	mov    %esp,%ebp
801054ea:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801054ed:	8d 45 fc             	lea    -0x4(%ebp),%eax
801054f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801054f4:	8b 45 08             	mov    0x8(%ebp),%eax
801054f7:	89 04 24             	mov    %eax,(%esp)
801054fa:	e8 58 ff ff ff       	call   80105457 <argint>
801054ff:	85 c0                	test   %eax,%eax
80105501:	79 07                	jns    8010550a <argstr+0x23>
    return -1;
80105503:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105508:	eb 12                	jmp    8010551c <argstr+0x35>
  return fetchstr(addr, pp);
8010550a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010550d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105510:	89 54 24 04          	mov    %edx,0x4(%esp)
80105514:	89 04 24             	mov    %eax,(%esp)
80105517:	e8 d9 fe ff ff       	call   801053f5 <fetchstr>
}
8010551c:	c9                   	leave  
8010551d:	c3                   	ret    

8010551e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010551e:	55                   	push   %ebp
8010551f:	89 e5                	mov    %esp,%ebp
80105521:	53                   	push   %ebx
80105522:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105525:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010552b:	8b 40 18             	mov    0x18(%eax),%eax
8010552e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105531:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105534:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105538:	7e 30                	jle    8010556a <syscall+0x4c>
8010553a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553d:	83 f8 15             	cmp    $0x15,%eax
80105540:	77 28                	ja     8010556a <syscall+0x4c>
80105542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105545:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010554c:	85 c0                	test   %eax,%eax
8010554e:	74 1a                	je     8010556a <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105550:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105556:	8b 58 18             	mov    0x18(%eax),%ebx
80105559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010555c:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105563:	ff d0                	call   *%eax
80105565:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105568:	eb 3d                	jmp    801055a7 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010556a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105570:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105573:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105579:	8b 40 10             	mov    0x10(%eax),%eax
8010557c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010557f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105583:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105587:	89 44 24 04          	mov    %eax,0x4(%esp)
8010558b:	c7 04 24 7b 88 10 80 	movl   $0x8010887b,(%esp)
80105592:	e8 09 ae ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105597:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010559d:	8b 40 18             	mov    0x18(%eax),%eax
801055a0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801055a7:	83 c4 24             	add    $0x24,%esp
801055aa:	5b                   	pop    %ebx
801055ab:	5d                   	pop    %ebp
801055ac:	c3                   	ret    

801055ad <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801055ad:	55                   	push   %ebp
801055ae:	89 e5                	mov    %esp,%ebp
801055b0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801055b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801055ba:	8b 45 08             	mov    0x8(%ebp),%eax
801055bd:	89 04 24             	mov    %eax,(%esp)
801055c0:	e8 92 fe ff ff       	call   80105457 <argint>
801055c5:	85 c0                	test   %eax,%eax
801055c7:	79 07                	jns    801055d0 <argfd+0x23>
    return -1;
801055c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ce:	eb 50                	jmp    80105620 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801055d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d3:	85 c0                	test   %eax,%eax
801055d5:	78 21                	js     801055f8 <argfd+0x4b>
801055d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055da:	83 f8 0f             	cmp    $0xf,%eax
801055dd:	7f 19                	jg     801055f8 <argfd+0x4b>
801055df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055e8:	83 c2 08             	add    $0x8,%edx
801055eb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801055ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055f6:	75 07                	jne    801055ff <argfd+0x52>
    return -1;
801055f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055fd:	eb 21                	jmp    80105620 <argfd+0x73>
  if(pfd)
801055ff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105603:	74 08                	je     8010560d <argfd+0x60>
    *pfd = fd;
80105605:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105608:	8b 45 0c             	mov    0xc(%ebp),%eax
8010560b:	89 10                	mov    %edx,(%eax)
  if(pf)
8010560d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105611:	74 08                	je     8010561b <argfd+0x6e>
    *pf = f;
80105613:	8b 45 10             	mov    0x10(%ebp),%eax
80105616:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105619:	89 10                	mov    %edx,(%eax)
  return 0;
8010561b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105620:	c9                   	leave  
80105621:	c3                   	ret    

80105622 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105622:	55                   	push   %ebp
80105623:	89 e5                	mov    %esp,%ebp
80105625:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105628:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010562f:	eb 30                	jmp    80105661 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105631:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105637:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010563a:	83 c2 08             	add    $0x8,%edx
8010563d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105641:	85 c0                	test   %eax,%eax
80105643:	75 18                	jne    8010565d <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105645:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010564b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010564e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105651:	8b 55 08             	mov    0x8(%ebp),%edx
80105654:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105658:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010565b:	eb 0f                	jmp    8010566c <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010565d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105661:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105665:	7e ca                	jle    80105631 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105667:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010566c:	c9                   	leave  
8010566d:	c3                   	ret    

8010566e <sys_dup>:

int
sys_dup(void)
{
8010566e:	55                   	push   %ebp
8010566f:	89 e5                	mov    %esp,%ebp
80105671:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105674:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105677:	89 44 24 08          	mov    %eax,0x8(%esp)
8010567b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105682:	00 
80105683:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010568a:	e8 1e ff ff ff       	call   801055ad <argfd>
8010568f:	85 c0                	test   %eax,%eax
80105691:	79 07                	jns    8010569a <sys_dup+0x2c>
    return -1;
80105693:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105698:	eb 29                	jmp    801056c3 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010569a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010569d:	89 04 24             	mov    %eax,(%esp)
801056a0:	e8 7d ff ff ff       	call   80105622 <fdalloc>
801056a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ac:	79 07                	jns    801056b5 <sys_dup+0x47>
    return -1;
801056ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b3:	eb 0e                	jmp    801056c3 <sys_dup+0x55>
  filedup(f);
801056b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b8:	89 04 24             	mov    %eax,(%esp)
801056bb:	e8 c6 b8 ff ff       	call   80100f86 <filedup>
  return fd;
801056c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801056c3:	c9                   	leave  
801056c4:	c3                   	ret    

801056c5 <sys_read>:

int
sys_read(void)
{
801056c5:	55                   	push   %ebp
801056c6:	89 e5                	mov    %esp,%ebp
801056c8:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801056cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056ce:	89 44 24 08          	mov    %eax,0x8(%esp)
801056d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056d9:	00 
801056da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056e1:	e8 c7 fe ff ff       	call   801055ad <argfd>
801056e6:	85 c0                	test   %eax,%eax
801056e8:	78 35                	js     8010571f <sys_read+0x5a>
801056ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801056f1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801056f8:	e8 5a fd ff ff       	call   80105457 <argint>
801056fd:	85 c0                	test   %eax,%eax
801056ff:	78 1e                	js     8010571f <sys_read+0x5a>
80105701:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105704:	89 44 24 08          	mov    %eax,0x8(%esp)
80105708:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010570b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010570f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105716:	e8 6a fd ff ff       	call   80105485 <argptr>
8010571b:	85 c0                	test   %eax,%eax
8010571d:	79 07                	jns    80105726 <sys_read+0x61>
    return -1;
8010571f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105724:	eb 19                	jmp    8010573f <sys_read+0x7a>
  return fileread(f, p, n);
80105726:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105729:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010572c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010572f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105733:	89 54 24 04          	mov    %edx,0x4(%esp)
80105737:	89 04 24             	mov    %eax,(%esp)
8010573a:	e8 b4 b9 ff ff       	call   801010f3 <fileread>
}
8010573f:	c9                   	leave  
80105740:	c3                   	ret    

80105741 <sys_write>:

int
sys_write(void)
{
80105741:	55                   	push   %ebp
80105742:	89 e5                	mov    %esp,%ebp
80105744:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105747:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010574a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010574e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105755:	00 
80105756:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010575d:	e8 4b fe ff ff       	call   801055ad <argfd>
80105762:	85 c0                	test   %eax,%eax
80105764:	78 35                	js     8010579b <sys_write+0x5a>
80105766:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105769:	89 44 24 04          	mov    %eax,0x4(%esp)
8010576d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105774:	e8 de fc ff ff       	call   80105457 <argint>
80105779:	85 c0                	test   %eax,%eax
8010577b:	78 1e                	js     8010579b <sys_write+0x5a>
8010577d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105780:	89 44 24 08          	mov    %eax,0x8(%esp)
80105784:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105787:	89 44 24 04          	mov    %eax,0x4(%esp)
8010578b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105792:	e8 ee fc ff ff       	call   80105485 <argptr>
80105797:	85 c0                	test   %eax,%eax
80105799:	79 07                	jns    801057a2 <sys_write+0x61>
    return -1;
8010579b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a0:	eb 19                	jmp    801057bb <sys_write+0x7a>
  return filewrite(f, p, n);
801057a2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801057a5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801057a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057af:	89 54 24 04          	mov    %edx,0x4(%esp)
801057b3:	89 04 24             	mov    %eax,(%esp)
801057b6:	e8 f4 b9 ff ff       	call   801011af <filewrite>
}
801057bb:	c9                   	leave  
801057bc:	c3                   	ret    

801057bd <sys_close>:

int
sys_close(void)
{
801057bd:	55                   	push   %ebp
801057be:	89 e5                	mov    %esp,%ebp
801057c0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801057c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057c6:	89 44 24 08          	mov    %eax,0x8(%esp)
801057ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801057d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057d8:	e8 d0 fd ff ff       	call   801055ad <argfd>
801057dd:	85 c0                	test   %eax,%eax
801057df:	79 07                	jns    801057e8 <sys_close+0x2b>
    return -1;
801057e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e6:	eb 24                	jmp    8010580c <sys_close+0x4f>
  proc->ofile[fd] = 0;
801057e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057f1:	83 c2 08             	add    $0x8,%edx
801057f4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801057fb:	00 
  fileclose(f);
801057fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ff:	89 04 24             	mov    %eax,(%esp)
80105802:	e8 c7 b7 ff ff       	call   80100fce <fileclose>
  return 0;
80105807:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010580c:	c9                   	leave  
8010580d:	c3                   	ret    

8010580e <sys_fstat>:

int
sys_fstat(void)
{
8010580e:	55                   	push   %ebp
8010580f:	89 e5                	mov    %esp,%ebp
80105811:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105814:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105817:	89 44 24 08          	mov    %eax,0x8(%esp)
8010581b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105822:	00 
80105823:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010582a:	e8 7e fd ff ff       	call   801055ad <argfd>
8010582f:	85 c0                	test   %eax,%eax
80105831:	78 1f                	js     80105852 <sys_fstat+0x44>
80105833:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010583a:	00 
8010583b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010583e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105842:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105849:	e8 37 fc ff ff       	call   80105485 <argptr>
8010584e:	85 c0                	test   %eax,%eax
80105850:	79 07                	jns    80105859 <sys_fstat+0x4b>
    return -1;
80105852:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105857:	eb 12                	jmp    8010586b <sys_fstat+0x5d>
  return filestat(f, st);
80105859:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010585c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105863:	89 04 24             	mov    %eax,(%esp)
80105866:	e8 39 b8 ff ff       	call   801010a4 <filestat>
}
8010586b:	c9                   	leave  
8010586c:	c3                   	ret    

8010586d <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010586d:	55                   	push   %ebp
8010586e:	89 e5                	mov    %esp,%ebp
80105870:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105873:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105876:	89 44 24 04          	mov    %eax,0x4(%esp)
8010587a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105881:	e8 61 fc ff ff       	call   801054e7 <argstr>
80105886:	85 c0                	test   %eax,%eax
80105888:	78 17                	js     801058a1 <sys_link+0x34>
8010588a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010588d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105891:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105898:	e8 4a fc ff ff       	call   801054e7 <argstr>
8010589d:	85 c0                	test   %eax,%eax
8010589f:	79 0a                	jns    801058ab <sys_link+0x3e>
    return -1;
801058a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a6:	e9 42 01 00 00       	jmp    801059ed <sys_link+0x180>

  begin_op();
801058ab:	e8 60 db ff ff       	call   80103410 <begin_op>
  if((ip = namei(old)) == 0){
801058b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801058b3:	89 04 24             	mov    %eax,(%esp)
801058b6:	e8 4b cb ff ff       	call   80102406 <namei>
801058bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c2:	75 0f                	jne    801058d3 <sys_link+0x66>
    end_op();
801058c4:	e8 cb db ff ff       	call   80103494 <end_op>
    return -1;
801058c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ce:	e9 1a 01 00 00       	jmp    801059ed <sys_link+0x180>
  }

  ilock(ip);
801058d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d6:	89 04 24             	mov    %eax,(%esp)
801058d9:	e8 7d bf ff ff       	call   8010185b <ilock>
  if(ip->type == T_DIR){
801058de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801058e5:	66 83 f8 01          	cmp    $0x1,%ax
801058e9:	75 1a                	jne    80105905 <sys_link+0x98>
    iunlockput(ip);
801058eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ee:	89 04 24             	mov    %eax,(%esp)
801058f1:	e8 e9 c1 ff ff       	call   80101adf <iunlockput>
    end_op();
801058f6:	e8 99 db ff ff       	call   80103494 <end_op>
    return -1;
801058fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105900:	e9 e8 00 00 00       	jmp    801059ed <sys_link+0x180>
  }

  ip->nlink++;
80105905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105908:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010590c:	8d 50 01             	lea    0x1(%eax),%edx
8010590f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105912:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105919:	89 04 24             	mov    %eax,(%esp)
8010591c:	e8 7e bd ff ff       	call   8010169f <iupdate>
  iunlock(ip);
80105921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105924:	89 04 24             	mov    %eax,(%esp)
80105927:	e8 7d c0 ff ff       	call   801019a9 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010592c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010592f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105932:	89 54 24 04          	mov    %edx,0x4(%esp)
80105936:	89 04 24             	mov    %eax,(%esp)
80105939:	e8 ea ca ff ff       	call   80102428 <nameiparent>
8010593e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105941:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105945:	75 02                	jne    80105949 <sys_link+0xdc>
    goto bad;
80105947:	eb 68                	jmp    801059b1 <sys_link+0x144>
  ilock(dp);
80105949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594c:	89 04 24             	mov    %eax,(%esp)
8010594f:	e8 07 bf ff ff       	call   8010185b <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105957:	8b 10                	mov    (%eax),%edx
80105959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595c:	8b 00                	mov    (%eax),%eax
8010595e:	39 c2                	cmp    %eax,%edx
80105960:	75 20                	jne    80105982 <sys_link+0x115>
80105962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105965:	8b 40 04             	mov    0x4(%eax),%eax
80105968:	89 44 24 08          	mov    %eax,0x8(%esp)
8010596c:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010596f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105973:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105976:	89 04 24             	mov    %eax,(%esp)
80105979:	e8 c8 c7 ff ff       	call   80102146 <dirlink>
8010597e:	85 c0                	test   %eax,%eax
80105980:	79 0d                	jns    8010598f <sys_link+0x122>
    iunlockput(dp);
80105982:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105985:	89 04 24             	mov    %eax,(%esp)
80105988:	e8 52 c1 ff ff       	call   80101adf <iunlockput>
    goto bad;
8010598d:	eb 22                	jmp    801059b1 <sys_link+0x144>
  }
  iunlockput(dp);
8010598f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105992:	89 04 24             	mov    %eax,(%esp)
80105995:	e8 45 c1 ff ff       	call   80101adf <iunlockput>
  iput(ip);
8010599a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599d:	89 04 24             	mov    %eax,(%esp)
801059a0:	e8 69 c0 ff ff       	call   80101a0e <iput>

  end_op();
801059a5:	e8 ea da ff ff       	call   80103494 <end_op>

  return 0;
801059aa:	b8 00 00 00 00       	mov    $0x0,%eax
801059af:	eb 3c                	jmp    801059ed <sys_link+0x180>

bad:
  ilock(ip);
801059b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b4:	89 04 24             	mov    %eax,(%esp)
801059b7:	e8 9f be ff ff       	call   8010185b <ilock>
  ip->nlink--;
801059bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801059c3:	8d 50 ff             	lea    -0x1(%eax),%edx
801059c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c9:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801059cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d0:	89 04 24             	mov    %eax,(%esp)
801059d3:	e8 c7 bc ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
801059d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059db:	89 04 24             	mov    %eax,(%esp)
801059de:	e8 fc c0 ff ff       	call   80101adf <iunlockput>
  end_op();
801059e3:	e8 ac da ff ff       	call   80103494 <end_op>
  return -1;
801059e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059ed:	c9                   	leave  
801059ee:	c3                   	ret    

801059ef <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801059ef:	55                   	push   %ebp
801059f0:	89 e5                	mov    %esp,%ebp
801059f2:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801059f5:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801059fc:	eb 4b                	jmp    80105a49 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801059fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a01:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105a08:	00 
80105a09:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a0d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a10:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a14:	8b 45 08             	mov    0x8(%ebp),%eax
80105a17:	89 04 24             	mov    %eax,(%esp)
80105a1a:	e8 49 c3 ff ff       	call   80101d68 <readi>
80105a1f:	83 f8 10             	cmp    $0x10,%eax
80105a22:	74 0c                	je     80105a30 <isdirempty+0x41>
      panic("isdirempty: readi");
80105a24:	c7 04 24 97 88 10 80 	movl   $0x80108897,(%esp)
80105a2b:	e8 0a ab ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105a30:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105a34:	66 85 c0             	test   %ax,%ax
80105a37:	74 07                	je     80105a40 <isdirempty+0x51>
      return 0;
80105a39:	b8 00 00 00 00       	mov    $0x0,%eax
80105a3e:	eb 1b                	jmp    80105a5b <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a43:	83 c0 10             	add    $0x10,%eax
80105a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80105a4f:	8b 40 18             	mov    0x18(%eax),%eax
80105a52:	39 c2                	cmp    %eax,%edx
80105a54:	72 a8                	jb     801059fe <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105a56:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105a5b:	c9                   	leave  
80105a5c:	c3                   	ret    

80105a5d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105a5d:	55                   	push   %ebp
80105a5e:	89 e5                	mov    %esp,%ebp
80105a60:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105a63:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105a66:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a71:	e8 71 fa ff ff       	call   801054e7 <argstr>
80105a76:	85 c0                	test   %eax,%eax
80105a78:	79 0a                	jns    80105a84 <sys_unlink+0x27>
    return -1;
80105a7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a7f:	e9 af 01 00 00       	jmp    80105c33 <sys_unlink+0x1d6>

  begin_op();
80105a84:	e8 87 d9 ff ff       	call   80103410 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105a89:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105a8c:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105a8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a93:	89 04 24             	mov    %eax,(%esp)
80105a96:	e8 8d c9 ff ff       	call   80102428 <nameiparent>
80105a9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aa2:	75 0f                	jne    80105ab3 <sys_unlink+0x56>
    end_op();
80105aa4:	e8 eb d9 ff ff       	call   80103494 <end_op>
    return -1;
80105aa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aae:	e9 80 01 00 00       	jmp    80105c33 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab6:	89 04 24             	mov    %eax,(%esp)
80105ab9:	e8 9d bd ff ff       	call   8010185b <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105abe:	c7 44 24 04 a9 88 10 	movl   $0x801088a9,0x4(%esp)
80105ac5:	80 
80105ac6:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ac9:	89 04 24             	mov    %eax,(%esp)
80105acc:	e8 8a c5 ff ff       	call   8010205b <namecmp>
80105ad1:	85 c0                	test   %eax,%eax
80105ad3:	0f 84 45 01 00 00    	je     80105c1e <sys_unlink+0x1c1>
80105ad9:	c7 44 24 04 ab 88 10 	movl   $0x801088ab,0x4(%esp)
80105ae0:	80 
80105ae1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ae4:	89 04 24             	mov    %eax,(%esp)
80105ae7:	e8 6f c5 ff ff       	call   8010205b <namecmp>
80105aec:	85 c0                	test   %eax,%eax
80105aee:	0f 84 2a 01 00 00    	je     80105c1e <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105af4:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105af7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105afb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105afe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b05:	89 04 24             	mov    %eax,(%esp)
80105b08:	e8 70 c5 ff ff       	call   8010207d <dirlookup>
80105b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b14:	75 05                	jne    80105b1b <sys_unlink+0xbe>
    goto bad;
80105b16:	e9 03 01 00 00       	jmp    80105c1e <sys_unlink+0x1c1>
  ilock(ip);
80105b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1e:	89 04 24             	mov    %eax,(%esp)
80105b21:	e8 35 bd ff ff       	call   8010185b <ilock>

  if(ip->nlink < 1)
80105b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b29:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b2d:	66 85 c0             	test   %ax,%ax
80105b30:	7f 0c                	jg     80105b3e <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105b32:	c7 04 24 ae 88 10 80 	movl   $0x801088ae,(%esp)
80105b39:	e8 fc a9 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b41:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b45:	66 83 f8 01          	cmp    $0x1,%ax
80105b49:	75 1f                	jne    80105b6a <sys_unlink+0x10d>
80105b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4e:	89 04 24             	mov    %eax,(%esp)
80105b51:	e8 99 fe ff ff       	call   801059ef <isdirempty>
80105b56:	85 c0                	test   %eax,%eax
80105b58:	75 10                	jne    80105b6a <sys_unlink+0x10d>
    iunlockput(ip);
80105b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5d:	89 04 24             	mov    %eax,(%esp)
80105b60:	e8 7a bf ff ff       	call   80101adf <iunlockput>
    goto bad;
80105b65:	e9 b4 00 00 00       	jmp    80105c1e <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105b6a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105b71:	00 
80105b72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b79:	00 
80105b7a:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b7d:	89 04 24             	mov    %eax,(%esp)
80105b80:	e8 90 f5 ff ff       	call   80105115 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b85:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105b88:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b8f:	00 
80105b90:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b94:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b97:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9e:	89 04 24             	mov    %eax,(%esp)
80105ba1:	e8 26 c3 ff ff       	call   80101ecc <writei>
80105ba6:	83 f8 10             	cmp    $0x10,%eax
80105ba9:	74 0c                	je     80105bb7 <sys_unlink+0x15a>
    panic("unlink: writei");
80105bab:	c7 04 24 c0 88 10 80 	movl   $0x801088c0,(%esp)
80105bb2:	e8 83 a9 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bba:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105bbe:	66 83 f8 01          	cmp    $0x1,%ax
80105bc2:	75 1c                	jne    80105be0 <sys_unlink+0x183>
    dp->nlink--;
80105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bcb:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd1:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd8:	89 04 24             	mov    %eax,(%esp)
80105bdb:	e8 bf ba ff ff       	call   8010169f <iupdate>
  }
  iunlockput(dp);
80105be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be3:	89 04 24             	mov    %eax,(%esp)
80105be6:	e8 f4 be ff ff       	call   80101adf <iunlockput>

  ip->nlink--;
80105beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bee:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bf2:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf8:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bff:	89 04 24             	mov    %eax,(%esp)
80105c02:	e8 98 ba ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80105c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0a:	89 04 24             	mov    %eax,(%esp)
80105c0d:	e8 cd be ff ff       	call   80101adf <iunlockput>

  end_op();
80105c12:	e8 7d d8 ff ff       	call   80103494 <end_op>

  return 0;
80105c17:	b8 00 00 00 00       	mov    $0x0,%eax
80105c1c:	eb 15                	jmp    80105c33 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c21:	89 04 24             	mov    %eax,(%esp)
80105c24:	e8 b6 be ff ff       	call   80101adf <iunlockput>
  end_op();
80105c29:	e8 66 d8 ff ff       	call   80103494 <end_op>
  return -1;
80105c2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c33:	c9                   	leave  
80105c34:	c3                   	ret    

80105c35 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105c35:	55                   	push   %ebp
80105c36:	89 e5                	mov    %esp,%ebp
80105c38:	83 ec 48             	sub    $0x48,%esp
80105c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c3e:	8b 55 10             	mov    0x10(%ebp),%edx
80105c41:	8b 45 14             	mov    0x14(%ebp),%eax
80105c44:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105c48:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105c4c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105c50:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c53:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c57:	8b 45 08             	mov    0x8(%ebp),%eax
80105c5a:	89 04 24             	mov    %eax,(%esp)
80105c5d:	e8 c6 c7 ff ff       	call   80102428 <nameiparent>
80105c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c69:	75 0a                	jne    80105c75 <create+0x40>
    return 0;
80105c6b:	b8 00 00 00 00       	mov    $0x0,%eax
80105c70:	e9 7e 01 00 00       	jmp    80105df3 <create+0x1be>
  ilock(dp);
80105c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c78:	89 04 24             	mov    %eax,(%esp)
80105c7b:	e8 db bb ff ff       	call   8010185b <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105c80:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c83:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c87:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c91:	89 04 24             	mov    %eax,(%esp)
80105c94:	e8 e4 c3 ff ff       	call   8010207d <dirlookup>
80105c99:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ca0:	74 47                	je     80105ce9 <create+0xb4>
    iunlockput(dp);
80105ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca5:	89 04 24             	mov    %eax,(%esp)
80105ca8:	e8 32 be ff ff       	call   80101adf <iunlockput>
    ilock(ip);
80105cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb0:	89 04 24             	mov    %eax,(%esp)
80105cb3:	e8 a3 bb ff ff       	call   8010185b <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105cb8:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105cbd:	75 15                	jne    80105cd4 <create+0x9f>
80105cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cc6:	66 83 f8 02          	cmp    $0x2,%ax
80105cca:	75 08                	jne    80105cd4 <create+0x9f>
      return ip;
80105ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ccf:	e9 1f 01 00 00       	jmp    80105df3 <create+0x1be>
    iunlockput(ip);
80105cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd7:	89 04 24             	mov    %eax,(%esp)
80105cda:	e8 00 be ff ff       	call   80101adf <iunlockput>
    return 0;
80105cdf:	b8 00 00 00 00       	mov    $0x0,%eax
80105ce4:	e9 0a 01 00 00       	jmp    80105df3 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105ce9:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf0:	8b 00                	mov    (%eax),%eax
80105cf2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cf6:	89 04 24             	mov    %eax,(%esp)
80105cf9:	e8 c2 b8 ff ff       	call   801015c0 <ialloc>
80105cfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d05:	75 0c                	jne    80105d13 <create+0xde>
    panic("create: ialloc");
80105d07:	c7 04 24 cf 88 10 80 	movl   $0x801088cf,(%esp)
80105d0e:	e8 27 a8 ff ff       	call   8010053a <panic>

  ilock(ip);
80105d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d16:	89 04 24             	mov    %eax,(%esp)
80105d19:	e8 3d bb ff ff       	call   8010185b <ilock>
  ip->major = major;
80105d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d21:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105d25:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2c:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105d30:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d37:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d40:	89 04 24             	mov    %eax,(%esp)
80105d43:	e8 57 b9 ff ff       	call   8010169f <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105d48:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105d4d:	75 6a                	jne    80105db9 <create+0x184>
    dp->nlink++;  // for ".."
80105d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d52:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d56:	8d 50 01             	lea    0x1(%eax),%edx
80105d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5c:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d63:	89 04 24             	mov    %eax,(%esp)
80105d66:	e8 34 b9 ff ff       	call   8010169f <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6e:	8b 40 04             	mov    0x4(%eax),%eax
80105d71:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d75:	c7 44 24 04 a9 88 10 	movl   $0x801088a9,0x4(%esp)
80105d7c:	80 
80105d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d80:	89 04 24             	mov    %eax,(%esp)
80105d83:	e8 be c3 ff ff       	call   80102146 <dirlink>
80105d88:	85 c0                	test   %eax,%eax
80105d8a:	78 21                	js     80105dad <create+0x178>
80105d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8f:	8b 40 04             	mov    0x4(%eax),%eax
80105d92:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d96:	c7 44 24 04 ab 88 10 	movl   $0x801088ab,0x4(%esp)
80105d9d:	80 
80105d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da1:	89 04 24             	mov    %eax,(%esp)
80105da4:	e8 9d c3 ff ff       	call   80102146 <dirlink>
80105da9:	85 c0                	test   %eax,%eax
80105dab:	79 0c                	jns    80105db9 <create+0x184>
      panic("create dots");
80105dad:	c7 04 24 de 88 10 80 	movl   $0x801088de,(%esp)
80105db4:	e8 81 a7 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbc:	8b 40 04             	mov    0x4(%eax),%eax
80105dbf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dc3:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dcd:	89 04 24             	mov    %eax,(%esp)
80105dd0:	e8 71 c3 ff ff       	call   80102146 <dirlink>
80105dd5:	85 c0                	test   %eax,%eax
80105dd7:	79 0c                	jns    80105de5 <create+0x1b0>
    panic("create: dirlink");
80105dd9:	c7 04 24 ea 88 10 80 	movl   $0x801088ea,(%esp)
80105de0:	e8 55 a7 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80105de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de8:	89 04 24             	mov    %eax,(%esp)
80105deb:	e8 ef bc ff ff       	call   80101adf <iunlockput>

  return ip;
80105df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105df3:	c9                   	leave  
80105df4:	c3                   	ret    

80105df5 <sys_open>:

int
sys_open(void)
{
80105df5:	55                   	push   %ebp
80105df6:	89 e5                	mov    %esp,%ebp
80105df8:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105dfb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e09:	e8 d9 f6 ff ff       	call   801054e7 <argstr>
80105e0e:	85 c0                	test   %eax,%eax
80105e10:	78 17                	js     80105e29 <sys_open+0x34>
80105e12:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e15:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e20:	e8 32 f6 ff ff       	call   80105457 <argint>
80105e25:	85 c0                	test   %eax,%eax
80105e27:	79 0a                	jns    80105e33 <sys_open+0x3e>
    return -1;
80105e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2e:	e9 5c 01 00 00       	jmp    80105f8f <sys_open+0x19a>

  begin_op();
80105e33:	e8 d8 d5 ff ff       	call   80103410 <begin_op>

  if(omode & O_CREATE){
80105e38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e3b:	25 00 02 00 00       	and    $0x200,%eax
80105e40:	85 c0                	test   %eax,%eax
80105e42:	74 3b                	je     80105e7f <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105e44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e47:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e4e:	00 
80105e4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e56:	00 
80105e57:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105e5e:	00 
80105e5f:	89 04 24             	mov    %eax,(%esp)
80105e62:	e8 ce fd ff ff       	call   80105c35 <create>
80105e67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105e6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e6e:	75 6b                	jne    80105edb <sys_open+0xe6>
      end_op();
80105e70:	e8 1f d6 ff ff       	call   80103494 <end_op>
      return -1;
80105e75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e7a:	e9 10 01 00 00       	jmp    80105f8f <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80105e7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e82:	89 04 24             	mov    %eax,(%esp)
80105e85:	e8 7c c5 ff ff       	call   80102406 <namei>
80105e8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e91:	75 0f                	jne    80105ea2 <sys_open+0xad>
      end_op();
80105e93:	e8 fc d5 ff ff       	call   80103494 <end_op>
      return -1;
80105e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e9d:	e9 ed 00 00 00       	jmp    80105f8f <sys_open+0x19a>
    }
    ilock(ip);
80105ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea5:	89 04 24             	mov    %eax,(%esp)
80105ea8:	e8 ae b9 ff ff       	call   8010185b <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105eb4:	66 83 f8 01          	cmp    $0x1,%ax
80105eb8:	75 21                	jne    80105edb <sys_open+0xe6>
80105eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ebd:	85 c0                	test   %eax,%eax
80105ebf:	74 1a                	je     80105edb <sys_open+0xe6>
      iunlockput(ip);
80105ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec4:	89 04 24             	mov    %eax,(%esp)
80105ec7:	e8 13 bc ff ff       	call   80101adf <iunlockput>
      end_op();
80105ecc:	e8 c3 d5 ff ff       	call   80103494 <end_op>
      return -1;
80105ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed6:	e9 b4 00 00 00       	jmp    80105f8f <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105edb:	e8 46 b0 ff ff       	call   80100f26 <filealloc>
80105ee0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ee3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ee7:	74 14                	je     80105efd <sys_open+0x108>
80105ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eec:	89 04 24             	mov    %eax,(%esp)
80105eef:	e8 2e f7 ff ff       	call   80105622 <fdalloc>
80105ef4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105ef7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105efb:	79 28                	jns    80105f25 <sys_open+0x130>
    if(f)
80105efd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f01:	74 0b                	je     80105f0e <sys_open+0x119>
      fileclose(f);
80105f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f06:	89 04 24             	mov    %eax,(%esp)
80105f09:	e8 c0 b0 ff ff       	call   80100fce <fileclose>
    iunlockput(ip);
80105f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f11:	89 04 24             	mov    %eax,(%esp)
80105f14:	e8 c6 bb ff ff       	call   80101adf <iunlockput>
    end_op();
80105f19:	e8 76 d5 ff ff       	call   80103494 <end_op>
    return -1;
80105f1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f23:	eb 6a                	jmp    80105f8f <sys_open+0x19a>
  }
  iunlock(ip);
80105f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f28:	89 04 24             	mov    %eax,(%esp)
80105f2b:	e8 79 ba ff ff       	call   801019a9 <iunlock>
  end_op();
80105f30:	e8 5f d5 ff ff       	call   80103494 <end_op>

  f->type = FD_INODE;
80105f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f38:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f44:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f4a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105f51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f54:	83 e0 01             	and    $0x1,%eax
80105f57:	85 c0                	test   %eax,%eax
80105f59:	0f 94 c0             	sete   %al
80105f5c:	89 c2                	mov    %eax,%edx
80105f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f61:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105f64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f67:	83 e0 01             	and    $0x1,%eax
80105f6a:	85 c0                	test   %eax,%eax
80105f6c:	75 0a                	jne    80105f78 <sys_open+0x183>
80105f6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f71:	83 e0 02             	and    $0x2,%eax
80105f74:	85 c0                	test   %eax,%eax
80105f76:	74 07                	je     80105f7f <sys_open+0x18a>
80105f78:	b8 01 00 00 00       	mov    $0x1,%eax
80105f7d:	eb 05                	jmp    80105f84 <sys_open+0x18f>
80105f7f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f84:	89 c2                	mov    %eax,%edx
80105f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f89:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105f8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f8f:	c9                   	leave  
80105f90:	c3                   	ret    

80105f91 <sys_mkdir>:

int
sys_mkdir(void)
{
80105f91:	55                   	push   %ebp
80105f92:	89 e5                	mov    %esp,%ebp
80105f94:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105f97:	e8 74 d4 ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105f9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fa3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105faa:	e8 38 f5 ff ff       	call   801054e7 <argstr>
80105faf:	85 c0                	test   %eax,%eax
80105fb1:	78 2c                	js     80105fdf <sys_mkdir+0x4e>
80105fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105fbd:	00 
80105fbe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fc5:	00 
80105fc6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105fcd:	00 
80105fce:	89 04 24             	mov    %eax,(%esp)
80105fd1:	e8 5f fc ff ff       	call   80105c35 <create>
80105fd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fd9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fdd:	75 0c                	jne    80105feb <sys_mkdir+0x5a>
    end_op();
80105fdf:	e8 b0 d4 ff ff       	call   80103494 <end_op>
    return -1;
80105fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe9:	eb 15                	jmp    80106000 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fee:	89 04 24             	mov    %eax,(%esp)
80105ff1:	e8 e9 ba ff ff       	call   80101adf <iunlockput>
  end_op();
80105ff6:	e8 99 d4 ff ff       	call   80103494 <end_op>
  return 0;
80105ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106000:	c9                   	leave  
80106001:	c3                   	ret    

80106002 <sys_mknod>:

int
sys_mknod(void)
{
80106002:	55                   	push   %ebp
80106003:	89 e5                	mov    %esp,%ebp
80106005:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106008:	e8 03 d4 ff ff       	call   80103410 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010600d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106010:	89 44 24 04          	mov    %eax,0x4(%esp)
80106014:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010601b:	e8 c7 f4 ff ff       	call   801054e7 <argstr>
80106020:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106023:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106027:	78 5e                	js     80106087 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106029:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010602c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106030:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106037:	e8 1b f4 ff ff       	call   80105457 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010603c:	85 c0                	test   %eax,%eax
8010603e:	78 47                	js     80106087 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106040:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106043:	89 44 24 04          	mov    %eax,0x4(%esp)
80106047:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010604e:	e8 04 f4 ff ff       	call   80105457 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106053:	85 c0                	test   %eax,%eax
80106055:	78 30                	js     80106087 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106057:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010605a:	0f bf c8             	movswl %ax,%ecx
8010605d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106060:	0f bf d0             	movswl %ax,%edx
80106063:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106066:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010606a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010606e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106075:	00 
80106076:	89 04 24             	mov    %eax,(%esp)
80106079:	e8 b7 fb ff ff       	call   80105c35 <create>
8010607e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106081:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106085:	75 0c                	jne    80106093 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106087:	e8 08 d4 ff ff       	call   80103494 <end_op>
    return -1;
8010608c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106091:	eb 15                	jmp    801060a8 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106093:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106096:	89 04 24             	mov    %eax,(%esp)
80106099:	e8 41 ba ff ff       	call   80101adf <iunlockput>
  end_op();
8010609e:	e8 f1 d3 ff ff       	call   80103494 <end_op>
  return 0;
801060a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060a8:	c9                   	leave  
801060a9:	c3                   	ret    

801060aa <sys_chdir>:

int
sys_chdir(void)
{
801060aa:	55                   	push   %ebp
801060ab:	89 e5                	mov    %esp,%ebp
801060ad:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060b0:	e8 5b d3 ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801060b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801060bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060c3:	e8 1f f4 ff ff       	call   801054e7 <argstr>
801060c8:	85 c0                	test   %eax,%eax
801060ca:	78 14                	js     801060e0 <sys_chdir+0x36>
801060cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cf:	89 04 24             	mov    %eax,(%esp)
801060d2:	e8 2f c3 ff ff       	call   80102406 <namei>
801060d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060de:	75 0c                	jne    801060ec <sys_chdir+0x42>
    end_op();
801060e0:	e8 af d3 ff ff       	call   80103494 <end_op>
    return -1;
801060e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ea:	eb 61                	jmp    8010614d <sys_chdir+0xa3>
  }
  ilock(ip);
801060ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ef:	89 04 24             	mov    %eax,(%esp)
801060f2:	e8 64 b7 ff ff       	call   8010185b <ilock>
  if(ip->type != T_DIR){
801060f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060fe:	66 83 f8 01          	cmp    $0x1,%ax
80106102:	74 17                	je     8010611b <sys_chdir+0x71>
    iunlockput(ip);
80106104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106107:	89 04 24             	mov    %eax,(%esp)
8010610a:	e8 d0 b9 ff ff       	call   80101adf <iunlockput>
    end_op();
8010610f:	e8 80 d3 ff ff       	call   80103494 <end_op>
    return -1;
80106114:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106119:	eb 32                	jmp    8010614d <sys_chdir+0xa3>
  }
  iunlock(ip);
8010611b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010611e:	89 04 24             	mov    %eax,(%esp)
80106121:	e8 83 b8 ff ff       	call   801019a9 <iunlock>
  iput(proc->cwd);
80106126:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010612c:	8b 40 68             	mov    0x68(%eax),%eax
8010612f:	89 04 24             	mov    %eax,(%esp)
80106132:	e8 d7 b8 ff ff       	call   80101a0e <iput>
  end_op();
80106137:	e8 58 d3 ff ff       	call   80103494 <end_op>
  proc->cwd = ip;
8010613c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106142:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106145:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106148:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010614d:	c9                   	leave  
8010614e:	c3                   	ret    

8010614f <sys_exec>:

int
sys_exec(void)
{
8010614f:	55                   	push   %ebp
80106150:	89 e5                	mov    %esp,%ebp
80106152:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106158:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010615b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010615f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106166:	e8 7c f3 ff ff       	call   801054e7 <argstr>
8010616b:	85 c0                	test   %eax,%eax
8010616d:	78 1a                	js     80106189 <sys_exec+0x3a>
8010616f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106175:	89 44 24 04          	mov    %eax,0x4(%esp)
80106179:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106180:	e8 d2 f2 ff ff       	call   80105457 <argint>
80106185:	85 c0                	test   %eax,%eax
80106187:	79 0a                	jns    80106193 <sys_exec+0x44>
    return -1;
80106189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618e:	e9 c8 00 00 00       	jmp    8010625b <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
80106193:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010619a:	00 
8010619b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801061a2:	00 
801061a3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801061a9:	89 04 24             	mov    %eax,(%esp)
801061ac:	e8 64 ef ff ff       	call   80105115 <memset>
  for(i=0;; i++){
801061b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801061b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061bb:	83 f8 1f             	cmp    $0x1f,%eax
801061be:	76 0a                	jbe    801061ca <sys_exec+0x7b>
      return -1;
801061c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c5:	e9 91 00 00 00       	jmp    8010625b <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801061ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cd:	c1 e0 02             	shl    $0x2,%eax
801061d0:	89 c2                	mov    %eax,%edx
801061d2:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801061d8:	01 c2                	add    %eax,%edx
801061da:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801061e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801061e4:	89 14 24             	mov    %edx,(%esp)
801061e7:	e8 cf f1 ff ff       	call   801053bb <fetchint>
801061ec:	85 c0                	test   %eax,%eax
801061ee:	79 07                	jns    801061f7 <sys_exec+0xa8>
      return -1;
801061f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f5:	eb 64                	jmp    8010625b <sys_exec+0x10c>
    if(uarg == 0){
801061f7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801061fd:	85 c0                	test   %eax,%eax
801061ff:	75 26                	jne    80106227 <sys_exec+0xd8>
      argv[i] = 0;
80106201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106204:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010620b:	00 00 00 00 
      break;
8010620f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106210:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106213:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106219:	89 54 24 04          	mov    %edx,0x4(%esp)
8010621d:	89 04 24             	mov    %eax,(%esp)
80106220:	e8 ca a8 ff ff       	call   80100aef <exec>
80106225:	eb 34                	jmp    8010625b <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106227:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010622d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106230:	c1 e2 02             	shl    $0x2,%edx
80106233:	01 c2                	add    %eax,%edx
80106235:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010623b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010623f:	89 04 24             	mov    %eax,(%esp)
80106242:	e8 ae f1 ff ff       	call   801053f5 <fetchstr>
80106247:	85 c0                	test   %eax,%eax
80106249:	79 07                	jns    80106252 <sys_exec+0x103>
      return -1;
8010624b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106250:	eb 09                	jmp    8010625b <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106252:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106256:	e9 5d ff ff ff       	jmp    801061b8 <sys_exec+0x69>
  return exec(path, argv);
}
8010625b:	c9                   	leave  
8010625c:	c3                   	ret    

8010625d <sys_pipe>:

int
sys_pipe(void)
{
8010625d:	55                   	push   %ebp
8010625e:	89 e5                	mov    %esp,%ebp
80106260:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106263:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010626a:	00 
8010626b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010626e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106272:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106279:	e8 07 f2 ff ff       	call   80105485 <argptr>
8010627e:	85 c0                	test   %eax,%eax
80106280:	79 0a                	jns    8010628c <sys_pipe+0x2f>
    return -1;
80106282:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106287:	e9 9b 00 00 00       	jmp    80106327 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
8010628c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010628f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106293:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106296:	89 04 24             	mov    %eax,(%esp)
80106299:	e8 83 dc ff ff       	call   80103f21 <pipealloc>
8010629e:	85 c0                	test   %eax,%eax
801062a0:	79 07                	jns    801062a9 <sys_pipe+0x4c>
    return -1;
801062a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a7:	eb 7e                	jmp    80106327 <sys_pipe+0xca>
  fd0 = -1;
801062a9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801062b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062b3:	89 04 24             	mov    %eax,(%esp)
801062b6:	e8 67 f3 ff ff       	call   80105622 <fdalloc>
801062bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062c2:	78 14                	js     801062d8 <sys_pipe+0x7b>
801062c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062c7:	89 04 24             	mov    %eax,(%esp)
801062ca:	e8 53 f3 ff ff       	call   80105622 <fdalloc>
801062cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062d6:	79 37                	jns    8010630f <sys_pipe+0xb2>
    if(fd0 >= 0)
801062d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062dc:	78 14                	js     801062f2 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801062de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062e7:	83 c2 08             	add    $0x8,%edx
801062ea:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801062f1:	00 
    fileclose(rf);
801062f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062f5:	89 04 24             	mov    %eax,(%esp)
801062f8:	e8 d1 ac ff ff       	call   80100fce <fileclose>
    fileclose(wf);
801062fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106300:	89 04 24             	mov    %eax,(%esp)
80106303:	e8 c6 ac ff ff       	call   80100fce <fileclose>
    return -1;
80106308:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630d:	eb 18                	jmp    80106327 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010630f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106312:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106315:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106317:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010631a:	8d 50 04             	lea    0x4(%eax),%edx
8010631d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106320:	89 02                	mov    %eax,(%edx)
  return 0;
80106322:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106327:	c9                   	leave  
80106328:	c3                   	ret    

80106329 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106329:	55                   	push   %ebp
8010632a:	89 e5                	mov    %esp,%ebp
8010632c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010632f:	e8 e4 e2 ff ff       	call   80104618 <fork>
}
80106334:	c9                   	leave  
80106335:	c3                   	ret    

80106336 <sys_exit>:

int
sys_exit(void)
{
80106336:	55                   	push   %ebp
80106337:	89 e5                	mov    %esp,%ebp
80106339:	83 ec 08             	sub    $0x8,%esp
  exit();
8010633c:	e8 52 e4 ff ff       	call   80104793 <exit>
  return 0;  // not reached
80106341:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106346:	c9                   	leave  
80106347:	c3                   	ret    

80106348 <sys_wait>:

int
sys_wait(void)
{
80106348:	55                   	push   %ebp
80106349:	89 e5                	mov    %esp,%ebp
8010634b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010634e:	e8 62 e5 ff ff       	call   801048b5 <wait>
}
80106353:	c9                   	leave  
80106354:	c3                   	ret    

80106355 <sys_kill>:

int
sys_kill(void)
{
80106355:	55                   	push   %ebp
80106356:	89 e5                	mov    %esp,%ebp
80106358:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010635b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010635e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106362:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106369:	e8 e9 f0 ff ff       	call   80105457 <argint>
8010636e:	85 c0                	test   %eax,%eax
80106370:	79 07                	jns    80106379 <sys_kill+0x24>
    return -1;
80106372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106377:	eb 0b                	jmp    80106384 <sys_kill+0x2f>
  return kill(pid);
80106379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637c:	89 04 24             	mov    %eax,(%esp)
8010637f:	e8 6d e9 ff ff       	call   80104cf1 <kill>
}
80106384:	c9                   	leave  
80106385:	c3                   	ret    

80106386 <sys_getpid>:

int
sys_getpid(void)
{
80106386:	55                   	push   %ebp
80106387:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106389:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010638f:	8b 40 10             	mov    0x10(%eax),%eax
}
80106392:	5d                   	pop    %ebp
80106393:	c3                   	ret    

80106394 <sys_sbrk>:

int
sys_sbrk(void)
{
80106394:	55                   	push   %ebp
80106395:	89 e5                	mov    %esp,%ebp
80106397:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010639a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010639d:	89 44 24 04          	mov    %eax,0x4(%esp)
801063a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063a8:	e8 aa f0 ff ff       	call   80105457 <argint>
801063ad:	85 c0                	test   %eax,%eax
801063af:	79 07                	jns    801063b8 <sys_sbrk+0x24>
    return -1;
801063b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b6:	eb 24                	jmp    801063dc <sys_sbrk+0x48>
  addr = proc->sz;
801063b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063be:	8b 00                	mov    (%eax),%eax
801063c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801063c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c6:	89 04 24             	mov    %eax,(%esp)
801063c9:	e8 a5 e1 ff ff       	call   80104573 <growproc>
801063ce:	85 c0                	test   %eax,%eax
801063d0:	79 07                	jns    801063d9 <sys_sbrk+0x45>
    return -1;
801063d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d7:	eb 03                	jmp    801063dc <sys_sbrk+0x48>
  return addr;
801063d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063dc:	c9                   	leave  
801063dd:	c3                   	ret    

801063de <sys_sleep>:

int
sys_sleep(void)
{
801063de:	55                   	push   %ebp
801063df:	89 e5                	mov    %esp,%ebp
801063e1:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801063e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801063eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063f2:	e8 60 f0 ff ff       	call   80105457 <argint>
801063f7:	85 c0                	test   %eax,%eax
801063f9:	79 07                	jns    80106402 <sys_sleep+0x24>
    return -1;
801063fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106400:	eb 6c                	jmp    8010646e <sys_sleep+0x90>
  acquire(&tickslock);
80106402:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
80106409:	e8 b3 ea ff ff       	call   80104ec1 <acquire>
  ticks0 = ticks;
8010640e:	a1 e0 50 11 80       	mov    0x801150e0,%eax
80106413:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106416:	eb 34                	jmp    8010644c <sys_sleep+0x6e>
    if(proc->killed){
80106418:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010641e:	8b 40 24             	mov    0x24(%eax),%eax
80106421:	85 c0                	test   %eax,%eax
80106423:	74 13                	je     80106438 <sys_sleep+0x5a>
      release(&tickslock);
80106425:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
8010642c:	e8 f2 ea ff ff       	call   80104f23 <release>
      return -1;
80106431:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106436:	eb 36                	jmp    8010646e <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106438:	c7 44 24 04 a0 48 11 	movl   $0x801148a0,0x4(%esp)
8010643f:	80 
80106440:	c7 04 24 e0 50 11 80 	movl   $0x801150e0,(%esp)
80106447:	e8 a2 e7 ff ff       	call   80104bee <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010644c:	a1 e0 50 11 80       	mov    0x801150e0,%eax
80106451:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106454:	89 c2                	mov    %eax,%edx
80106456:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106459:	39 c2                	cmp    %eax,%edx
8010645b:	72 bb                	jb     80106418 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010645d:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
80106464:	e8 ba ea ff ff       	call   80104f23 <release>
  return 0;
80106469:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010646e:	c9                   	leave  
8010646f:	c3                   	ret    

80106470 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106470:	55                   	push   %ebp
80106471:	89 e5                	mov    %esp,%ebp
80106473:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106476:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
8010647d:	e8 3f ea ff ff       	call   80104ec1 <acquire>
  xticks = ticks;
80106482:	a1 e0 50 11 80       	mov    0x801150e0,%eax
80106487:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010648a:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
80106491:	e8 8d ea ff ff       	call   80104f23 <release>
  return xticks;
80106496:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106499:	c9                   	leave  
8010649a:	c3                   	ret    

8010649b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010649b:	55                   	push   %ebp
8010649c:	89 e5                	mov    %esp,%ebp
8010649e:	83 ec 08             	sub    $0x8,%esp
801064a1:	8b 55 08             	mov    0x8(%ebp),%edx
801064a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801064a7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801064ab:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801064ae:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801064b2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801064b6:	ee                   	out    %al,(%dx)
}
801064b7:	c9                   	leave  
801064b8:	c3                   	ret    

801064b9 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801064b9:	55                   	push   %ebp
801064ba:	89 e5                	mov    %esp,%ebp
801064bc:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801064bf:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801064c6:	00 
801064c7:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801064ce:	e8 c8 ff ff ff       	call   8010649b <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801064d3:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801064da:	00 
801064db:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801064e2:	e8 b4 ff ff ff       	call   8010649b <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801064e7:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801064ee:	00 
801064ef:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801064f6:	e8 a0 ff ff ff       	call   8010649b <outb>
  picenable(IRQ_TIMER);
801064fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106502:	e8 ad d8 ff ff       	call   80103db4 <picenable>
}
80106507:	c9                   	leave  
80106508:	c3                   	ret    

80106509 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106509:	1e                   	push   %ds
  pushl %es
8010650a:	06                   	push   %es
  pushl %fs
8010650b:	0f a0                	push   %fs
  pushl %gs
8010650d:	0f a8                	push   %gs
  pushal
8010650f:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106510:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106514:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106516:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106518:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010651c:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010651e:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106520:	54                   	push   %esp
  call trap
80106521:	e8 d8 01 00 00       	call   801066fe <trap>
  addl $4, %esp
80106526:	83 c4 04             	add    $0x4,%esp

80106529 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106529:	61                   	popa   
  popl %gs
8010652a:	0f a9                	pop    %gs
  popl %fs
8010652c:	0f a1                	pop    %fs
  popl %es
8010652e:	07                   	pop    %es
  popl %ds
8010652f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106530:	83 c4 08             	add    $0x8,%esp
  iret
80106533:	cf                   	iret   

80106534 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106534:	55                   	push   %ebp
80106535:	89 e5                	mov    %esp,%ebp
80106537:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010653a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010653d:	83 e8 01             	sub    $0x1,%eax
80106540:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106544:	8b 45 08             	mov    0x8(%ebp),%eax
80106547:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010654b:	8b 45 08             	mov    0x8(%ebp),%eax
8010654e:	c1 e8 10             	shr    $0x10,%eax
80106551:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106555:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106558:	0f 01 18             	lidtl  (%eax)
}
8010655b:	c9                   	leave  
8010655c:	c3                   	ret    

8010655d <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010655d:	55                   	push   %ebp
8010655e:	89 e5                	mov    %esp,%ebp
80106560:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106563:	0f 20 d0             	mov    %cr2,%eax
80106566:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106569:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010656c:	c9                   	leave  
8010656d:	c3                   	ret    

8010656e <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010656e:	55                   	push   %ebp
8010656f:	89 e5                	mov    %esp,%ebp
80106571:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106574:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010657b:	e9 c3 00 00 00       	jmp    80106643 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106583:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
8010658a:	89 c2                	mov    %eax,%edx
8010658c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658f:	66 89 14 c5 e0 48 11 	mov    %dx,-0x7feeb720(,%eax,8)
80106596:	80 
80106597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659a:	66 c7 04 c5 e2 48 11 	movw   $0x8,-0x7feeb71e(,%eax,8)
801065a1:	80 08 00 
801065a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a7:	0f b6 14 c5 e4 48 11 	movzbl -0x7feeb71c(,%eax,8),%edx
801065ae:	80 
801065af:	83 e2 e0             	and    $0xffffffe0,%edx
801065b2:	88 14 c5 e4 48 11 80 	mov    %dl,-0x7feeb71c(,%eax,8)
801065b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065bc:	0f b6 14 c5 e4 48 11 	movzbl -0x7feeb71c(,%eax,8),%edx
801065c3:	80 
801065c4:	83 e2 1f             	and    $0x1f,%edx
801065c7:	88 14 c5 e4 48 11 80 	mov    %dl,-0x7feeb71c(,%eax,8)
801065ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d1:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801065d8:	80 
801065d9:	83 e2 f0             	and    $0xfffffff0,%edx
801065dc:	83 ca 0e             	or     $0xe,%edx
801065df:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801065e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e9:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801065f0:	80 
801065f1:	83 e2 ef             	and    $0xffffffef,%edx
801065f4:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801065fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fe:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
80106605:	80 
80106606:	83 e2 9f             	and    $0xffffff9f,%edx
80106609:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
80106610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106613:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
8010661a:	80 
8010661b:	83 ca 80             	or     $0xffffff80,%edx
8010661e:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
80106625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106628:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
8010662f:	c1 e8 10             	shr    $0x10,%eax
80106632:	89 c2                	mov    %eax,%edx
80106634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106637:	66 89 14 c5 e6 48 11 	mov    %dx,-0x7feeb71a(,%eax,8)
8010663e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010663f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106643:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010664a:	0f 8e 30 ff ff ff    	jle    80106580 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106650:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106655:	66 a3 e0 4a 11 80    	mov    %ax,0x80114ae0
8010665b:	66 c7 05 e2 4a 11 80 	movw   $0x8,0x80114ae2
80106662:	08 00 
80106664:	0f b6 05 e4 4a 11 80 	movzbl 0x80114ae4,%eax
8010666b:	83 e0 e0             	and    $0xffffffe0,%eax
8010666e:	a2 e4 4a 11 80       	mov    %al,0x80114ae4
80106673:	0f b6 05 e4 4a 11 80 	movzbl 0x80114ae4,%eax
8010667a:	83 e0 1f             	and    $0x1f,%eax
8010667d:	a2 e4 4a 11 80       	mov    %al,0x80114ae4
80106682:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
80106689:	83 c8 0f             	or     $0xf,%eax
8010668c:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
80106691:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
80106698:	83 e0 ef             	and    $0xffffffef,%eax
8010669b:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
801066a0:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
801066a7:	83 c8 60             	or     $0x60,%eax
801066aa:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
801066af:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
801066b6:	83 c8 80             	or     $0xffffff80,%eax
801066b9:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
801066be:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801066c3:	c1 e8 10             	shr    $0x10,%eax
801066c6:	66 a3 e6 4a 11 80    	mov    %ax,0x80114ae6
  
  initlock(&tickslock, "time");
801066cc:	c7 44 24 04 fc 88 10 	movl   $0x801088fc,0x4(%esp)
801066d3:	80 
801066d4:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
801066db:	e8 c0 e7 ff ff       	call   80104ea0 <initlock>
}
801066e0:	c9                   	leave  
801066e1:	c3                   	ret    

801066e2 <idtinit>:

void
idtinit(void)
{
801066e2:	55                   	push   %ebp
801066e3:	89 e5                	mov    %esp,%ebp
801066e5:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801066e8:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801066ef:	00 
801066f0:	c7 04 24 e0 48 11 80 	movl   $0x801148e0,(%esp)
801066f7:	e8 38 fe ff ff       	call   80106534 <lidt>
}
801066fc:	c9                   	leave  
801066fd:	c3                   	ret    

801066fe <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801066fe:	55                   	push   %ebp
801066ff:	89 e5                	mov    %esp,%ebp
80106701:	57                   	push   %edi
80106702:	56                   	push   %esi
80106703:	53                   	push   %ebx
80106704:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106707:	8b 45 08             	mov    0x8(%ebp),%eax
8010670a:	8b 40 30             	mov    0x30(%eax),%eax
8010670d:	83 f8 40             	cmp    $0x40,%eax
80106710:	75 3f                	jne    80106751 <trap+0x53>
    if(proc->killed)
80106712:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106718:	8b 40 24             	mov    0x24(%eax),%eax
8010671b:	85 c0                	test   %eax,%eax
8010671d:	74 05                	je     80106724 <trap+0x26>
      exit();
8010671f:	e8 6f e0 ff ff       	call   80104793 <exit>
    proc->tf = tf;
80106724:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010672a:	8b 55 08             	mov    0x8(%ebp),%edx
8010672d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106730:	e8 e9 ed ff ff       	call   8010551e <syscall>
    if(proc->killed)
80106735:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010673b:	8b 40 24             	mov    0x24(%eax),%eax
8010673e:	85 c0                	test   %eax,%eax
80106740:	74 0a                	je     8010674c <trap+0x4e>
      exit();
80106742:	e8 4c e0 ff ff       	call   80104793 <exit>
    return;
80106747:	e9 2d 02 00 00       	jmp    80106979 <trap+0x27b>
8010674c:	e9 28 02 00 00       	jmp    80106979 <trap+0x27b>
  }

  switch(tf->trapno){
80106751:	8b 45 08             	mov    0x8(%ebp),%eax
80106754:	8b 40 30             	mov    0x30(%eax),%eax
80106757:	83 e8 20             	sub    $0x20,%eax
8010675a:	83 f8 1f             	cmp    $0x1f,%eax
8010675d:	0f 87 bc 00 00 00    	ja     8010681f <trap+0x121>
80106763:	8b 04 85 a4 89 10 80 	mov    -0x7fef765c(,%eax,4),%eax
8010676a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010676c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106772:	0f b6 00             	movzbl (%eax),%eax
80106775:	84 c0                	test   %al,%al
80106777:	75 31                	jne    801067aa <trap+0xac>
      acquire(&tickslock);
80106779:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
80106780:	e8 3c e7 ff ff       	call   80104ec1 <acquire>
      ticks++;
80106785:	a1 e0 50 11 80       	mov    0x801150e0,%eax
8010678a:	83 c0 01             	add    $0x1,%eax
8010678d:	a3 e0 50 11 80       	mov    %eax,0x801150e0
      wakeup(&ticks);
80106792:	c7 04 24 e0 50 11 80 	movl   $0x801150e0,(%esp)
80106799:	e8 28 e5 ff ff       	call   80104cc6 <wakeup>
      release(&tickslock);
8010679e:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
801067a5:	e8 79 e7 ff ff       	call   80104f23 <release>
    }
    lapiceoi();
801067aa:	e8 21 c7 ff ff       	call   80102ed0 <lapiceoi>
    break;
801067af:	e9 41 01 00 00       	jmp    801068f5 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801067b4:	e8 25 bf ff ff       	call   801026de <ideintr>
    lapiceoi();
801067b9:	e8 12 c7 ff ff       	call   80102ed0 <lapiceoi>
    break;
801067be:	e9 32 01 00 00       	jmp    801068f5 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801067c3:	e8 d7 c4 ff ff       	call   80102c9f <kbdintr>
    lapiceoi();
801067c8:	e8 03 c7 ff ff       	call   80102ed0 <lapiceoi>
    break;
801067cd:	e9 23 01 00 00       	jmp    801068f5 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801067d2:	e8 97 03 00 00       	call   80106b6e <uartintr>
    lapiceoi();
801067d7:	e8 f4 c6 ff ff       	call   80102ed0 <lapiceoi>
    break;
801067dc:	e9 14 01 00 00       	jmp    801068f5 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067e1:	8b 45 08             	mov    0x8(%ebp),%eax
801067e4:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801067e7:	8b 45 08             	mov    0x8(%ebp),%eax
801067ea:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067ee:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801067f1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801067f7:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067fa:	0f b6 c0             	movzbl %al,%eax
801067fd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106801:	89 54 24 08          	mov    %edx,0x8(%esp)
80106805:	89 44 24 04          	mov    %eax,0x4(%esp)
80106809:	c7 04 24 04 89 10 80 	movl   $0x80108904,(%esp)
80106810:	e8 8b 9b ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106815:	e8 b6 c6 ff ff       	call   80102ed0 <lapiceoi>
    break;
8010681a:	e9 d6 00 00 00       	jmp    801068f5 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010681f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106825:	85 c0                	test   %eax,%eax
80106827:	74 11                	je     8010683a <trap+0x13c>
80106829:	8b 45 08             	mov    0x8(%ebp),%eax
8010682c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106830:	0f b7 c0             	movzwl %ax,%eax
80106833:	83 e0 03             	and    $0x3,%eax
80106836:	85 c0                	test   %eax,%eax
80106838:	75 46                	jne    80106880 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010683a:	e8 1e fd ff ff       	call   8010655d <rcr2>
8010683f:	8b 55 08             	mov    0x8(%ebp),%edx
80106842:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106845:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010684c:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010684f:	0f b6 ca             	movzbl %dl,%ecx
80106852:	8b 55 08             	mov    0x8(%ebp),%edx
80106855:	8b 52 30             	mov    0x30(%edx),%edx
80106858:	89 44 24 10          	mov    %eax,0x10(%esp)
8010685c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106860:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106864:	89 54 24 04          	mov    %edx,0x4(%esp)
80106868:	c7 04 24 28 89 10 80 	movl   $0x80108928,(%esp)
8010686f:	e8 2c 9b ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106874:	c7 04 24 5a 89 10 80 	movl   $0x8010895a,(%esp)
8010687b:	e8 ba 9c ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106880:	e8 d8 fc ff ff       	call   8010655d <rcr2>
80106885:	89 c2                	mov    %eax,%edx
80106887:	8b 45 08             	mov    0x8(%ebp),%eax
8010688a:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010688d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106893:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106896:	0f b6 f0             	movzbl %al,%esi
80106899:	8b 45 08             	mov    0x8(%ebp),%eax
8010689c:	8b 58 34             	mov    0x34(%eax),%ebx
8010689f:	8b 45 08             	mov    0x8(%ebp),%eax
801068a2:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801068a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068ab:	83 c0 6c             	add    $0x6c,%eax
801068ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801068b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068b7:	8b 40 10             	mov    0x10(%eax),%eax
801068ba:	89 54 24 1c          	mov    %edx,0x1c(%esp)
801068be:	89 7c 24 18          	mov    %edi,0x18(%esp)
801068c2:	89 74 24 14          	mov    %esi,0x14(%esp)
801068c6:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801068ca:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801068ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801068d1:	89 74 24 08          	mov    %esi,0x8(%esp)
801068d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801068d9:	c7 04 24 60 89 10 80 	movl   $0x80108960,(%esp)
801068e0:	e8 bb 9a ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801068e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068eb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801068f2:	eb 01                	jmp    801068f5 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801068f4:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801068f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068fb:	85 c0                	test   %eax,%eax
801068fd:	74 24                	je     80106923 <trap+0x225>
801068ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106905:	8b 40 24             	mov    0x24(%eax),%eax
80106908:	85 c0                	test   %eax,%eax
8010690a:	74 17                	je     80106923 <trap+0x225>
8010690c:	8b 45 08             	mov    0x8(%ebp),%eax
8010690f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106913:	0f b7 c0             	movzwl %ax,%eax
80106916:	83 e0 03             	and    $0x3,%eax
80106919:	83 f8 03             	cmp    $0x3,%eax
8010691c:	75 05                	jne    80106923 <trap+0x225>
    exit();
8010691e:	e8 70 de ff ff       	call   80104793 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106923:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106929:	85 c0                	test   %eax,%eax
8010692b:	74 1e                	je     8010694b <trap+0x24d>
8010692d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106933:	8b 40 0c             	mov    0xc(%eax),%eax
80106936:	83 f8 04             	cmp    $0x4,%eax
80106939:	75 10                	jne    8010694b <trap+0x24d>
8010693b:	8b 45 08             	mov    0x8(%ebp),%eax
8010693e:	8b 40 30             	mov    0x30(%eax),%eax
80106941:	83 f8 20             	cmp    $0x20,%eax
80106944:	75 05                	jne    8010694b <trap+0x24d>
    yield();
80106946:	e8 45 e2 ff ff       	call   80104b90 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010694b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106951:	85 c0                	test   %eax,%eax
80106953:	74 24                	je     80106979 <trap+0x27b>
80106955:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010695b:	8b 40 24             	mov    0x24(%eax),%eax
8010695e:	85 c0                	test   %eax,%eax
80106960:	74 17                	je     80106979 <trap+0x27b>
80106962:	8b 45 08             	mov    0x8(%ebp),%eax
80106965:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106969:	0f b7 c0             	movzwl %ax,%eax
8010696c:	83 e0 03             	and    $0x3,%eax
8010696f:	83 f8 03             	cmp    $0x3,%eax
80106972:	75 05                	jne    80106979 <trap+0x27b>
    exit();
80106974:	e8 1a de ff ff       	call   80104793 <exit>
}
80106979:	83 c4 3c             	add    $0x3c,%esp
8010697c:	5b                   	pop    %ebx
8010697d:	5e                   	pop    %esi
8010697e:	5f                   	pop    %edi
8010697f:	5d                   	pop    %ebp
80106980:	c3                   	ret    

80106981 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106981:	55                   	push   %ebp
80106982:	89 e5                	mov    %esp,%ebp
80106984:	83 ec 14             	sub    $0x14,%esp
80106987:	8b 45 08             	mov    0x8(%ebp),%eax
8010698a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010698e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106992:	89 c2                	mov    %eax,%edx
80106994:	ec                   	in     (%dx),%al
80106995:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106998:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010699c:	c9                   	leave  
8010699d:	c3                   	ret    

8010699e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010699e:	55                   	push   %ebp
8010699f:	89 e5                	mov    %esp,%ebp
801069a1:	83 ec 08             	sub    $0x8,%esp
801069a4:	8b 55 08             	mov    0x8(%ebp),%edx
801069a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801069aa:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801069ae:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801069b1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801069b5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801069b9:	ee                   	out    %al,(%dx)
}
801069ba:	c9                   	leave  
801069bb:	c3                   	ret    

801069bc <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801069bc:	55                   	push   %ebp
801069bd:	89 e5                	mov    %esp,%ebp
801069bf:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801069c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801069c9:	00 
801069ca:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801069d1:	e8 c8 ff ff ff       	call   8010699e <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801069d6:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801069dd:	00 
801069de:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801069e5:	e8 b4 ff ff ff       	call   8010699e <outb>
  outb(COM1+0, 115200/9600);
801069ea:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801069f1:	00 
801069f2:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801069f9:	e8 a0 ff ff ff       	call   8010699e <outb>
  outb(COM1+1, 0);
801069fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a05:	00 
80106a06:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106a0d:	e8 8c ff ff ff       	call   8010699e <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106a12:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106a19:	00 
80106a1a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106a21:	e8 78 ff ff ff       	call   8010699e <outb>
  outb(COM1+4, 0);
80106a26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a2d:	00 
80106a2e:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106a35:	e8 64 ff ff ff       	call   8010699e <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106a3a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106a41:	00 
80106a42:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106a49:	e8 50 ff ff ff       	call   8010699e <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106a4e:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a55:	e8 27 ff ff ff       	call   80106981 <inb>
80106a5a:	3c ff                	cmp    $0xff,%al
80106a5c:	75 02                	jne    80106a60 <uartinit+0xa4>
    return;
80106a5e:	eb 6a                	jmp    80106aca <uartinit+0x10e>
  uart = 1;
80106a60:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106a67:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106a6a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106a71:	e8 0b ff ff ff       	call   80106981 <inb>
  inb(COM1+0);
80106a76:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a7d:	e8 ff fe ff ff       	call   80106981 <inb>
  picenable(IRQ_COM1);
80106a82:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106a89:	e8 26 d3 ff ff       	call   80103db4 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106a8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a95:	00 
80106a96:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106a9d:	e8 bb be ff ff       	call   8010295d <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106aa2:	c7 45 f4 24 8a 10 80 	movl   $0x80108a24,-0xc(%ebp)
80106aa9:	eb 15                	jmp    80106ac0 <uartinit+0x104>
    uartputc(*p);
80106aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aae:	0f b6 00             	movzbl (%eax),%eax
80106ab1:	0f be c0             	movsbl %al,%eax
80106ab4:	89 04 24             	mov    %eax,(%esp)
80106ab7:	e8 10 00 00 00       	call   80106acc <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106abc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac3:	0f b6 00             	movzbl (%eax),%eax
80106ac6:	84 c0                	test   %al,%al
80106ac8:	75 e1                	jne    80106aab <uartinit+0xef>
    uartputc(*p);
}
80106aca:	c9                   	leave  
80106acb:	c3                   	ret    

80106acc <uartputc>:

void
uartputc(int c)
{
80106acc:	55                   	push   %ebp
80106acd:	89 e5                	mov    %esp,%ebp
80106acf:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106ad2:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106ad7:	85 c0                	test   %eax,%eax
80106ad9:	75 02                	jne    80106add <uartputc+0x11>
    return;
80106adb:	eb 4b                	jmp    80106b28 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106add:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ae4:	eb 10                	jmp    80106af6 <uartputc+0x2a>
    microdelay(10);
80106ae6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106aed:	e8 03 c4 ff ff       	call   80102ef5 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106af2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106af6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106afa:	7f 16                	jg     80106b12 <uartputc+0x46>
80106afc:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106b03:	e8 79 fe ff ff       	call   80106981 <inb>
80106b08:	0f b6 c0             	movzbl %al,%eax
80106b0b:	83 e0 20             	and    $0x20,%eax
80106b0e:	85 c0                	test   %eax,%eax
80106b10:	74 d4                	je     80106ae6 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106b12:	8b 45 08             	mov    0x8(%ebp),%eax
80106b15:	0f b6 c0             	movzbl %al,%eax
80106b18:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b1c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b23:	e8 76 fe ff ff       	call   8010699e <outb>
}
80106b28:	c9                   	leave  
80106b29:	c3                   	ret    

80106b2a <uartgetc>:

static int
uartgetc(void)
{
80106b2a:	55                   	push   %ebp
80106b2b:	89 e5                	mov    %esp,%ebp
80106b2d:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106b30:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106b35:	85 c0                	test   %eax,%eax
80106b37:	75 07                	jne    80106b40 <uartgetc+0x16>
    return -1;
80106b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b3e:	eb 2c                	jmp    80106b6c <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106b40:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106b47:	e8 35 fe ff ff       	call   80106981 <inb>
80106b4c:	0f b6 c0             	movzbl %al,%eax
80106b4f:	83 e0 01             	and    $0x1,%eax
80106b52:	85 c0                	test   %eax,%eax
80106b54:	75 07                	jne    80106b5d <uartgetc+0x33>
    return -1;
80106b56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b5b:	eb 0f                	jmp    80106b6c <uartgetc+0x42>
  return inb(COM1+0);
80106b5d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b64:	e8 18 fe ff ff       	call   80106981 <inb>
80106b69:	0f b6 c0             	movzbl %al,%eax
}
80106b6c:	c9                   	leave  
80106b6d:	c3                   	ret    

80106b6e <uartintr>:

void
uartintr(void)
{
80106b6e:	55                   	push   %ebp
80106b6f:	89 e5                	mov    %esp,%ebp
80106b71:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106b74:	c7 04 24 2a 6b 10 80 	movl   $0x80106b2a,(%esp)
80106b7b:	e8 2d 9c ff ff       	call   801007ad <consoleintr>
}
80106b80:	c9                   	leave  
80106b81:	c3                   	ret    

80106b82 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $0
80106b84:	6a 00                	push   $0x0
  jmp alltraps
80106b86:	e9 7e f9 ff ff       	jmp    80106509 <alltraps>

80106b8b <vector1>:
.globl vector1
vector1:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $1
80106b8d:	6a 01                	push   $0x1
  jmp alltraps
80106b8f:	e9 75 f9 ff ff       	jmp    80106509 <alltraps>

80106b94 <vector2>:
.globl vector2
vector2:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $2
80106b96:	6a 02                	push   $0x2
  jmp alltraps
80106b98:	e9 6c f9 ff ff       	jmp    80106509 <alltraps>

80106b9d <vector3>:
.globl vector3
vector3:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $3
80106b9f:	6a 03                	push   $0x3
  jmp alltraps
80106ba1:	e9 63 f9 ff ff       	jmp    80106509 <alltraps>

80106ba6 <vector4>:
.globl vector4
vector4:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $4
80106ba8:	6a 04                	push   $0x4
  jmp alltraps
80106baa:	e9 5a f9 ff ff       	jmp    80106509 <alltraps>

80106baf <vector5>:
.globl vector5
vector5:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $5
80106bb1:	6a 05                	push   $0x5
  jmp alltraps
80106bb3:	e9 51 f9 ff ff       	jmp    80106509 <alltraps>

80106bb8 <vector6>:
.globl vector6
vector6:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $6
80106bba:	6a 06                	push   $0x6
  jmp alltraps
80106bbc:	e9 48 f9 ff ff       	jmp    80106509 <alltraps>

80106bc1 <vector7>:
.globl vector7
vector7:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $7
80106bc3:	6a 07                	push   $0x7
  jmp alltraps
80106bc5:	e9 3f f9 ff ff       	jmp    80106509 <alltraps>

80106bca <vector8>:
.globl vector8
vector8:
  pushl $8
80106bca:	6a 08                	push   $0x8
  jmp alltraps
80106bcc:	e9 38 f9 ff ff       	jmp    80106509 <alltraps>

80106bd1 <vector9>:
.globl vector9
vector9:
  pushl $0
80106bd1:	6a 00                	push   $0x0
  pushl $9
80106bd3:	6a 09                	push   $0x9
  jmp alltraps
80106bd5:	e9 2f f9 ff ff       	jmp    80106509 <alltraps>

80106bda <vector10>:
.globl vector10
vector10:
  pushl $10
80106bda:	6a 0a                	push   $0xa
  jmp alltraps
80106bdc:	e9 28 f9 ff ff       	jmp    80106509 <alltraps>

80106be1 <vector11>:
.globl vector11
vector11:
  pushl $11
80106be1:	6a 0b                	push   $0xb
  jmp alltraps
80106be3:	e9 21 f9 ff ff       	jmp    80106509 <alltraps>

80106be8 <vector12>:
.globl vector12
vector12:
  pushl $12
80106be8:	6a 0c                	push   $0xc
  jmp alltraps
80106bea:	e9 1a f9 ff ff       	jmp    80106509 <alltraps>

80106bef <vector13>:
.globl vector13
vector13:
  pushl $13
80106bef:	6a 0d                	push   $0xd
  jmp alltraps
80106bf1:	e9 13 f9 ff ff       	jmp    80106509 <alltraps>

80106bf6 <vector14>:
.globl vector14
vector14:
  pushl $14
80106bf6:	6a 0e                	push   $0xe
  jmp alltraps
80106bf8:	e9 0c f9 ff ff       	jmp    80106509 <alltraps>

80106bfd <vector15>:
.globl vector15
vector15:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $15
80106bff:	6a 0f                	push   $0xf
  jmp alltraps
80106c01:	e9 03 f9 ff ff       	jmp    80106509 <alltraps>

80106c06 <vector16>:
.globl vector16
vector16:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $16
80106c08:	6a 10                	push   $0x10
  jmp alltraps
80106c0a:	e9 fa f8 ff ff       	jmp    80106509 <alltraps>

80106c0f <vector17>:
.globl vector17
vector17:
  pushl $17
80106c0f:	6a 11                	push   $0x11
  jmp alltraps
80106c11:	e9 f3 f8 ff ff       	jmp    80106509 <alltraps>

80106c16 <vector18>:
.globl vector18
vector18:
  pushl $0
80106c16:	6a 00                	push   $0x0
  pushl $18
80106c18:	6a 12                	push   $0x12
  jmp alltraps
80106c1a:	e9 ea f8 ff ff       	jmp    80106509 <alltraps>

80106c1f <vector19>:
.globl vector19
vector19:
  pushl $0
80106c1f:	6a 00                	push   $0x0
  pushl $19
80106c21:	6a 13                	push   $0x13
  jmp alltraps
80106c23:	e9 e1 f8 ff ff       	jmp    80106509 <alltraps>

80106c28 <vector20>:
.globl vector20
vector20:
  pushl $0
80106c28:	6a 00                	push   $0x0
  pushl $20
80106c2a:	6a 14                	push   $0x14
  jmp alltraps
80106c2c:	e9 d8 f8 ff ff       	jmp    80106509 <alltraps>

80106c31 <vector21>:
.globl vector21
vector21:
  pushl $0
80106c31:	6a 00                	push   $0x0
  pushl $21
80106c33:	6a 15                	push   $0x15
  jmp alltraps
80106c35:	e9 cf f8 ff ff       	jmp    80106509 <alltraps>

80106c3a <vector22>:
.globl vector22
vector22:
  pushl $0
80106c3a:	6a 00                	push   $0x0
  pushl $22
80106c3c:	6a 16                	push   $0x16
  jmp alltraps
80106c3e:	e9 c6 f8 ff ff       	jmp    80106509 <alltraps>

80106c43 <vector23>:
.globl vector23
vector23:
  pushl $0
80106c43:	6a 00                	push   $0x0
  pushl $23
80106c45:	6a 17                	push   $0x17
  jmp alltraps
80106c47:	e9 bd f8 ff ff       	jmp    80106509 <alltraps>

80106c4c <vector24>:
.globl vector24
vector24:
  pushl $0
80106c4c:	6a 00                	push   $0x0
  pushl $24
80106c4e:	6a 18                	push   $0x18
  jmp alltraps
80106c50:	e9 b4 f8 ff ff       	jmp    80106509 <alltraps>

80106c55 <vector25>:
.globl vector25
vector25:
  pushl $0
80106c55:	6a 00                	push   $0x0
  pushl $25
80106c57:	6a 19                	push   $0x19
  jmp alltraps
80106c59:	e9 ab f8 ff ff       	jmp    80106509 <alltraps>

80106c5e <vector26>:
.globl vector26
vector26:
  pushl $0
80106c5e:	6a 00                	push   $0x0
  pushl $26
80106c60:	6a 1a                	push   $0x1a
  jmp alltraps
80106c62:	e9 a2 f8 ff ff       	jmp    80106509 <alltraps>

80106c67 <vector27>:
.globl vector27
vector27:
  pushl $0
80106c67:	6a 00                	push   $0x0
  pushl $27
80106c69:	6a 1b                	push   $0x1b
  jmp alltraps
80106c6b:	e9 99 f8 ff ff       	jmp    80106509 <alltraps>

80106c70 <vector28>:
.globl vector28
vector28:
  pushl $0
80106c70:	6a 00                	push   $0x0
  pushl $28
80106c72:	6a 1c                	push   $0x1c
  jmp alltraps
80106c74:	e9 90 f8 ff ff       	jmp    80106509 <alltraps>

80106c79 <vector29>:
.globl vector29
vector29:
  pushl $0
80106c79:	6a 00                	push   $0x0
  pushl $29
80106c7b:	6a 1d                	push   $0x1d
  jmp alltraps
80106c7d:	e9 87 f8 ff ff       	jmp    80106509 <alltraps>

80106c82 <vector30>:
.globl vector30
vector30:
  pushl $0
80106c82:	6a 00                	push   $0x0
  pushl $30
80106c84:	6a 1e                	push   $0x1e
  jmp alltraps
80106c86:	e9 7e f8 ff ff       	jmp    80106509 <alltraps>

80106c8b <vector31>:
.globl vector31
vector31:
  pushl $0
80106c8b:	6a 00                	push   $0x0
  pushl $31
80106c8d:	6a 1f                	push   $0x1f
  jmp alltraps
80106c8f:	e9 75 f8 ff ff       	jmp    80106509 <alltraps>

80106c94 <vector32>:
.globl vector32
vector32:
  pushl $0
80106c94:	6a 00                	push   $0x0
  pushl $32
80106c96:	6a 20                	push   $0x20
  jmp alltraps
80106c98:	e9 6c f8 ff ff       	jmp    80106509 <alltraps>

80106c9d <vector33>:
.globl vector33
vector33:
  pushl $0
80106c9d:	6a 00                	push   $0x0
  pushl $33
80106c9f:	6a 21                	push   $0x21
  jmp alltraps
80106ca1:	e9 63 f8 ff ff       	jmp    80106509 <alltraps>

80106ca6 <vector34>:
.globl vector34
vector34:
  pushl $0
80106ca6:	6a 00                	push   $0x0
  pushl $34
80106ca8:	6a 22                	push   $0x22
  jmp alltraps
80106caa:	e9 5a f8 ff ff       	jmp    80106509 <alltraps>

80106caf <vector35>:
.globl vector35
vector35:
  pushl $0
80106caf:	6a 00                	push   $0x0
  pushl $35
80106cb1:	6a 23                	push   $0x23
  jmp alltraps
80106cb3:	e9 51 f8 ff ff       	jmp    80106509 <alltraps>

80106cb8 <vector36>:
.globl vector36
vector36:
  pushl $0
80106cb8:	6a 00                	push   $0x0
  pushl $36
80106cba:	6a 24                	push   $0x24
  jmp alltraps
80106cbc:	e9 48 f8 ff ff       	jmp    80106509 <alltraps>

80106cc1 <vector37>:
.globl vector37
vector37:
  pushl $0
80106cc1:	6a 00                	push   $0x0
  pushl $37
80106cc3:	6a 25                	push   $0x25
  jmp alltraps
80106cc5:	e9 3f f8 ff ff       	jmp    80106509 <alltraps>

80106cca <vector38>:
.globl vector38
vector38:
  pushl $0
80106cca:	6a 00                	push   $0x0
  pushl $38
80106ccc:	6a 26                	push   $0x26
  jmp alltraps
80106cce:	e9 36 f8 ff ff       	jmp    80106509 <alltraps>

80106cd3 <vector39>:
.globl vector39
vector39:
  pushl $0
80106cd3:	6a 00                	push   $0x0
  pushl $39
80106cd5:	6a 27                	push   $0x27
  jmp alltraps
80106cd7:	e9 2d f8 ff ff       	jmp    80106509 <alltraps>

80106cdc <vector40>:
.globl vector40
vector40:
  pushl $0
80106cdc:	6a 00                	push   $0x0
  pushl $40
80106cde:	6a 28                	push   $0x28
  jmp alltraps
80106ce0:	e9 24 f8 ff ff       	jmp    80106509 <alltraps>

80106ce5 <vector41>:
.globl vector41
vector41:
  pushl $0
80106ce5:	6a 00                	push   $0x0
  pushl $41
80106ce7:	6a 29                	push   $0x29
  jmp alltraps
80106ce9:	e9 1b f8 ff ff       	jmp    80106509 <alltraps>

80106cee <vector42>:
.globl vector42
vector42:
  pushl $0
80106cee:	6a 00                	push   $0x0
  pushl $42
80106cf0:	6a 2a                	push   $0x2a
  jmp alltraps
80106cf2:	e9 12 f8 ff ff       	jmp    80106509 <alltraps>

80106cf7 <vector43>:
.globl vector43
vector43:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $43
80106cf9:	6a 2b                	push   $0x2b
  jmp alltraps
80106cfb:	e9 09 f8 ff ff       	jmp    80106509 <alltraps>

80106d00 <vector44>:
.globl vector44
vector44:
  pushl $0
80106d00:	6a 00                	push   $0x0
  pushl $44
80106d02:	6a 2c                	push   $0x2c
  jmp alltraps
80106d04:	e9 00 f8 ff ff       	jmp    80106509 <alltraps>

80106d09 <vector45>:
.globl vector45
vector45:
  pushl $0
80106d09:	6a 00                	push   $0x0
  pushl $45
80106d0b:	6a 2d                	push   $0x2d
  jmp alltraps
80106d0d:	e9 f7 f7 ff ff       	jmp    80106509 <alltraps>

80106d12 <vector46>:
.globl vector46
vector46:
  pushl $0
80106d12:	6a 00                	push   $0x0
  pushl $46
80106d14:	6a 2e                	push   $0x2e
  jmp alltraps
80106d16:	e9 ee f7 ff ff       	jmp    80106509 <alltraps>

80106d1b <vector47>:
.globl vector47
vector47:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $47
80106d1d:	6a 2f                	push   $0x2f
  jmp alltraps
80106d1f:	e9 e5 f7 ff ff       	jmp    80106509 <alltraps>

80106d24 <vector48>:
.globl vector48
vector48:
  pushl $0
80106d24:	6a 00                	push   $0x0
  pushl $48
80106d26:	6a 30                	push   $0x30
  jmp alltraps
80106d28:	e9 dc f7 ff ff       	jmp    80106509 <alltraps>

80106d2d <vector49>:
.globl vector49
vector49:
  pushl $0
80106d2d:	6a 00                	push   $0x0
  pushl $49
80106d2f:	6a 31                	push   $0x31
  jmp alltraps
80106d31:	e9 d3 f7 ff ff       	jmp    80106509 <alltraps>

80106d36 <vector50>:
.globl vector50
vector50:
  pushl $0
80106d36:	6a 00                	push   $0x0
  pushl $50
80106d38:	6a 32                	push   $0x32
  jmp alltraps
80106d3a:	e9 ca f7 ff ff       	jmp    80106509 <alltraps>

80106d3f <vector51>:
.globl vector51
vector51:
  pushl $0
80106d3f:	6a 00                	push   $0x0
  pushl $51
80106d41:	6a 33                	push   $0x33
  jmp alltraps
80106d43:	e9 c1 f7 ff ff       	jmp    80106509 <alltraps>

80106d48 <vector52>:
.globl vector52
vector52:
  pushl $0
80106d48:	6a 00                	push   $0x0
  pushl $52
80106d4a:	6a 34                	push   $0x34
  jmp alltraps
80106d4c:	e9 b8 f7 ff ff       	jmp    80106509 <alltraps>

80106d51 <vector53>:
.globl vector53
vector53:
  pushl $0
80106d51:	6a 00                	push   $0x0
  pushl $53
80106d53:	6a 35                	push   $0x35
  jmp alltraps
80106d55:	e9 af f7 ff ff       	jmp    80106509 <alltraps>

80106d5a <vector54>:
.globl vector54
vector54:
  pushl $0
80106d5a:	6a 00                	push   $0x0
  pushl $54
80106d5c:	6a 36                	push   $0x36
  jmp alltraps
80106d5e:	e9 a6 f7 ff ff       	jmp    80106509 <alltraps>

80106d63 <vector55>:
.globl vector55
vector55:
  pushl $0
80106d63:	6a 00                	push   $0x0
  pushl $55
80106d65:	6a 37                	push   $0x37
  jmp alltraps
80106d67:	e9 9d f7 ff ff       	jmp    80106509 <alltraps>

80106d6c <vector56>:
.globl vector56
vector56:
  pushl $0
80106d6c:	6a 00                	push   $0x0
  pushl $56
80106d6e:	6a 38                	push   $0x38
  jmp alltraps
80106d70:	e9 94 f7 ff ff       	jmp    80106509 <alltraps>

80106d75 <vector57>:
.globl vector57
vector57:
  pushl $0
80106d75:	6a 00                	push   $0x0
  pushl $57
80106d77:	6a 39                	push   $0x39
  jmp alltraps
80106d79:	e9 8b f7 ff ff       	jmp    80106509 <alltraps>

80106d7e <vector58>:
.globl vector58
vector58:
  pushl $0
80106d7e:	6a 00                	push   $0x0
  pushl $58
80106d80:	6a 3a                	push   $0x3a
  jmp alltraps
80106d82:	e9 82 f7 ff ff       	jmp    80106509 <alltraps>

80106d87 <vector59>:
.globl vector59
vector59:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $59
80106d89:	6a 3b                	push   $0x3b
  jmp alltraps
80106d8b:	e9 79 f7 ff ff       	jmp    80106509 <alltraps>

80106d90 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d90:	6a 00                	push   $0x0
  pushl $60
80106d92:	6a 3c                	push   $0x3c
  jmp alltraps
80106d94:	e9 70 f7 ff ff       	jmp    80106509 <alltraps>

80106d99 <vector61>:
.globl vector61
vector61:
  pushl $0
80106d99:	6a 00                	push   $0x0
  pushl $61
80106d9b:	6a 3d                	push   $0x3d
  jmp alltraps
80106d9d:	e9 67 f7 ff ff       	jmp    80106509 <alltraps>

80106da2 <vector62>:
.globl vector62
vector62:
  pushl $0
80106da2:	6a 00                	push   $0x0
  pushl $62
80106da4:	6a 3e                	push   $0x3e
  jmp alltraps
80106da6:	e9 5e f7 ff ff       	jmp    80106509 <alltraps>

80106dab <vector63>:
.globl vector63
vector63:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $63
80106dad:	6a 3f                	push   $0x3f
  jmp alltraps
80106daf:	e9 55 f7 ff ff       	jmp    80106509 <alltraps>

80106db4 <vector64>:
.globl vector64
vector64:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $64
80106db6:	6a 40                	push   $0x40
  jmp alltraps
80106db8:	e9 4c f7 ff ff       	jmp    80106509 <alltraps>

80106dbd <vector65>:
.globl vector65
vector65:
  pushl $0
80106dbd:	6a 00                	push   $0x0
  pushl $65
80106dbf:	6a 41                	push   $0x41
  jmp alltraps
80106dc1:	e9 43 f7 ff ff       	jmp    80106509 <alltraps>

80106dc6 <vector66>:
.globl vector66
vector66:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $66
80106dc8:	6a 42                	push   $0x42
  jmp alltraps
80106dca:	e9 3a f7 ff ff       	jmp    80106509 <alltraps>

80106dcf <vector67>:
.globl vector67
vector67:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $67
80106dd1:	6a 43                	push   $0x43
  jmp alltraps
80106dd3:	e9 31 f7 ff ff       	jmp    80106509 <alltraps>

80106dd8 <vector68>:
.globl vector68
vector68:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $68
80106dda:	6a 44                	push   $0x44
  jmp alltraps
80106ddc:	e9 28 f7 ff ff       	jmp    80106509 <alltraps>

80106de1 <vector69>:
.globl vector69
vector69:
  pushl $0
80106de1:	6a 00                	push   $0x0
  pushl $69
80106de3:	6a 45                	push   $0x45
  jmp alltraps
80106de5:	e9 1f f7 ff ff       	jmp    80106509 <alltraps>

80106dea <vector70>:
.globl vector70
vector70:
  pushl $0
80106dea:	6a 00                	push   $0x0
  pushl $70
80106dec:	6a 46                	push   $0x46
  jmp alltraps
80106dee:	e9 16 f7 ff ff       	jmp    80106509 <alltraps>

80106df3 <vector71>:
.globl vector71
vector71:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $71
80106df5:	6a 47                	push   $0x47
  jmp alltraps
80106df7:	e9 0d f7 ff ff       	jmp    80106509 <alltraps>

80106dfc <vector72>:
.globl vector72
vector72:
  pushl $0
80106dfc:	6a 00                	push   $0x0
  pushl $72
80106dfe:	6a 48                	push   $0x48
  jmp alltraps
80106e00:	e9 04 f7 ff ff       	jmp    80106509 <alltraps>

80106e05 <vector73>:
.globl vector73
vector73:
  pushl $0
80106e05:	6a 00                	push   $0x0
  pushl $73
80106e07:	6a 49                	push   $0x49
  jmp alltraps
80106e09:	e9 fb f6 ff ff       	jmp    80106509 <alltraps>

80106e0e <vector74>:
.globl vector74
vector74:
  pushl $0
80106e0e:	6a 00                	push   $0x0
  pushl $74
80106e10:	6a 4a                	push   $0x4a
  jmp alltraps
80106e12:	e9 f2 f6 ff ff       	jmp    80106509 <alltraps>

80106e17 <vector75>:
.globl vector75
vector75:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $75
80106e19:	6a 4b                	push   $0x4b
  jmp alltraps
80106e1b:	e9 e9 f6 ff ff       	jmp    80106509 <alltraps>

80106e20 <vector76>:
.globl vector76
vector76:
  pushl $0
80106e20:	6a 00                	push   $0x0
  pushl $76
80106e22:	6a 4c                	push   $0x4c
  jmp alltraps
80106e24:	e9 e0 f6 ff ff       	jmp    80106509 <alltraps>

80106e29 <vector77>:
.globl vector77
vector77:
  pushl $0
80106e29:	6a 00                	push   $0x0
  pushl $77
80106e2b:	6a 4d                	push   $0x4d
  jmp alltraps
80106e2d:	e9 d7 f6 ff ff       	jmp    80106509 <alltraps>

80106e32 <vector78>:
.globl vector78
vector78:
  pushl $0
80106e32:	6a 00                	push   $0x0
  pushl $78
80106e34:	6a 4e                	push   $0x4e
  jmp alltraps
80106e36:	e9 ce f6 ff ff       	jmp    80106509 <alltraps>

80106e3b <vector79>:
.globl vector79
vector79:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $79
80106e3d:	6a 4f                	push   $0x4f
  jmp alltraps
80106e3f:	e9 c5 f6 ff ff       	jmp    80106509 <alltraps>

80106e44 <vector80>:
.globl vector80
vector80:
  pushl $0
80106e44:	6a 00                	push   $0x0
  pushl $80
80106e46:	6a 50                	push   $0x50
  jmp alltraps
80106e48:	e9 bc f6 ff ff       	jmp    80106509 <alltraps>

80106e4d <vector81>:
.globl vector81
vector81:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $81
80106e4f:	6a 51                	push   $0x51
  jmp alltraps
80106e51:	e9 b3 f6 ff ff       	jmp    80106509 <alltraps>

80106e56 <vector82>:
.globl vector82
vector82:
  pushl $0
80106e56:	6a 00                	push   $0x0
  pushl $82
80106e58:	6a 52                	push   $0x52
  jmp alltraps
80106e5a:	e9 aa f6 ff ff       	jmp    80106509 <alltraps>

80106e5f <vector83>:
.globl vector83
vector83:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $83
80106e61:	6a 53                	push   $0x53
  jmp alltraps
80106e63:	e9 a1 f6 ff ff       	jmp    80106509 <alltraps>

80106e68 <vector84>:
.globl vector84
vector84:
  pushl $0
80106e68:	6a 00                	push   $0x0
  pushl $84
80106e6a:	6a 54                	push   $0x54
  jmp alltraps
80106e6c:	e9 98 f6 ff ff       	jmp    80106509 <alltraps>

80106e71 <vector85>:
.globl vector85
vector85:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $85
80106e73:	6a 55                	push   $0x55
  jmp alltraps
80106e75:	e9 8f f6 ff ff       	jmp    80106509 <alltraps>

80106e7a <vector86>:
.globl vector86
vector86:
  pushl $0
80106e7a:	6a 00                	push   $0x0
  pushl $86
80106e7c:	6a 56                	push   $0x56
  jmp alltraps
80106e7e:	e9 86 f6 ff ff       	jmp    80106509 <alltraps>

80106e83 <vector87>:
.globl vector87
vector87:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $87
80106e85:	6a 57                	push   $0x57
  jmp alltraps
80106e87:	e9 7d f6 ff ff       	jmp    80106509 <alltraps>

80106e8c <vector88>:
.globl vector88
vector88:
  pushl $0
80106e8c:	6a 00                	push   $0x0
  pushl $88
80106e8e:	6a 58                	push   $0x58
  jmp alltraps
80106e90:	e9 74 f6 ff ff       	jmp    80106509 <alltraps>

80106e95 <vector89>:
.globl vector89
vector89:
  pushl $0
80106e95:	6a 00                	push   $0x0
  pushl $89
80106e97:	6a 59                	push   $0x59
  jmp alltraps
80106e99:	e9 6b f6 ff ff       	jmp    80106509 <alltraps>

80106e9e <vector90>:
.globl vector90
vector90:
  pushl $0
80106e9e:	6a 00                	push   $0x0
  pushl $90
80106ea0:	6a 5a                	push   $0x5a
  jmp alltraps
80106ea2:	e9 62 f6 ff ff       	jmp    80106509 <alltraps>

80106ea7 <vector91>:
.globl vector91
vector91:
  pushl $0
80106ea7:	6a 00                	push   $0x0
  pushl $91
80106ea9:	6a 5b                	push   $0x5b
  jmp alltraps
80106eab:	e9 59 f6 ff ff       	jmp    80106509 <alltraps>

80106eb0 <vector92>:
.globl vector92
vector92:
  pushl $0
80106eb0:	6a 00                	push   $0x0
  pushl $92
80106eb2:	6a 5c                	push   $0x5c
  jmp alltraps
80106eb4:	e9 50 f6 ff ff       	jmp    80106509 <alltraps>

80106eb9 <vector93>:
.globl vector93
vector93:
  pushl $0
80106eb9:	6a 00                	push   $0x0
  pushl $93
80106ebb:	6a 5d                	push   $0x5d
  jmp alltraps
80106ebd:	e9 47 f6 ff ff       	jmp    80106509 <alltraps>

80106ec2 <vector94>:
.globl vector94
vector94:
  pushl $0
80106ec2:	6a 00                	push   $0x0
  pushl $94
80106ec4:	6a 5e                	push   $0x5e
  jmp alltraps
80106ec6:	e9 3e f6 ff ff       	jmp    80106509 <alltraps>

80106ecb <vector95>:
.globl vector95
vector95:
  pushl $0
80106ecb:	6a 00                	push   $0x0
  pushl $95
80106ecd:	6a 5f                	push   $0x5f
  jmp alltraps
80106ecf:	e9 35 f6 ff ff       	jmp    80106509 <alltraps>

80106ed4 <vector96>:
.globl vector96
vector96:
  pushl $0
80106ed4:	6a 00                	push   $0x0
  pushl $96
80106ed6:	6a 60                	push   $0x60
  jmp alltraps
80106ed8:	e9 2c f6 ff ff       	jmp    80106509 <alltraps>

80106edd <vector97>:
.globl vector97
vector97:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $97
80106edf:	6a 61                	push   $0x61
  jmp alltraps
80106ee1:	e9 23 f6 ff ff       	jmp    80106509 <alltraps>

80106ee6 <vector98>:
.globl vector98
vector98:
  pushl $0
80106ee6:	6a 00                	push   $0x0
  pushl $98
80106ee8:	6a 62                	push   $0x62
  jmp alltraps
80106eea:	e9 1a f6 ff ff       	jmp    80106509 <alltraps>

80106eef <vector99>:
.globl vector99
vector99:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $99
80106ef1:	6a 63                	push   $0x63
  jmp alltraps
80106ef3:	e9 11 f6 ff ff       	jmp    80106509 <alltraps>

80106ef8 <vector100>:
.globl vector100
vector100:
  pushl $0
80106ef8:	6a 00                	push   $0x0
  pushl $100
80106efa:	6a 64                	push   $0x64
  jmp alltraps
80106efc:	e9 08 f6 ff ff       	jmp    80106509 <alltraps>

80106f01 <vector101>:
.globl vector101
vector101:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $101
80106f03:	6a 65                	push   $0x65
  jmp alltraps
80106f05:	e9 ff f5 ff ff       	jmp    80106509 <alltraps>

80106f0a <vector102>:
.globl vector102
vector102:
  pushl $0
80106f0a:	6a 00                	push   $0x0
  pushl $102
80106f0c:	6a 66                	push   $0x66
  jmp alltraps
80106f0e:	e9 f6 f5 ff ff       	jmp    80106509 <alltraps>

80106f13 <vector103>:
.globl vector103
vector103:
  pushl $0
80106f13:	6a 00                	push   $0x0
  pushl $103
80106f15:	6a 67                	push   $0x67
  jmp alltraps
80106f17:	e9 ed f5 ff ff       	jmp    80106509 <alltraps>

80106f1c <vector104>:
.globl vector104
vector104:
  pushl $0
80106f1c:	6a 00                	push   $0x0
  pushl $104
80106f1e:	6a 68                	push   $0x68
  jmp alltraps
80106f20:	e9 e4 f5 ff ff       	jmp    80106509 <alltraps>

80106f25 <vector105>:
.globl vector105
vector105:
  pushl $0
80106f25:	6a 00                	push   $0x0
  pushl $105
80106f27:	6a 69                	push   $0x69
  jmp alltraps
80106f29:	e9 db f5 ff ff       	jmp    80106509 <alltraps>

80106f2e <vector106>:
.globl vector106
vector106:
  pushl $0
80106f2e:	6a 00                	push   $0x0
  pushl $106
80106f30:	6a 6a                	push   $0x6a
  jmp alltraps
80106f32:	e9 d2 f5 ff ff       	jmp    80106509 <alltraps>

80106f37 <vector107>:
.globl vector107
vector107:
  pushl $0
80106f37:	6a 00                	push   $0x0
  pushl $107
80106f39:	6a 6b                	push   $0x6b
  jmp alltraps
80106f3b:	e9 c9 f5 ff ff       	jmp    80106509 <alltraps>

80106f40 <vector108>:
.globl vector108
vector108:
  pushl $0
80106f40:	6a 00                	push   $0x0
  pushl $108
80106f42:	6a 6c                	push   $0x6c
  jmp alltraps
80106f44:	e9 c0 f5 ff ff       	jmp    80106509 <alltraps>

80106f49 <vector109>:
.globl vector109
vector109:
  pushl $0
80106f49:	6a 00                	push   $0x0
  pushl $109
80106f4b:	6a 6d                	push   $0x6d
  jmp alltraps
80106f4d:	e9 b7 f5 ff ff       	jmp    80106509 <alltraps>

80106f52 <vector110>:
.globl vector110
vector110:
  pushl $0
80106f52:	6a 00                	push   $0x0
  pushl $110
80106f54:	6a 6e                	push   $0x6e
  jmp alltraps
80106f56:	e9 ae f5 ff ff       	jmp    80106509 <alltraps>

80106f5b <vector111>:
.globl vector111
vector111:
  pushl $0
80106f5b:	6a 00                	push   $0x0
  pushl $111
80106f5d:	6a 6f                	push   $0x6f
  jmp alltraps
80106f5f:	e9 a5 f5 ff ff       	jmp    80106509 <alltraps>

80106f64 <vector112>:
.globl vector112
vector112:
  pushl $0
80106f64:	6a 00                	push   $0x0
  pushl $112
80106f66:	6a 70                	push   $0x70
  jmp alltraps
80106f68:	e9 9c f5 ff ff       	jmp    80106509 <alltraps>

80106f6d <vector113>:
.globl vector113
vector113:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $113
80106f6f:	6a 71                	push   $0x71
  jmp alltraps
80106f71:	e9 93 f5 ff ff       	jmp    80106509 <alltraps>

80106f76 <vector114>:
.globl vector114
vector114:
  pushl $0
80106f76:	6a 00                	push   $0x0
  pushl $114
80106f78:	6a 72                	push   $0x72
  jmp alltraps
80106f7a:	e9 8a f5 ff ff       	jmp    80106509 <alltraps>

80106f7f <vector115>:
.globl vector115
vector115:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $115
80106f81:	6a 73                	push   $0x73
  jmp alltraps
80106f83:	e9 81 f5 ff ff       	jmp    80106509 <alltraps>

80106f88 <vector116>:
.globl vector116
vector116:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $116
80106f8a:	6a 74                	push   $0x74
  jmp alltraps
80106f8c:	e9 78 f5 ff ff       	jmp    80106509 <alltraps>

80106f91 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $117
80106f93:	6a 75                	push   $0x75
  jmp alltraps
80106f95:	e9 6f f5 ff ff       	jmp    80106509 <alltraps>

80106f9a <vector118>:
.globl vector118
vector118:
  pushl $0
80106f9a:	6a 00                	push   $0x0
  pushl $118
80106f9c:	6a 76                	push   $0x76
  jmp alltraps
80106f9e:	e9 66 f5 ff ff       	jmp    80106509 <alltraps>

80106fa3 <vector119>:
.globl vector119
vector119:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $119
80106fa5:	6a 77                	push   $0x77
  jmp alltraps
80106fa7:	e9 5d f5 ff ff       	jmp    80106509 <alltraps>

80106fac <vector120>:
.globl vector120
vector120:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $120
80106fae:	6a 78                	push   $0x78
  jmp alltraps
80106fb0:	e9 54 f5 ff ff       	jmp    80106509 <alltraps>

80106fb5 <vector121>:
.globl vector121
vector121:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $121
80106fb7:	6a 79                	push   $0x79
  jmp alltraps
80106fb9:	e9 4b f5 ff ff       	jmp    80106509 <alltraps>

80106fbe <vector122>:
.globl vector122
vector122:
  pushl $0
80106fbe:	6a 00                	push   $0x0
  pushl $122
80106fc0:	6a 7a                	push   $0x7a
  jmp alltraps
80106fc2:	e9 42 f5 ff ff       	jmp    80106509 <alltraps>

80106fc7 <vector123>:
.globl vector123
vector123:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $123
80106fc9:	6a 7b                	push   $0x7b
  jmp alltraps
80106fcb:	e9 39 f5 ff ff       	jmp    80106509 <alltraps>

80106fd0 <vector124>:
.globl vector124
vector124:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $124
80106fd2:	6a 7c                	push   $0x7c
  jmp alltraps
80106fd4:	e9 30 f5 ff ff       	jmp    80106509 <alltraps>

80106fd9 <vector125>:
.globl vector125
vector125:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $125
80106fdb:	6a 7d                	push   $0x7d
  jmp alltraps
80106fdd:	e9 27 f5 ff ff       	jmp    80106509 <alltraps>

80106fe2 <vector126>:
.globl vector126
vector126:
  pushl $0
80106fe2:	6a 00                	push   $0x0
  pushl $126
80106fe4:	6a 7e                	push   $0x7e
  jmp alltraps
80106fe6:	e9 1e f5 ff ff       	jmp    80106509 <alltraps>

80106feb <vector127>:
.globl vector127
vector127:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $127
80106fed:	6a 7f                	push   $0x7f
  jmp alltraps
80106fef:	e9 15 f5 ff ff       	jmp    80106509 <alltraps>

80106ff4 <vector128>:
.globl vector128
vector128:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $128
80106ff6:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106ffb:	e9 09 f5 ff ff       	jmp    80106509 <alltraps>

80107000 <vector129>:
.globl vector129
vector129:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $129
80107002:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107007:	e9 fd f4 ff ff       	jmp    80106509 <alltraps>

8010700c <vector130>:
.globl vector130
vector130:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $130
8010700e:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107013:	e9 f1 f4 ff ff       	jmp    80106509 <alltraps>

80107018 <vector131>:
.globl vector131
vector131:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $131
8010701a:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010701f:	e9 e5 f4 ff ff       	jmp    80106509 <alltraps>

80107024 <vector132>:
.globl vector132
vector132:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $132
80107026:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010702b:	e9 d9 f4 ff ff       	jmp    80106509 <alltraps>

80107030 <vector133>:
.globl vector133
vector133:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $133
80107032:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107037:	e9 cd f4 ff ff       	jmp    80106509 <alltraps>

8010703c <vector134>:
.globl vector134
vector134:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $134
8010703e:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107043:	e9 c1 f4 ff ff       	jmp    80106509 <alltraps>

80107048 <vector135>:
.globl vector135
vector135:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $135
8010704a:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010704f:	e9 b5 f4 ff ff       	jmp    80106509 <alltraps>

80107054 <vector136>:
.globl vector136
vector136:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $136
80107056:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010705b:	e9 a9 f4 ff ff       	jmp    80106509 <alltraps>

80107060 <vector137>:
.globl vector137
vector137:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $137
80107062:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107067:	e9 9d f4 ff ff       	jmp    80106509 <alltraps>

8010706c <vector138>:
.globl vector138
vector138:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $138
8010706e:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107073:	e9 91 f4 ff ff       	jmp    80106509 <alltraps>

80107078 <vector139>:
.globl vector139
vector139:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $139
8010707a:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010707f:	e9 85 f4 ff ff       	jmp    80106509 <alltraps>

80107084 <vector140>:
.globl vector140
vector140:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $140
80107086:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010708b:	e9 79 f4 ff ff       	jmp    80106509 <alltraps>

80107090 <vector141>:
.globl vector141
vector141:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $141
80107092:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107097:	e9 6d f4 ff ff       	jmp    80106509 <alltraps>

8010709c <vector142>:
.globl vector142
vector142:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $142
8010709e:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801070a3:	e9 61 f4 ff ff       	jmp    80106509 <alltraps>

801070a8 <vector143>:
.globl vector143
vector143:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $143
801070aa:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801070af:	e9 55 f4 ff ff       	jmp    80106509 <alltraps>

801070b4 <vector144>:
.globl vector144
vector144:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $144
801070b6:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801070bb:	e9 49 f4 ff ff       	jmp    80106509 <alltraps>

801070c0 <vector145>:
.globl vector145
vector145:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $145
801070c2:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801070c7:	e9 3d f4 ff ff       	jmp    80106509 <alltraps>

801070cc <vector146>:
.globl vector146
vector146:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $146
801070ce:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801070d3:	e9 31 f4 ff ff       	jmp    80106509 <alltraps>

801070d8 <vector147>:
.globl vector147
vector147:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $147
801070da:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801070df:	e9 25 f4 ff ff       	jmp    80106509 <alltraps>

801070e4 <vector148>:
.globl vector148
vector148:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $148
801070e6:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801070eb:	e9 19 f4 ff ff       	jmp    80106509 <alltraps>

801070f0 <vector149>:
.globl vector149
vector149:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $149
801070f2:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801070f7:	e9 0d f4 ff ff       	jmp    80106509 <alltraps>

801070fc <vector150>:
.globl vector150
vector150:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $150
801070fe:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107103:	e9 01 f4 ff ff       	jmp    80106509 <alltraps>

80107108 <vector151>:
.globl vector151
vector151:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $151
8010710a:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010710f:	e9 f5 f3 ff ff       	jmp    80106509 <alltraps>

80107114 <vector152>:
.globl vector152
vector152:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $152
80107116:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010711b:	e9 e9 f3 ff ff       	jmp    80106509 <alltraps>

80107120 <vector153>:
.globl vector153
vector153:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $153
80107122:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107127:	e9 dd f3 ff ff       	jmp    80106509 <alltraps>

8010712c <vector154>:
.globl vector154
vector154:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $154
8010712e:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107133:	e9 d1 f3 ff ff       	jmp    80106509 <alltraps>

80107138 <vector155>:
.globl vector155
vector155:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $155
8010713a:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010713f:	e9 c5 f3 ff ff       	jmp    80106509 <alltraps>

80107144 <vector156>:
.globl vector156
vector156:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $156
80107146:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010714b:	e9 b9 f3 ff ff       	jmp    80106509 <alltraps>

80107150 <vector157>:
.globl vector157
vector157:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $157
80107152:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107157:	e9 ad f3 ff ff       	jmp    80106509 <alltraps>

8010715c <vector158>:
.globl vector158
vector158:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $158
8010715e:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107163:	e9 a1 f3 ff ff       	jmp    80106509 <alltraps>

80107168 <vector159>:
.globl vector159
vector159:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $159
8010716a:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010716f:	e9 95 f3 ff ff       	jmp    80106509 <alltraps>

80107174 <vector160>:
.globl vector160
vector160:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $160
80107176:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010717b:	e9 89 f3 ff ff       	jmp    80106509 <alltraps>

80107180 <vector161>:
.globl vector161
vector161:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $161
80107182:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107187:	e9 7d f3 ff ff       	jmp    80106509 <alltraps>

8010718c <vector162>:
.globl vector162
vector162:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $162
8010718e:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107193:	e9 71 f3 ff ff       	jmp    80106509 <alltraps>

80107198 <vector163>:
.globl vector163
vector163:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $163
8010719a:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010719f:	e9 65 f3 ff ff       	jmp    80106509 <alltraps>

801071a4 <vector164>:
.globl vector164
vector164:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $164
801071a6:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801071ab:	e9 59 f3 ff ff       	jmp    80106509 <alltraps>

801071b0 <vector165>:
.globl vector165
vector165:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $165
801071b2:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801071b7:	e9 4d f3 ff ff       	jmp    80106509 <alltraps>

801071bc <vector166>:
.globl vector166
vector166:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $166
801071be:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801071c3:	e9 41 f3 ff ff       	jmp    80106509 <alltraps>

801071c8 <vector167>:
.globl vector167
vector167:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $167
801071ca:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801071cf:	e9 35 f3 ff ff       	jmp    80106509 <alltraps>

801071d4 <vector168>:
.globl vector168
vector168:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $168
801071d6:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801071db:	e9 29 f3 ff ff       	jmp    80106509 <alltraps>

801071e0 <vector169>:
.globl vector169
vector169:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $169
801071e2:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801071e7:	e9 1d f3 ff ff       	jmp    80106509 <alltraps>

801071ec <vector170>:
.globl vector170
vector170:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $170
801071ee:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801071f3:	e9 11 f3 ff ff       	jmp    80106509 <alltraps>

801071f8 <vector171>:
.globl vector171
vector171:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $171
801071fa:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801071ff:	e9 05 f3 ff ff       	jmp    80106509 <alltraps>

80107204 <vector172>:
.globl vector172
vector172:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $172
80107206:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010720b:	e9 f9 f2 ff ff       	jmp    80106509 <alltraps>

80107210 <vector173>:
.globl vector173
vector173:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $173
80107212:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107217:	e9 ed f2 ff ff       	jmp    80106509 <alltraps>

8010721c <vector174>:
.globl vector174
vector174:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $174
8010721e:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107223:	e9 e1 f2 ff ff       	jmp    80106509 <alltraps>

80107228 <vector175>:
.globl vector175
vector175:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $175
8010722a:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010722f:	e9 d5 f2 ff ff       	jmp    80106509 <alltraps>

80107234 <vector176>:
.globl vector176
vector176:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $176
80107236:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010723b:	e9 c9 f2 ff ff       	jmp    80106509 <alltraps>

80107240 <vector177>:
.globl vector177
vector177:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $177
80107242:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107247:	e9 bd f2 ff ff       	jmp    80106509 <alltraps>

8010724c <vector178>:
.globl vector178
vector178:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $178
8010724e:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107253:	e9 b1 f2 ff ff       	jmp    80106509 <alltraps>

80107258 <vector179>:
.globl vector179
vector179:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $179
8010725a:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010725f:	e9 a5 f2 ff ff       	jmp    80106509 <alltraps>

80107264 <vector180>:
.globl vector180
vector180:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $180
80107266:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010726b:	e9 99 f2 ff ff       	jmp    80106509 <alltraps>

80107270 <vector181>:
.globl vector181
vector181:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $181
80107272:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107277:	e9 8d f2 ff ff       	jmp    80106509 <alltraps>

8010727c <vector182>:
.globl vector182
vector182:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $182
8010727e:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107283:	e9 81 f2 ff ff       	jmp    80106509 <alltraps>

80107288 <vector183>:
.globl vector183
vector183:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $183
8010728a:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010728f:	e9 75 f2 ff ff       	jmp    80106509 <alltraps>

80107294 <vector184>:
.globl vector184
vector184:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $184
80107296:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010729b:	e9 69 f2 ff ff       	jmp    80106509 <alltraps>

801072a0 <vector185>:
.globl vector185
vector185:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $185
801072a2:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801072a7:	e9 5d f2 ff ff       	jmp    80106509 <alltraps>

801072ac <vector186>:
.globl vector186
vector186:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $186
801072ae:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801072b3:	e9 51 f2 ff ff       	jmp    80106509 <alltraps>

801072b8 <vector187>:
.globl vector187
vector187:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $187
801072ba:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801072bf:	e9 45 f2 ff ff       	jmp    80106509 <alltraps>

801072c4 <vector188>:
.globl vector188
vector188:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $188
801072c6:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801072cb:	e9 39 f2 ff ff       	jmp    80106509 <alltraps>

801072d0 <vector189>:
.globl vector189
vector189:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $189
801072d2:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801072d7:	e9 2d f2 ff ff       	jmp    80106509 <alltraps>

801072dc <vector190>:
.globl vector190
vector190:
  pushl $0
801072dc:	6a 00                	push   $0x0
  pushl $190
801072de:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801072e3:	e9 21 f2 ff ff       	jmp    80106509 <alltraps>

801072e8 <vector191>:
.globl vector191
vector191:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $191
801072ea:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801072ef:	e9 15 f2 ff ff       	jmp    80106509 <alltraps>

801072f4 <vector192>:
.globl vector192
vector192:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $192
801072f6:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801072fb:	e9 09 f2 ff ff       	jmp    80106509 <alltraps>

80107300 <vector193>:
.globl vector193
vector193:
  pushl $0
80107300:	6a 00                	push   $0x0
  pushl $193
80107302:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107307:	e9 fd f1 ff ff       	jmp    80106509 <alltraps>

8010730c <vector194>:
.globl vector194
vector194:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $194
8010730e:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107313:	e9 f1 f1 ff ff       	jmp    80106509 <alltraps>

80107318 <vector195>:
.globl vector195
vector195:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $195
8010731a:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010731f:	e9 e5 f1 ff ff       	jmp    80106509 <alltraps>

80107324 <vector196>:
.globl vector196
vector196:
  pushl $0
80107324:	6a 00                	push   $0x0
  pushl $196
80107326:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010732b:	e9 d9 f1 ff ff       	jmp    80106509 <alltraps>

80107330 <vector197>:
.globl vector197
vector197:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $197
80107332:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107337:	e9 cd f1 ff ff       	jmp    80106509 <alltraps>

8010733c <vector198>:
.globl vector198
vector198:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $198
8010733e:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107343:	e9 c1 f1 ff ff       	jmp    80106509 <alltraps>

80107348 <vector199>:
.globl vector199
vector199:
  pushl $0
80107348:	6a 00                	push   $0x0
  pushl $199
8010734a:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010734f:	e9 b5 f1 ff ff       	jmp    80106509 <alltraps>

80107354 <vector200>:
.globl vector200
vector200:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $200
80107356:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010735b:	e9 a9 f1 ff ff       	jmp    80106509 <alltraps>

80107360 <vector201>:
.globl vector201
vector201:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $201
80107362:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107367:	e9 9d f1 ff ff       	jmp    80106509 <alltraps>

8010736c <vector202>:
.globl vector202
vector202:
  pushl $0
8010736c:	6a 00                	push   $0x0
  pushl $202
8010736e:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107373:	e9 91 f1 ff ff       	jmp    80106509 <alltraps>

80107378 <vector203>:
.globl vector203
vector203:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $203
8010737a:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010737f:	e9 85 f1 ff ff       	jmp    80106509 <alltraps>

80107384 <vector204>:
.globl vector204
vector204:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $204
80107386:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010738b:	e9 79 f1 ff ff       	jmp    80106509 <alltraps>

80107390 <vector205>:
.globl vector205
vector205:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $205
80107392:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107397:	e9 6d f1 ff ff       	jmp    80106509 <alltraps>

8010739c <vector206>:
.globl vector206
vector206:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $206
8010739e:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801073a3:	e9 61 f1 ff ff       	jmp    80106509 <alltraps>

801073a8 <vector207>:
.globl vector207
vector207:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $207
801073aa:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801073af:	e9 55 f1 ff ff       	jmp    80106509 <alltraps>

801073b4 <vector208>:
.globl vector208
vector208:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $208
801073b6:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801073bb:	e9 49 f1 ff ff       	jmp    80106509 <alltraps>

801073c0 <vector209>:
.globl vector209
vector209:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $209
801073c2:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801073c7:	e9 3d f1 ff ff       	jmp    80106509 <alltraps>

801073cc <vector210>:
.globl vector210
vector210:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $210
801073ce:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801073d3:	e9 31 f1 ff ff       	jmp    80106509 <alltraps>

801073d8 <vector211>:
.globl vector211
vector211:
  pushl $0
801073d8:	6a 00                	push   $0x0
  pushl $211
801073da:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801073df:	e9 25 f1 ff ff       	jmp    80106509 <alltraps>

801073e4 <vector212>:
.globl vector212
vector212:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $212
801073e6:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801073eb:	e9 19 f1 ff ff       	jmp    80106509 <alltraps>

801073f0 <vector213>:
.globl vector213
vector213:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $213
801073f2:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801073f7:	e9 0d f1 ff ff       	jmp    80106509 <alltraps>

801073fc <vector214>:
.globl vector214
vector214:
  pushl $0
801073fc:	6a 00                	push   $0x0
  pushl $214
801073fe:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107403:	e9 01 f1 ff ff       	jmp    80106509 <alltraps>

80107408 <vector215>:
.globl vector215
vector215:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $215
8010740a:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010740f:	e9 f5 f0 ff ff       	jmp    80106509 <alltraps>

80107414 <vector216>:
.globl vector216
vector216:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $216
80107416:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010741b:	e9 e9 f0 ff ff       	jmp    80106509 <alltraps>

80107420 <vector217>:
.globl vector217
vector217:
  pushl $0
80107420:	6a 00                	push   $0x0
  pushl $217
80107422:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107427:	e9 dd f0 ff ff       	jmp    80106509 <alltraps>

8010742c <vector218>:
.globl vector218
vector218:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $218
8010742e:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107433:	e9 d1 f0 ff ff       	jmp    80106509 <alltraps>

80107438 <vector219>:
.globl vector219
vector219:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $219
8010743a:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010743f:	e9 c5 f0 ff ff       	jmp    80106509 <alltraps>

80107444 <vector220>:
.globl vector220
vector220:
  pushl $0
80107444:	6a 00                	push   $0x0
  pushl $220
80107446:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010744b:	e9 b9 f0 ff ff       	jmp    80106509 <alltraps>

80107450 <vector221>:
.globl vector221
vector221:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $221
80107452:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107457:	e9 ad f0 ff ff       	jmp    80106509 <alltraps>

8010745c <vector222>:
.globl vector222
vector222:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $222
8010745e:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107463:	e9 a1 f0 ff ff       	jmp    80106509 <alltraps>

80107468 <vector223>:
.globl vector223
vector223:
  pushl $0
80107468:	6a 00                	push   $0x0
  pushl $223
8010746a:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010746f:	e9 95 f0 ff ff       	jmp    80106509 <alltraps>

80107474 <vector224>:
.globl vector224
vector224:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $224
80107476:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010747b:	e9 89 f0 ff ff       	jmp    80106509 <alltraps>

80107480 <vector225>:
.globl vector225
vector225:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $225
80107482:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107487:	e9 7d f0 ff ff       	jmp    80106509 <alltraps>

8010748c <vector226>:
.globl vector226
vector226:
  pushl $0
8010748c:	6a 00                	push   $0x0
  pushl $226
8010748e:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107493:	e9 71 f0 ff ff       	jmp    80106509 <alltraps>

80107498 <vector227>:
.globl vector227
vector227:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $227
8010749a:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010749f:	e9 65 f0 ff ff       	jmp    80106509 <alltraps>

801074a4 <vector228>:
.globl vector228
vector228:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $228
801074a6:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801074ab:	e9 59 f0 ff ff       	jmp    80106509 <alltraps>

801074b0 <vector229>:
.globl vector229
vector229:
  pushl $0
801074b0:	6a 00                	push   $0x0
  pushl $229
801074b2:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801074b7:	e9 4d f0 ff ff       	jmp    80106509 <alltraps>

801074bc <vector230>:
.globl vector230
vector230:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $230
801074be:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801074c3:	e9 41 f0 ff ff       	jmp    80106509 <alltraps>

801074c8 <vector231>:
.globl vector231
vector231:
  pushl $0
801074c8:	6a 00                	push   $0x0
  pushl $231
801074ca:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801074cf:	e9 35 f0 ff ff       	jmp    80106509 <alltraps>

801074d4 <vector232>:
.globl vector232
vector232:
  pushl $0
801074d4:	6a 00                	push   $0x0
  pushl $232
801074d6:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801074db:	e9 29 f0 ff ff       	jmp    80106509 <alltraps>

801074e0 <vector233>:
.globl vector233
vector233:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $233
801074e2:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801074e7:	e9 1d f0 ff ff       	jmp    80106509 <alltraps>

801074ec <vector234>:
.globl vector234
vector234:
  pushl $0
801074ec:	6a 00                	push   $0x0
  pushl $234
801074ee:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801074f3:	e9 11 f0 ff ff       	jmp    80106509 <alltraps>

801074f8 <vector235>:
.globl vector235
vector235:
  pushl $0
801074f8:	6a 00                	push   $0x0
  pushl $235
801074fa:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801074ff:	e9 05 f0 ff ff       	jmp    80106509 <alltraps>

80107504 <vector236>:
.globl vector236
vector236:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $236
80107506:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010750b:	e9 f9 ef ff ff       	jmp    80106509 <alltraps>

80107510 <vector237>:
.globl vector237
vector237:
  pushl $0
80107510:	6a 00                	push   $0x0
  pushl $237
80107512:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107517:	e9 ed ef ff ff       	jmp    80106509 <alltraps>

8010751c <vector238>:
.globl vector238
vector238:
  pushl $0
8010751c:	6a 00                	push   $0x0
  pushl $238
8010751e:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107523:	e9 e1 ef ff ff       	jmp    80106509 <alltraps>

80107528 <vector239>:
.globl vector239
vector239:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $239
8010752a:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010752f:	e9 d5 ef ff ff       	jmp    80106509 <alltraps>

80107534 <vector240>:
.globl vector240
vector240:
  pushl $0
80107534:	6a 00                	push   $0x0
  pushl $240
80107536:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010753b:	e9 c9 ef ff ff       	jmp    80106509 <alltraps>

80107540 <vector241>:
.globl vector241
vector241:
  pushl $0
80107540:	6a 00                	push   $0x0
  pushl $241
80107542:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107547:	e9 bd ef ff ff       	jmp    80106509 <alltraps>

8010754c <vector242>:
.globl vector242
vector242:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $242
8010754e:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107553:	e9 b1 ef ff ff       	jmp    80106509 <alltraps>

80107558 <vector243>:
.globl vector243
vector243:
  pushl $0
80107558:	6a 00                	push   $0x0
  pushl $243
8010755a:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010755f:	e9 a5 ef ff ff       	jmp    80106509 <alltraps>

80107564 <vector244>:
.globl vector244
vector244:
  pushl $0
80107564:	6a 00                	push   $0x0
  pushl $244
80107566:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010756b:	e9 99 ef ff ff       	jmp    80106509 <alltraps>

80107570 <vector245>:
.globl vector245
vector245:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $245
80107572:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107577:	e9 8d ef ff ff       	jmp    80106509 <alltraps>

8010757c <vector246>:
.globl vector246
vector246:
  pushl $0
8010757c:	6a 00                	push   $0x0
  pushl $246
8010757e:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107583:	e9 81 ef ff ff       	jmp    80106509 <alltraps>

80107588 <vector247>:
.globl vector247
vector247:
  pushl $0
80107588:	6a 00                	push   $0x0
  pushl $247
8010758a:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010758f:	e9 75 ef ff ff       	jmp    80106509 <alltraps>

80107594 <vector248>:
.globl vector248
vector248:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $248
80107596:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010759b:	e9 69 ef ff ff       	jmp    80106509 <alltraps>

801075a0 <vector249>:
.globl vector249
vector249:
  pushl $0
801075a0:	6a 00                	push   $0x0
  pushl $249
801075a2:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801075a7:	e9 5d ef ff ff       	jmp    80106509 <alltraps>

801075ac <vector250>:
.globl vector250
vector250:
  pushl $0
801075ac:	6a 00                	push   $0x0
  pushl $250
801075ae:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801075b3:	e9 51 ef ff ff       	jmp    80106509 <alltraps>

801075b8 <vector251>:
.globl vector251
vector251:
  pushl $0
801075b8:	6a 00                	push   $0x0
  pushl $251
801075ba:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801075bf:	e9 45 ef ff ff       	jmp    80106509 <alltraps>

801075c4 <vector252>:
.globl vector252
vector252:
  pushl $0
801075c4:	6a 00                	push   $0x0
  pushl $252
801075c6:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801075cb:	e9 39 ef ff ff       	jmp    80106509 <alltraps>

801075d0 <vector253>:
.globl vector253
vector253:
  pushl $0
801075d0:	6a 00                	push   $0x0
  pushl $253
801075d2:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801075d7:	e9 2d ef ff ff       	jmp    80106509 <alltraps>

801075dc <vector254>:
.globl vector254
vector254:
  pushl $0
801075dc:	6a 00                	push   $0x0
  pushl $254
801075de:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801075e3:	e9 21 ef ff ff       	jmp    80106509 <alltraps>

801075e8 <vector255>:
.globl vector255
vector255:
  pushl $0
801075e8:	6a 00                	push   $0x0
  pushl $255
801075ea:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801075ef:	e9 15 ef ff ff       	jmp    80106509 <alltraps>

801075f4 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801075f4:	55                   	push   %ebp
801075f5:	89 e5                	mov    %esp,%ebp
801075f7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801075fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801075fd:	83 e8 01             	sub    $0x1,%eax
80107600:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107604:	8b 45 08             	mov    0x8(%ebp),%eax
80107607:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010760b:	8b 45 08             	mov    0x8(%ebp),%eax
8010760e:	c1 e8 10             	shr    $0x10,%eax
80107611:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107615:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107618:	0f 01 10             	lgdtl  (%eax)
}
8010761b:	c9                   	leave  
8010761c:	c3                   	ret    

8010761d <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010761d:	55                   	push   %ebp
8010761e:	89 e5                	mov    %esp,%ebp
80107620:	83 ec 04             	sub    $0x4,%esp
80107623:	8b 45 08             	mov    0x8(%ebp),%eax
80107626:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010762a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010762e:	0f 00 d8             	ltr    %ax
}
80107631:	c9                   	leave  
80107632:	c3                   	ret    

80107633 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107633:	55                   	push   %ebp
80107634:	89 e5                	mov    %esp,%ebp
80107636:	83 ec 04             	sub    $0x4,%esp
80107639:	8b 45 08             	mov    0x8(%ebp),%eax
8010763c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107640:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107644:	8e e8                	mov    %eax,%gs
}
80107646:	c9                   	leave  
80107647:	c3                   	ret    

80107648 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107648:	55                   	push   %ebp
80107649:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010764b:	8b 45 08             	mov    0x8(%ebp),%eax
8010764e:	0f 22 d8             	mov    %eax,%cr3
}
80107651:	5d                   	pop    %ebp
80107652:	c3                   	ret    

80107653 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107653:	55                   	push   %ebp
80107654:	89 e5                	mov    %esp,%ebp
80107656:	8b 45 08             	mov    0x8(%ebp),%eax
80107659:	05 00 00 00 80       	add    $0x80000000,%eax
8010765e:	5d                   	pop    %ebp
8010765f:	c3                   	ret    

80107660 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107660:	55                   	push   %ebp
80107661:	89 e5                	mov    %esp,%ebp
80107663:	8b 45 08             	mov    0x8(%ebp),%eax
80107666:	05 00 00 00 80       	add    $0x80000000,%eax
8010766b:	5d                   	pop    %ebp
8010766c:	c3                   	ret    

8010766d <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010766d:	55                   	push   %ebp
8010766e:	89 e5                	mov    %esp,%ebp
80107670:	53                   	push   %ebx
80107671:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107674:	e8 ff b7 ff ff       	call   80102e78 <cpunum>
80107679:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010767f:	05 60 23 11 80       	add    $0x80112360,%eax
80107684:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107693:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801076a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076a7:	83 e2 f0             	and    $0xfffffff0,%edx
801076aa:	83 ca 0a             	or     $0xa,%edx
801076ad:	88 50 7d             	mov    %dl,0x7d(%eax)
801076b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076b7:	83 ca 10             	or     $0x10,%edx
801076ba:	88 50 7d             	mov    %dl,0x7d(%eax)
801076bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076c4:	83 e2 9f             	and    $0xffffff9f,%edx
801076c7:	88 50 7d             	mov    %dl,0x7d(%eax)
801076ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076d1:	83 ca 80             	or     $0xffffff80,%edx
801076d4:	88 50 7d             	mov    %dl,0x7d(%eax)
801076d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076da:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801076de:	83 ca 0f             	or     $0xf,%edx
801076e1:	88 50 7e             	mov    %dl,0x7e(%eax)
801076e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801076eb:	83 e2 ef             	and    $0xffffffef,%edx
801076ee:	88 50 7e             	mov    %dl,0x7e(%eax)
801076f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801076f8:	83 e2 df             	and    $0xffffffdf,%edx
801076fb:	88 50 7e             	mov    %dl,0x7e(%eax)
801076fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107701:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107705:	83 ca 40             	or     $0x40,%edx
80107708:	88 50 7e             	mov    %dl,0x7e(%eax)
8010770b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107712:	83 ca 80             	or     $0xffffff80,%edx
80107715:	88 50 7e             	mov    %dl,0x7e(%eax)
80107718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010771f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107722:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107729:	ff ff 
8010772b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107735:	00 00 
80107737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107744:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010774b:	83 e2 f0             	and    $0xfffffff0,%edx
8010774e:	83 ca 02             	or     $0x2,%edx
80107751:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107761:	83 ca 10             	or     $0x10,%edx
80107764:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010776a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107774:	83 e2 9f             	and    $0xffffff9f,%edx
80107777:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010777d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107780:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107787:	83 ca 80             	or     $0xffffff80,%edx
8010778a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107793:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010779a:	83 ca 0f             	or     $0xf,%edx
8010779d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077ad:	83 e2 ef             	and    $0xffffffef,%edx
801077b0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077c0:	83 e2 df             	and    $0xffffffdf,%edx
801077c3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077d3:	83 ca 40             	or     $0x40,%edx
801077d6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077df:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077e6:	83 ca 80             	or     $0xffffff80,%edx
801077e9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f2:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801077f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fc:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107803:	ff ff 
80107805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107808:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010780f:	00 00 
80107811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107814:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010781b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107825:	83 e2 f0             	and    $0xfffffff0,%edx
80107828:	83 ca 0a             	or     $0xa,%edx
8010782b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107834:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010783b:	83 ca 10             	or     $0x10,%edx
8010783e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107847:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010784e:	83 ca 60             	or     $0x60,%edx
80107851:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107861:	83 ca 80             	or     $0xffffff80,%edx
80107864:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010786a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107874:	83 ca 0f             	or     $0xf,%edx
80107877:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010787d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107880:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107887:	83 e2 ef             	and    $0xffffffef,%edx
8010788a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107893:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010789a:	83 e2 df             	and    $0xffffffdf,%edx
8010789d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078ad:	83 ca 40             	or     $0x40,%edx
801078b0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078c0:	83 ca 80             	or     $0xffffff80,%edx
801078c3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cc:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801078d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d6:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801078dd:	ff ff 
801078df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e2:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801078e9:	00 00 
801078eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ee:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801078f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801078ff:	83 e2 f0             	and    $0xfffffff0,%edx
80107902:	83 ca 02             	or     $0x2,%edx
80107905:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010790b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107915:	83 ca 10             	or     $0x10,%edx
80107918:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010791e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107921:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107928:	83 ca 60             	or     $0x60,%edx
8010792b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107934:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010793b:	83 ca 80             	or     $0xffffff80,%edx
8010793e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107947:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010794e:	83 ca 0f             	or     $0xf,%edx
80107951:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107961:	83 e2 ef             	and    $0xffffffef,%edx
80107964:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010796a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107974:	83 e2 df             	and    $0xffffffdf,%edx
80107977:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010797d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107980:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107987:	83 ca 40             	or     $0x40,%edx
8010798a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107993:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010799a:	83 ca 80             	or     $0xffffff80,%edx
8010799d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a6:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801079ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b0:	05 b4 00 00 00       	add    $0xb4,%eax
801079b5:	89 c3                	mov    %eax,%ebx
801079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ba:	05 b4 00 00 00       	add    $0xb4,%eax
801079bf:	c1 e8 10             	shr    $0x10,%eax
801079c2:	89 c1                	mov    %eax,%ecx
801079c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c7:	05 b4 00 00 00       	add    $0xb4,%eax
801079cc:	c1 e8 18             	shr    $0x18,%eax
801079cf:	89 c2                	mov    %eax,%edx
801079d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d4:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801079db:	00 00 
801079dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e0:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801079e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ea:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801079f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801079fa:	83 e1 f0             	and    $0xfffffff0,%ecx
801079fd:	83 c9 02             	or     $0x2,%ecx
80107a00:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a09:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a10:	83 c9 10             	or     $0x10,%ecx
80107a13:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1c:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a23:	83 e1 9f             	and    $0xffffff9f,%ecx
80107a26:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a36:	83 c9 80             	or     $0xffffff80,%ecx
80107a39:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a42:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a49:	83 e1 f0             	and    $0xfffffff0,%ecx
80107a4c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a55:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a5c:	83 e1 ef             	and    $0xffffffef,%ecx
80107a5f:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a68:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a6f:	83 e1 df             	and    $0xffffffdf,%ecx
80107a72:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7b:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a82:	83 c9 40             	or     $0x40,%ecx
80107a85:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a95:	83 c9 80             	or     $0xffffff80,%ecx
80107a98:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa1:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aaa:	83 c0 70             	add    $0x70,%eax
80107aad:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107ab4:	00 
80107ab5:	89 04 24             	mov    %eax,(%esp)
80107ab8:	e8 37 fb ff ff       	call   801075f4 <lgdt>
  loadgs(SEG_KCPU << 3);
80107abd:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107ac4:	e8 6a fb ff ff       	call   80107633 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acc:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107ad2:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107ad9:	00 00 00 00 
}
80107add:	83 c4 24             	add    $0x24,%esp
80107ae0:	5b                   	pop    %ebx
80107ae1:	5d                   	pop    %ebp
80107ae2:	c3                   	ret    

80107ae3 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107ae3:	55                   	push   %ebp
80107ae4:	89 e5                	mov    %esp,%ebp
80107ae6:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107aec:	c1 e8 16             	shr    $0x16,%eax
80107aef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107af6:	8b 45 08             	mov    0x8(%ebp),%eax
80107af9:	01 d0                	add    %edx,%eax
80107afb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b01:	8b 00                	mov    (%eax),%eax
80107b03:	83 e0 01             	and    $0x1,%eax
80107b06:	85 c0                	test   %eax,%eax
80107b08:	74 17                	je     80107b21 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b0d:	8b 00                	mov    (%eax),%eax
80107b0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b14:	89 04 24             	mov    %eax,(%esp)
80107b17:	e8 44 fb ff ff       	call   80107660 <p2v>
80107b1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b1f:	eb 4b                	jmp    80107b6c <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107b21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107b25:	74 0e                	je     80107b35 <walkpgdir+0x52>
80107b27:	e8 b6 af ff ff       	call   80102ae2 <kalloc>
80107b2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b33:	75 07                	jne    80107b3c <walkpgdir+0x59>
      return 0;
80107b35:	b8 00 00 00 00       	mov    $0x0,%eax
80107b3a:	eb 47                	jmp    80107b83 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107b3c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107b43:	00 
80107b44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107b4b:	00 
80107b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4f:	89 04 24             	mov    %eax,(%esp)
80107b52:	e8 be d5 ff ff       	call   80105115 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5a:	89 04 24             	mov    %eax,(%esp)
80107b5d:	e8 f1 fa ff ff       	call   80107653 <v2p>
80107b62:	83 c8 07             	or     $0x7,%eax
80107b65:	89 c2                	mov    %eax,%edx
80107b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b6a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b6f:	c1 e8 0c             	shr    $0xc,%eax
80107b72:	25 ff 03 00 00       	and    $0x3ff,%eax
80107b77:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b81:	01 d0                	add    %edx,%eax
}
80107b83:	c9                   	leave  
80107b84:	c3                   	ret    

80107b85 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107b85:	55                   	push   %ebp
80107b86:	89 e5                	mov    %esp,%ebp
80107b88:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b93:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107b96:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b99:	8b 45 10             	mov    0x10(%ebp),%eax
80107b9c:	01 d0                	add    %edx,%eax
80107b9e:	83 e8 01             	sub    $0x1,%eax
80107ba1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ba6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ba9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107bb0:	00 
80107bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
80107bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80107bbb:	89 04 24             	mov    %eax,(%esp)
80107bbe:	e8 20 ff ff ff       	call   80107ae3 <walkpgdir>
80107bc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107bc6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bca:	75 07                	jne    80107bd3 <mappages+0x4e>
      return -1;
80107bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bd1:	eb 48                	jmp    80107c1b <mappages+0x96>
    if(*pte & PTE_P)
80107bd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bd6:	8b 00                	mov    (%eax),%eax
80107bd8:	83 e0 01             	and    $0x1,%eax
80107bdb:	85 c0                	test   %eax,%eax
80107bdd:	74 0c                	je     80107beb <mappages+0x66>
      panic("remap");
80107bdf:	c7 04 24 2c 8a 10 80 	movl   $0x80108a2c,(%esp)
80107be6:	e8 4f 89 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107beb:	8b 45 18             	mov    0x18(%ebp),%eax
80107bee:	0b 45 14             	or     0x14(%ebp),%eax
80107bf1:	83 c8 01             	or     $0x1,%eax
80107bf4:	89 c2                	mov    %eax,%edx
80107bf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bf9:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfe:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c01:	75 08                	jne    80107c0b <mappages+0x86>
      break;
80107c03:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107c04:	b8 00 00 00 00       	mov    $0x0,%eax
80107c09:	eb 10                	jmp    80107c1b <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107c0b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c12:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107c19:	eb 8e                	jmp    80107ba9 <mappages+0x24>
  return 0;
}
80107c1b:	c9                   	leave  
80107c1c:	c3                   	ret    

80107c1d <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107c1d:	55                   	push   %ebp
80107c1e:	89 e5                	mov    %esp,%ebp
80107c20:	53                   	push   %ebx
80107c21:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107c24:	e8 b9 ae ff ff       	call   80102ae2 <kalloc>
80107c29:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c30:	75 0a                	jne    80107c3c <setupkvm+0x1f>
    return 0;
80107c32:	b8 00 00 00 00       	mov    $0x0,%eax
80107c37:	e9 98 00 00 00       	jmp    80107cd4 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107c3c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c43:	00 
80107c44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c4b:	00 
80107c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c4f:	89 04 24             	mov    %eax,(%esp)
80107c52:	e8 be d4 ff ff       	call   80105115 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107c57:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107c5e:	e8 fd f9 ff ff       	call   80107660 <p2v>
80107c63:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107c68:	76 0c                	jbe    80107c76 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107c6a:	c7 04 24 32 8a 10 80 	movl   $0x80108a32,(%esp)
80107c71:	e8 c4 88 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c76:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107c7d:	eb 49                	jmp    80107cc8 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c82:	8b 48 0c             	mov    0xc(%eax),%ecx
80107c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c88:	8b 50 04             	mov    0x4(%eax),%edx
80107c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8e:	8b 58 08             	mov    0x8(%eax),%ebx
80107c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c94:	8b 40 04             	mov    0x4(%eax),%eax
80107c97:	29 c3                	sub    %eax,%ebx
80107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9c:	8b 00                	mov    (%eax),%eax
80107c9e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107ca2:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107ca6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107caa:	89 44 24 04          	mov    %eax,0x4(%esp)
80107cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cb1:	89 04 24             	mov    %eax,(%esp)
80107cb4:	e8 cc fe ff ff       	call   80107b85 <mappages>
80107cb9:	85 c0                	test   %eax,%eax
80107cbb:	79 07                	jns    80107cc4 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107cbd:	b8 00 00 00 00       	mov    $0x0,%eax
80107cc2:	eb 10                	jmp    80107cd4 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107cc4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107cc8:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107ccf:	72 ae                	jb     80107c7f <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107cd4:	83 c4 34             	add    $0x34,%esp
80107cd7:	5b                   	pop    %ebx
80107cd8:	5d                   	pop    %ebp
80107cd9:	c3                   	ret    

80107cda <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107cda:	55                   	push   %ebp
80107cdb:	89 e5                	mov    %esp,%ebp
80107cdd:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107ce0:	e8 38 ff ff ff       	call   80107c1d <setupkvm>
80107ce5:	a3 38 51 11 80       	mov    %eax,0x80115138
  switchkvm();
80107cea:	e8 02 00 00 00       	call   80107cf1 <switchkvm>
}
80107cef:	c9                   	leave  
80107cf0:	c3                   	ret    

80107cf1 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107cf1:	55                   	push   %ebp
80107cf2:	89 e5                	mov    %esp,%ebp
80107cf4:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107cf7:	a1 38 51 11 80       	mov    0x80115138,%eax
80107cfc:	89 04 24             	mov    %eax,(%esp)
80107cff:	e8 4f f9 ff ff       	call   80107653 <v2p>
80107d04:	89 04 24             	mov    %eax,(%esp)
80107d07:	e8 3c f9 ff ff       	call   80107648 <lcr3>
}
80107d0c:	c9                   	leave  
80107d0d:	c3                   	ret    

80107d0e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107d0e:	55                   	push   %ebp
80107d0f:	89 e5                	mov    %esp,%ebp
80107d11:	53                   	push   %ebx
80107d12:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107d15:	e8 fb d2 ff ff       	call   80105015 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107d1a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d20:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d27:	83 c2 08             	add    $0x8,%edx
80107d2a:	89 d3                	mov    %edx,%ebx
80107d2c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d33:	83 c2 08             	add    $0x8,%edx
80107d36:	c1 ea 10             	shr    $0x10,%edx
80107d39:	89 d1                	mov    %edx,%ecx
80107d3b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d42:	83 c2 08             	add    $0x8,%edx
80107d45:	c1 ea 18             	shr    $0x18,%edx
80107d48:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107d4f:	67 00 
80107d51:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107d58:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107d5e:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107d65:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d68:	83 c9 09             	or     $0x9,%ecx
80107d6b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107d71:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107d78:	83 c9 10             	or     $0x10,%ecx
80107d7b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107d81:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107d88:	83 e1 9f             	and    $0xffffff9f,%ecx
80107d8b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107d91:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107d98:	83 c9 80             	or     $0xffffff80,%ecx
80107d9b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107da1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107da8:	83 e1 f0             	and    $0xfffffff0,%ecx
80107dab:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107db1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107db8:	83 e1 ef             	and    $0xffffffef,%ecx
80107dbb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107dc1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107dc8:	83 e1 df             	and    $0xffffffdf,%ecx
80107dcb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107dd1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107dd8:	83 c9 40             	or     $0x40,%ecx
80107ddb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107de1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107de8:	83 e1 7f             	and    $0x7f,%ecx
80107deb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107df1:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107df7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107dfd:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e04:	83 e2 ef             	and    $0xffffffef,%edx
80107e07:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107e0d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e13:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107e19:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e1f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107e26:	8b 52 08             	mov    0x8(%edx),%edx
80107e29:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107e2f:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107e32:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107e39:	e8 df f7 ff ff       	call   8010761d <ltr>
  if(p->pgdir == 0)
80107e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80107e41:	8b 40 04             	mov    0x4(%eax),%eax
80107e44:	85 c0                	test   %eax,%eax
80107e46:	75 0c                	jne    80107e54 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107e48:	c7 04 24 43 8a 10 80 	movl   $0x80108a43,(%esp)
80107e4f:	e8 e6 86 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107e54:	8b 45 08             	mov    0x8(%ebp),%eax
80107e57:	8b 40 04             	mov    0x4(%eax),%eax
80107e5a:	89 04 24             	mov    %eax,(%esp)
80107e5d:	e8 f1 f7 ff ff       	call   80107653 <v2p>
80107e62:	89 04 24             	mov    %eax,(%esp)
80107e65:	e8 de f7 ff ff       	call   80107648 <lcr3>
  popcli();
80107e6a:	e8 ea d1 ff ff       	call   80105059 <popcli>
}
80107e6f:	83 c4 14             	add    $0x14,%esp
80107e72:	5b                   	pop    %ebx
80107e73:	5d                   	pop    %ebp
80107e74:	c3                   	ret    

80107e75 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107e75:	55                   	push   %ebp
80107e76:	89 e5                	mov    %esp,%ebp
80107e78:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107e7b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107e82:	76 0c                	jbe    80107e90 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107e84:	c7 04 24 57 8a 10 80 	movl   $0x80108a57,(%esp)
80107e8b:	e8 aa 86 ff ff       	call   8010053a <panic>
  mem = kalloc();
80107e90:	e8 4d ac ff ff       	call   80102ae2 <kalloc>
80107e95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107e98:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e9f:	00 
80107ea0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ea7:	00 
80107ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eab:	89 04 24             	mov    %eax,(%esp)
80107eae:	e8 62 d2 ff ff       	call   80105115 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb6:	89 04 24             	mov    %eax,(%esp)
80107eb9:	e8 95 f7 ff ff       	call   80107653 <v2p>
80107ebe:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107ec5:	00 
80107ec6:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107eca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ed1:	00 
80107ed2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ed9:	00 
80107eda:	8b 45 08             	mov    0x8(%ebp),%eax
80107edd:	89 04 24             	mov    %eax,(%esp)
80107ee0:	e8 a0 fc ff ff       	call   80107b85 <mappages>
  memmove(mem, init, sz);
80107ee5:	8b 45 10             	mov    0x10(%ebp),%eax
80107ee8:	89 44 24 08          	mov    %eax,0x8(%esp)
80107eec:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eef:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef6:	89 04 24             	mov    %eax,(%esp)
80107ef9:	e8 e6 d2 ff ff       	call   801051e4 <memmove>
}
80107efe:	c9                   	leave  
80107eff:	c3                   	ret    

80107f00 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f00:	55                   	push   %ebp
80107f01:	89 e5                	mov    %esp,%ebp
80107f03:	53                   	push   %ebx
80107f04:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f07:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f0a:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f0f:	85 c0                	test   %eax,%eax
80107f11:	74 0c                	je     80107f1f <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107f13:	c7 04 24 74 8a 10 80 	movl   $0x80108a74,(%esp)
80107f1a:	e8 1b 86 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f26:	e9 a9 00 00 00       	jmp    80107fd4 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f31:	01 d0                	add    %edx,%eax
80107f33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f3a:	00 
80107f3b:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80107f42:	89 04 24             	mov    %eax,(%esp)
80107f45:	e8 99 fb ff ff       	call   80107ae3 <walkpgdir>
80107f4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f4d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f51:	75 0c                	jne    80107f5f <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107f53:	c7 04 24 97 8a 10 80 	movl   $0x80108a97,(%esp)
80107f5a:	e8 db 85 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80107f5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f62:	8b 00                	mov    (%eax),%eax
80107f64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f69:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6f:	8b 55 18             	mov    0x18(%ebp),%edx
80107f72:	29 c2                	sub    %eax,%edx
80107f74:	89 d0                	mov    %edx,%eax
80107f76:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107f7b:	77 0f                	ja     80107f8c <loaduvm+0x8c>
      n = sz - i;
80107f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f80:	8b 55 18             	mov    0x18(%ebp),%edx
80107f83:	29 c2                	sub    %eax,%edx
80107f85:	89 d0                	mov    %edx,%eax
80107f87:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f8a:	eb 07                	jmp    80107f93 <loaduvm+0x93>
    else
      n = PGSIZE;
80107f8c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	8b 55 14             	mov    0x14(%ebp),%edx
80107f99:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107f9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f9f:	89 04 24             	mov    %eax,(%esp)
80107fa2:	e8 b9 f6 ff ff       	call   80107660 <p2v>
80107fa7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107faa:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107fae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fb6:	8b 45 10             	mov    0x10(%ebp),%eax
80107fb9:	89 04 24             	mov    %eax,(%esp)
80107fbc:	e8 a7 9d ff ff       	call   80101d68 <readi>
80107fc1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fc4:	74 07                	je     80107fcd <loaduvm+0xcd>
      return -1;
80107fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fcb:	eb 18                	jmp    80107fe5 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107fcd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd7:	3b 45 18             	cmp    0x18(%ebp),%eax
80107fda:	0f 82 4b ff ff ff    	jb     80107f2b <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107fe0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fe5:	83 c4 24             	add    $0x24,%esp
80107fe8:	5b                   	pop    %ebx
80107fe9:	5d                   	pop    %ebp
80107fea:	c3                   	ret    

80107feb <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107feb:	55                   	push   %ebp
80107fec:	89 e5                	mov    %esp,%ebp
80107fee:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107ff1:	8b 45 10             	mov    0x10(%ebp),%eax
80107ff4:	85 c0                	test   %eax,%eax
80107ff6:	79 0a                	jns    80108002 <allocuvm+0x17>
    return 0;
80107ff8:	b8 00 00 00 00       	mov    $0x0,%eax
80107ffd:	e9 c1 00 00 00       	jmp    801080c3 <allocuvm+0xd8>
  if(newsz < oldsz)
80108002:	8b 45 10             	mov    0x10(%ebp),%eax
80108005:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108008:	73 08                	jae    80108012 <allocuvm+0x27>
    return oldsz;
8010800a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010800d:	e9 b1 00 00 00       	jmp    801080c3 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108012:	8b 45 0c             	mov    0xc(%ebp),%eax
80108015:	05 ff 0f 00 00       	add    $0xfff,%eax
8010801a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010801f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108022:	e9 8d 00 00 00       	jmp    801080b4 <allocuvm+0xc9>
    mem = kalloc();
80108027:	e8 b6 aa ff ff       	call   80102ae2 <kalloc>
8010802c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010802f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108033:	75 2c                	jne    80108061 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108035:	c7 04 24 b5 8a 10 80 	movl   $0x80108ab5,(%esp)
8010803c:	e8 5f 83 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108041:	8b 45 0c             	mov    0xc(%ebp),%eax
80108044:	89 44 24 08          	mov    %eax,0x8(%esp)
80108048:	8b 45 10             	mov    0x10(%ebp),%eax
8010804b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010804f:	8b 45 08             	mov    0x8(%ebp),%eax
80108052:	89 04 24             	mov    %eax,(%esp)
80108055:	e8 6b 00 00 00       	call   801080c5 <deallocuvm>
      return 0;
8010805a:	b8 00 00 00 00       	mov    $0x0,%eax
8010805f:	eb 62                	jmp    801080c3 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108061:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108068:	00 
80108069:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108070:	00 
80108071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108074:	89 04 24             	mov    %eax,(%esp)
80108077:	e8 99 d0 ff ff       	call   80105115 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010807c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010807f:	89 04 24             	mov    %eax,(%esp)
80108082:	e8 cc f5 ff ff       	call   80107653 <v2p>
80108087:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010808a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108091:	00 
80108092:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108096:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010809d:	00 
8010809e:	89 54 24 04          	mov    %edx,0x4(%esp)
801080a2:	8b 45 08             	mov    0x8(%ebp),%eax
801080a5:	89 04 24             	mov    %eax,(%esp)
801080a8:	e8 d8 fa ff ff       	call   80107b85 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801080ad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b7:	3b 45 10             	cmp    0x10(%ebp),%eax
801080ba:	0f 82 67 ff ff ff    	jb     80108027 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801080c0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801080c3:	c9                   	leave  
801080c4:	c3                   	ret    

801080c5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801080c5:	55                   	push   %ebp
801080c6:	89 e5                	mov    %esp,%ebp
801080c8:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801080cb:	8b 45 10             	mov    0x10(%ebp),%eax
801080ce:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080d1:	72 08                	jb     801080db <deallocuvm+0x16>
    return oldsz;
801080d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801080d6:	e9 a4 00 00 00       	jmp    8010817f <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801080db:	8b 45 10             	mov    0x10(%ebp),%eax
801080de:	05 ff 0f 00 00       	add    $0xfff,%eax
801080e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801080eb:	e9 80 00 00 00       	jmp    80108170 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801080f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080fa:	00 
801080fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801080ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108102:	89 04 24             	mov    %eax,(%esp)
80108105:	e8 d9 f9 ff ff       	call   80107ae3 <walkpgdir>
8010810a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010810d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108111:	75 09                	jne    8010811c <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108113:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010811a:	eb 4d                	jmp    80108169 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
8010811c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010811f:	8b 00                	mov    (%eax),%eax
80108121:	83 e0 01             	and    $0x1,%eax
80108124:	85 c0                	test   %eax,%eax
80108126:	74 41                	je     80108169 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010812b:	8b 00                	mov    (%eax),%eax
8010812d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108132:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108135:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108139:	75 0c                	jne    80108147 <deallocuvm+0x82>
        panic("kfree");
8010813b:	c7 04 24 cd 8a 10 80 	movl   $0x80108acd,(%esp)
80108142:	e8 f3 83 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108147:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010814a:	89 04 24             	mov    %eax,(%esp)
8010814d:	e8 0e f5 ff ff       	call   80107660 <p2v>
80108152:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108155:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108158:	89 04 24             	mov    %eax,(%esp)
8010815b:	e8 e9 a8 ff ff       	call   80102a49 <kfree>
      *pte = 0;
80108160:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108163:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108169:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108173:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108176:	0f 82 74 ff ff ff    	jb     801080f0 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010817c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010817f:	c9                   	leave  
80108180:	c3                   	ret    

80108181 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108181:	55                   	push   %ebp
80108182:	89 e5                	mov    %esp,%ebp
80108184:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108187:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010818b:	75 0c                	jne    80108199 <freevm+0x18>
    panic("freevm: no pgdir");
8010818d:	c7 04 24 d3 8a 10 80 	movl   $0x80108ad3,(%esp)
80108194:	e8 a1 83 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108199:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081a0:	00 
801081a1:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801081a8:	80 
801081a9:	8b 45 08             	mov    0x8(%ebp),%eax
801081ac:	89 04 24             	mov    %eax,(%esp)
801081af:	e8 11 ff ff ff       	call   801080c5 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801081b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081bb:	eb 48                	jmp    80108205 <freevm+0x84>
    if(pgdir[i] & PTE_P){
801081bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801081c7:	8b 45 08             	mov    0x8(%ebp),%eax
801081ca:	01 d0                	add    %edx,%eax
801081cc:	8b 00                	mov    (%eax),%eax
801081ce:	83 e0 01             	and    $0x1,%eax
801081d1:	85 c0                	test   %eax,%eax
801081d3:	74 2c                	je     80108201 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801081d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801081df:	8b 45 08             	mov    0x8(%ebp),%eax
801081e2:	01 d0                	add    %edx,%eax
801081e4:	8b 00                	mov    (%eax),%eax
801081e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081eb:	89 04 24             	mov    %eax,(%esp)
801081ee:	e8 6d f4 ff ff       	call   80107660 <p2v>
801081f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801081f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f9:	89 04 24             	mov    %eax,(%esp)
801081fc:	e8 48 a8 ff ff       	call   80102a49 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108201:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108205:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010820c:	76 af                	jbe    801081bd <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010820e:	8b 45 08             	mov    0x8(%ebp),%eax
80108211:	89 04 24             	mov    %eax,(%esp)
80108214:	e8 30 a8 ff ff       	call   80102a49 <kfree>
}
80108219:	c9                   	leave  
8010821a:	c3                   	ret    

8010821b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010821b:	55                   	push   %ebp
8010821c:	89 e5                	mov    %esp,%ebp
8010821e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108221:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108228:	00 
80108229:	8b 45 0c             	mov    0xc(%ebp),%eax
8010822c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108230:	8b 45 08             	mov    0x8(%ebp),%eax
80108233:	89 04 24             	mov    %eax,(%esp)
80108236:	e8 a8 f8 ff ff       	call   80107ae3 <walkpgdir>
8010823b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010823e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108242:	75 0c                	jne    80108250 <clearpteu+0x35>
    panic("clearpteu");
80108244:	c7 04 24 e4 8a 10 80 	movl   $0x80108ae4,(%esp)
8010824b:	e8 ea 82 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80108250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108253:	8b 00                	mov    (%eax),%eax
80108255:	83 e0 fb             	and    $0xfffffffb,%eax
80108258:	89 c2                	mov    %eax,%edx
8010825a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825d:	89 10                	mov    %edx,(%eax)
}
8010825f:	c9                   	leave  
80108260:	c3                   	ret    

80108261 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108261:	55                   	push   %ebp
80108262:	89 e5                	mov    %esp,%ebp
80108264:	53                   	push   %ebx
80108265:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108268:	e8 b0 f9 ff ff       	call   80107c1d <setupkvm>
8010826d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108270:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108274:	75 0a                	jne    80108280 <copyuvm+0x1f>
    return 0;
80108276:	b8 00 00 00 00       	mov    $0x0,%eax
8010827b:	e9 fd 00 00 00       	jmp    8010837d <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108280:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108287:	e9 d0 00 00 00       	jmp    8010835c <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010828c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108296:	00 
80108297:	89 44 24 04          	mov    %eax,0x4(%esp)
8010829b:	8b 45 08             	mov    0x8(%ebp),%eax
8010829e:	89 04 24             	mov    %eax,(%esp)
801082a1:	e8 3d f8 ff ff       	call   80107ae3 <walkpgdir>
801082a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082ad:	75 0c                	jne    801082bb <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801082af:	c7 04 24 ee 8a 10 80 	movl   $0x80108aee,(%esp)
801082b6:	e8 7f 82 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
801082bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082be:	8b 00                	mov    (%eax),%eax
801082c0:	83 e0 01             	and    $0x1,%eax
801082c3:	85 c0                	test   %eax,%eax
801082c5:	75 0c                	jne    801082d3 <copyuvm+0x72>
      panic("copyuvm: page not present");
801082c7:	c7 04 24 08 8b 10 80 	movl   $0x80108b08,(%esp)
801082ce:	e8 67 82 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801082d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082d6:	8b 00                	mov    (%eax),%eax
801082d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801082e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e3:	8b 00                	mov    (%eax),%eax
801082e5:	25 ff 0f 00 00       	and    $0xfff,%eax
801082ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801082ed:	e8 f0 a7 ff ff       	call   80102ae2 <kalloc>
801082f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801082f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801082f9:	75 02                	jne    801082fd <copyuvm+0x9c>
      goto bad;
801082fb:	eb 70                	jmp    8010836d <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801082fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108300:	89 04 24             	mov    %eax,(%esp)
80108303:	e8 58 f3 ff ff       	call   80107660 <p2v>
80108308:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010830f:	00 
80108310:	89 44 24 04          	mov    %eax,0x4(%esp)
80108314:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108317:	89 04 24             	mov    %eax,(%esp)
8010831a:	e8 c5 ce ff ff       	call   801051e4 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010831f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108322:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108325:	89 04 24             	mov    %eax,(%esp)
80108328:	e8 26 f3 ff ff       	call   80107653 <v2p>
8010832d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108330:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108334:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108338:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010833f:	00 
80108340:	89 54 24 04          	mov    %edx,0x4(%esp)
80108344:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108347:	89 04 24             	mov    %eax,(%esp)
8010834a:	e8 36 f8 ff ff       	call   80107b85 <mappages>
8010834f:	85 c0                	test   %eax,%eax
80108351:	79 02                	jns    80108355 <copyuvm+0xf4>
      goto bad;
80108353:	eb 18                	jmp    8010836d <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108355:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010835c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108362:	0f 82 24 ff ff ff    	jb     8010828c <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108368:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010836b:	eb 10                	jmp    8010837d <copyuvm+0x11c>

bad:
  freevm(d);
8010836d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108370:	89 04 24             	mov    %eax,(%esp)
80108373:	e8 09 fe ff ff       	call   80108181 <freevm>
  return 0;
80108378:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010837d:	83 c4 44             	add    $0x44,%esp
80108380:	5b                   	pop    %ebx
80108381:	5d                   	pop    %ebp
80108382:	c3                   	ret    

80108383 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108383:	55                   	push   %ebp
80108384:	89 e5                	mov    %esp,%ebp
80108386:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108389:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108390:	00 
80108391:	8b 45 0c             	mov    0xc(%ebp),%eax
80108394:	89 44 24 04          	mov    %eax,0x4(%esp)
80108398:	8b 45 08             	mov    0x8(%ebp),%eax
8010839b:	89 04 24             	mov    %eax,(%esp)
8010839e:	e8 40 f7 ff ff       	call   80107ae3 <walkpgdir>
801083a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801083a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a9:	8b 00                	mov    (%eax),%eax
801083ab:	83 e0 01             	and    $0x1,%eax
801083ae:	85 c0                	test   %eax,%eax
801083b0:	75 07                	jne    801083b9 <uva2ka+0x36>
    return 0;
801083b2:	b8 00 00 00 00       	mov    $0x0,%eax
801083b7:	eb 25                	jmp    801083de <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801083b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bc:	8b 00                	mov    (%eax),%eax
801083be:	83 e0 04             	and    $0x4,%eax
801083c1:	85 c0                	test   %eax,%eax
801083c3:	75 07                	jne    801083cc <uva2ka+0x49>
    return 0;
801083c5:	b8 00 00 00 00       	mov    $0x0,%eax
801083ca:	eb 12                	jmp    801083de <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801083cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cf:	8b 00                	mov    (%eax),%eax
801083d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083d6:	89 04 24             	mov    %eax,(%esp)
801083d9:	e8 82 f2 ff ff       	call   80107660 <p2v>
}
801083de:	c9                   	leave  
801083df:	c3                   	ret    

801083e0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801083e0:	55                   	push   %ebp
801083e1:	89 e5                	mov    %esp,%ebp
801083e3:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801083e6:	8b 45 10             	mov    0x10(%ebp),%eax
801083e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801083ec:	e9 87 00 00 00       	jmp    80108478 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801083f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801083fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80108403:	8b 45 08             	mov    0x8(%ebp),%eax
80108406:	89 04 24             	mov    %eax,(%esp)
80108409:	e8 75 ff ff ff       	call   80108383 <uva2ka>
8010840e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108411:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108415:	75 07                	jne    8010841e <copyout+0x3e>
      return -1;
80108417:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010841c:	eb 69                	jmp    80108487 <copyout+0xa7>
    n = PGSIZE - (va - va0);
8010841e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108421:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108424:	29 c2                	sub    %eax,%edx
80108426:	89 d0                	mov    %edx,%eax
80108428:	05 00 10 00 00       	add    $0x1000,%eax
8010842d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108430:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108433:	3b 45 14             	cmp    0x14(%ebp),%eax
80108436:	76 06                	jbe    8010843e <copyout+0x5e>
      n = len;
80108438:	8b 45 14             	mov    0x14(%ebp),%eax
8010843b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010843e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108441:	8b 55 0c             	mov    0xc(%ebp),%edx
80108444:	29 c2                	sub    %eax,%edx
80108446:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108449:	01 c2                	add    %eax,%edx
8010844b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010844e:	89 44 24 08          	mov    %eax,0x8(%esp)
80108452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108455:	89 44 24 04          	mov    %eax,0x4(%esp)
80108459:	89 14 24             	mov    %edx,(%esp)
8010845c:	e8 83 cd ff ff       	call   801051e4 <memmove>
    len -= n;
80108461:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108464:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010846a:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010846d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108470:	05 00 10 00 00       	add    $0x1000,%eax
80108475:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108478:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010847c:	0f 85 6f ff ff ff    	jne    801083f1 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108482:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108487:	c9                   	leave  
80108488:	c3                   	ret    
