
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
80100028:	bc b0 d6 10 80       	mov    $0x8010d6b0,%esp

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
8010003a:	c7 44 24 04 74 8b 10 	movl   $0x80108b74,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 c0 d6 10 80 	movl   $0x8010d6c0,(%esp)
80100049:	e8 96 54 00 00       	call   801054e4 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 d0 15 11 80 c4 	movl   $0x801115c4,0x801115d0
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 d4 15 11 80 c4 	movl   $0x801115c4,0x801115d4
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 f4 d6 10 80 	movl   $0x8010d6f4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 d4 15 11 80    	mov    0x801115d4,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c c4 15 11 80 	movl   $0x801115c4,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 d4 15 11 80       	mov    0x801115d4,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 d4 15 11 80       	mov    %eax,0x801115d4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 c4 15 11 80 	cmpl   $0x801115c4,-0xc(%ebp)
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
801000b6:	c7 04 24 c0 d6 10 80 	movl   $0x8010d6c0,(%esp)
801000bd:	e8 43 54 00 00       	call   80105505 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 d4 15 11 80       	mov    0x801115d4,%eax
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
801000fd:	c7 04 24 c0 d6 10 80 	movl   $0x8010d6c0,(%esp)
80100104:	e8 5e 54 00 00       	call   80105567 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 c0 d6 10 	movl   $0x8010d6c0,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 2d 4c 00 00       	call   80104d51 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 c4 15 11 80 	cmpl   $0x801115c4,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 d0 15 11 80       	mov    0x801115d0,%eax
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
80100175:	c7 04 24 c0 d6 10 80 	movl   $0x8010d6c0,(%esp)
8010017c:	e8 e6 53 00 00       	call   80105567 <release>
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
8010018f:	81 7d f4 c4 15 11 80 	cmpl   $0x801115c4,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 7b 8b 10 80 	movl   $0x80108b7b,(%esp)
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
801001ef:	c7 04 24 8c 8b 10 80 	movl   $0x80108b8c,(%esp)
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
80100229:	c7 04 24 93 8b 10 80 	movl   $0x80108b93,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 c0 d6 10 80 	movl   $0x8010d6c0,(%esp)
8010023c:	e8 c4 52 00 00       	call   80105505 <acquire>

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
8010025f:	8b 15 d4 15 11 80    	mov    0x801115d4,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c c4 15 11 80 	movl   $0x801115c4,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 d4 15 11 80       	mov    0x801115d4,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 d4 15 11 80       	mov    %eax,0x801115d4

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
8010029d:	e8 b7 4b 00 00       	call   80104e59 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 c0 d6 10 80 	movl   $0x8010d6c0,(%esp)
801002a9:	e8 b9 52 00 00       	call   80105567 <release>
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
801003a6:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801003bb:	e8 45 51 00 00       	call   80105505 <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 9a 8b 10 80 	movl   $0x80108b9a,(%esp)
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
801004b0:	c7 45 ec a3 8b 10 80 	movl   $0x80108ba3,-0x14(%ebp)
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
8010052c:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80100533:	e8 2f 50 00 00       	call   80105567 <release>
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
80100545:	c7 05 54 c6 10 80 00 	movl   $0x0,0x8010c654
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 aa 8b 10 80 	movl   $0x80108baa,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 b9 8b 10 80 	movl   $0x80108bb9,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 22 50 00 00       	call   801055b6 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 bb 8b 10 80 	movl   $0x80108bbb,(%esp)
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
801005be:	c7 05 00 c6 10 80 01 	movl   $0x1,0x8010c600
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
801006b2:	e8 71 51 00 00       	call   80105828 <memmove>
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
801006e1:	e8 73 50 00 00       	call   80105759 <memset>
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
80100756:	a1 00 c6 10 80       	mov    0x8010c600,%eax
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
80100776:	e8 3c 6a 00 00       	call   801071b7 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 30 6a 00 00       	call   801071b7 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 24 6a 00 00       	call   801071b7 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 17 6a 00 00       	call   801071b7 <uartputc>
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
801007b3:	c7 04 24 e0 17 11 80 	movl   $0x801117e0,(%esp)
801007ba:	e8 46 4d 00 00       	call   80105505 <acquire>
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
801007ea:	e8 02 47 00 00       	call   80104ef1 <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 9c 18 11 80       	mov    0x8011189c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 9c 18 11 80       	mov    %eax,0x8011189c
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
80100810:	8b 15 9c 18 11 80    	mov    0x8011189c,%edx
80100816:	a1 98 18 11 80       	mov    0x80111898,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 9c 18 11 80       	mov    0x8011189c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 14 18 11 80 	movzbl -0x7feee7ec(%eax),%eax
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
8010083a:	8b 15 9c 18 11 80    	mov    0x8011189c,%edx
80100840:	a1 98 18 11 80       	mov    0x80111898,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 9c 18 11 80       	mov    0x8011189c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 9c 18 11 80       	mov    %eax,0x8011189c
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
80100876:	8b 15 9c 18 11 80    	mov    0x8011189c,%edx
8010087c:	a1 94 18 11 80       	mov    0x80111894,%eax
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
8010089d:	a1 9c 18 11 80       	mov    0x8011189c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 9c 18 11 80    	mov    %edx,0x8011189c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 14 18 11 80    	mov    %al,-0x7feee7ec(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 9c 18 11 80       	mov    0x8011189c,%eax
801008d5:	8b 15 94 18 11 80    	mov    0x80111894,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 9c 18 11 80       	mov    0x8011189c,%eax
801008e7:	a3 98 18 11 80       	mov    %eax,0x80111898
          wakeup(&input.r);
801008ec:	c7 04 24 94 18 11 80 	movl   $0x80111894,(%esp)
801008f3:	e8 61 45 00 00       	call   80104e59 <wakeup>
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
8010090d:	c7 04 24 e0 17 11 80 	movl   $0x801117e0,(%esp)
80100914:	e8 4e 4c 00 00       	call   80105567 <release>
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
80100932:	c7 04 24 e0 17 11 80 	movl   $0x801117e0,(%esp)
80100939:	e8 c7 4b 00 00       	call   80105505 <acquire>
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
80100952:	c7 04 24 e0 17 11 80 	movl   $0x801117e0,(%esp)
80100959:	e8 09 4c 00 00       	call   80105567 <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 ff 0e 00 00       	call   80101868 <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 e0 17 11 	movl   $0x801117e0,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 94 18 11 80 	movl   $0x80111894,(%esp)
80100982:	e8 ca 43 00 00       	call   80104d51 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 94 18 11 80    	mov    0x80111894,%edx
8010098d:	a1 98 18 11 80       	mov    0x80111898,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 94 18 11 80       	mov    0x80111894,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 94 18 11 80    	mov    %edx,0x80111894
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 14 18 11 80 	movzbl -0x7feee7ec(%eax),%eax
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
801009c2:	a1 94 18 11 80       	mov    0x80111894,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 94 18 11 80       	mov    %eax,0x80111894
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
801009f7:	c7 04 24 e0 17 11 80 	movl   $0x801117e0,(%esp)
801009fe:	e8 64 4b 00 00       	call   80105567 <release>
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
80100a2b:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80100a32:	e8 ce 4a 00 00       	call   80105505 <acquire>
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
80100a65:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80100a6c:	e8 f6 4a 00 00       	call   80105567 <release>
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
80100a87:	c7 44 24 04 bf 8b 10 	movl   $0x80108bbf,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80100a96:	e8 49 4a 00 00       	call   801054e4 <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 c7 8b 10 	movl   $0x80108bc7,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 e0 17 11 80 	movl   $0x801117e0,(%esp)
80100aaa:	e8 35 4a 00 00       	call   801054e4 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 4c 22 11 80 1a 	movl   $0x80100a1a,0x8011224c
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 48 22 11 80 1b 	movl   $0x8010091b,0x80112248
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 54 c6 10 80 01 	movl   $0x1,0x8010c654
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
80100b73:	e8 90 77 00 00       	call   80108308 <setupkvm>
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
80100c14:	e8 bd 7a 00 00       	call   801086d6 <allocuvm>
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
80100c52:	e8 94 79 00 00       	call   801085eb <loaduvm>
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
80100cc0:	e8 11 7a 00 00       	call   801086d6 <allocuvm>
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
80100ce5:	e8 1c 7c 00 00       	call   80108906 <clearpteu>
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
80100d1b:	e8 a3 4c 00 00       	call   801059c3 <strlen>
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
80100d44:	e8 7a 4c 00 00       	call   801059c3 <strlen>
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
80100d74:	e8 52 7d 00 00       	call   80108acb <copyout>
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
80100e1b:	e8 ab 7c 00 00       	call   80108acb <copyout>
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
80100e73:	e8 01 4b 00 00       	call   80105979 <safestrcpy>

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
80100ed2:	e8 22 75 00 00       	call   801083f9 <switchuvm>
  freevm(oldpgdir);
80100ed7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eda:	89 04 24             	mov    %eax,(%esp)
80100edd:	e8 8a 79 00 00       	call   8010886c <freevm>
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
80100ef5:	e8 72 79 00 00       	call   8010886c <freevm>
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
80100f1d:	c7 44 24 04 cd 8b 10 	movl   $0x80108bcd,0x4(%esp)
80100f24:	80 
80100f25:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80100f2c:	e8 b3 45 00 00       	call   801054e4 <initlock>
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
80100f39:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80100f40:	e8 c0 45 00 00       	call   80105505 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f45:	c7 45 f4 d4 18 11 80 	movl   $0x801118d4,-0xc(%ebp)
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
80100f62:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80100f69:	e8 f9 45 00 00       	call   80105567 <release>
      return f;
80100f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f71:	eb 1e                	jmp    80100f91 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f73:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f77:	81 7d f4 34 22 11 80 	cmpl   $0x80112234,-0xc(%ebp)
80100f7e:	72 ce                	jb     80100f4e <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f80:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80100f87:	e8 db 45 00 00       	call   80105567 <release>
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
80100f99:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80100fa0:	e8 60 45 00 00       	call   80105505 <acquire>
  if(f->ref < 1)
80100fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa8:	8b 40 04             	mov    0x4(%eax),%eax
80100fab:	85 c0                	test   %eax,%eax
80100fad:	7f 0c                	jg     80100fbb <filedup+0x28>
    panic("filedup");
80100faf:	c7 04 24 d4 8b 10 80 	movl   $0x80108bd4,(%esp)
80100fb6:	e8 7f f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbe:	8b 40 04             	mov    0x4(%eax),%eax
80100fc1:	8d 50 01             	lea    0x1(%eax),%edx
80100fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc7:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fca:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80100fd1:	e8 91 45 00 00       	call   80105567 <release>
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
80100fe1:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80100fe8:	e8 18 45 00 00       	call   80105505 <acquire>
  if(f->ref < 1)
80100fed:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff0:	8b 40 04             	mov    0x4(%eax),%eax
80100ff3:	85 c0                	test   %eax,%eax
80100ff5:	7f 0c                	jg     80101003 <fileclose+0x28>
    panic("fileclose");
80100ff7:	c7 04 24 dc 8b 10 80 	movl   $0x80108bdc,(%esp)
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
8010101c:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80101023:	e8 3f 45 00 00       	call   80105567 <release>
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
80101066:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
8010106d:	e8 f5 44 00 00       	call   80105567 <release>
  
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
801011ae:	c7 04 24 e6 8b 10 80 	movl   $0x80108be6,(%esp)
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
801012ba:	c7 04 24 ef 8b 10 80 	movl   $0x80108bef,(%esp)
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
801012ec:	c7 04 24 ff 8b 10 80 	movl   $0x80108bff,(%esp)
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
80101332:	e8 f1 44 00 00       	call   80105828 <memmove>
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
80101378:	e8 dc 43 00 00       	call   80105759 <memset>
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
801014d5:	c7 04 24 09 8c 10 80 	movl   $0x80108c09,(%esp)
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
80101567:	c7 04 24 1f 8c 10 80 	movl   $0x80108c1f,(%esp)
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
801015b7:	c7 44 24 04 32 8c 10 	movl   $0x80108c32,0x4(%esp)
801015be:	80 
801015bf:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
801015c6:	e8 19 3f 00 00       	call   801054e4 <initlock>
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
80101648:	e8 0c 41 00 00       	call   80105759 <memset>
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
8010169e:	c7 04 24 39 8c 10 80 	movl   $0x80108c39,(%esp)
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
80101747:	e8 dc 40 00 00       	call   80105828 <memmove>
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
8010176a:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
80101771:	e8 8f 3d 00 00       	call   80105505 <acquire>

  // Is the inode already cached?
  empty = 0;
80101776:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010177d:	c7 45 f4 d4 22 11 80 	movl   $0x801122d4,-0xc(%ebp)
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
801017b4:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
801017bb:	e8 a7 3d 00 00       	call   80105567 <release>
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
801017df:	81 7d f4 74 32 11 80 	cmpl   $0x80113274,-0xc(%ebp)
801017e6:	72 9e                	jb     80101786 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017ec:	75 0c                	jne    801017fa <iget+0x96>
    panic("iget: no inodes");
801017ee:	c7 04 24 4b 8c 10 80 	movl   $0x80108c4b,(%esp)
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
80101825:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
8010182c:	e8 36 3d 00 00       	call   80105567 <release>

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
8010183c:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
80101843:	e8 bd 3c 00 00       	call   80105505 <acquire>
  ip->ref++;
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 08             	mov    0x8(%eax),%eax
8010184e:	8d 50 01             	lea    0x1(%eax),%edx
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101857:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
8010185e:	e8 04 3d 00 00       	call   80105567 <release>
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
8010187e:	c7 04 24 5b 8c 10 80 	movl   $0x80108c5b,(%esp)
80101885:	e8 b0 ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010188a:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
80101891:	e8 6f 3c 00 00       	call   80105505 <acquire>
  while(ip->flags & I_BUSY)
80101896:	eb 13                	jmp    801018ab <ilock+0x43>
    sleep(ip, &icache.lock);
80101898:	c7 44 24 04 a0 22 11 	movl   $0x801122a0,0x4(%esp)
8010189f:	80 
801018a0:	8b 45 08             	mov    0x8(%ebp),%eax
801018a3:	89 04 24             	mov    %eax,(%esp)
801018a6:	e8 a6 34 00 00       	call   80104d51 <sleep>

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
801018c9:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
801018d0:	e8 92 3c 00 00       	call   80105567 <release>

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
8010197b:	e8 a8 3e 00 00       	call   80105828 <memmove>
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
801019a8:	c7 04 24 61 8c 10 80 	movl   $0x80108c61,(%esp)
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
801019d9:	c7 04 24 70 8c 10 80 	movl   $0x80108c70,(%esp)
801019e0:	e8 55 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019e5:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
801019ec:	e8 14 3b 00 00       	call   80105505 <acquire>
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
80101a08:	e8 4c 34 00 00       	call   80104e59 <wakeup>
  release(&icache.lock);
80101a0d:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
80101a14:	e8 4e 3b 00 00       	call   80105567 <release>
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
80101a21:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
80101a28:	e8 d8 3a 00 00       	call   80105505 <acquire>
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
80101a66:	c7 04 24 78 8c 10 80 	movl   $0x80108c78,(%esp)
80101a6d:	e8 c8 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	8b 40 0c             	mov    0xc(%eax),%eax
80101a78:	83 c8 01             	or     $0x1,%eax
80101a7b:	89 c2                	mov    %eax,%edx
80101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a80:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a83:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
80101a8a:	e8 d8 3a 00 00       	call   80105567 <release>
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
80101aae:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
80101ab5:	e8 4b 3a 00 00       	call   80105505 <acquire>
    ip->flags = 0;
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac7:	89 04 24             	mov    %eax,(%esp)
80101aca:	e8 8a 33 00 00       	call   80104e59 <wakeup>
  }
  ip->ref--;
80101acf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad2:	8b 40 08             	mov    0x8(%eax),%eax
80101ad5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ade:	c7 04 24 a0 22 11 80 	movl   $0x801122a0,(%esp)
80101ae5:	e8 7d 3a 00 00       	call   80105567 <release>
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
80101c05:	c7 04 24 82 8c 10 80 	movl   $0x80108c82,(%esp)
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
80101da9:	8b 04 c5 40 22 11 80 	mov    -0x7feeddc0(,%eax,8),%eax
80101db0:	85 c0                	test   %eax,%eax
80101db2:	75 0a                	jne    80101dbe <readi+0x49>
      return -1;
80101db4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101db9:	e9 19 01 00 00       	jmp    80101ed7 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dc5:	98                   	cwtl   
80101dc6:	8b 04 c5 40 22 11 80 	mov    -0x7feeddc0(,%eax,8),%eax
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
80101ea6:	e8 7d 39 00 00       	call   80105828 <memmove>
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
80101f0d:	8b 04 c5 44 22 11 80 	mov    -0x7feeddbc(,%eax,8),%eax
80101f14:	85 c0                	test   %eax,%eax
80101f16:	75 0a                	jne    80101f22 <writei+0x49>
      return -1;
80101f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1d:	e9 44 01 00 00       	jmp    80102066 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f22:	8b 45 08             	mov    0x8(%ebp),%eax
80101f25:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f29:	98                   	cwtl   
80101f2a:	8b 04 c5 44 22 11 80 	mov    -0x7feeddbc(,%eax,8),%eax
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
80102005:	e8 1e 38 00 00       	call   80105828 <memmove>
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
80102083:	e8 43 38 00 00       	call   801058cb <strncmp>
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
8010209d:	c7 04 24 95 8c 10 80 	movl   $0x80108c95,(%esp)
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
801020db:	c7 04 24 a7 8c 10 80 	movl   $0x80108ca7,(%esp)
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
801021c0:	c7 04 24 a7 8c 10 80 	movl   $0x80108ca7,(%esp)
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
80102205:	e8 17 37 00 00       	call   80105921 <strncpy>
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
80102237:	c7 04 24 b4 8c 10 80 	movl   $0x80108cb4,(%esp)
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
801022bc:	e8 67 35 00 00       	call   80105828 <memmove>
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
801022d7:	e8 4c 35 00 00       	call   80105828 <memmove>
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
80102526:	c7 44 24 04 bc 8c 10 	movl   $0x80108cbc,0x4(%esp)
8010252d:	80 
8010252e:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80102535:	e8 aa 2f 00 00       	call   801054e4 <initlock>
  picenable(IRQ_IDE);
8010253a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102541:	e8 7b 18 00 00       	call   80103dc1 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102546:	a1 a0 39 11 80       	mov    0x801139a0,%eax
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
80102597:	c7 05 98 c6 10 80 01 	movl   $0x1,0x8010c698
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
801025d2:	c7 04 24 c0 8c 10 80 	movl   $0x80108cc0,(%esp)
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
801026f1:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801026f8:	e8 08 2e 00 00       	call   80105505 <acquire>
  if((b = idequeue) == 0){
801026fd:	a1 94 c6 10 80       	mov    0x8010c694,%eax
80102702:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102705:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102709:	75 11                	jne    8010271c <ideintr+0x31>
    release(&idelock);
8010270b:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80102712:	e8 50 2e 00 00       	call   80105567 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102717:	e9 90 00 00 00       	jmp    801027ac <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010271c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271f:	8b 40 14             	mov    0x14(%eax),%eax
80102722:	a3 94 c6 10 80       	mov    %eax,0x8010c694

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
80102785:	e8 cf 26 00 00       	call   80104e59 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010278a:	a1 94 c6 10 80       	mov    0x8010c694,%eax
8010278f:	85 c0                	test   %eax,%eax
80102791:	74 0d                	je     801027a0 <ideintr+0xb5>
    idestart(idequeue);
80102793:	a1 94 c6 10 80       	mov    0x8010c694,%eax
80102798:	89 04 24             	mov    %eax,(%esp)
8010279b:	e8 26 fe ff ff       	call   801025c6 <idestart>

  release(&idelock);
801027a0:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801027a7:	e8 bb 2d 00 00       	call   80105567 <release>
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
801027c0:	c7 04 24 c9 8c 10 80 	movl   $0x80108cc9,(%esp)
801027c7:	e8 6e dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027cc:	8b 45 08             	mov    0x8(%ebp),%eax
801027cf:	8b 00                	mov    (%eax),%eax
801027d1:	83 e0 06             	and    $0x6,%eax
801027d4:	83 f8 02             	cmp    $0x2,%eax
801027d7:	75 0c                	jne    801027e5 <iderw+0x37>
    panic("iderw: nothing to do");
801027d9:	c7 04 24 dd 8c 10 80 	movl   $0x80108cdd,(%esp)
801027e0:	e8 55 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027e5:	8b 45 08             	mov    0x8(%ebp),%eax
801027e8:	8b 40 04             	mov    0x4(%eax),%eax
801027eb:	85 c0                	test   %eax,%eax
801027ed:	74 15                	je     80102804 <iderw+0x56>
801027ef:	a1 98 c6 10 80       	mov    0x8010c698,%eax
801027f4:	85 c0                	test   %eax,%eax
801027f6:	75 0c                	jne    80102804 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027f8:	c7 04 24 f2 8c 10 80 	movl   $0x80108cf2,(%esp)
801027ff:	e8 36 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102804:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010280b:	e8 f5 2c 00 00       	call   80105505 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102810:	8b 45 08             	mov    0x8(%ebp),%eax
80102813:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010281a:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
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
8010283f:	a1 94 c6 10 80       	mov    0x8010c694,%eax
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
80102858:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
8010285f:	80 
80102860:	8b 45 08             	mov    0x8(%ebp),%eax
80102863:	89 04 24             	mov    %eax,(%esp)
80102866:	e8 e6 24 00 00       	call   80104d51 <sleep>
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
80102878:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010287f:	e8 e3 2c 00 00       	call   80105567 <release>
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
80102889:	a1 74 32 11 80       	mov    0x80113274,%eax
8010288e:	8b 55 08             	mov    0x8(%ebp),%edx
80102891:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102893:	a1 74 32 11 80       	mov    0x80113274,%eax
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
801028a0:	a1 74 32 11 80       	mov    0x80113274,%eax
801028a5:	8b 55 08             	mov    0x8(%ebp),%edx
801028a8:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028aa:	a1 74 32 11 80       	mov    0x80113274,%eax
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
801028bd:	a1 a4 33 11 80       	mov    0x801133a4,%eax
801028c2:	85 c0                	test   %eax,%eax
801028c4:	75 05                	jne    801028cb <ioapicinit+0x14>
    return;
801028c6:	e9 9d 00 00 00       	jmp    80102968 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028cb:	c7 05 74 32 11 80 00 	movl   $0xfec00000,0x80113274
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
801028fe:	0f b6 05 a0 33 11 80 	movzbl 0x801133a0,%eax
80102905:	0f b6 c0             	movzbl %al,%eax
80102908:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010290b:	74 0c                	je     80102919 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010290d:	c7 04 24 10 8d 10 80 	movl   $0x80108d10,(%esp)
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
80102970:	a1 a4 33 11 80       	mov    0x801133a4,%eax
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
801029c7:	c7 44 24 04 42 8d 10 	movl   $0x80108d42,0x4(%esp)
801029ce:	80 
801029cf:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801029d6:	e8 09 2b 00 00       	call   801054e4 <initlock>
  kmem.use_lock = 0;
801029db:	c7 05 b4 32 11 80 00 	movl   $0x0,0x801132b4
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
80102a11:	c7 05 b4 32 11 80 01 	movl   $0x1,0x801132b4
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
80102a68:	81 7d 08 5c aa 11 80 	cmpl   $0x8011aa5c,0x8(%ebp)
80102a6f:	72 12                	jb     80102a83 <kfree+0x2d>
80102a71:	8b 45 08             	mov    0x8(%ebp),%eax
80102a74:	89 04 24             	mov    %eax,(%esp)
80102a77:	e8 38 ff ff ff       	call   801029b4 <v2p>
80102a7c:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a81:	76 0c                	jbe    80102a8f <kfree+0x39>
    panic("kfree");
80102a83:	c7 04 24 47 8d 10 80 	movl   $0x80108d47,(%esp)
80102a8a:	e8 ab da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a8f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a96:	00 
80102a97:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a9e:	00 
80102a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa2:	89 04 24             	mov    %eax,(%esp)
80102aa5:	e8 af 2c 00 00       	call   80105759 <memset>

  if(kmem.use_lock)
80102aaa:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80102aaf:	85 c0                	test   %eax,%eax
80102ab1:	74 0c                	je     80102abf <kfree+0x69>
    acquire(&kmem.lock);
80102ab3:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80102aba:	e8 46 2a 00 00       	call   80105505 <acquire>
  r = (struct run*)v;
80102abf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ac5:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80102acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ace:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad3:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  if(kmem.use_lock)
80102ad8:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80102add:	85 c0                	test   %eax,%eax
80102adf:	74 0c                	je     80102aed <kfree+0x97>
    release(&kmem.lock);
80102ae1:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80102ae8:	e8 7a 2a 00 00       	call   80105567 <release>
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
80102af5:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80102afa:	85 c0                	test   %eax,%eax
80102afc:	74 0c                	je     80102b0a <kalloc+0x1b>
    acquire(&kmem.lock);
80102afe:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80102b05:	e8 fb 29 00 00       	call   80105505 <acquire>
  r = kmem.freelist;
80102b0a:	a1 b8 32 11 80       	mov    0x801132b8,%eax
80102b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b16:	74 0a                	je     80102b22 <kalloc+0x33>
    kmem.freelist = r->next;
80102b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1b:	8b 00                	mov    (%eax),%eax
80102b1d:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  if(kmem.use_lock)
80102b22:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80102b27:	85 c0                	test   %eax,%eax
80102b29:	74 0c                	je     80102b37 <kalloc+0x48>
    release(&kmem.lock);
80102b2b:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80102b32:	e8 30 2a 00 00       	call   80105567 <release>
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
80102ba0:	a1 9c c6 10 80       	mov    0x8010c69c,%eax
80102ba5:	83 c8 40             	or     $0x40,%eax
80102ba8:	a3 9c c6 10 80       	mov    %eax,0x8010c69c
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
80102bc3:	a1 9c c6 10 80       	mov    0x8010c69c,%eax
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
80102bf2:	a1 9c c6 10 80       	mov    0x8010c69c,%eax
80102bf7:	21 d0                	and    %edx,%eax
80102bf9:	a3 9c c6 10 80       	mov    %eax,0x8010c69c
    return 0;
80102bfe:	b8 00 00 00 00       	mov    $0x0,%eax
80102c03:	e9 a2 00 00 00       	jmp    80102caa <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102c08:	a1 9c c6 10 80       	mov    0x8010c69c,%eax
80102c0d:	83 e0 40             	and    $0x40,%eax
80102c10:	85 c0                	test   %eax,%eax
80102c12:	74 14                	je     80102c28 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c14:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c1b:	a1 9c c6 10 80       	mov    0x8010c69c,%eax
80102c20:	83 e0 bf             	and    $0xffffffbf,%eax
80102c23:	a3 9c c6 10 80       	mov    %eax,0x8010c69c
  }

  shift |= shiftcode[data];
80102c28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c2b:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c30:	0f b6 00             	movzbl (%eax),%eax
80102c33:	0f b6 d0             	movzbl %al,%edx
80102c36:	a1 9c c6 10 80       	mov    0x8010c69c,%eax
80102c3b:	09 d0                	or     %edx,%eax
80102c3d:	a3 9c c6 10 80       	mov    %eax,0x8010c69c
  shift ^= togglecode[data];
80102c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c45:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102c4a:	0f b6 00             	movzbl (%eax),%eax
80102c4d:	0f b6 d0             	movzbl %al,%edx
80102c50:	a1 9c c6 10 80       	mov    0x8010c69c,%eax
80102c55:	31 d0                	xor    %edx,%eax
80102c57:	a3 9c c6 10 80       	mov    %eax,0x8010c69c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c5c:	a1 9c c6 10 80       	mov    0x8010c69c,%eax
80102c61:	83 e0 03             	and    $0x3,%eax
80102c64:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102c6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6e:	01 d0                	add    %edx,%eax
80102c70:	0f b6 00             	movzbl (%eax),%eax
80102c73:	0f b6 c0             	movzbl %al,%eax
80102c76:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c79:	a1 9c c6 10 80       	mov    0x8010c69c,%eax
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
80102d0e:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80102d13:	8b 55 08             	mov    0x8(%ebp),%edx
80102d16:	c1 e2 02             	shl    $0x2,%edx
80102d19:	01 c2                	add    %eax,%edx
80102d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d1e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d20:	a1 bc 32 11 80       	mov    0x801132bc,%eax
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
80102d32:	a1 bc 32 11 80       	mov    0x801132bc,%eax
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
80102db8:	a1 bc 32 11 80       	mov    0x801132bc,%eax
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
80102e5a:	a1 bc 32 11 80       	mov    0x801132bc,%eax
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
80102e99:	a1 a0 c6 10 80       	mov    0x8010c6a0,%eax
80102e9e:	8d 50 01             	lea    0x1(%eax),%edx
80102ea1:	89 15 a0 c6 10 80    	mov    %edx,0x8010c6a0
80102ea7:	85 c0                	test   %eax,%eax
80102ea9:	75 13                	jne    80102ebe <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eab:	8b 45 04             	mov    0x4(%ebp),%eax
80102eae:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eb2:	c7 04 24 50 8d 10 80 	movl   $0x80108d50,(%esp)
80102eb9:	e8 e2 d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102ebe:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80102ec3:	85 c0                	test   %eax,%eax
80102ec5:	74 0f                	je     80102ed6 <cpunum+0x51>
    return lapic[ID]>>24;
80102ec7:	a1 bc 32 11 80       	mov    0x801132bc,%eax
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
80102ee3:	a1 bc 32 11 80       	mov    0x801132bc,%eax
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
80103115:	e8 b6 26 00 00       	call   801057d0 <memcmp>
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
80103215:	c7 44 24 04 7c 8d 10 	movl   $0x80108d7c,0x4(%esp)
8010321c:	80 
8010321d:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
80103224:	e8 bb 22 00 00       	call   801054e4 <initlock>
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
80103246:	a3 f4 32 11 80       	mov    %eax,0x801132f4
  log.size = sb.nlog;
8010324b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010324e:	a3 f8 32 11 80       	mov    %eax,0x801132f8
  log.dev = ROOTDEV;
80103253:	c7 05 04 33 11 80 01 	movl   $0x1,0x80113304
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
80103276:	8b 15 f4 32 11 80    	mov    0x801132f4,%edx
8010327c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010327f:	01 d0                	add    %edx,%eax
80103281:	83 c0 01             	add    $0x1,%eax
80103284:	89 c2                	mov    %eax,%edx
80103286:	a1 04 33 11 80       	mov    0x80113304,%eax
8010328b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010328f:	89 04 24             	mov    %eax,(%esp)
80103292:	e8 0f cf ff ff       	call   801001a6 <bread>
80103297:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010329a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010329d:	83 c0 10             	add    $0x10,%eax
801032a0:	8b 04 85 cc 32 11 80 	mov    -0x7feecd34(,%eax,4),%eax
801032a7:	89 c2                	mov    %eax,%edx
801032a9:	a1 04 33 11 80       	mov    0x80113304,%eax
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
801032d8:	e8 4b 25 00 00       	call   80105828 <memmove>
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
80103302:	a1 08 33 11 80       	mov    0x80113308,%eax
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
80103318:	a1 f4 32 11 80       	mov    0x801132f4,%eax
8010331d:	89 c2                	mov    %eax,%edx
8010331f:	a1 04 33 11 80       	mov    0x80113304,%eax
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
80103341:	a3 08 33 11 80       	mov    %eax,0x80113308
  for (i = 0; i < log.lh.n; i++) {
80103346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010334d:	eb 1b                	jmp    8010336a <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010334f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103352:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103355:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103359:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010335c:	83 c2 10             	add    $0x10,%edx
8010335f:	89 04 95 cc 32 11 80 	mov    %eax,-0x7feecd34(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103366:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010336a:	a1 08 33 11 80       	mov    0x80113308,%eax
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
80103387:	a1 f4 32 11 80       	mov    0x801132f4,%eax
8010338c:	89 c2                	mov    %eax,%edx
8010338e:	a1 04 33 11 80       	mov    0x80113304,%eax
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
801033ab:	8b 15 08 33 11 80    	mov    0x80113308,%edx
801033b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b4:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033bd:	eb 1b                	jmp    801033da <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c2:	83 c0 10             	add    $0x10,%eax
801033c5:	8b 0c 85 cc 32 11 80 	mov    -0x7feecd34(,%eax,4),%ecx
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
801033da:	a1 08 33 11 80       	mov    0x80113308,%eax
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
8010340c:	c7 05 08 33 11 80 00 	movl   $0x0,0x80113308
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
80103423:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
8010342a:	e8 d6 20 00 00       	call   80105505 <acquire>
  while(1){
    if(log.committing){
8010342f:	a1 00 33 11 80       	mov    0x80113300,%eax
80103434:	85 c0                	test   %eax,%eax
80103436:	74 16                	je     8010344e <begin_op+0x31>
      sleep(&log, &log.lock);
80103438:	c7 44 24 04 c0 32 11 	movl   $0x801132c0,0x4(%esp)
8010343f:	80 
80103440:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
80103447:	e8 05 19 00 00       	call   80104d51 <sleep>
8010344c:	eb 4f                	jmp    8010349d <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010344e:	8b 0d 08 33 11 80    	mov    0x80113308,%ecx
80103454:	a1 fc 32 11 80       	mov    0x801132fc,%eax
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
8010346c:	c7 44 24 04 c0 32 11 	movl   $0x801132c0,0x4(%esp)
80103473:	80 
80103474:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
8010347b:	e8 d1 18 00 00       	call   80104d51 <sleep>
80103480:	eb 1b                	jmp    8010349d <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103482:	a1 fc 32 11 80       	mov    0x801132fc,%eax
80103487:	83 c0 01             	add    $0x1,%eax
8010348a:	a3 fc 32 11 80       	mov    %eax,0x801132fc
      release(&log.lock);
8010348f:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
80103496:	e8 cc 20 00 00       	call   80105567 <release>
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
801034ae:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
801034b5:	e8 4b 20 00 00       	call   80105505 <acquire>
  log.outstanding -= 1;
801034ba:	a1 fc 32 11 80       	mov    0x801132fc,%eax
801034bf:	83 e8 01             	sub    $0x1,%eax
801034c2:	a3 fc 32 11 80       	mov    %eax,0x801132fc
  if(log.committing)
801034c7:	a1 00 33 11 80       	mov    0x80113300,%eax
801034cc:	85 c0                	test   %eax,%eax
801034ce:	74 0c                	je     801034dc <end_op+0x3b>
    panic("log.committing");
801034d0:	c7 04 24 80 8d 10 80 	movl   $0x80108d80,(%esp)
801034d7:	e8 5e d0 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
801034dc:	a1 fc 32 11 80       	mov    0x801132fc,%eax
801034e1:	85 c0                	test   %eax,%eax
801034e3:	75 13                	jne    801034f8 <end_op+0x57>
    do_commit = 1;
801034e5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801034ec:	c7 05 00 33 11 80 01 	movl   $0x1,0x80113300
801034f3:	00 00 00 
801034f6:	eb 0c                	jmp    80103504 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801034f8:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
801034ff:	e8 55 19 00 00       	call   80104e59 <wakeup>
  }
  release(&log.lock);
80103504:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
8010350b:	e8 57 20 00 00       	call   80105567 <release>

  if(do_commit){
80103510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103514:	74 33                	je     80103549 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103516:	e8 de 00 00 00       	call   801035f9 <commit>
    acquire(&log.lock);
8010351b:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
80103522:	e8 de 1f 00 00       	call   80105505 <acquire>
    log.committing = 0;
80103527:	c7 05 00 33 11 80 00 	movl   $0x0,0x80113300
8010352e:	00 00 00 
    wakeup(&log);
80103531:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
80103538:	e8 1c 19 00 00       	call   80104e59 <wakeup>
    release(&log.lock);
8010353d:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
80103544:	e8 1e 20 00 00       	call   80105567 <release>
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
8010355d:	8b 15 f4 32 11 80    	mov    0x801132f4,%edx
80103563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103566:	01 d0                	add    %edx,%eax
80103568:	83 c0 01             	add    $0x1,%eax
8010356b:	89 c2                	mov    %eax,%edx
8010356d:	a1 04 33 11 80       	mov    0x80113304,%eax
80103572:	89 54 24 04          	mov    %edx,0x4(%esp)
80103576:	89 04 24             	mov    %eax,(%esp)
80103579:	e8 28 cc ff ff       	call   801001a6 <bread>
8010357e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103584:	83 c0 10             	add    $0x10,%eax
80103587:	8b 04 85 cc 32 11 80 	mov    -0x7feecd34(,%eax,4),%eax
8010358e:	89 c2                	mov    %eax,%edx
80103590:	a1 04 33 11 80       	mov    0x80113304,%eax
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
801035bf:	e8 64 22 00 00       	call   80105828 <memmove>
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
801035e9:	a1 08 33 11 80       	mov    0x80113308,%eax
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
801035ff:	a1 08 33 11 80       	mov    0x80113308,%eax
80103604:	85 c0                	test   %eax,%eax
80103606:	7e 1e                	jle    80103626 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103608:	e8 3e ff ff ff       	call   8010354b <write_log>
    write_head();    // Write header to disk -- the real commit
8010360d:	e8 6f fd ff ff       	call   80103381 <write_head>
    install_trans(); // Now install writes to home locations
80103612:	e8 4d fc ff ff       	call   80103264 <install_trans>
    log.lh.n = 0; 
80103617:	c7 05 08 33 11 80 00 	movl   $0x0,0x80113308
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
8010362e:	a1 08 33 11 80       	mov    0x80113308,%eax
80103633:	83 f8 1d             	cmp    $0x1d,%eax
80103636:	7f 12                	jg     8010364a <log_write+0x22>
80103638:	a1 08 33 11 80       	mov    0x80113308,%eax
8010363d:	8b 15 f8 32 11 80    	mov    0x801132f8,%edx
80103643:	83 ea 01             	sub    $0x1,%edx
80103646:	39 d0                	cmp    %edx,%eax
80103648:	7c 0c                	jl     80103656 <log_write+0x2e>
    panic("too big a transaction");
8010364a:	c7 04 24 8f 8d 10 80 	movl   $0x80108d8f,(%esp)
80103651:	e8 e4 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103656:	a1 fc 32 11 80       	mov    0x801132fc,%eax
8010365b:	85 c0                	test   %eax,%eax
8010365d:	7f 0c                	jg     8010366b <log_write+0x43>
    panic("log_write outside of trans");
8010365f:	c7 04 24 a5 8d 10 80 	movl   $0x80108da5,(%esp)
80103666:	e8 cf ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010366b:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
80103672:	e8 8e 1e 00 00       	call   80105505 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103677:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367e:	eb 1f                	jmp    8010369f <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103683:	83 c0 10             	add    $0x10,%eax
80103686:	8b 04 85 cc 32 11 80 	mov    -0x7feecd34(,%eax,4),%eax
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
8010369f:	a1 08 33 11 80       	mov    0x80113308,%eax
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
801036b5:	89 04 95 cc 32 11 80 	mov    %eax,-0x7feecd34(,%edx,4)
  if (i == log.lh.n)
801036bc:	a1 08 33 11 80       	mov    0x80113308,%eax
801036c1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036c4:	75 0d                	jne    801036d3 <log_write+0xab>
    log.lh.n++;
801036c6:	a1 08 33 11 80       	mov    0x80113308,%eax
801036cb:	83 c0 01             	add    $0x1,%eax
801036ce:	a3 08 33 11 80       	mov    %eax,0x80113308
  b->flags |= B_DIRTY; // prevent eviction
801036d3:	8b 45 08             	mov    0x8(%ebp),%eax
801036d6:	8b 00                	mov    (%eax),%eax
801036d8:	83 c8 04             	or     $0x4,%eax
801036db:	89 c2                	mov    %eax,%edx
801036dd:	8b 45 08             	mov    0x8(%ebp),%eax
801036e0:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801036e2:	c7 04 24 c0 32 11 80 	movl   $0x801132c0,(%esp)
801036e9:	e8 79 1e 00 00       	call   80105567 <release>
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
80103735:	c7 04 24 5c aa 11 80 	movl   $0x8011aa5c,(%esp)
8010373c:	e8 80 f2 ff ff       	call   801029c1 <kinit1>
  kvmalloc();      // kernel page table
80103741:	e8 7f 4c 00 00       	call   801083c5 <kvmalloc>
  mpinit();        // collect info about this machine
80103746:	e8 46 04 00 00       	call   80103b91 <mpinit>
  lapicinit();
8010374b:	e8 dc f5 ff ff       	call   80102d2c <lapicinit>
  seginit();       // set up segments
80103750:	e8 03 46 00 00       	call   80107d58 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103755:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010375b:	0f b6 00             	movzbl (%eax),%eax
8010375e:	0f b6 c0             	movzbl %al,%eax
80103761:	89 44 24 04          	mov    %eax,0x4(%esp)
80103765:	c7 04 24 c0 8d 10 80 	movl   $0x80108dc0,(%esp)
8010376c:	e8 2f cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103771:	e8 79 06 00 00       	call   80103def <picinit>
  ioapicinit();    // another interrupt controller
80103776:	e8 3c f1 ff ff       	call   801028b7 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010377b:	e8 01 d3 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103780:	e8 22 39 00 00       	call   801070a7 <uartinit>
  pinit();         // process table
80103785:	e8 a3 0b 00 00       	call   8010432d <pinit>
  tvinit();        // trap vectors
8010378a:	e8 ca 34 00 00       	call   80106c59 <tvinit>
  binit();         // buffer cache
8010378f:	e8 a0 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103794:	e8 7e d7 ff ff       	call   80100f17 <fileinit>
  iinit();         // inode cache
80103799:	e8 13 de ff ff       	call   801015b1 <iinit>
  ideinit();       // disk
8010379e:	e8 7d ed ff ff       	call   80102520 <ideinit>
  if(!ismp)
801037a3:	a1 a4 33 11 80       	mov    0x801133a4,%eax
801037a8:	85 c0                	test   %eax,%eax
801037aa:	75 05                	jne    801037b1 <main+0x8d>
    timerinit();   // uniprocessor timer
801037ac:	e8 ee 33 00 00       	call   80106b9f <timerinit>
  startothers();   // start other processors
801037b1:	e8 7f 00 00 00       	call   80103835 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037b6:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037bd:	8e 
801037be:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037c5:	e8 2f f2 ff ff       	call   801029f9 <kinit2>
  userinit();      // first user process
801037ca:	e8 c0 0c 00 00       	call   8010448f <userinit>
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
801037da:	e8 fd 4b 00 00       	call   801083dc <switchkvm>
  seginit();
801037df:	e8 74 45 00 00       	call   80107d58 <seginit>
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
80103804:	c7 04 24 d7 8d 10 80 	movl   $0x80108dd7,(%esp)
8010380b:	e8 90 cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103810:	e8 b8 35 00 00       	call   80106dcd <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103815:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010381b:	05 a8 00 00 00       	add    $0xa8,%eax
80103820:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103827:	00 
80103828:	89 04 24             	mov    %eax,(%esp)
8010382b:	e8 da fe ff ff       	call   8010370a <xchg>
  scheduler();     // start running processes
80103830:	e8 15 13 00 00       	call   80104b4a <scheduler>

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
80103854:	c7 44 24 04 6c c5 10 	movl   $0x8010c56c,0x4(%esp)
8010385b:	80 
8010385c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010385f:	89 04 24             	mov    %eax,(%esp)
80103862:	e8 c1 1f 00 00       	call   80105828 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103867:	c7 45 f4 c0 33 11 80 	movl   $0x801133c0,-0xc(%ebp)
8010386e:	e9 85 00 00 00       	jmp    801038f8 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103873:	e8 0d f6 ff ff       	call   80102e85 <cpunum>
80103878:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010387e:	05 c0 33 11 80       	add    $0x801133c0,%eax
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
801038f8:	a1 a0 39 11 80       	mov    0x801139a0,%eax
801038fd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103903:	05 c0 33 11 80       	add    $0x801133c0,%eax
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
80103962:	a1 a4 c6 10 80       	mov    0x8010c6a4,%eax
80103967:	89 c2                	mov    %eax,%edx
80103969:	b8 c0 33 11 80       	mov    $0x801133c0,%eax
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
801039e4:	c7 44 24 04 e8 8d 10 	movl   $0x80108de8,0x4(%esp)
801039eb:	80 
801039ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ef:	89 04 24             	mov    %eax,(%esp)
801039f2:	e8 d9 1d 00 00       	call   801057d0 <memcmp>
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
80103b25:	c7 44 24 04 ed 8d 10 	movl   $0x80108ded,0x4(%esp)
80103b2c:	80 
80103b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b30:	89 04 24             	mov    %eax,(%esp)
80103b33:	e8 98 1c 00 00       	call   801057d0 <memcmp>
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
80103b97:	c7 05 a4 c6 10 80 c0 	movl   $0x801133c0,0x8010c6a4
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
80103bba:	c7 05 a4 33 11 80 01 	movl   $0x1,0x801133a4
80103bc1:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc7:	8b 40 24             	mov    0x24(%eax),%eax
80103bca:	a3 bc 32 11 80       	mov    %eax,0x801132bc
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
80103c01:	8b 04 85 30 8e 10 80 	mov    -0x7fef71d0(,%eax,4),%eax
80103c08:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c13:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c17:	0f b6 d0             	movzbl %al,%edx
80103c1a:	a1 a0 39 11 80       	mov    0x801139a0,%eax
80103c1f:	39 c2                	cmp    %eax,%edx
80103c21:	74 2d                	je     80103c50 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c26:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c2a:	0f b6 d0             	movzbl %al,%edx
80103c2d:	a1 a0 39 11 80       	mov    0x801139a0,%eax
80103c32:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c36:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c3a:	c7 04 24 f2 8d 10 80 	movl   $0x80108df2,(%esp)
80103c41:	e8 5a c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c46:	c7 05 a4 33 11 80 00 	movl   $0x0,0x801133a4
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
80103c61:	a1 a0 39 11 80       	mov    0x801139a0,%eax
80103c66:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c6c:	05 c0 33 11 80       	add    $0x801133c0,%eax
80103c71:	a3 a4 c6 10 80       	mov    %eax,0x8010c6a4
      cpus[ncpu].id = ncpu;
80103c76:	8b 15 a0 39 11 80    	mov    0x801139a0,%edx
80103c7c:	a1 a0 39 11 80       	mov    0x801139a0,%eax
80103c81:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103c87:	81 c2 c0 33 11 80    	add    $0x801133c0,%edx
80103c8d:	88 02                	mov    %al,(%edx)
      ncpu++;
80103c8f:	a1 a0 39 11 80       	mov    0x801139a0,%eax
80103c94:	83 c0 01             	add    $0x1,%eax
80103c97:	a3 a0 39 11 80       	mov    %eax,0x801139a0
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
80103caf:	a2 a0 33 11 80       	mov    %al,0x801133a0
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
80103ccd:	c7 04 24 10 8e 10 80 	movl   $0x80108e10,(%esp)
80103cd4:	e8 c7 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103cd9:	c7 05 a4 33 11 80 00 	movl   $0x0,0x801133a4
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
80103cef:	a1 a4 33 11 80       	mov    0x801133a4,%eax
80103cf4:	85 c0                	test   %eax,%eax
80103cf6:	75 1d                	jne    80103d15 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cf8:	c7 05 a0 39 11 80 01 	movl   $0x1,0x801139a0
80103cff:	00 00 00 
    lapic = 0;
80103d02:	c7 05 bc 32 11 80 00 	movl   $0x0,0x801132bc
80103d09:	00 00 00 
    ioapicid = 0;
80103d0c:	c6 05 a0 33 11 80 00 	movb   $0x0,0x801133a0
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
80103fc6:	c7 44 24 04 44 8e 10 	movl   $0x80108e44,0x4(%esp)
80103fcd:	80 
80103fce:	89 04 24             	mov    %eax,(%esp)
80103fd1:	e8 0e 15 00 00       	call   801054e4 <initlock>
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
8010407d:	e8 83 14 00 00       	call   80105505 <acquire>
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
801040a0:	e8 b4 0d 00 00       	call   80104e59 <wakeup>
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
801040bf:	e8 95 0d 00 00       	call   80104e59 <wakeup>
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
801040e4:	e8 7e 14 00 00       	call   80105567 <release>
    kfree((char*)p);
801040e9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ec:	89 04 24             	mov    %eax,(%esp)
801040ef:	e8 62 e9 ff ff       	call   80102a56 <kfree>
801040f4:	eb 0b                	jmp    80104101 <pipeclose+0x90>
  } else
    release(&p->lock);
801040f6:	8b 45 08             	mov    0x8(%ebp),%eax
801040f9:	89 04 24             	mov    %eax,(%esp)
801040fc:	e8 66 14 00 00       	call   80105567 <release>
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
8010410f:	e8 f1 13 00 00       	call   80105505 <acquire>
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
80104142:	e8 20 14 00 00       	call   80105567 <release>
        return -1;
80104147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010414c:	e9 9f 00 00 00       	jmp    801041f0 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104151:	8b 45 08             	mov    0x8(%ebp),%eax
80104154:	05 34 02 00 00       	add    $0x234,%eax
80104159:	89 04 24             	mov    %eax,(%esp)
8010415c:	e8 f8 0c 00 00       	call   80104e59 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104161:	8b 45 08             	mov    0x8(%ebp),%eax
80104164:	8b 55 08             	mov    0x8(%ebp),%edx
80104167:	81 c2 38 02 00 00    	add    $0x238,%edx
8010416d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104171:	89 14 24             	mov    %edx,(%esp)
80104174:	e8 d8 0b 00 00       	call   80104d51 <sleep>
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
801041dd:	e8 77 0c 00 00       	call   80104e59 <wakeup>
  release(&p->lock);
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	89 04 24             	mov    %eax,(%esp)
801041e8:	e8 7a 13 00 00       	call   80105567 <release>
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
801041ff:	e8 01 13 00 00       	call   80105505 <acquire>
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
80104219:	e8 49 13 00 00       	call   80105567 <release>
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
8010423b:	e8 11 0b 00 00       	call   80104d51 <sleep>
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
801042ca:	e8 8a 0b 00 00       	call   80104e59 <wakeup>
  release(&p->lock);
801042cf:	8b 45 08             	mov    0x8(%ebp),%eax
801042d2:	89 04 24             	mov    %eax,(%esp)
801042d5:	e8 8d 12 00 00       	call   80105567 <release>
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
  //initlock(&ptable.lock, "ptable");
}
80104330:	5d                   	pop    %ebp
80104331:	c3                   	ret    

80104332 <allocpid>:

int 
allocpid(void) 
{
80104332:	55                   	push   %ebp
80104333:	89 e5                	mov    %esp,%ebp
80104335:	83 ec 1c             	sub    $0x1c,%esp
  //acquire(&ptable.lock);
  //pid = nextpid++;
  //release(&ptable.lock);

  do{
    pid = nextpid;
80104338:	a1 20 c0 10 80       	mov    0x8010c020,%eax
8010433d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  } while(!cas(&nextpid, pid, pid+1));
80104340:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104343:	83 c0 01             	add    $0x1,%eax
80104346:	89 44 24 08          	mov    %eax,0x8(%esp)
8010434a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010434d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104351:	c7 04 24 20 c0 10 80 	movl   $0x8010c020,(%esp)
80104358:	e8 9c ff ff ff       	call   801042f9 <cas>
8010435d:	85 c0                	test   %eax,%eax
8010435f:	74 d7                	je     80104338 <allocpid+0x6>
  //cprintf("alloc pid = %d", pid + 1);
  return pid;
80104361:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104364:	c9                   	leave  
80104365:	c3                   	ret    

80104366 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104366:	55                   	push   %ebp
80104367:	89 e5                	mov    %esp,%ebp
80104369:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  //acquire(&ptable.lock);
  //pushcli();
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010436c:	c7 45 f4 c0 39 11 80 	movl   $0x801139c0,-0xc(%ebp)
80104373:	eb 4c                	jmp    801043c1 <allocproc+0x5b>
    //if(p->state == UNUSED)
    if(cas(&(p->state), UNUSED, EMBRYO))
80104375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104378:	83 c0 0c             	add    $0xc,%eax
8010437b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80104382:	00 
80104383:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010438a:	00 
8010438b:	89 04 24             	mov    %eax,(%esp)
8010438e:	e8 66 ff ff ff       	call   801042f9 <cas>
80104393:	85 c0                	test   %eax,%eax
80104395:	74 23                	je     801043ba <allocproc+0x54>
      goto found;
80104397:	90                   	nop
found:
  //p->state = EMBRYO;  
  //release(&ptable.lock);
  //popcli();

  p->pid = allocpid();
80104398:	e8 95 ff ff ff       	call   80104332 <allocpid>
8010439d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043a0:	89 42 10             	mov    %eax,0x10(%edx)

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043a3:	e8 47 e7 ff ff       	call   80102aef <kalloc>
801043a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ab:	89 42 08             	mov    %eax,0x8(%edx)
801043ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b1:	8b 40 08             	mov    0x8(%eax),%eax
801043b4:	85 c0                	test   %eax,%eax
801043b6:	75 30                	jne    801043e8 <allocproc+0x82>
801043b8:	eb 1a                	jmp    801043d4 <allocproc+0x6e>
  struct proc *p;
  char *sp;

  //acquire(&ptable.lock);
  //pushcli();
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043ba:	81 45 f4 a0 01 00 00 	addl   $0x1a0,-0xc(%ebp)
801043c1:	81 7d f4 c0 a1 11 80 	cmpl   $0x8011a1c0,-0xc(%ebp)
801043c8:	72 ab                	jb     80104375 <allocproc+0xf>
    //if(p->state == UNUSED)
    if(cas(&(p->state), UNUSED, EMBRYO))
      goto found;
  //release(&ptable.lock);
  //popcli();
  return 0;
801043ca:	b8 00 00 00 00       	mov    $0x0,%eax
801043cf:	e9 b9 00 00 00       	jmp    8010448d <allocproc+0x127>

  p->pid = allocpid();

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043de:	b8 00 00 00 00       	mov    $0x0,%eax
801043e3:	e9 a5 00 00 00       	jmp    8010448d <allocproc+0x127>
  }
  sp = p->kstack + KSTACKSIZE;
801043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043eb:	8b 40 08             	mov    0x8(%eax),%eax
801043ee:	05 00 10 00 00       	add    $0x1000,%eax
801043f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043f6:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
801043fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104400:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104403:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80104407:	ba 0f 6c 10 80       	mov    $0x80106c0f,%edx
8010440c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010440f:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104411:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80104415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104418:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010441b:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010441e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104421:	8b 40 1c             	mov    0x1c(%eax),%eax
80104424:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010442b:	00 
8010442c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104433:	00 
80104434:	89 04 24             	mov    %eax,(%esp)
80104437:	e8 1d 13 00 00       	call   80105759 <memset>
  p->context->eip = (uint)forkret;
8010443c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104442:	ba 2c 4d 10 80       	mov    $0x80104d2c,%edx
80104447:	89 50 10             	mov    %edx,0x10(%eax)

  //initialize cstack
  struct cstackframe *csf;
  for(csf = p->pending_signals.frames; csf < &p->pending_signals.frames[MAX_CSTACK_FRAMES]; csf++) {
8010444a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444d:	83 e8 80             	sub    $0xffffff80,%eax
80104450:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104453:	eb 0e                	jmp    80104463 <allocproc+0xfd>
    csf->used = 0;
80104455:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104458:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  //initialize cstack
  struct cstackframe *csf;
  for(csf = p->pending_signals.frames; csf < &p->pending_signals.frames[MAX_CSTACK_FRAMES]; csf++) {
8010445f:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
80104463:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104466:	05 48 01 00 00       	add    $0x148,%eax
8010446b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010446e:	77 e5                	ja     80104455 <allocproc+0xef>
    csf->used = 0;
  }
  p->pending_signals.head = 0;
80104470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104473:	c7 80 48 01 00 00 00 	movl   $0x0,0x148(%eax)
8010447a:	00 00 00 

  // available for handeling signal 
  p->handling_signal = 0;
8010447d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104480:	c7 80 9c 01 00 00 00 	movl   $0x0,0x19c(%eax)
80104487:	00 00 00 

  return p;
8010448a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010448d:	c9                   	leave  
8010448e:	c3                   	ret    

8010448f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010448f:	55                   	push   %ebp
80104490:	89 e5                	mov    %esp,%ebp
80104492:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104495:	e8 cc fe ff ff       	call   80104366 <allocproc>
8010449a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010449d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a0:	a3 a8 c6 10 80       	mov    %eax,0x8010c6a8
  if((p->pgdir = setupkvm()) == 0)
801044a5:	e8 5e 3e 00 00       	call   80108308 <setupkvm>
801044aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044ad:	89 42 04             	mov    %eax,0x4(%edx)
801044b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b3:	8b 40 04             	mov    0x4(%eax),%eax
801044b6:	85 c0                	test   %eax,%eax
801044b8:	75 0c                	jne    801044c6 <userinit+0x37>
    panic("userinit: out of memory?");
801044ba:	c7 04 24 49 8e 10 80 	movl   $0x80108e49,(%esp)
801044c1:	e8 74 c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044c6:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ce:	8b 40 04             	mov    0x4(%eax),%eax
801044d1:	89 54 24 08          	mov    %edx,0x8(%esp)
801044d5:	c7 44 24 04 40 c5 10 	movl   $0x8010c540,0x4(%esp)
801044dc:	80 
801044dd:	89 04 24             	mov    %eax,(%esp)
801044e0:	e8 7b 40 00 00       	call   80108560 <inituvm>
  p->sz = PGSIZE;
801044e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f1:	8b 40 18             	mov    0x18(%eax),%eax
801044f4:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044fb:	00 
801044fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104503:	00 
80104504:	89 04 24             	mov    %eax,(%esp)
80104507:	e8 4d 12 00 00       	call   80105759 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010450c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450f:	8b 40 18             	mov    0x18(%eax),%eax
80104512:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451b:	8b 40 18             	mov    0x18(%eax),%eax
8010451e:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 40 18             	mov    0x18(%eax),%eax
8010452a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010452d:	8b 52 18             	mov    0x18(%edx),%edx
80104530:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104534:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453b:	8b 40 18             	mov    0x18(%eax),%eax
8010453e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104541:	8b 52 18             	mov    0x18(%edx),%edx
80104544:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104548:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010454c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454f:	8b 40 18             	mov    0x18(%eax),%eax
80104552:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455c:	8b 40 18             	mov    0x18(%eax),%eax
8010455f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104569:	8b 40 18             	mov    0x18(%eax),%eax
8010456c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104576:	83 c0 6c             	add    $0x6c,%eax
80104579:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104580:	00 
80104581:	c7 44 24 04 62 8e 10 	movl   $0x80108e62,0x4(%esp)
80104588:	80 
80104589:	89 04 24             	mov    %eax,(%esp)
8010458c:	e8 e8 13 00 00       	call   80105979 <safestrcpy>
  p->cwd = namei("/");
80104591:	c7 04 24 6b 8e 10 80 	movl   $0x80108e6b,(%esp)
80104598:	e8 76 de ff ff       	call   80102413 <namei>
8010459d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045a0:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801045a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045ad:	c9                   	leave  
801045ae:	c3                   	ret    

801045af <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045af:	55                   	push   %ebp
801045b0:	89 e5                	mov    %esp,%ebp
801045b2:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045bb:	8b 00                	mov    (%eax),%eax
801045bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045c4:	7e 34                	jle    801045fa <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045c6:	8b 55 08             	mov    0x8(%ebp),%edx
801045c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cc:	01 c2                	add    %eax,%edx
801045ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d4:	8b 40 04             	mov    0x4(%eax),%eax
801045d7:	89 54 24 08          	mov    %edx,0x8(%esp)
801045db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045de:	89 54 24 04          	mov    %edx,0x4(%esp)
801045e2:	89 04 24             	mov    %eax,(%esp)
801045e5:	e8 ec 40 00 00       	call   801086d6 <allocuvm>
801045ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045f1:	75 41                	jne    80104634 <growproc+0x85>
      return -1;
801045f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045f8:	eb 58                	jmp    80104652 <growproc+0xa3>
  } else if(n < 0){
801045fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045fe:	79 34                	jns    80104634 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104600:	8b 55 08             	mov    0x8(%ebp),%edx
80104603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104606:	01 c2                	add    %eax,%edx
80104608:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010460e:	8b 40 04             	mov    0x4(%eax),%eax
80104611:	89 54 24 08          	mov    %edx,0x8(%esp)
80104615:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104618:	89 54 24 04          	mov    %edx,0x4(%esp)
8010461c:	89 04 24             	mov    %eax,(%esp)
8010461f:	e8 8c 41 00 00       	call   801087b0 <deallocuvm>
80104624:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104627:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010462b:	75 07                	jne    80104634 <growproc+0x85>
      return -1;
8010462d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104632:	eb 1e                	jmp    80104652 <growproc+0xa3>
  }
  proc->sz = sz;
80104634:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010463d:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010463f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104645:	89 04 24             	mov    %eax,(%esp)
80104648:	e8 ac 3d 00 00       	call   801083f9 <switchuvm>
  return 0;
8010464d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104652:	c9                   	leave  
80104653:	c3                   	ret    

80104654 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104654:	55                   	push   %ebp
80104655:	89 e5                	mov    %esp,%ebp
80104657:	57                   	push   %edi
80104658:	56                   	push   %esi
80104659:	53                   	push   %ebx
8010465a:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010465d:	e8 04 fd ff ff       	call   80104366 <allocproc>
80104662:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104665:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104669:	75 0a                	jne    80104675 <fork+0x21>
    return -1;
8010466b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104670:	e9 77 01 00 00       	jmp    801047ec <fork+0x198>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104675:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010467b:	8b 10                	mov    (%eax),%edx
8010467d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104683:	8b 40 04             	mov    0x4(%eax),%eax
80104686:	89 54 24 04          	mov    %edx,0x4(%esp)
8010468a:	89 04 24             	mov    %eax,(%esp)
8010468d:	e8 ba 42 00 00       	call   8010894c <copyuvm>
80104692:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104695:	89 42 04             	mov    %eax,0x4(%edx)
80104698:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469b:	8b 40 04             	mov    0x4(%eax),%eax
8010469e:	85 c0                	test   %eax,%eax
801046a0:	75 2c                	jne    801046ce <fork+0x7a>
    kfree(np->kstack);
801046a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a5:	8b 40 08             	mov    0x8(%eax),%eax
801046a8:	89 04 24             	mov    %eax,(%esp)
801046ab:	e8 a6 e3 ff ff       	call   80102a56 <kfree>
    np->kstack = 0;
801046b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046c9:	e9 1e 01 00 00       	jmp    801047ec <fork+0x198>
  }
  np->sz = proc->sz;
801046ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d4:	8b 10                	mov    (%eax),%edx
801046d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d9:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046db:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e5:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046eb:	8b 50 18             	mov    0x18(%eax),%edx
801046ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f4:	8b 40 18             	mov    0x18(%eax),%eax
801046f7:	89 c3                	mov    %eax,%ebx
801046f9:	b8 13 00 00 00       	mov    $0x13,%eax
801046fe:	89 d7                	mov    %edx,%edi
80104700:	89 de                	mov    %ebx,%esi
80104702:	89 c1                	mov    %eax,%ecx
80104704:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104706:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104709:	8b 40 18             	mov    0x18(%eax),%eax
8010470c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104713:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010471a:	eb 3d                	jmp    80104759 <fork+0x105>
    if(proc->ofile[i])
8010471c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104722:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104725:	83 c2 08             	add    $0x8,%edx
80104728:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010472c:	85 c0                	test   %eax,%eax
8010472e:	74 25                	je     80104755 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104730:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104736:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104739:	83 c2 08             	add    $0x8,%edx
8010473c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104740:	89 04 24             	mov    %eax,(%esp)
80104743:	e8 4b c8 ff ff       	call   80100f93 <filedup>
80104748:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010474b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010474e:	83 c1 08             	add    $0x8,%ecx
80104751:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104755:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104759:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010475d:	7e bd                	jle    8010471c <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010475f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104765:	8b 40 68             	mov    0x68(%eax),%eax
80104768:	89 04 24             	mov    %eax,(%esp)
8010476b:	e8 c6 d0 ff ff       	call   80101836 <idup>
80104770:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104773:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104776:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010477c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010477f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104782:	83 c0 6c             	add    $0x6c,%eax
80104785:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010478c:	00 
8010478d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104791:	89 04 24             	mov    %eax,(%esp)
80104794:	e8 e0 11 00 00       	call   80105979 <safestrcpy>
  //copy signal handler
  np->sighandler = proc->sighandler; 
80104799:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010479f:	8b 50 7c             	mov    0x7c(%eax),%edx
801047a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a5:	89 50 7c             	mov    %edx,0x7c(%eax)
  pid = np->pid;
801047a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ab:	8b 40 10             	mov    0x10(%eax),%eax
801047ae:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  //acquire(&ptable.lock);
  //np->state = RUNNABLE;
  //release(&ptable.lock);
  pushcli();
801047b1:	e8 a3 0e 00 00       	call   80105659 <pushcli>
  //change process state, if didn't succeed then return -1 for fork() failed
  if(!cas(&(np->state), EMBRYO, RUNNABLE))
801047b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b9:	83 c0 0c             	add    $0xc,%eax
801047bc:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
801047c3:	00 
801047c4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801047cb:	00 
801047cc:	89 04 24             	mov    %eax,(%esp)
801047cf:	e8 25 fb ff ff       	call   801042f9 <cas>
801047d4:	85 c0                	test   %eax,%eax
801047d6:	75 0c                	jne    801047e4 <fork+0x190>
  {
    popcli();
801047d8:	e8 c0 0e 00 00       	call   8010569d <popcli>
    return -1;
801047dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047e2:	eb 08                	jmp    801047ec <fork+0x198>
  }
  popcli();
801047e4:	e8 b4 0e 00 00       	call   8010569d <popcli>
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
80104801:	a1 a8 c6 10 80       	mov    0x8010c6a8,%eax
80104806:	39 c2                	cmp    %eax,%edx
80104808:	75 0c                	jne    80104816 <exit+0x22>
    panic("init exiting");
8010480a:	c7 04 24 6d 8e 10 80 	movl   $0x80108e6d,(%esp)
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
80104846:	e8 90 c7 ff ff       	call   80100fdb <fileclose>
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
80104869:	e8 af eb ff ff       	call   8010341d <begin_op>
  iput(proc->cwd);
8010486e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104874:	8b 40 68             	mov    0x68(%eax),%eax
80104877:	89 04 24             	mov    %eax,(%esp)
8010487a:	e8 9c d1 ff ff       	call   80101a1b <iput>
  end_op();
8010487f:	e8 1d ec ff ff       	call   801034a1 <end_op>
  proc->cwd = 0;
80104884:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  //acquire(&ptable.lock);
  //proc->state = ZOMBIE;
  pushcli();
80104891:	e8 c3 0d 00 00       	call   80105659 <pushcli>
  if(!cas(&(proc->state), RUNNING, nZOMBIE)){
80104896:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489c:	83 c0 0c             	add    $0xc,%eax
8010489f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801048a6:	00 
801048a7:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
801048ae:	00 
801048af:	89 04 24             	mov    %eax,(%esp)
801048b2:	e8 42 fa ff ff       	call   801042f9 <cas>
801048b7:	85 c0                	test   %eax,%eax
801048b9:	75 02                	jne    801048bd <exit+0xc9>
    return; // if cas() failed then exit() failed
801048bb:	eb 7a                	jmp    80104937 <exit+0x143>
  }

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801048bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c3:	8b 40 14             	mov    0x14(%eax),%eax
801048c6:	89 04 24             	mov    %eax,(%esp)
801048c9:	e8 05 05 00 00       	call   80104dd3 <wakeup1>
  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048ce:	c7 45 f4 c0 39 11 80 	movl   $0x801139c0,-0xc(%ebp)
801048d5:	eb 46                	jmp    8010491d <exit+0x129>
    if(p->parent == proc)
801048d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048da:	8b 50 14             	mov    0x14(%eax),%edx
801048dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048e3:	39 c2                	cmp    %eax,%edx
801048e5:	75 2f                	jne    80104916 <exit+0x122>
    {
      p->parent = initproc;
801048e7:	8b 15 a8 c6 10 80    	mov    0x8010c6a8,%edx
801048ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f0:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE || p->state == nZOMBIE)
801048f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f6:	8b 40 0c             	mov    0xc(%eax),%eax
801048f9:	83 f8 05             	cmp    $0x5,%eax
801048fc:	74 0b                	je     80104909 <exit+0x115>
801048fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104901:	8b 40 0c             	mov    0xc(%eax),%eax
80104904:	83 f8 08             	cmp    $0x8,%eax
80104907:	75 0d                	jne    80104916 <exit+0x122>
        wakeup1(initproc);
80104909:	a1 a8 c6 10 80       	mov    0x8010c6a8,%eax
8010490e:	89 04 24             	mov    %eax,(%esp)
80104911:	e8 bd 04 00 00       	call   80104dd3 <wakeup1>
  }

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104916:	81 45 f4 a0 01 00 00 	addl   $0x1a0,-0xc(%ebp)
8010491d:	81 7d f4 c0 a1 11 80 	cmpl   $0x8011a1c0,-0xc(%ebp)
80104924:	72 b1                	jb     801048d7 <exit+0xe3>
      if(p->state == ZOMBIE || p->state == nZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  sched();
80104926:	e8 33 03 00 00       	call   80104c5e <sched>
  panic("zombie exit");
8010492b:	c7 04 24 7a 8e 10 80 	movl   $0x80108e7a,(%esp)
80104932:	e8 03 bc ff ff       	call   8010053a <panic>
}
80104937:	c9                   	leave  
80104938:	c3                   	ret    

80104939 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104939:	55                   	push   %ebp
8010493a:	89 e5                	mov    %esp,%ebp
8010493c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  //acquire(&ptable.lock);
  pushcli();
8010493f:	e8 15 0d 00 00       	call   80105659 <pushcli>

  for(;;){
    proc->chan = (int)proc;
80104944:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104951:	89 50 20             	mov    %edx,0x20(%eax)
    //proc->state = SLEEPING;
    // start transition to SLEEPING (finish in scheduler)
    cas(&(proc->state),RUNNING, nSLEEPING);    
80104954:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010495a:	83 c0 0c             	add    $0xc,%eax
8010495d:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
80104964:	00 
80104965:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
8010496c:	00 
8010496d:	89 04 24             	mov    %eax,(%esp)
80104970:	e8 84 f9 ff ff       	call   801042f9 <cas>
    // Scan through table looking for zombie children.
    havekids = 0;
80104975:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010497c:	c7 45 f4 c0 39 11 80 	movl   $0x801139c0,-0xc(%ebp)
80104983:	e9 dc 00 00 00       	jmp    80104a64 <wait+0x12b>
      if(p->parent != proc)
80104988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498b:	8b 50 14             	mov    0x14(%eax),%edx
8010498e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104994:	39 c2                	cmp    %eax,%edx
80104996:	74 05                	je     8010499d <wait+0x64>
        continue;
80104998:	e9 c0 00 00 00       	jmp    80104a5d <wait+0x124>
      
      havekids = 1;
8010499d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      //busy wait until scheduler finish transition to ZOMBIE
      while(p->state == nZOMBIE);
801049a4:	90                   	nop
801049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a8:	8b 40 0c             	mov    0xc(%eax),%eax
801049ab:	83 f8 08             	cmp    $0x8,%eax
801049ae:	74 f5                	je     801049a5 <wait+0x6c>

      // transition finished, now we are sure the state is ZOMBIE
      if(p->state == ZOMBIE){
801049b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b3:	8b 40 0c             	mov    0xc(%eax),%eax
801049b6:	83 f8 05             	cmp    $0x5,%eax
801049b9:	0f 85 9e 00 00 00    	jne    80104a5d <wait+0x124>
        // Found one.
        pid = p->pid;
801049bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c2:	8b 40 10             	mov    0x10(%eax),%eax
801049c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        //p->state = UNUSED;
        cas(&(p->state), ZOMBIE, UNUSED);
801049c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049cb:	83 c0 0c             	add    $0xc,%eax
801049ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801049d5:	00 
801049d6:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
801049dd:	00 
801049de:	89 04 24             	mov    %eax,(%esp)
801049e1:	e8 13 f9 ff ff       	call   801042f9 <cas>
        p->pid = 0;
801049e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e9:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fd:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)

        proc->chan = 0;
80104a01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a07:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
        //proc->state = RUNNING;
        //release(&ptable.lock);
        // if a child zombie so we need to return it's pid, so we're back to RUNNING
        cas(&(proc->state), nSLEEPING, RUNNING);
80104a0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a14:	83 c0 0c             	add    $0xc,%eax
80104a17:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104a1e:	00 
80104a1f:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
80104a26:	00 
80104a27:	89 04 24             	mov    %eax,(%esp)
80104a2a:	e8 ca f8 ff ff       	call   801042f9 <cas>
        cas(&(proc->state), nRUNNABLE, RUNNING);  
80104a2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a35:	83 c0 0c             	add    $0xc,%eax
80104a38:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104a3f:	00 
80104a40:	c7 44 24 04 07 00 00 	movl   $0x7,0x4(%esp)
80104a47:	00 
80104a48:	89 04 24             	mov    %eax,(%esp)
80104a4b:	e8 a9 f8 ff ff       	call   801042f9 <cas>

        popcli();
80104a50:	e8 48 0c 00 00       	call   8010569d <popcli>
        return pid;
80104a55:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a58:	e9 8c 00 00 00       	jmp    80104ae9 <wait+0x1b0>
    //proc->state = SLEEPING;
    // start transition to SLEEPING (finish in scheduler)
    cas(&(proc->state),RUNNING, nSLEEPING);    
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a5d:	81 45 f4 a0 01 00 00 	addl   $0x1a0,-0xc(%ebp)
80104a64:	81 7d f4 c0 a1 11 80 	cmpl   $0x8011a1c0,-0xc(%ebp)
80104a6b:	0f 82 17 ff ff ff    	jb     80104988 <wait+0x4f>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104a71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a75:	74 0d                	je     80104a84 <wait+0x14b>
80104a77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a7d:	8b 40 24             	mov    0x24(%eax),%eax
80104a80:	85 c0                	test   %eax,%eax
80104a82:	74 5b                	je     80104adf <wait+0x1a6>
      proc->chan = 0;
80104a84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a8a:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      //proc->state = RUNNING;      
      //release(&ptable.lock);
      cas(&(proc->state), nSLEEPING, RUNNING);
80104a91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a97:	83 c0 0c             	add    $0xc,%eax
80104a9a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104aa1:	00 
80104aa2:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
80104aa9:	00 
80104aaa:	89 04 24             	mov    %eax,(%esp)
80104aad:	e8 47 f8 ff ff       	call   801042f9 <cas>
      cas(&(proc->state), SLEEPING, RUNNING);
80104ab2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab8:	83 c0 0c             	add    $0xc,%eax
80104abb:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104ac2:	00 
80104ac3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80104aca:	00 
80104acb:	89 04 24             	mov    %eax,(%esp)
80104ace:	e8 26 f8 ff ff       	call   801042f9 <cas>
      popcli();
80104ad3:	e8 c5 0b 00 00       	call   8010569d <popcli>
      return -1;
80104ad8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104add:	eb 0a                	jmp    80104ae9 <wait+0x1b0>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sched();
80104adf:	e8 7a 01 00 00       	call   80104c5e <sched>
  }
80104ae4:	e9 5b fe ff ff       	jmp    80104944 <wait+0xb>
}
80104ae9:	c9                   	leave  
80104aea:	c3                   	ret    

80104aeb <freeproc>:

void 
freeproc(struct proc *p)
{
80104aeb:	55                   	push   %ebp
80104aec:	89 e5                	mov    %esp,%ebp
80104aee:	83 ec 18             	sub    $0x18,%esp
  if (!p || p->state != nZOMBIE)
80104af1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104af5:	74 0b                	je     80104b02 <freeproc+0x17>
80104af7:	8b 45 08             	mov    0x8(%ebp),%eax
80104afa:	8b 40 0c             	mov    0xc(%eax),%eax
80104afd:	83 f8 08             	cmp    $0x8,%eax
80104b00:	74 0c                	je     80104b0e <freeproc+0x23>
    panic("freeproc not zombie");
80104b02:	c7 04 24 86 8e 10 80 	movl   $0x80108e86,(%esp)
80104b09:	e8 2c ba ff ff       	call   8010053a <panic>
  kfree(p->kstack);
80104b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b11:	8b 40 08             	mov    0x8(%eax),%eax
80104b14:	89 04 24             	mov    %eax,(%esp)
80104b17:	e8 3a df ff ff       	call   80102a56 <kfree>
  p->kstack = 0;
80104b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  freevm(p->pgdir);
80104b26:	8b 45 08             	mov    0x8(%ebp),%eax
80104b29:	8b 40 04             	mov    0x4(%eax),%eax
80104b2c:	89 04 24             	mov    %eax,(%esp)
80104b2f:	e8 38 3d 00 00       	call   8010886c <freevm>
  p->killed = 0;
80104b34:	8b 45 08             	mov    0x8(%ebp),%eax
80104b37:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
  p->chan = 0;
80104b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b41:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
}
80104b48:	c9                   	leave  
80104b49:	c3                   	ret    

80104b4a <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b4a:	55                   	push   %ebp
80104b4b:	89 e5                	mov    %esp,%ebp
80104b4d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b50:	e8 9e f7 ff ff       	call   801042f3 <sti>

    // Loop over process table looking for process to run.
    //acquire(&ptable.lock);
    pushcli();
80104b55:	e8 ff 0a 00 00       	call   80105659 <pushcli>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b5a:	c7 45 f4 c0 39 11 80 	movl   $0x801139c0,-0xc(%ebp)
80104b61:	e9 e1 00 00 00       	jmp    80104c47 <scheduler+0xfd>
      //if(p->state != RUNNABLE)
      if(!cas(&(p->state), RUNNABLE, RUNNING))
80104b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b69:	83 c0 0c             	add    $0xc,%eax
80104b6c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104b73:	00 
80104b74:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80104b7b:	00 
80104b7c:	89 04 24             	mov    %eax,(%esp)
80104b7f:	e8 75 f7 ff ff       	call   801042f9 <cas>
80104b84:	85 c0                	test   %eax,%eax
80104b86:	75 05                	jne    80104b8d <scheduler+0x43>
        continue;
80104b88:	e9 b3 00 00 00       	jmp    80104c40 <scheduler+0xf6>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b90:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b99:	89 04 24             	mov    %eax,(%esp)
80104b9c:	e8 58 38 00 00       	call   801083f9 <switchuvm>
      //p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
80104ba1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba7:	8b 40 1c             	mov    0x1c(%eax),%eax
80104baa:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bb1:	83 c2 04             	add    $0x4,%edx
80104bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bb8:	89 14 24             	mov    %edx,(%esp)
80104bbb:	e8 2a 0e 00 00       	call   801059ea <swtch>
      cas(&(p->state), nSLEEPING, SLEEPING);
80104bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc3:	83 c0 0c             	add    $0xc,%eax
80104bc6:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
80104bcd:	00 
80104bce:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
80104bd5:	00 
80104bd6:	89 04 24             	mov    %eax,(%esp)
80104bd9:	e8 1b f7 ff ff       	call   801042f9 <cas>
      cas(&(p->state), nRUNNABLE, RUNNABLE);
80104bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be1:	83 c0 0c             	add    $0xc,%eax
80104be4:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
80104beb:	00 
80104bec:	c7 44 24 04 07 00 00 	movl   $0x7,0x4(%esp)
80104bf3:	00 
80104bf4:	89 04 24             	mov    %eax,(%esp)
80104bf7:	e8 fd f6 ff ff       	call   801042f9 <cas>
      switchkvm();
80104bfc:	e8 db 37 00 00       	call   801083dc <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c01:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c08:	00 00 00 00 
      if (p->state == nZOMBIE)
80104c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0f:	8b 40 0c             	mov    0xc(%eax),%eax
80104c12:	83 f8 08             	cmp    $0x8,%eax
80104c15:	75 29                	jne    80104c40 <scheduler+0xf6>
      {
        freeproc(p);
80104c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1a:	89 04 24             	mov    %eax,(%esp)
80104c1d:	e8 c9 fe ff ff       	call   80104aeb <freeproc>
        cas(&(p->state), nZOMBIE, ZOMBIE);
80104c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c25:	83 c0 0c             	add    $0xc,%eax
80104c28:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
80104c2f:	00 
80104c30:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
80104c37:	00 
80104c38:	89 04 24             	mov    %eax,(%esp)
80104c3b:	e8 b9 f6 ff ff       	call   801042f9 <cas>
    sti();

    // Loop over process table looking for process to run.
    //acquire(&ptable.lock);
    pushcli();
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c40:	81 45 f4 a0 01 00 00 	addl   $0x1a0,-0xc(%ebp)
80104c47:	81 7d f4 c0 a1 11 80 	cmpl   $0x8011a1c0,-0xc(%ebp)
80104c4e:	0f 82 12 ff ff ff    	jb     80104b66 <scheduler+0x1c>
        freeproc(p);
        cas(&(p->state), nZOMBIE, ZOMBIE);
      }
    }
    //release(&ptable.lock);
    popcli();
80104c54:	e8 44 0a 00 00       	call   8010569d <popcli>
  }
80104c59:	e9 f2 fe ff ff       	jmp    80104b50 <scheduler+0x6>

80104c5e <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c5e:	55                   	push   %ebp
80104c5f:	89 e5                	mov    %esp,%ebp
80104c61:	83 ec 28             	sub    $0x28,%esp
  int intena;

  //if(!holding(&ptable.lock))
  //  panic("sched ptable.lock");
  if(cpu->ncli != 1)
80104c64:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c6a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c70:	83 f8 01             	cmp    $0x1,%eax
80104c73:	74 0c                	je     80104c81 <sched+0x23>
    panic("sched locks");
80104c75:	c7 04 24 9a 8e 10 80 	movl   $0x80108e9a,(%esp)
80104c7c:	e8 b9 b8 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104c81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c87:	8b 40 0c             	mov    0xc(%eax),%eax
80104c8a:	83 f8 04             	cmp    $0x4,%eax
80104c8d:	75 0c                	jne    80104c9b <sched+0x3d>
    panic("sched running");
80104c8f:	c7 04 24 a6 8e 10 80 	movl   $0x80108ea6,(%esp)
80104c96:	e8 9f b8 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104c9b:	e8 43 f6 ff ff       	call   801042e3 <readeflags>
80104ca0:	25 00 02 00 00       	and    $0x200,%eax
80104ca5:	85 c0                	test   %eax,%eax
80104ca7:	74 0c                	je     80104cb5 <sched+0x57>
    panic("sched interruptible");
80104ca9:	c7 04 24 b4 8e 10 80 	movl   $0x80108eb4,(%esp)
80104cb0:	e8 85 b8 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104cb5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cbb:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104cc4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cca:	8b 40 04             	mov    0x4(%eax),%eax
80104ccd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cd4:	83 c2 1c             	add    $0x1c,%edx
80104cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cdb:	89 14 24             	mov    %edx,(%esp)
80104cde:	e8 07 0d 00 00       	call   801059ea <swtch>
  cpu->intena = intena;
80104ce3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ce9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cec:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cf2:	c9                   	leave  
80104cf3:	c3                   	ret    

80104cf4 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104cf4:	55                   	push   %ebp
80104cf5:	89 e5                	mov    %esp,%ebp
80104cf7:	83 ec 18             	sub    $0x18,%esp
  //acquire(&ptable.lock);  //DOC: yieldlock
  //proc->state = RUNNABLE;
  pushcli();
80104cfa:	e8 5a 09 00 00       	call   80105659 <pushcli>
  cas(&(proc->state), RUNNING, nRUNNABLE);
80104cff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d05:	83 c0 0c             	add    $0xc,%eax
80104d08:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
80104d0f:	00 
80104d10:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80104d17:	00 
80104d18:	89 04 24             	mov    %eax,(%esp)
80104d1b:	e8 d9 f5 ff ff       	call   801042f9 <cas>
  sched();
80104d20:	e8 39 ff ff ff       	call   80104c5e <sched>
  popcli();
80104d25:	e8 73 09 00 00       	call   8010569d <popcli>
  //release(&ptable.lock);
}
80104d2a:	c9                   	leave  
80104d2b:	c3                   	ret    

80104d2c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d2c:	55                   	push   %ebp
80104d2d:	89 e5                	mov    %esp,%ebp
80104d2f:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  //release(&ptable.lock);
  popcli();
80104d32:	e8 66 09 00 00       	call   8010569d <popcli>

  if (first) {
80104d37:	a1 24 c0 10 80       	mov    0x8010c024,%eax
80104d3c:	85 c0                	test   %eax,%eax
80104d3e:	74 0f                	je     80104d4f <forkret+0x23>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d40:	c7 05 24 c0 10 80 00 	movl   $0x0,0x8010c024
80104d47:	00 00 00 
    initlog();
80104d4a:	e8 c0 e4 ff ff       	call   8010320f <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d4f:	c9                   	leave  
80104d50:	c3                   	ret    

80104d51 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d51:	55                   	push   %ebp
80104d52:	89 e5                	mov    %esp,%ebp
80104d54:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104d57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d5d:	85 c0                	test   %eax,%eax
80104d5f:	75 0c                	jne    80104d6d <sleep+0x1c>
    panic("sleep");
80104d61:	c7 04 24 c8 8e 10 80 	movl   $0x80108ec8,(%esp)
80104d68:	e8 cd b7 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104d6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d71:	75 0c                	jne    80104d7f <sleep+0x2e>
    panic("sleep without lk");
80104d73:	c7 04 24 ce 8e 10 80 	movl   $0x80108ece,(%esp)
80104d7a:	e8 bb b7 ff ff       	call   8010053a <panic>
  //  acquire(&ptable.lock);  //DOC: sleeplock1
  //  release(lk);
  //}

  // Go to sleep.
  proc->chan = (int)chan;
80104d7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d85:	8b 55 08             	mov    0x8(%ebp),%edx
80104d88:	89 50 20             	mov    %edx,0x20(%eax)
  //proc->state = SLEEPING;
  cas(&(proc->state), RUNNING, nSLEEPING);
80104d8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d91:	83 c0 0c             	add    $0xc,%eax
80104d94:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
80104d9b:	00 
80104d9c:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80104da3:	00 
80104da4:	89 04 24             	mov    %eax,(%esp)
80104da7:	e8 4d f5 ff ff       	call   801042f9 <cas>

  pushcli();
80104dac:	e8 a8 08 00 00       	call   80105659 <pushcli>
  release(lk);
80104db1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104db4:	89 04 24             	mov    %eax,(%esp)
80104db7:	e8 ab 07 00 00       	call   80105567 <release>
  sched();
80104dbc:	e8 9d fe ff ff       	call   80104c5e <sched>
  acquire(lk);
80104dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc4:	89 04 24             	mov    %eax,(%esp)
80104dc7:	e8 39 07 00 00       	call   80105505 <acquire>
  popcli();
80104dcc:	e8 cc 08 00 00       	call   8010569d <popcli>
  // Reacquire original lock.
  //if(lk != &ptable.lock){  //DOC: sleeplock2
  //  release(&ptable.lock);
  //  acquire(lk);
  //}
}
80104dd1:	c9                   	leave  
80104dd2:	c3                   	ret    

80104dd3 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104dd3:	55                   	push   %ebp
80104dd4:	89 e5                	mov    %esp,%ebp
80104dd6:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dd9:	c7 45 fc c0 39 11 80 	movl   $0x801139c0,-0x4(%ebp)
80104de0:	eb 6c                	jmp    80104e4e <wakeup1+0x7b>
    // if the proccess is sleeping
    if(p->chan == (int)chan)
80104de2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104de5:	8b 50 20             	mov    0x20(%eax),%edx
80104de8:	8b 45 08             	mov    0x8(%ebp),%eax
80104deb:	39 c2                	cmp    %eax,%edx
80104ded:	75 58                	jne    80104e47 <wakeup1+0x74>
    {
      // if the proccess did'nt finish transition to SLEEPING then start the transition to RUNNABLE
      if(cas(&(p->state),nSLEEPING, nRUNNABLE))
80104def:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104df2:	83 c0 0c             	add    $0xc,%eax
80104df5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
80104dfc:	00 
80104dfd:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
80104e04:	00 
80104e05:	89 04 24             	mov    %eax,(%esp)
80104e08:	e8 ec f4 ff ff       	call   801042f9 <cas>
80104e0d:	85 c0                	test   %eax,%eax
80104e0f:	74 0a                	je     80104e1b <wakeup1+0x48>
        p->chan= 0;
80104e11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e14:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
      // proccess is SLEEPING
      if(cas(&(p->state),SLEEPING, RUNNABLE))
80104e1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e1e:	83 c0 0c             	add    $0xc,%eax
80104e21:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
80104e28:	00 
80104e29:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80104e30:	00 
80104e31:	89 04 24             	mov    %eax,(%esp)
80104e34:	e8 c0 f4 ff ff       	call   801042f9 <cas>
80104e39:	85 c0                	test   %eax,%eax
80104e3b:	74 0a                	je     80104e47 <wakeup1+0x74>
        p->chan= 0;
80104e3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e40:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e47:	81 45 fc a0 01 00 00 	addl   $0x1a0,-0x4(%ebp)
80104e4e:	81 7d fc c0 a1 11 80 	cmpl   $0x8011a1c0,-0x4(%ebp)
80104e55:	72 8b                	jb     80104de2 <wakeup1+0xf>
      // proccess is SLEEPING
      if(cas(&(p->state),SLEEPING, RUNNABLE))
        p->chan= 0;
    }
  }
}
80104e57:	c9                   	leave  
80104e58:	c3                   	ret    

80104e59 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e59:	55                   	push   %ebp
80104e5a:	89 e5                	mov    %esp,%ebp
80104e5c:	83 ec 18             	sub    $0x18,%esp
  //acquire(&ptable.lock);
  pushcli();
80104e5f:	e8 f5 07 00 00       	call   80105659 <pushcli>
  wakeup1(chan);
80104e64:	8b 45 08             	mov    0x8(%ebp),%eax
80104e67:	89 04 24             	mov    %eax,(%esp)
80104e6a:	e8 64 ff ff ff       	call   80104dd3 <wakeup1>
  popcli();
80104e6f:	e8 29 08 00 00       	call   8010569d <popcli>
  //release(&ptable.lock);
}
80104e74:	c9                   	leave  
80104e75:	c3                   	ret    

80104e76 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e76:	55                   	push   %ebp
80104e77:	89 e5                	mov    %esp,%ebp
80104e79:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  //acquire(&ptable.lock);
  pushcli();
80104e7c:	e8 d8 07 00 00       	call   80105659 <pushcli>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e81:	c7 45 f4 c0 39 11 80 	movl   $0x801139c0,-0xc(%ebp)
80104e88:	eb 52                	jmp    80104edc <kill+0x66>
  {  
    if(p->pid == pid)
80104e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8d:	8b 40 10             	mov    0x10(%eax),%eax
80104e90:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e93:	75 40                	jne    80104ed5 <kill+0x5f>
    {
      p->killed = 1;
80104e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e98:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      //if(p->state == SLEEPING)
        //p->state = RUNNABLE;
      //busy wait until scheduler finish transition to SLEEPING
      while(p->state == nSLEEPING);
80104e9f:	90                   	nop
80104ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea3:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea6:	83 f8 06             	cmp    $0x6,%eax
80104ea9:	74 f5                	je     80104ea0 <kill+0x2a>
      cas(&(p->state), SLEEPING, RUNNABLE);
80104eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eae:	83 c0 0c             	add    $0xc,%eax
80104eb1:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
80104eb8:	00 
80104eb9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80104ec0:	00 
80104ec1:	89 04 24             	mov    %eax,(%esp)
80104ec4:	e8 30 f4 ff ff       	call   801042f9 <cas>
      //release(&ptable.lock);
      popcli();
80104ec9:	e8 cf 07 00 00       	call   8010569d <popcli>
      return 0;
80104ece:	b8 00 00 00 00       	mov    $0x0,%eax
80104ed3:	eb 1a                	jmp    80104eef <kill+0x79>
kill(int pid)
{
  struct proc *p;
  //acquire(&ptable.lock);
  pushcli();
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ed5:	81 45 f4 a0 01 00 00 	addl   $0x1a0,-0xc(%ebp)
80104edc:	81 7d f4 c0 a1 11 80 	cmpl   $0x8011a1c0,-0xc(%ebp)
80104ee3:	72 a5                	jb     80104e8a <kill+0x14>
      popcli();
      return 0;
    }
  }
  //release(&ptable.lock);
  popcli();
80104ee5:	e8 b3 07 00 00       	call   8010569d <popcli>
  return -1;
80104eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104eef:	c9                   	leave  
80104ef0:	c3                   	ret    

80104ef1 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104ef1:	55                   	push   %ebp
80104ef2:	89 e5                	mov    %esp,%ebp
80104ef4:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ef7:	c7 45 f0 c0 39 11 80 	movl   $0x801139c0,-0x10(%ebp)
80104efe:	e9 ef 00 00 00       	jmp    80104ff2 <procdump+0x101>
    if(p->state == UNUSED)
80104f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f06:	8b 40 0c             	mov    0xc(%eax),%eax
80104f09:	85 c0                	test   %eax,%eax
80104f0b:	75 05                	jne    80104f12 <procdump+0x21>
      continue;
80104f0d:	e9 d9 00 00 00       	jmp    80104feb <procdump+0xfa>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f15:	8b 40 0c             	mov    0xc(%eax),%eax
80104f18:	85 c0                	test   %eax,%eax
80104f1a:	78 2e                	js     80104f4a <procdump+0x59>
80104f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f1f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f22:	83 f8 08             	cmp    $0x8,%eax
80104f25:	77 23                	ja     80104f4a <procdump+0x59>
80104f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f2a:	8b 40 0c             	mov    0xc(%eax),%eax
80104f2d:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80104f34:	85 c0                	test   %eax,%eax
80104f36:	74 12                	je     80104f4a <procdump+0x59>
      state = states[p->state];
80104f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f3b:	8b 40 0c             	mov    0xc(%eax),%eax
80104f3e:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80104f45:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f48:	eb 07                	jmp    80104f51 <procdump+0x60>
    else
      state = "???";
80104f4a:	c7 45 ec df 8e 10 80 	movl   $0x80108edf,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f54:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f5a:	8b 40 10             	mov    0x10(%eax),%eax
80104f5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f61:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f64:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f68:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f6c:	c7 04 24 e3 8e 10 80 	movl   $0x80108ee3,(%esp)
80104f73:	e8 28 b4 ff ff       	call   801003a0 <cprintf>
    //busy wait until scheduler finish transition to SLEEPING
    while(p->state == nSLEEPING);
80104f78:	90                   	nop
80104f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f7c:	8b 40 0c             	mov    0xc(%eax),%eax
80104f7f:	83 f8 06             	cmp    $0x6,%eax
80104f82:	74 f5                	je     80104f79 <procdump+0x88>
    if(p->state == SLEEPING){
80104f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f87:	8b 40 0c             	mov    0xc(%eax),%eax
80104f8a:	83 f8 02             	cmp    $0x2,%eax
80104f8d:	75 50                	jne    80104fdf <procdump+0xee>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f92:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f95:	8b 40 0c             	mov    0xc(%eax),%eax
80104f98:	83 c0 08             	add    $0x8,%eax
80104f9b:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f9e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104fa2:	89 04 24             	mov    %eax,(%esp)
80104fa5:	e8 0c 06 00 00       	call   801055b6 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104faa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fb1:	eb 1b                	jmp    80104fce <procdump+0xdd>
        cprintf(" %p", pc[i]);
80104fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fba:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fbe:	c7 04 24 ec 8e 10 80 	movl   $0x80108eec,(%esp)
80104fc5:	e8 d6 b3 ff ff       	call   801003a0 <cprintf>
    cprintf("%d %s %s", p->pid, state, p->name);
    //busy wait until scheduler finish transition to SLEEPING
    while(p->state == nSLEEPING);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104fca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fce:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104fd2:	7f 0b                	jg     80104fdf <procdump+0xee>
80104fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fdb:	85 c0                	test   %eax,%eax
80104fdd:	75 d4                	jne    80104fb3 <procdump+0xc2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104fdf:	c7 04 24 f0 8e 10 80 	movl   $0x80108ef0,(%esp)
80104fe6:	e8 b5 b3 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104feb:	81 45 f0 a0 01 00 00 	addl   $0x1a0,-0x10(%ebp)
80104ff2:	81 7d f0 c0 a1 11 80 	cmpl   $0x8011a1c0,-0x10(%ebp)
80104ff9:	0f 82 04 ff ff ff    	jb     80104f03 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104fff:	c9                   	leave  
80105000:	c3                   	ret    

80105001 <sigset>:

void* 
sigset(void* new_handler)
{
80105001:	55                   	push   %ebp
80105002:	89 e5                	mov    %esp,%ebp
80105004:	83 ec 10             	sub    $0x10,%esp
  sig_handler oldhandler = proc->sighandler; 
80105007:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010500d:	8b 40 7c             	mov    0x7c(%eax),%eax
80105010:	89 45 fc             	mov    %eax,-0x4(%ebp)
  proc->sighandler = new_handler;
80105013:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105019:	8b 55 08             	mov    0x8(%ebp),%edx
8010501c:	89 50 7c             	mov    %edx,0x7c(%eax)
  return oldhandler;
8010501f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105022:	c9                   	leave  
80105023:	c3                   	ret    

80105024 <sigsend>:

int
sigsend(int dest_pid, int value)
{
80105024:	55                   	push   %ebp
80105025:	89 e5                	mov    %esp,%ebp
80105027:	83 ec 28             	sub    $0x28,%esp
  struct proc *p; 

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010502a:	c7 45 f4 c0 39 11 80 	movl   $0x801139c0,-0xc(%ebp)
80105031:	eb 59                	jmp    8010508c <sigsend+0x68>
    if (p->pid == dest_pid) {
80105033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105036:	8b 40 10             	mov    0x10(%eax),%eax
80105039:	3b 45 08             	cmp    0x8(%ebp),%eax
8010503c:	75 47                	jne    80105085 <sigsend+0x61>
      //found dest_pid process
  
      //if push succeed wakeup current proc and return 0
      if (push(&p->pending_signals, proc->pid, dest_pid, value)) 
8010503e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105044:	8b 40 10             	mov    0x10(%eax),%eax
80105047:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010504a:	8d 8a 80 00 00 00    	lea    0x80(%edx),%ecx
80105050:	8b 55 0c             	mov    0xc(%ebp),%edx
80105053:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105057:	8b 55 08             	mov    0x8(%ebp),%edx
8010505a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010505e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105062:	89 0c 24             	mov    %ecx,(%esp)
80105065:	e8 86 01 00 00       	call   801051f0 <push>
8010506a:	85 c0                	test   %eax,%eax
8010506c:	74 15                	je     80105083 <sigsend+0x5f>
      {
        wakeup((void*)p->chan);
8010506e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105071:	8b 40 20             	mov    0x20(%eax),%eax
80105074:	89 04 24             	mov    %eax,(%esp)
80105077:	e8 dd fd ff ff       	call   80104e59 <wakeup>
        return 0;
8010507c:	b8 00 00 00 00       	mov    $0x0,%eax
80105081:	eb 17                	jmp    8010509a <sigsend+0x76>
      }
      break;
80105083:	eb 10                	jmp    80105095 <sigsend+0x71>
int
sigsend(int dest_pid, int value)
{
  struct proc *p; 

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80105085:	81 45 f4 a0 01 00 00 	addl   $0x1a0,-0xc(%ebp)
8010508c:	81 7d f4 c0 a1 11 80 	cmpl   $0x8011a1c0,-0xc(%ebp)
80105093:	72 9e                	jb     80105033 <sigsend+0xf>
        return 0;
      }
      break;
    }
  }
  return -1;  
80105095:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010509a:	c9                   	leave  
8010509b:	c3                   	ret    

8010509c <sigret>:

int
sigret(void)
{
8010509c:	55                   	push   %ebp
8010509d:	89 e5                	mov    %esp,%ebp
8010509f:	57                   	push   %edi
801050a0:	56                   	push   %esi
801050a1:	53                   	push   %ebx
  if(proc)
801050a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a8:	85 c0                	test   %eax,%eax
801050aa:	74 45                	je     801050f1 <sigret+0x55>
  {
    // restore origin user stack
    *(proc->tf) = proc->old_tf;  
801050ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b2:	8b 50 18             	mov    0x18(%eax),%edx
801050b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050bb:	8d 98 4c 01 00 00    	lea    0x14c(%eax),%ebx
801050c1:	b8 13 00 00 00       	mov    $0x13,%eax
801050c6:	89 d7                	mov    %edx,%edi
801050c8:	89 de                	mov    %ebx,%esi
801050ca:	89 c1                	mov    %eax,%ecx
801050cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

    //finish handling signal so we could handle the next one
    proc->handling_signal = 0;
801050ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d4:	c7 80 9c 01 00 00 00 	movl   $0x0,0x19c(%eax)
801050db:	00 00 00 
    proc->curr_signal->used = 0;
801050de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e4:	8b 80 98 01 00 00    	mov    0x198(%eax),%eax
801050ea:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  }

  return 0;
801050f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050f6:	5b                   	pop    %ebx
801050f7:	5e                   	pop    %esi
801050f8:	5f                   	pop    %edi
801050f9:	5d                   	pop    %ebp
801050fa:	c3                   	ret    

801050fb <sigpause>:

int
sigpause(void)
{
801050fb:	55                   	push   %ebp
801050fc:	89 e5                	mov    %esp,%ebp
801050fe:	83 ec 28             	sub    $0x28,%esp
      release(&ptable.lock);
    }
  }
  return 0;
  */
  if(proc)
80105101:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105107:	85 c0                	test   %eax,%eax
80105109:	0f 84 da 00 00 00    	je     801051e9 <sigpause+0xee>
  {
    if(is_empty(&(proc->pending_signals)))
8010510f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105115:	83 e8 80             	sub    $0xffffff80,%eax
80105118:	89 04 24             	mov    %eax,(%esp)
8010511b:	e8 c1 01 00 00       	call   801052e1 <is_empty>
80105120:	85 c0                	test   %eax,%eax
80105122:	74 0a                	je     8010512e <sigpause+0x33>
      return 0;
80105124:	b8 00 00 00 00       	mov    $0x0,%eax
80105129:	e9 c0 00 00 00       	jmp    801051ee <sigpause+0xf3>
    int toRun = 1;
8010512e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    while(toRun)
80105135:	e9 a5 00 00 00       	jmp    801051df <sigpause+0xe4>
    {
      proc->chan = (int)proc;    
8010513a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105140:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105147:	89 50 20             	mov    %edx,0x20(%eax)
      cas(&proc->state, RUNNING, nSLEEPING);
8010514a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105150:	83 c0 0c             	add    $0xc,%eax
80105153:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
8010515a:	00 
8010515b:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80105162:	00 
80105163:	89 04 24             	mov    %eax,(%esp)
80105166:	e8 8e f1 ff ff       	call   801042f9 <cas>
      // again, check if there are pending signals
      if(is_empty(&(proc->pending_signals)))
8010516b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105171:	83 e8 80             	sub    $0xffffff80,%eax
80105174:	89 04 24             	mov    %eax,(%esp)
80105177:	e8 65 01 00 00       	call   801052e1 <is_empty>
8010517c:	85 c0                	test   %eax,%eax
8010517e:	74 50                	je     801051d0 <sigpause+0xd5>
      {
        cas(&proc->state, SLEEPING, RUNNING);
80105180:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105186:	83 c0 0c             	add    $0xc,%eax
80105189:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80105190:	00 
80105191:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105198:	00 
80105199:	89 04 24             	mov    %eax,(%esp)
8010519c:	e8 58 f1 ff ff       	call   801042f9 <cas>
        cas(&proc->state, nSLEEPING, RUNNING);
801051a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051a7:	83 c0 0c             	add    $0xc,%eax
801051aa:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801051b1:	00 
801051b2:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
801051b9:	00 
801051ba:	89 04 24             	mov    %eax,(%esp)
801051bd:	e8 37 f1 ff ff       	call   801042f9 <cas>
        toRun = 0;
801051c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        return 0;
801051c9:	b8 00 00 00 00       	mov    $0x0,%eax
801051ce:	eb 1e                	jmp    801051ee <sigpause+0xf3>
      }
      pushcli();
801051d0:	e8 84 04 00 00       	call   80105659 <pushcli>
      sched();
801051d5:	e8 84 fa ff ff       	call   80104c5e <sched>
      popcli();
801051da:	e8 be 04 00 00       	call   8010569d <popcli>
  if(proc)
  {
    if(is_empty(&(proc->pending_signals)))
      return 0;
    int toRun = 1;
    while(toRun)
801051df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051e3:	0f 85 51 ff ff ff    	jne    8010513a <sigpause+0x3f>
      pushcli();
      sched();
      popcli();
    }
  }
  return 0;
801051e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051ee:	c9                   	leave  
801051ef:	c3                   	ret    

801051f0 <push>:


// -------------- cstack implementation ------------
int 
push(struct cstack *cstack, int sender_pid, int recepient_pid, int value)
{
801051f0:	55                   	push   %ebp
801051f1:	89 e5                	mov    %esp,%ebp
801051f3:	83 ec 1c             	sub    $0x1c,%esp
  struct cstackframe *csf;
  for(csf = cstack->frames; csf < &cstack->frames[MAX_CSTACK_FRAMES]; csf++) {
801051f6:	8b 45 08             	mov    0x8(%ebp),%eax
801051f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
801051fc:	eb 43                	jmp    80105241 <push+0x51>
    if(cas(&(csf->used), 0, 1)) 
801051fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105201:	83 c0 0c             	add    $0xc,%eax
80105204:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010520b:	00 
8010520c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105213:	00 
80105214:	89 04 24             	mov    %eax,(%esp)
80105217:	e8 dd f0 ff ff       	call   801042f9 <cas>
8010521c:	85 c0                	test   %eax,%eax
8010521e:	74 1d                	je     8010523d <push+0x4d>
      goto found;
80105220:	90                   	nop

  //found an unused signal
  found:

  // copy values
  csf->sender_pid = sender_pid;
80105221:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105224:	8b 55 0c             	mov    0xc(%ebp),%edx
80105227:	89 10                	mov    %edx,(%eax)
  csf->recepient_pid = recepient_pid;
80105229:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010522c:	8b 55 10             	mov    0x10(%ebp),%edx
8010522f:	89 50 04             	mov    %edx,0x4(%eax)
  csf->value = value;
80105232:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105235:	8b 55 14             	mov    0x14(%ebp),%edx
80105238:	89 50 08             	mov    %edx,0x8(%eax)
8010523b:	eb 18                	jmp    80105255 <push+0x65>
// -------------- cstack implementation ------------
int 
push(struct cstack *cstack, int sender_pid, int recepient_pid, int value)
{
  struct cstackframe *csf;
  for(csf = cstack->frames; csf < &cstack->frames[MAX_CSTACK_FRAMES]; csf++) {
8010523d:	83 45 fc 14          	addl   $0x14,-0x4(%ebp)
80105241:	8b 45 08             	mov    0x8(%ebp),%eax
80105244:	05 c8 00 00 00       	add    $0xc8,%eax
80105249:	3b 45 fc             	cmp    -0x4(%ebp),%eax
8010524c:	77 b0                	ja     801051fe <push+0xe>
    if(cas(&(csf->used), 0, 1)) 
      goto found;
  }

  //stack is full
  return 0;
8010524e:	b8 00 00 00 00       	mov    $0x0,%eax
80105253:	eb 3a                	jmp    8010528f <push+0x9f>
  csf->sender_pid = sender_pid;
  csf->recepient_pid = recepient_pid;
  csf->value = value;
  
  do {
    csf->next = cstack->head;
80105255:	8b 45 08             	mov    0x8(%ebp),%eax
80105258:	8b 90 c8 00 00 00    	mov    0xc8(%eax),%edx
8010525e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105261:	89 50 10             	mov    %edx,0x10(%eax)
  } while (!cas((int*)&(cstack->head), (int)csf->next, (int)csf));
80105264:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105267:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010526a:	8b 40 10             	mov    0x10(%eax),%eax
8010526d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105270:	81 c1 c8 00 00 00    	add    $0xc8,%ecx
80105276:	89 54 24 08          	mov    %edx,0x8(%esp)
8010527a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010527e:	89 0c 24             	mov    %ecx,(%esp)
80105281:	e8 73 f0 ff ff       	call   801042f9 <cas>
80105286:	85 c0                	test   %eax,%eax
80105288:	74 cb                	je     80105255 <push+0x65>
  
  return 1;
8010528a:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010528f:	c9                   	leave  
80105290:	c3                   	ret    

80105291 <pop>:

struct cstackframe*
pop(struct cstack *cstack)
{
80105291:	55                   	push   %ebp
80105292:	89 e5                	mov    %esp,%ebp
80105294:	83 ec 1c             	sub    $0x1c,%esp
  struct cstackframe *csf;
  struct cstackframe *next;
  
  do {
    csf = cstack->head;
80105297:	8b 45 08             	mov    0x8(%ebp),%eax
8010529a:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
801052a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (!csf)
801052a3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801052a7:	75 07                	jne    801052b0 <pop+0x1f>
      return 0;
801052a9:	b8 00 00 00 00       	mov    $0x0,%eax
801052ae:	eb 2f                	jmp    801052df <pop+0x4e>

    next = csf->next;
801052b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052b3:	8b 40 10             	mov    0x10(%eax),%eax
801052b6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  } while (!cas((int*)&(cstack->head), (int)csf, (int)next));
801052b9:	8b 55 f8             	mov    -0x8(%ebp),%edx
801052bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052c2:	81 c1 c8 00 00 00    	add    $0xc8,%ecx
801052c8:	89 54 24 08          	mov    %edx,0x8(%esp)
801052cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801052d0:	89 0c 24             	mov    %ecx,(%esp)
801052d3:	e8 21 f0 ff ff       	call   801042f9 <cas>
801052d8:	85 c0                	test   %eax,%eax
801052da:	74 bb                	je     80105297 <pop+0x6>

  return csf;
801052dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052df:	c9                   	leave  
801052e0:	c3                   	ret    

801052e1 <is_empty>:

int
is_empty(struct cstack *cstack)
{
801052e1:	55                   	push   %ebp
801052e2:	89 e5                	mov    %esp,%ebp
  return cstack->head == 0 ? 1 : 0;
801052e4:	8b 45 08             	mov    0x8(%ebp),%eax
801052e7:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
801052ed:	85 c0                	test   %eax,%eax
801052ef:	0f 94 c0             	sete   %al
801052f2:	0f b6 c0             	movzbl %al,%eax
}
801052f5:	5d                   	pop    %ebp
801052f6:	c3                   	ret    

801052f7 <roundup_4div>:

// this function takes a number and round it up to a number that is divided by 4
// use is in order to push address space to stack, keep stack aligned
int 
roundup_4div(int num)
{
801052f7:	55                   	push   %ebp
801052f8:	89 e5                	mov    %esp,%ebp
  return (((num + 3) >> 2) << 2);
801052fa:	8b 45 08             	mov    0x8(%ebp),%eax
801052fd:	83 c0 03             	add    $0x3,%eax
80105300:	83 e0 fc             	and    $0xfffffffc,%eax
}
80105303:	5d                   	pop    %ebp
80105304:	c3                   	ret    

80105305 <fix_tf>:

void
fix_tf(struct trapframe *tf)
{ 
80105305:	55                   	push   %ebp
80105306:	89 e5                	mov    %esp,%ebp
80105308:	57                   	push   %edi
80105309:	56                   	push   %esi
8010530a:	53                   	push   %ebx
8010530b:	83 ec 2c             	sub    $0x2c,%esp
  if (proc == 0)  //no proccess
8010530e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105314:	85 c0                	test   %eax,%eax
80105316:	75 05                	jne    8010531d <fix_tf+0x18>
    return;
80105318:	e9 89 01 00 00       	jmp    801054a6 <fix_tf+0x1a1>

  if (((tf->cs) & 3) != DPL_USER) //has no user privilge
8010531d:	8b 45 08             	mov    0x8(%ebp),%eax
80105320:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80105324:	0f b7 c0             	movzwl %ax,%eax
80105327:	83 e0 03             	and    $0x3,%eax
8010532a:	83 f8 03             	cmp    $0x3,%eax
8010532d:	74 05                	je     80105334 <fix_tf+0x2f>
    return;
8010532f:	e9 72 01 00 00       	jmp    801054a6 <fix_tf+0x1a1>

  // ---- here only user -----

  // if proc already handling a signal then return
  if (!cas((int*)&proc->handling_signal, 0, 1))
80105334:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010533a:	05 9c 01 00 00       	add    $0x19c,%eax
8010533f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80105346:	00 
80105347:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010534e:	00 
8010534f:	89 04 24             	mov    %eax,(%esp)
80105352:	e8 a2 ef ff ff       	call   801042f9 <cas>
80105357:	85 c0                	test   %eax,%eax
80105359:	75 05                	jne    80105360 <fix_tf+0x5b>
    goto done;
8010535b:	e9 46 01 00 00       	jmp    801054a6 <fix_tf+0x1a1>

  struct cstackframe *new_signal;
  // no pending signal in the stack  OR  signal_handler is default
  if(!(new_signal = pop(&proc->pending_signals)) || proc->sighandler == DEFSIG_HENDLER) {
80105360:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105366:	83 e8 80             	sub    $0xffffff80,%eax
80105369:	89 04 24             	mov    %eax,(%esp)
8010536c:	e8 20 ff ff ff       	call   80105291 <pop>
80105371:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105374:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80105378:	74 0e                	je     80105388 <fix_tf+0x83>
8010537a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105380:	8b 40 7c             	mov    0x7c(%eax),%eax
80105383:	83 f8 ff             	cmp    $0xffffffff,%eax
80105386:	75 25                	jne    801053ad <fix_tf+0xa8>
    if (new_signal)
80105388:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010538c:	74 0a                	je     80105398 <fix_tf+0x93>
      new_signal->used = 0;
8010538e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105391:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    proc->handling_signal = 0;
80105398:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010539e:	c7 80 9c 01 00 00 00 	movl   $0x0,0x19c(%eax)
801053a5:	00 00 00 
    goto done; 
801053a8:	e9 f9 00 00 00       	jmp    801054a6 <fix_tf+0x1a1>
  }

  proc->curr_signal = new_signal;
801053ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801053b6:	89 90 98 01 00 00    	mov    %edx,0x198(%eax)

  //else, we have a pending signal and a handler: 
  
  // back-up the old trap-frame for handeling user stack
  proc->old_tf = *(tf);
801053bc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801053c3:	8b 45 08             	mov    0x8(%ebp),%eax
801053c6:	8d 9a 4c 01 00 00    	lea    0x14c(%edx),%ebx
801053cc:	89 c2                	mov    %eax,%edx
801053ce:	b8 13 00 00 00       	mov    $0x13,%eax
801053d3:	89 df                	mov    %ebx,%edi
801053d5:	89 d6                	mov    %edx,%esi
801053d7:	89 c1                	mov    %eax,%ecx
801053d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  
  int addr_space; 
  //int ret_addr;
  
  int stam = 0;
801053db:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  if (1 == stam) {
801053e2:	83 7d e0 01          	cmpl   $0x1,-0x20(%ebp)
801053e6:	75 07                	jne    801053ef <fix_tf+0xea>
    goToStack: // lable#1
    asm volatile("movl $24, %eax; int $64"); //movl $SYS_sigret, %eax; int $T_SYSCALL; 
801053e8:	b8 18 00 00 00       	mov    $0x18,%eax
801053ed:	cd 40                	int    $0x40
    returnFromStack:; // lable#2
  }

  addr_space = &&returnFromStack - &&goToStack;
801053ef:	ba ef 53 10 80       	mov    $0x801053ef,%edx
801053f4:	b8 e8 53 10 80       	mov    $0x801053e8,%eax
801053f9:	29 c2                	sub    %eax,%edx
801053fb:	89 d0                	mov    %edx,%eax
801053fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  addr_space = roundup_4div(addr_space);
80105400:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105403:	89 04 24             	mov    %eax,(%esp)
80105406:	e8 ec fe ff ff       	call   801052f7 <roundup_4div>
8010540b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  tf->esp -= addr_space;
8010540e:	8b 45 08             	mov    0x8(%ebp),%eax
80105411:	8b 50 44             	mov    0x44(%eax),%edx
80105414:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105417:	29 c2                	sub    %eax,%edx
80105419:	8b 45 08             	mov    0x8(%ebp),%eax
8010541c:	89 50 44             	mov    %edx,0x44(%eax)
  memmove((void *)tf->esp, &&goToStack, addr_space);
8010541f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105422:	8b 45 08             	mov    0x8(%ebp),%eax
80105425:	8b 40 44             	mov    0x44(%eax),%eax
80105428:	89 54 24 08          	mov    %edx,0x8(%esp)
8010542c:	c7 44 24 04 e8 53 10 	movl   $0x801053e8,0x4(%esp)
80105433:	80 
80105434:	89 04 24             	mov    %eax,(%esp)
80105437:	e8 ec 03 00 00       	call   80105828 <memmove>

  tf->esp -= 4;
8010543c:	8b 45 08             	mov    0x8(%ebp),%eax
8010543f:	8b 40 44             	mov    0x44(%eax),%eax
80105442:	8d 50 fc             	lea    -0x4(%eax),%edx
80105445:	8b 45 08             	mov    0x8(%ebp),%eax
80105448:	89 50 44             	mov    %edx,0x44(%eax)
  *(uint *)tf->esp = new_signal->value;      //param 2
8010544b:	8b 45 08             	mov    0x8(%ebp),%eax
8010544e:	8b 40 44             	mov    0x44(%eax),%eax
80105451:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105454:	8b 52 08             	mov    0x8(%edx),%edx
80105457:	89 10                	mov    %edx,(%eax)

  tf->esp -= 4;
80105459:	8b 45 08             	mov    0x8(%ebp),%eax
8010545c:	8b 40 44             	mov    0x44(%eax),%eax
8010545f:	8d 50 fc             	lea    -0x4(%eax),%edx
80105462:	8b 45 08             	mov    0x8(%ebp),%eax
80105465:	89 50 44             	mov    %edx,0x44(%eax)
  *(uint *)tf->esp = new_signal->sender_pid; //param 1
80105468:	8b 45 08             	mov    0x8(%ebp),%eax
8010546b:	8b 40 44             	mov    0x44(%eax),%eax
8010546e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105471:	8b 12                	mov    (%edx),%edx
80105473:	89 10                	mov    %edx,(%eax)

  tf->esp -= 4;
80105475:	8b 45 08             	mov    0x8(%ebp),%eax
80105478:	8b 40 44             	mov    0x44(%eax),%eax
8010547b:	8d 50 fc             	lea    -0x4(%eax),%edx
8010547e:	8b 45 08             	mov    0x8(%ebp),%eax
80105481:	89 50 44             	mov    %edx,0x44(%eax)
  *(uint *)tf->esp = tf->esp + 12;
80105484:	8b 45 08             	mov    0x8(%ebp),%eax
80105487:	8b 40 44             	mov    0x44(%eax),%eax
8010548a:	8b 55 08             	mov    0x8(%ebp),%edx
8010548d:	8b 52 44             	mov    0x44(%edx),%edx
80105490:	83 c2 0c             	add    $0xc,%edx
80105493:	89 10                	mov    %edx,(%eax)
  
  tf->eip = (int)proc->sighandler;  
80105495:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010549b:	8b 40 7c             	mov    0x7c(%eax),%eax
8010549e:	89 c2                	mov    %eax,%edx
801054a0:	8b 45 08             	mov    0x8(%ebp),%eax
801054a3:	89 50 38             	mov    %edx,0x38(%eax)

  done:;
801054a6:	83 c4 2c             	add    $0x2c,%esp
801054a9:	5b                   	pop    %ebx
801054aa:	5e                   	pop    %esi
801054ab:	5f                   	pop    %edi
801054ac:	5d                   	pop    %ebp
801054ad:	c3                   	ret    

801054ae <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801054ae:	55                   	push   %ebp
801054af:	89 e5                	mov    %esp,%ebp
801054b1:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801054b4:	9c                   	pushf  
801054b5:	58                   	pop    %eax
801054b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801054b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054bc:	c9                   	leave  
801054bd:	c3                   	ret    

801054be <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801054be:	55                   	push   %ebp
801054bf:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801054c1:	fa                   	cli    
}
801054c2:	5d                   	pop    %ebp
801054c3:	c3                   	ret    

801054c4 <sti>:

static inline void
sti(void)
{
801054c4:	55                   	push   %ebp
801054c5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801054c7:	fb                   	sti    
}
801054c8:	5d                   	pop    %ebp
801054c9:	c3                   	ret    

801054ca <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801054ca:	55                   	push   %ebp
801054cb:	89 e5                	mov    %esp,%ebp
801054cd:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801054d0:	8b 55 08             	mov    0x8(%ebp),%edx
801054d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054d9:	f0 87 02             	lock xchg %eax,(%edx)
801054dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801054df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054e2:	c9                   	leave  
801054e3:	c3                   	ret    

801054e4 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801054e4:	55                   	push   %ebp
801054e5:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801054e7:	8b 45 08             	mov    0x8(%ebp),%eax
801054ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801054ed:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801054f0:	8b 45 08             	mov    0x8(%ebp),%eax
801054f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801054f9:	8b 45 08             	mov    0x8(%ebp),%eax
801054fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105503:	5d                   	pop    %ebp
80105504:	c3                   	ret    

80105505 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105505:	55                   	push   %ebp
80105506:	89 e5                	mov    %esp,%ebp
80105508:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010550b:	e8 49 01 00 00       	call   80105659 <pushcli>
  if(holding(lk))
80105510:	8b 45 08             	mov    0x8(%ebp),%eax
80105513:	89 04 24             	mov    %eax,(%esp)
80105516:	e8 14 01 00 00       	call   8010562f <holding>
8010551b:	85 c0                	test   %eax,%eax
8010551d:	74 0c                	je     8010552b <acquire+0x26>
    panic("acquire");
8010551f:	c7 04 24 33 8f 10 80 	movl   $0x80108f33,(%esp)
80105526:	e8 0f b0 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
8010552b:	90                   	nop
8010552c:	8b 45 08             	mov    0x8(%ebp),%eax
8010552f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105536:	00 
80105537:	89 04 24             	mov    %eax,(%esp)
8010553a:	e8 8b ff ff ff       	call   801054ca <xchg>
8010553f:	85 c0                	test   %eax,%eax
80105541:	75 e9                	jne    8010552c <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105543:	8b 45 08             	mov    0x8(%ebp),%eax
80105546:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010554d:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105550:	8b 45 08             	mov    0x8(%ebp),%eax
80105553:	83 c0 0c             	add    $0xc,%eax
80105556:	89 44 24 04          	mov    %eax,0x4(%esp)
8010555a:	8d 45 08             	lea    0x8(%ebp),%eax
8010555d:	89 04 24             	mov    %eax,(%esp)
80105560:	e8 51 00 00 00       	call   801055b6 <getcallerpcs>
}
80105565:	c9                   	leave  
80105566:	c3                   	ret    

80105567 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105567:	55                   	push   %ebp
80105568:	89 e5                	mov    %esp,%ebp
8010556a:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010556d:	8b 45 08             	mov    0x8(%ebp),%eax
80105570:	89 04 24             	mov    %eax,(%esp)
80105573:	e8 b7 00 00 00       	call   8010562f <holding>
80105578:	85 c0                	test   %eax,%eax
8010557a:	75 0c                	jne    80105588 <release+0x21>
    panic("release");
8010557c:	c7 04 24 3b 8f 10 80 	movl   $0x80108f3b,(%esp)
80105583:	e8 b2 af ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80105588:	8b 45 08             	mov    0x8(%ebp),%eax
8010558b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105592:	8b 45 08             	mov    0x8(%ebp),%eax
80105595:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010559c:	8b 45 08             	mov    0x8(%ebp),%eax
8010559f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055a6:	00 
801055a7:	89 04 24             	mov    %eax,(%esp)
801055aa:	e8 1b ff ff ff       	call   801054ca <xchg>

  popcli();
801055af:	e8 e9 00 00 00       	call   8010569d <popcli>
}
801055b4:	c9                   	leave  
801055b5:	c3                   	ret    

801055b6 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801055b6:	55                   	push   %ebp
801055b7:	89 e5                	mov    %esp,%ebp
801055b9:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801055bc:	8b 45 08             	mov    0x8(%ebp),%eax
801055bf:	83 e8 08             	sub    $0x8,%eax
801055c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801055c5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801055cc:	eb 38                	jmp    80105606 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801055ce:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801055d2:	74 38                	je     8010560c <getcallerpcs+0x56>
801055d4:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801055db:	76 2f                	jbe    8010560c <getcallerpcs+0x56>
801055dd:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801055e1:	74 29                	je     8010560c <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
801055e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055e6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801055ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f0:	01 c2                	add    %eax,%edx
801055f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f5:	8b 40 04             	mov    0x4(%eax),%eax
801055f8:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801055fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055fd:	8b 00                	mov    (%eax),%eax
801055ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105602:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105606:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010560a:	7e c2                	jle    801055ce <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010560c:	eb 19                	jmp    80105627 <getcallerpcs+0x71>
    pcs[i] = 0;
8010560e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105611:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105618:	8b 45 0c             	mov    0xc(%ebp),%eax
8010561b:	01 d0                	add    %edx,%eax
8010561d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105623:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105627:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010562b:	7e e1                	jle    8010560e <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010562d:	c9                   	leave  
8010562e:	c3                   	ret    

8010562f <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010562f:	55                   	push   %ebp
80105630:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105632:	8b 45 08             	mov    0x8(%ebp),%eax
80105635:	8b 00                	mov    (%eax),%eax
80105637:	85 c0                	test   %eax,%eax
80105639:	74 17                	je     80105652 <holding+0x23>
8010563b:	8b 45 08             	mov    0x8(%ebp),%eax
8010563e:	8b 50 08             	mov    0x8(%eax),%edx
80105641:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105647:	39 c2                	cmp    %eax,%edx
80105649:	75 07                	jne    80105652 <holding+0x23>
8010564b:	b8 01 00 00 00       	mov    $0x1,%eax
80105650:	eb 05                	jmp    80105657 <holding+0x28>
80105652:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105657:	5d                   	pop    %ebp
80105658:	c3                   	ret    

80105659 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105659:	55                   	push   %ebp
8010565a:	89 e5                	mov    %esp,%ebp
8010565c:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010565f:	e8 4a fe ff ff       	call   801054ae <readeflags>
80105664:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105667:	e8 52 fe ff ff       	call   801054be <cli>
  if(cpu->ncli++ == 0)
8010566c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105673:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105679:	8d 48 01             	lea    0x1(%eax),%ecx
8010567c:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105682:	85 c0                	test   %eax,%eax
80105684:	75 15                	jne    8010569b <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105686:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010568c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010568f:	81 e2 00 02 00 00    	and    $0x200,%edx
80105695:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010569b:	c9                   	leave  
8010569c:	c3                   	ret    

8010569d <popcli>:

void
popcli(void)
{
8010569d:	55                   	push   %ebp
8010569e:	89 e5                	mov    %esp,%ebp
801056a0:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801056a3:	e8 06 fe ff ff       	call   801054ae <readeflags>
801056a8:	25 00 02 00 00       	and    $0x200,%eax
801056ad:	85 c0                	test   %eax,%eax
801056af:	74 0c                	je     801056bd <popcli+0x20>
    panic("popcli - interruptible");
801056b1:	c7 04 24 43 8f 10 80 	movl   $0x80108f43,(%esp)
801056b8:	e8 7d ae ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
801056bd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056c3:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801056c9:	83 ea 01             	sub    $0x1,%edx
801056cc:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801056d2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801056d8:	85 c0                	test   %eax,%eax
801056da:	79 0c                	jns    801056e8 <popcli+0x4b>
    panic("popcli");
801056dc:	c7 04 24 5a 8f 10 80 	movl   $0x80108f5a,(%esp)
801056e3:	e8 52 ae ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
801056e8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056ee:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801056f4:	85 c0                	test   %eax,%eax
801056f6:	75 15                	jne    8010570d <popcli+0x70>
801056f8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056fe:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105704:	85 c0                	test   %eax,%eax
80105706:	74 05                	je     8010570d <popcli+0x70>
    sti();
80105708:	e8 b7 fd ff ff       	call   801054c4 <sti>
}
8010570d:	c9                   	leave  
8010570e:	c3                   	ret    

8010570f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010570f:	55                   	push   %ebp
80105710:	89 e5                	mov    %esp,%ebp
80105712:	57                   	push   %edi
80105713:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105714:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105717:	8b 55 10             	mov    0x10(%ebp),%edx
8010571a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010571d:	89 cb                	mov    %ecx,%ebx
8010571f:	89 df                	mov    %ebx,%edi
80105721:	89 d1                	mov    %edx,%ecx
80105723:	fc                   	cld    
80105724:	f3 aa                	rep stos %al,%es:(%edi)
80105726:	89 ca                	mov    %ecx,%edx
80105728:	89 fb                	mov    %edi,%ebx
8010572a:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010572d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105730:	5b                   	pop    %ebx
80105731:	5f                   	pop    %edi
80105732:	5d                   	pop    %ebp
80105733:	c3                   	ret    

80105734 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105734:	55                   	push   %ebp
80105735:	89 e5                	mov    %esp,%ebp
80105737:	57                   	push   %edi
80105738:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105739:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010573c:	8b 55 10             	mov    0x10(%ebp),%edx
8010573f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105742:	89 cb                	mov    %ecx,%ebx
80105744:	89 df                	mov    %ebx,%edi
80105746:	89 d1                	mov    %edx,%ecx
80105748:	fc                   	cld    
80105749:	f3 ab                	rep stos %eax,%es:(%edi)
8010574b:	89 ca                	mov    %ecx,%edx
8010574d:	89 fb                	mov    %edi,%ebx
8010574f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105752:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105755:	5b                   	pop    %ebx
80105756:	5f                   	pop    %edi
80105757:	5d                   	pop    %ebp
80105758:	c3                   	ret    

80105759 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105759:	55                   	push   %ebp
8010575a:	89 e5                	mov    %esp,%ebp
8010575c:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010575f:	8b 45 08             	mov    0x8(%ebp),%eax
80105762:	83 e0 03             	and    $0x3,%eax
80105765:	85 c0                	test   %eax,%eax
80105767:	75 49                	jne    801057b2 <memset+0x59>
80105769:	8b 45 10             	mov    0x10(%ebp),%eax
8010576c:	83 e0 03             	and    $0x3,%eax
8010576f:	85 c0                	test   %eax,%eax
80105771:	75 3f                	jne    801057b2 <memset+0x59>
    c &= 0xFF;
80105773:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010577a:	8b 45 10             	mov    0x10(%ebp),%eax
8010577d:	c1 e8 02             	shr    $0x2,%eax
80105780:	89 c2                	mov    %eax,%edx
80105782:	8b 45 0c             	mov    0xc(%ebp),%eax
80105785:	c1 e0 18             	shl    $0x18,%eax
80105788:	89 c1                	mov    %eax,%ecx
8010578a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010578d:	c1 e0 10             	shl    $0x10,%eax
80105790:	09 c1                	or     %eax,%ecx
80105792:	8b 45 0c             	mov    0xc(%ebp),%eax
80105795:	c1 e0 08             	shl    $0x8,%eax
80105798:	09 c8                	or     %ecx,%eax
8010579a:	0b 45 0c             	or     0xc(%ebp),%eax
8010579d:	89 54 24 08          	mov    %edx,0x8(%esp)
801057a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801057a5:	8b 45 08             	mov    0x8(%ebp),%eax
801057a8:	89 04 24             	mov    %eax,(%esp)
801057ab:	e8 84 ff ff ff       	call   80105734 <stosl>
801057b0:	eb 19                	jmp    801057cb <memset+0x72>
  } else
    stosb(dst, c, n);
801057b2:	8b 45 10             	mov    0x10(%ebp),%eax
801057b5:	89 44 24 08          	mov    %eax,0x8(%esp)
801057b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801057bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801057c0:	8b 45 08             	mov    0x8(%ebp),%eax
801057c3:	89 04 24             	mov    %eax,(%esp)
801057c6:	e8 44 ff ff ff       	call   8010570f <stosb>
  return dst;
801057cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801057ce:	c9                   	leave  
801057cf:	c3                   	ret    

801057d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801057d0:	55                   	push   %ebp
801057d1:	89 e5                	mov    %esp,%ebp
801057d3:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801057d6:	8b 45 08             	mov    0x8(%ebp),%eax
801057d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801057dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801057df:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801057e2:	eb 30                	jmp    80105814 <memcmp+0x44>
    if(*s1 != *s2)
801057e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057e7:	0f b6 10             	movzbl (%eax),%edx
801057ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057ed:	0f b6 00             	movzbl (%eax),%eax
801057f0:	38 c2                	cmp    %al,%dl
801057f2:	74 18                	je     8010580c <memcmp+0x3c>
      return *s1 - *s2;
801057f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057f7:	0f b6 00             	movzbl (%eax),%eax
801057fa:	0f b6 d0             	movzbl %al,%edx
801057fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105800:	0f b6 00             	movzbl (%eax),%eax
80105803:	0f b6 c0             	movzbl %al,%eax
80105806:	29 c2                	sub    %eax,%edx
80105808:	89 d0                	mov    %edx,%eax
8010580a:	eb 1a                	jmp    80105826 <memcmp+0x56>
    s1++, s2++;
8010580c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105810:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105814:	8b 45 10             	mov    0x10(%ebp),%eax
80105817:	8d 50 ff             	lea    -0x1(%eax),%edx
8010581a:	89 55 10             	mov    %edx,0x10(%ebp)
8010581d:	85 c0                	test   %eax,%eax
8010581f:	75 c3                	jne    801057e4 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105821:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105826:	c9                   	leave  
80105827:	c3                   	ret    

80105828 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105828:	55                   	push   %ebp
80105829:	89 e5                	mov    %esp,%ebp
8010582b:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010582e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105831:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105834:	8b 45 08             	mov    0x8(%ebp),%eax
80105837:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010583a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010583d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105840:	73 3d                	jae    8010587f <memmove+0x57>
80105842:	8b 45 10             	mov    0x10(%ebp),%eax
80105845:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105848:	01 d0                	add    %edx,%eax
8010584a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010584d:	76 30                	jbe    8010587f <memmove+0x57>
    s += n;
8010584f:	8b 45 10             	mov    0x10(%ebp),%eax
80105852:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105855:	8b 45 10             	mov    0x10(%ebp),%eax
80105858:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010585b:	eb 13                	jmp    80105870 <memmove+0x48>
      *--d = *--s;
8010585d:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105861:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105865:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105868:	0f b6 10             	movzbl (%eax),%edx
8010586b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010586e:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105870:	8b 45 10             	mov    0x10(%ebp),%eax
80105873:	8d 50 ff             	lea    -0x1(%eax),%edx
80105876:	89 55 10             	mov    %edx,0x10(%ebp)
80105879:	85 c0                	test   %eax,%eax
8010587b:	75 e0                	jne    8010585d <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010587d:	eb 26                	jmp    801058a5 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010587f:	eb 17                	jmp    80105898 <memmove+0x70>
      *d++ = *s++;
80105881:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105884:	8d 50 01             	lea    0x1(%eax),%edx
80105887:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010588a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010588d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105890:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105893:	0f b6 12             	movzbl (%edx),%edx
80105896:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105898:	8b 45 10             	mov    0x10(%ebp),%eax
8010589b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010589e:	89 55 10             	mov    %edx,0x10(%ebp)
801058a1:	85 c0                	test   %eax,%eax
801058a3:	75 dc                	jne    80105881 <memmove+0x59>
      *d++ = *s++;

  return dst;
801058a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801058a8:	c9                   	leave  
801058a9:	c3                   	ret    

801058aa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801058aa:	55                   	push   %ebp
801058ab:	89 e5                	mov    %esp,%ebp
801058ad:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801058b0:	8b 45 10             	mov    0x10(%ebp),%eax
801058b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801058b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801058be:	8b 45 08             	mov    0x8(%ebp),%eax
801058c1:	89 04 24             	mov    %eax,(%esp)
801058c4:	e8 5f ff ff ff       	call   80105828 <memmove>
}
801058c9:	c9                   	leave  
801058ca:	c3                   	ret    

801058cb <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801058cb:	55                   	push   %ebp
801058cc:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801058ce:	eb 0c                	jmp    801058dc <strncmp+0x11>
    n--, p++, q++;
801058d0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801058d4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801058d8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801058dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058e0:	74 1a                	je     801058fc <strncmp+0x31>
801058e2:	8b 45 08             	mov    0x8(%ebp),%eax
801058e5:	0f b6 00             	movzbl (%eax),%eax
801058e8:	84 c0                	test   %al,%al
801058ea:	74 10                	je     801058fc <strncmp+0x31>
801058ec:	8b 45 08             	mov    0x8(%ebp),%eax
801058ef:	0f b6 10             	movzbl (%eax),%edx
801058f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f5:	0f b6 00             	movzbl (%eax),%eax
801058f8:	38 c2                	cmp    %al,%dl
801058fa:	74 d4                	je     801058d0 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801058fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105900:	75 07                	jne    80105909 <strncmp+0x3e>
    return 0;
80105902:	b8 00 00 00 00       	mov    $0x0,%eax
80105907:	eb 16                	jmp    8010591f <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105909:	8b 45 08             	mov    0x8(%ebp),%eax
8010590c:	0f b6 00             	movzbl (%eax),%eax
8010590f:	0f b6 d0             	movzbl %al,%edx
80105912:	8b 45 0c             	mov    0xc(%ebp),%eax
80105915:	0f b6 00             	movzbl (%eax),%eax
80105918:	0f b6 c0             	movzbl %al,%eax
8010591b:	29 c2                	sub    %eax,%edx
8010591d:	89 d0                	mov    %edx,%eax
}
8010591f:	5d                   	pop    %ebp
80105920:	c3                   	ret    

80105921 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105921:	55                   	push   %ebp
80105922:	89 e5                	mov    %esp,%ebp
80105924:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105927:	8b 45 08             	mov    0x8(%ebp),%eax
8010592a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010592d:	90                   	nop
8010592e:	8b 45 10             	mov    0x10(%ebp),%eax
80105931:	8d 50 ff             	lea    -0x1(%eax),%edx
80105934:	89 55 10             	mov    %edx,0x10(%ebp)
80105937:	85 c0                	test   %eax,%eax
80105939:	7e 1e                	jle    80105959 <strncpy+0x38>
8010593b:	8b 45 08             	mov    0x8(%ebp),%eax
8010593e:	8d 50 01             	lea    0x1(%eax),%edx
80105941:	89 55 08             	mov    %edx,0x8(%ebp)
80105944:	8b 55 0c             	mov    0xc(%ebp),%edx
80105947:	8d 4a 01             	lea    0x1(%edx),%ecx
8010594a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010594d:	0f b6 12             	movzbl (%edx),%edx
80105950:	88 10                	mov    %dl,(%eax)
80105952:	0f b6 00             	movzbl (%eax),%eax
80105955:	84 c0                	test   %al,%al
80105957:	75 d5                	jne    8010592e <strncpy+0xd>
    ;
  while(n-- > 0)
80105959:	eb 0c                	jmp    80105967 <strncpy+0x46>
    *s++ = 0;
8010595b:	8b 45 08             	mov    0x8(%ebp),%eax
8010595e:	8d 50 01             	lea    0x1(%eax),%edx
80105961:	89 55 08             	mov    %edx,0x8(%ebp)
80105964:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105967:	8b 45 10             	mov    0x10(%ebp),%eax
8010596a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010596d:	89 55 10             	mov    %edx,0x10(%ebp)
80105970:	85 c0                	test   %eax,%eax
80105972:	7f e7                	jg     8010595b <strncpy+0x3a>
    *s++ = 0;
  return os;
80105974:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105977:	c9                   	leave  
80105978:	c3                   	ret    

80105979 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105979:	55                   	push   %ebp
8010597a:	89 e5                	mov    %esp,%ebp
8010597c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010597f:	8b 45 08             	mov    0x8(%ebp),%eax
80105982:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105985:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105989:	7f 05                	jg     80105990 <safestrcpy+0x17>
    return os;
8010598b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010598e:	eb 31                	jmp    801059c1 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105990:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105994:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105998:	7e 1e                	jle    801059b8 <safestrcpy+0x3f>
8010599a:	8b 45 08             	mov    0x8(%ebp),%eax
8010599d:	8d 50 01             	lea    0x1(%eax),%edx
801059a0:	89 55 08             	mov    %edx,0x8(%ebp)
801059a3:	8b 55 0c             	mov    0xc(%ebp),%edx
801059a6:	8d 4a 01             	lea    0x1(%edx),%ecx
801059a9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801059ac:	0f b6 12             	movzbl (%edx),%edx
801059af:	88 10                	mov    %dl,(%eax)
801059b1:	0f b6 00             	movzbl (%eax),%eax
801059b4:	84 c0                	test   %al,%al
801059b6:	75 d8                	jne    80105990 <safestrcpy+0x17>
    ;
  *s = 0;
801059b8:	8b 45 08             	mov    0x8(%ebp),%eax
801059bb:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801059be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059c1:	c9                   	leave  
801059c2:	c3                   	ret    

801059c3 <strlen>:

int
strlen(const char *s)
{
801059c3:	55                   	push   %ebp
801059c4:	89 e5                	mov    %esp,%ebp
801059c6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801059c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801059d0:	eb 04                	jmp    801059d6 <strlen+0x13>
801059d2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059d9:	8b 45 08             	mov    0x8(%ebp),%eax
801059dc:	01 d0                	add    %edx,%eax
801059de:	0f b6 00             	movzbl (%eax),%eax
801059e1:	84 c0                	test   %al,%al
801059e3:	75 ed                	jne    801059d2 <strlen+0xf>
    ;
  return n;
801059e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059e8:	c9                   	leave  
801059e9:	c3                   	ret    

801059ea <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801059ea:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801059ee:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801059f2:	55                   	push   %ebp
  pushl %ebx
801059f3:	53                   	push   %ebx
  pushl %esi
801059f4:	56                   	push   %esi
  pushl %edi
801059f5:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801059f6:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801059f8:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801059fa:	5f                   	pop    %edi
  popl %esi
801059fb:	5e                   	pop    %esi
  popl %ebx
801059fc:	5b                   	pop    %ebx
  popl %ebp
801059fd:	5d                   	pop    %ebp
  ret
801059fe:	c3                   	ret    

801059ff <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801059ff:	55                   	push   %ebp
80105a00:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105a02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a08:	8b 00                	mov    (%eax),%eax
80105a0a:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a0d:	76 12                	jbe    80105a21 <fetchint+0x22>
80105a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80105a12:	8d 50 04             	lea    0x4(%eax),%edx
80105a15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a1b:	8b 00                	mov    (%eax),%eax
80105a1d:	39 c2                	cmp    %eax,%edx
80105a1f:	76 07                	jbe    80105a28 <fetchint+0x29>
    return -1;
80105a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a26:	eb 0f                	jmp    80105a37 <fetchint+0x38>
  *ip = *(int*)(addr);
80105a28:	8b 45 08             	mov    0x8(%ebp),%eax
80105a2b:	8b 10                	mov    (%eax),%edx
80105a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a30:	89 10                	mov    %edx,(%eax)
  return 0;
80105a32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a37:	5d                   	pop    %ebp
80105a38:	c3                   	ret    

80105a39 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105a39:	55                   	push   %ebp
80105a3a:	89 e5                	mov    %esp,%ebp
80105a3c:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105a3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a45:	8b 00                	mov    (%eax),%eax
80105a47:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a4a:	77 07                	ja     80105a53 <fetchstr+0x1a>
    return -1;
80105a4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a51:	eb 46                	jmp    80105a99 <fetchstr+0x60>
  *pp = (char*)addr;
80105a53:	8b 55 08             	mov    0x8(%ebp),%edx
80105a56:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a59:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105a5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a61:	8b 00                	mov    (%eax),%eax
80105a63:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105a66:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a69:	8b 00                	mov    (%eax),%eax
80105a6b:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105a6e:	eb 1c                	jmp    80105a8c <fetchstr+0x53>
    if(*s == 0)
80105a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a73:	0f b6 00             	movzbl (%eax),%eax
80105a76:	84 c0                	test   %al,%al
80105a78:	75 0e                	jne    80105a88 <fetchstr+0x4f>
      return s - *pp;
80105a7a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a80:	8b 00                	mov    (%eax),%eax
80105a82:	29 c2                	sub    %eax,%edx
80105a84:	89 d0                	mov    %edx,%eax
80105a86:	eb 11                	jmp    80105a99 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105a88:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105a8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a8f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105a92:	72 dc                	jb     80105a70 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105a94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a99:	c9                   	leave  
80105a9a:	c3                   	ret    

80105a9b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105a9b:	55                   	push   %ebp
80105a9c:	89 e5                	mov    %esp,%ebp
80105a9e:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105aa1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105aa7:	8b 40 18             	mov    0x18(%eax),%eax
80105aaa:	8b 50 44             	mov    0x44(%eax),%edx
80105aad:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab0:	c1 e0 02             	shl    $0x2,%eax
80105ab3:	01 d0                	add    %edx,%eax
80105ab5:	8d 50 04             	lea    0x4(%eax),%edx
80105ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105abb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105abf:	89 14 24             	mov    %edx,(%esp)
80105ac2:	e8 38 ff ff ff       	call   801059ff <fetchint>
}
80105ac7:	c9                   	leave  
80105ac8:	c3                   	ret    

80105ac9 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105ac9:	55                   	push   %ebp
80105aca:	89 e5                	mov    %esp,%ebp
80105acc:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105acf:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ad9:	89 04 24             	mov    %eax,(%esp)
80105adc:	e8 ba ff ff ff       	call   80105a9b <argint>
80105ae1:	85 c0                	test   %eax,%eax
80105ae3:	79 07                	jns    80105aec <argptr+0x23>
    return -1;
80105ae5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aea:	eb 3d                	jmp    80105b29 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105aec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105aef:	89 c2                	mov    %eax,%edx
80105af1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105af7:	8b 00                	mov    (%eax),%eax
80105af9:	39 c2                	cmp    %eax,%edx
80105afb:	73 16                	jae    80105b13 <argptr+0x4a>
80105afd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b00:	89 c2                	mov    %eax,%edx
80105b02:	8b 45 10             	mov    0x10(%ebp),%eax
80105b05:	01 c2                	add    %eax,%edx
80105b07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b0d:	8b 00                	mov    (%eax),%eax
80105b0f:	39 c2                	cmp    %eax,%edx
80105b11:	76 07                	jbe    80105b1a <argptr+0x51>
    return -1;
80105b13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b18:	eb 0f                	jmp    80105b29 <argptr+0x60>
  *pp = (char*)i;
80105b1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b1d:	89 c2                	mov    %eax,%edx
80105b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b22:	89 10                	mov    %edx,(%eax)
  return 0;
80105b24:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b29:	c9                   	leave  
80105b2a:	c3                   	ret    

80105b2b <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105b2b:	55                   	push   %ebp
80105b2c:	89 e5                	mov    %esp,%ebp
80105b2e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105b31:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105b34:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b38:	8b 45 08             	mov    0x8(%ebp),%eax
80105b3b:	89 04 24             	mov    %eax,(%esp)
80105b3e:	e8 58 ff ff ff       	call   80105a9b <argint>
80105b43:	85 c0                	test   %eax,%eax
80105b45:	79 07                	jns    80105b4e <argstr+0x23>
    return -1;
80105b47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4c:	eb 12                	jmp    80105b60 <argstr+0x35>
  return fetchstr(addr, pp);
80105b4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b51:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b54:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b58:	89 04 24             	mov    %eax,(%esp)
80105b5b:	e8 d9 fe ff ff       	call   80105a39 <fetchstr>
}
80105b60:	c9                   	leave  
80105b61:	c3                   	ret    

80105b62 <syscall>:
[SYS_sigpause] sys_sigpause,
};

void
syscall(void)
{
80105b62:	55                   	push   %ebp
80105b63:	89 e5                	mov    %esp,%ebp
80105b65:	53                   	push   %ebx
80105b66:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105b69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b6f:	8b 40 18             	mov    0x18(%eax),%eax
80105b72:	8b 40 1c             	mov    0x1c(%eax),%eax
80105b75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105b78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b7c:	7e 30                	jle    80105bae <syscall+0x4c>
80105b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b81:	83 f8 19             	cmp    $0x19,%eax
80105b84:	77 28                	ja     80105bae <syscall+0x4c>
80105b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b89:	8b 04 85 80 c0 10 80 	mov    -0x7fef3f80(,%eax,4),%eax
80105b90:	85 c0                	test   %eax,%eax
80105b92:	74 1a                	je     80105bae <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105b94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b9a:	8b 58 18             	mov    0x18(%eax),%ebx
80105b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba0:	8b 04 85 80 c0 10 80 	mov    -0x7fef3f80(,%eax,4),%eax
80105ba7:	ff d0                	call   *%eax
80105ba9:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105bac:	eb 3d                	jmp    80105beb <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105bae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bb4:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105bb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105bbd:	8b 40 10             	mov    0x10(%eax),%eax
80105bc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bc3:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105bc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bcf:	c7 04 24 61 8f 10 80 	movl   $0x80108f61,(%esp)
80105bd6:	e8 c5 a7 ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105bdb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105be1:	8b 40 18             	mov    0x18(%eax),%eax
80105be4:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105beb:	83 c4 24             	add    $0x24,%esp
80105bee:	5b                   	pop    %ebx
80105bef:	5d                   	pop    %ebp
80105bf0:	c3                   	ret    

80105bf1 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105bf1:	55                   	push   %ebp
80105bf2:	89 e5                	mov    %esp,%ebp
80105bf4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105bf7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80105c01:	89 04 24             	mov    %eax,(%esp)
80105c04:	e8 92 fe ff ff       	call   80105a9b <argint>
80105c09:	85 c0                	test   %eax,%eax
80105c0b:	79 07                	jns    80105c14 <argfd+0x23>
    return -1;
80105c0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c12:	eb 50                	jmp    80105c64 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c17:	85 c0                	test   %eax,%eax
80105c19:	78 21                	js     80105c3c <argfd+0x4b>
80105c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1e:	83 f8 0f             	cmp    $0xf,%eax
80105c21:	7f 19                	jg     80105c3c <argfd+0x4b>
80105c23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c29:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c2c:	83 c2 08             	add    $0x8,%edx
80105c2f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c36:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c3a:	75 07                	jne    80105c43 <argfd+0x52>
    return -1;
80105c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c41:	eb 21                	jmp    80105c64 <argfd+0x73>
  if(pfd)
80105c43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105c47:	74 08                	je     80105c51 <argfd+0x60>
    *pfd = fd;
80105c49:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c4f:	89 10                	mov    %edx,(%eax)
  if(pf)
80105c51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c55:	74 08                	je     80105c5f <argfd+0x6e>
    *pf = f;
80105c57:	8b 45 10             	mov    0x10(%ebp),%eax
80105c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c5d:	89 10                	mov    %edx,(%eax)
  return 0;
80105c5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c64:	c9                   	leave  
80105c65:	c3                   	ret    

80105c66 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105c66:	55                   	push   %ebp
80105c67:	89 e5                	mov    %esp,%ebp
80105c69:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105c6c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105c73:	eb 30                	jmp    80105ca5 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105c75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c7b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c7e:	83 c2 08             	add    $0x8,%edx
80105c81:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c85:	85 c0                	test   %eax,%eax
80105c87:	75 18                	jne    80105ca1 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105c89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c8f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c92:	8d 4a 08             	lea    0x8(%edx),%ecx
80105c95:	8b 55 08             	mov    0x8(%ebp),%edx
80105c98:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105c9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c9f:	eb 0f                	jmp    80105cb0 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105ca1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ca5:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105ca9:	7e ca                	jle    80105c75 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cb0:	c9                   	leave  
80105cb1:	c3                   	ret    

80105cb2 <sys_dup>:

int
sys_dup(void)
{
80105cb2:	55                   	push   %ebp
80105cb3:	89 e5                	mov    %esp,%ebp
80105cb5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105cb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cbb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cbf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cc6:	00 
80105cc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cce:	e8 1e ff ff ff       	call   80105bf1 <argfd>
80105cd3:	85 c0                	test   %eax,%eax
80105cd5:	79 07                	jns    80105cde <sys_dup+0x2c>
    return -1;
80105cd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cdc:	eb 29                	jmp    80105d07 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce1:	89 04 24             	mov    %eax,(%esp)
80105ce4:	e8 7d ff ff ff       	call   80105c66 <fdalloc>
80105ce9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cf0:	79 07                	jns    80105cf9 <sys_dup+0x47>
    return -1;
80105cf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf7:	eb 0e                	jmp    80105d07 <sys_dup+0x55>
  filedup(f);
80105cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cfc:	89 04 24             	mov    %eax,(%esp)
80105cff:	e8 8f b2 ff ff       	call   80100f93 <filedup>
  return fd;
80105d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d07:	c9                   	leave  
80105d08:	c3                   	ret    

80105d09 <sys_read>:

int
sys_read(void)
{
80105d09:	55                   	push   %ebp
80105d0a:	89 e5                	mov    %esp,%ebp
80105d0c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d12:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d1d:	00 
80105d1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d25:	e8 c7 fe ff ff       	call   80105bf1 <argfd>
80105d2a:	85 c0                	test   %eax,%eax
80105d2c:	78 35                	js     80105d63 <sys_read+0x5a>
80105d2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d31:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d35:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105d3c:	e8 5a fd ff ff       	call   80105a9b <argint>
80105d41:	85 c0                	test   %eax,%eax
80105d43:	78 1e                	js     80105d63 <sys_read+0x5a>
80105d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d48:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d4c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d5a:	e8 6a fd ff ff       	call   80105ac9 <argptr>
80105d5f:	85 c0                	test   %eax,%eax
80105d61:	79 07                	jns    80105d6a <sys_read+0x61>
    return -1;
80105d63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d68:	eb 19                	jmp    80105d83 <sys_read+0x7a>
  return fileread(f, p, n);
80105d6a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d6d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d77:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d7b:	89 04 24             	mov    %eax,(%esp)
80105d7e:	e8 7d b3 ff ff       	call   80101100 <fileread>
}
80105d83:	c9                   	leave  
80105d84:	c3                   	ret    

80105d85 <sys_write>:

int
sys_write(void)
{
80105d85:	55                   	push   %ebp
80105d86:	89 e5                	mov    %esp,%ebp
80105d88:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d8e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d99:	00 
80105d9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105da1:	e8 4b fe ff ff       	call   80105bf1 <argfd>
80105da6:	85 c0                	test   %eax,%eax
80105da8:	78 35                	js     80105ddf <sys_write+0x5a>
80105daa:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dad:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105db8:	e8 de fc ff ff       	call   80105a9b <argint>
80105dbd:	85 c0                	test   %eax,%eax
80105dbf:	78 1e                	js     80105ddf <sys_write+0x5a>
80105dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dc8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dcf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105dd6:	e8 ee fc ff ff       	call   80105ac9 <argptr>
80105ddb:	85 c0                	test   %eax,%eax
80105ddd:	79 07                	jns    80105de6 <sys_write+0x61>
    return -1;
80105ddf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de4:	eb 19                	jmp    80105dff <sys_write+0x7a>
  return filewrite(f, p, n);
80105de6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105de9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105def:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105df3:	89 54 24 04          	mov    %edx,0x4(%esp)
80105df7:	89 04 24             	mov    %eax,(%esp)
80105dfa:	e8 bd b3 ff ff       	call   801011bc <filewrite>
}
80105dff:	c9                   	leave  
80105e00:	c3                   	ret    

80105e01 <sys_close>:

int
sys_close(void)
{
80105e01:	55                   	push   %ebp
80105e02:	89 e5                	mov    %esp,%ebp
80105e04:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105e07:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e11:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e1c:	e8 d0 fd ff ff       	call   80105bf1 <argfd>
80105e21:	85 c0                	test   %eax,%eax
80105e23:	79 07                	jns    80105e2c <sys_close+0x2b>
    return -1;
80105e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2a:	eb 24                	jmp    80105e50 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105e2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e35:	83 c2 08             	add    $0x8,%edx
80105e38:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105e3f:	00 
  fileclose(f);
80105e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e43:	89 04 24             	mov    %eax,(%esp)
80105e46:	e8 90 b1 ff ff       	call   80100fdb <fileclose>
  return 0;
80105e4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e50:	c9                   	leave  
80105e51:	c3                   	ret    

80105e52 <sys_fstat>:

int
sys_fstat(void)
{
80105e52:	55                   	push   %ebp
80105e53:	89 e5                	mov    %esp,%ebp
80105e55:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e5b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e66:	00 
80105e67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e6e:	e8 7e fd ff ff       	call   80105bf1 <argfd>
80105e73:	85 c0                	test   %eax,%eax
80105e75:	78 1f                	js     80105e96 <sys_fstat+0x44>
80105e77:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105e7e:	00 
80105e7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e82:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e8d:	e8 37 fc ff ff       	call   80105ac9 <argptr>
80105e92:	85 c0                	test   %eax,%eax
80105e94:	79 07                	jns    80105e9d <sys_fstat+0x4b>
    return -1;
80105e96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e9b:	eb 12                	jmp    80105eaf <sys_fstat+0x5d>
  return filestat(f, st);
80105e9d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea3:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ea7:	89 04 24             	mov    %eax,(%esp)
80105eaa:	e8 02 b2 ff ff       	call   801010b1 <filestat>
}
80105eaf:	c9                   	leave  
80105eb0:	c3                   	ret    

80105eb1 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105eb1:	55                   	push   %ebp
80105eb2:	89 e5                	mov    %esp,%ebp
80105eb4:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105eb7:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105eba:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ebe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ec5:	e8 61 fc ff ff       	call   80105b2b <argstr>
80105eca:	85 c0                	test   %eax,%eax
80105ecc:	78 17                	js     80105ee5 <sys_link+0x34>
80105ece:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105ed1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ed5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105edc:	e8 4a fc ff ff       	call   80105b2b <argstr>
80105ee1:	85 c0                	test   %eax,%eax
80105ee3:	79 0a                	jns    80105eef <sys_link+0x3e>
    return -1;
80105ee5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eea:	e9 42 01 00 00       	jmp    80106031 <sys_link+0x180>

  begin_op();
80105eef:	e8 29 d5 ff ff       	call   8010341d <begin_op>
  if((ip = namei(old)) == 0){
80105ef4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105ef7:	89 04 24             	mov    %eax,(%esp)
80105efa:	e8 14 c5 ff ff       	call   80102413 <namei>
80105eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f06:	75 0f                	jne    80105f17 <sys_link+0x66>
    end_op();
80105f08:	e8 94 d5 ff ff       	call   801034a1 <end_op>
    return -1;
80105f0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f12:	e9 1a 01 00 00       	jmp    80106031 <sys_link+0x180>
  }

  ilock(ip);
80105f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1a:	89 04 24             	mov    %eax,(%esp)
80105f1d:	e8 46 b9 ff ff       	call   80101868 <ilock>
  if(ip->type == T_DIR){
80105f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f25:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f29:	66 83 f8 01          	cmp    $0x1,%ax
80105f2d:	75 1a                	jne    80105f49 <sys_link+0x98>
    iunlockput(ip);
80105f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f32:	89 04 24             	mov    %eax,(%esp)
80105f35:	e8 b2 bb ff ff       	call   80101aec <iunlockput>
    end_op();
80105f3a:	e8 62 d5 ff ff       	call   801034a1 <end_op>
    return -1;
80105f3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f44:	e9 e8 00 00 00       	jmp    80106031 <sys_link+0x180>
  }

  ip->nlink++;
80105f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f50:	8d 50 01             	lea    0x1(%eax),%edx
80105f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f56:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5d:	89 04 24             	mov    %eax,(%esp)
80105f60:	e8 47 b7 ff ff       	call   801016ac <iupdate>
  iunlock(ip);
80105f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f68:	89 04 24             	mov    %eax,(%esp)
80105f6b:	e8 46 ba ff ff       	call   801019b6 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105f70:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105f73:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105f76:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f7a:	89 04 24             	mov    %eax,(%esp)
80105f7d:	e8 b3 c4 ff ff       	call   80102435 <nameiparent>
80105f82:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f85:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f89:	75 02                	jne    80105f8d <sys_link+0xdc>
    goto bad;
80105f8b:	eb 68                	jmp    80105ff5 <sys_link+0x144>
  ilock(dp);
80105f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f90:	89 04 24             	mov    %eax,(%esp)
80105f93:	e8 d0 b8 ff ff       	call   80101868 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9b:	8b 10                	mov    (%eax),%edx
80105f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa0:	8b 00                	mov    (%eax),%eax
80105fa2:	39 c2                	cmp    %eax,%edx
80105fa4:	75 20                	jne    80105fc6 <sys_link+0x115>
80105fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa9:	8b 40 04             	mov    0x4(%eax),%eax
80105fac:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fb0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fba:	89 04 24             	mov    %eax,(%esp)
80105fbd:	e8 91 c1 ff ff       	call   80102153 <dirlink>
80105fc2:	85 c0                	test   %eax,%eax
80105fc4:	79 0d                	jns    80105fd3 <sys_link+0x122>
    iunlockput(dp);
80105fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc9:	89 04 24             	mov    %eax,(%esp)
80105fcc:	e8 1b bb ff ff       	call   80101aec <iunlockput>
    goto bad;
80105fd1:	eb 22                	jmp    80105ff5 <sys_link+0x144>
  }
  iunlockput(dp);
80105fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd6:	89 04 24             	mov    %eax,(%esp)
80105fd9:	e8 0e bb ff ff       	call   80101aec <iunlockput>
  iput(ip);
80105fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe1:	89 04 24             	mov    %eax,(%esp)
80105fe4:	e8 32 ba ff ff       	call   80101a1b <iput>

  end_op();
80105fe9:	e8 b3 d4 ff ff       	call   801034a1 <end_op>

  return 0;
80105fee:	b8 00 00 00 00       	mov    $0x0,%eax
80105ff3:	eb 3c                	jmp    80106031 <sys_link+0x180>

bad:
  ilock(ip);
80105ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff8:	89 04 24             	mov    %eax,(%esp)
80105ffb:	e8 68 b8 ff ff       	call   80101868 <ilock>
  ip->nlink--;
80106000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106003:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106007:	8d 50 ff             	lea    -0x1(%eax),%edx
8010600a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106014:	89 04 24             	mov    %eax,(%esp)
80106017:	e8 90 b6 ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
8010601c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601f:	89 04 24             	mov    %eax,(%esp)
80106022:	e8 c5 ba ff ff       	call   80101aec <iunlockput>
  end_op();
80106027:	e8 75 d4 ff ff       	call   801034a1 <end_op>
  return -1;
8010602c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106031:	c9                   	leave  
80106032:	c3                   	ret    

80106033 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106033:	55                   	push   %ebp
80106034:	89 e5                	mov    %esp,%ebp
80106036:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106039:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106040:	eb 4b                	jmp    8010608d <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106045:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010604c:	00 
8010604d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106051:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106054:	89 44 24 04          	mov    %eax,0x4(%esp)
80106058:	8b 45 08             	mov    0x8(%ebp),%eax
8010605b:	89 04 24             	mov    %eax,(%esp)
8010605e:	e8 12 bd ff ff       	call   80101d75 <readi>
80106063:	83 f8 10             	cmp    $0x10,%eax
80106066:	74 0c                	je     80106074 <isdirempty+0x41>
      panic("isdirempty: readi");
80106068:	c7 04 24 7d 8f 10 80 	movl   $0x80108f7d,(%esp)
8010606f:	e8 c6 a4 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80106074:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106078:	66 85 c0             	test   %ax,%ax
8010607b:	74 07                	je     80106084 <isdirempty+0x51>
      return 0;
8010607d:	b8 00 00 00 00       	mov    $0x0,%eax
80106082:	eb 1b                	jmp    8010609f <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106087:	83 c0 10             	add    $0x10,%eax
8010608a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010608d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106090:	8b 45 08             	mov    0x8(%ebp),%eax
80106093:	8b 40 18             	mov    0x18(%eax),%eax
80106096:	39 c2                	cmp    %eax,%edx
80106098:	72 a8                	jb     80106042 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010609a:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010609f:	c9                   	leave  
801060a0:	c3                   	ret    

801060a1 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801060a1:	55                   	push   %ebp
801060a2:	89 e5                	mov    %esp,%ebp
801060a4:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801060a7:	8d 45 cc             	lea    -0x34(%ebp),%eax
801060aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060b5:	e8 71 fa ff ff       	call   80105b2b <argstr>
801060ba:	85 c0                	test   %eax,%eax
801060bc:	79 0a                	jns    801060c8 <sys_unlink+0x27>
    return -1;
801060be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c3:	e9 af 01 00 00       	jmp    80106277 <sys_unlink+0x1d6>

  begin_op();
801060c8:	e8 50 d3 ff ff       	call   8010341d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801060cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
801060d0:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801060d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801060d7:	89 04 24             	mov    %eax,(%esp)
801060da:	e8 56 c3 ff ff       	call   80102435 <nameiparent>
801060df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060e6:	75 0f                	jne    801060f7 <sys_unlink+0x56>
    end_op();
801060e8:	e8 b4 d3 ff ff       	call   801034a1 <end_op>
    return -1;
801060ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f2:	e9 80 01 00 00       	jmp    80106277 <sys_unlink+0x1d6>
  }

  ilock(dp);
801060f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fa:	89 04 24             	mov    %eax,(%esp)
801060fd:	e8 66 b7 ff ff       	call   80101868 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106102:	c7 44 24 04 8f 8f 10 	movl   $0x80108f8f,0x4(%esp)
80106109:	80 
8010610a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010610d:	89 04 24             	mov    %eax,(%esp)
80106110:	e8 53 bf ff ff       	call   80102068 <namecmp>
80106115:	85 c0                	test   %eax,%eax
80106117:	0f 84 45 01 00 00    	je     80106262 <sys_unlink+0x1c1>
8010611d:	c7 44 24 04 91 8f 10 	movl   $0x80108f91,0x4(%esp)
80106124:	80 
80106125:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106128:	89 04 24             	mov    %eax,(%esp)
8010612b:	e8 38 bf ff ff       	call   80102068 <namecmp>
80106130:	85 c0                	test   %eax,%eax
80106132:	0f 84 2a 01 00 00    	je     80106262 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106138:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010613b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010613f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106142:	89 44 24 04          	mov    %eax,0x4(%esp)
80106146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106149:	89 04 24             	mov    %eax,(%esp)
8010614c:	e8 39 bf ff ff       	call   8010208a <dirlookup>
80106151:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106154:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106158:	75 05                	jne    8010615f <sys_unlink+0xbe>
    goto bad;
8010615a:	e9 03 01 00 00       	jmp    80106262 <sys_unlink+0x1c1>
  ilock(ip);
8010615f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106162:	89 04 24             	mov    %eax,(%esp)
80106165:	e8 fe b6 ff ff       	call   80101868 <ilock>

  if(ip->nlink < 1)
8010616a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106171:	66 85 c0             	test   %ax,%ax
80106174:	7f 0c                	jg     80106182 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80106176:	c7 04 24 94 8f 10 80 	movl   $0x80108f94,(%esp)
8010617d:	e8 b8 a3 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106185:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106189:	66 83 f8 01          	cmp    $0x1,%ax
8010618d:	75 1f                	jne    801061ae <sys_unlink+0x10d>
8010618f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106192:	89 04 24             	mov    %eax,(%esp)
80106195:	e8 99 fe ff ff       	call   80106033 <isdirempty>
8010619a:	85 c0                	test   %eax,%eax
8010619c:	75 10                	jne    801061ae <sys_unlink+0x10d>
    iunlockput(ip);
8010619e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a1:	89 04 24             	mov    %eax,(%esp)
801061a4:	e8 43 b9 ff ff       	call   80101aec <iunlockput>
    goto bad;
801061a9:	e9 b4 00 00 00       	jmp    80106262 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
801061ae:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801061b5:	00 
801061b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801061bd:	00 
801061be:	8d 45 e0             	lea    -0x20(%ebp),%eax
801061c1:	89 04 24             	mov    %eax,(%esp)
801061c4:	e8 90 f5 ff ff       	call   80105759 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801061c9:	8b 45 c8             	mov    -0x38(%ebp),%eax
801061cc:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801061d3:	00 
801061d4:	89 44 24 08          	mov    %eax,0x8(%esp)
801061d8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801061db:	89 44 24 04          	mov    %eax,0x4(%esp)
801061df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e2:	89 04 24             	mov    %eax,(%esp)
801061e5:	e8 ef bc ff ff       	call   80101ed9 <writei>
801061ea:	83 f8 10             	cmp    $0x10,%eax
801061ed:	74 0c                	je     801061fb <sys_unlink+0x15a>
    panic("unlink: writei");
801061ef:	c7 04 24 a6 8f 10 80 	movl   $0x80108fa6,(%esp)
801061f6:	e8 3f a3 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
801061fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fe:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106202:	66 83 f8 01          	cmp    $0x1,%ax
80106206:	75 1c                	jne    80106224 <sys_unlink+0x183>
    dp->nlink--;
80106208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010620f:	8d 50 ff             	lea    -0x1(%eax),%edx
80106212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106215:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621c:	89 04 24             	mov    %eax,(%esp)
8010621f:	e8 88 b4 ff ff       	call   801016ac <iupdate>
  }
  iunlockput(dp);
80106224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106227:	89 04 24             	mov    %eax,(%esp)
8010622a:	e8 bd b8 ff ff       	call   80101aec <iunlockput>

  ip->nlink--;
8010622f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106232:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106236:	8d 50 ff             	lea    -0x1(%eax),%edx
80106239:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106240:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106243:	89 04 24             	mov    %eax,(%esp)
80106246:	e8 61 b4 ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
8010624b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624e:	89 04 24             	mov    %eax,(%esp)
80106251:	e8 96 b8 ff ff       	call   80101aec <iunlockput>

  end_op();
80106256:	e8 46 d2 ff ff       	call   801034a1 <end_op>

  return 0;
8010625b:	b8 00 00 00 00       	mov    $0x0,%eax
80106260:	eb 15                	jmp    80106277 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80106262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106265:	89 04 24             	mov    %eax,(%esp)
80106268:	e8 7f b8 ff ff       	call   80101aec <iunlockput>
  end_op();
8010626d:	e8 2f d2 ff ff       	call   801034a1 <end_op>
  return -1;
80106272:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106277:	c9                   	leave  
80106278:	c3                   	ret    

80106279 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106279:	55                   	push   %ebp
8010627a:	89 e5                	mov    %esp,%ebp
8010627c:	83 ec 48             	sub    $0x48,%esp
8010627f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106282:	8b 55 10             	mov    0x10(%ebp),%edx
80106285:	8b 45 14             	mov    0x14(%ebp),%eax
80106288:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010628c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106290:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106294:	8d 45 de             	lea    -0x22(%ebp),%eax
80106297:	89 44 24 04          	mov    %eax,0x4(%esp)
8010629b:	8b 45 08             	mov    0x8(%ebp),%eax
8010629e:	89 04 24             	mov    %eax,(%esp)
801062a1:	e8 8f c1 ff ff       	call   80102435 <nameiparent>
801062a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062ad:	75 0a                	jne    801062b9 <create+0x40>
    return 0;
801062af:	b8 00 00 00 00       	mov    $0x0,%eax
801062b4:	e9 7e 01 00 00       	jmp    80106437 <create+0x1be>
  ilock(dp);
801062b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bc:	89 04 24             	mov    %eax,(%esp)
801062bf:	e8 a4 b5 ff ff       	call   80101868 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801062c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062c7:	89 44 24 08          	mov    %eax,0x8(%esp)
801062cb:	8d 45 de             	lea    -0x22(%ebp),%eax
801062ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801062d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d5:	89 04 24             	mov    %eax,(%esp)
801062d8:	e8 ad bd ff ff       	call   8010208a <dirlookup>
801062dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062e4:	74 47                	je     8010632d <create+0xb4>
    iunlockput(dp);
801062e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e9:	89 04 24             	mov    %eax,(%esp)
801062ec:	e8 fb b7 ff ff       	call   80101aec <iunlockput>
    ilock(ip);
801062f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f4:	89 04 24             	mov    %eax,(%esp)
801062f7:	e8 6c b5 ff ff       	call   80101868 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801062fc:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106301:	75 15                	jne    80106318 <create+0x9f>
80106303:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106306:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010630a:	66 83 f8 02          	cmp    $0x2,%ax
8010630e:	75 08                	jne    80106318 <create+0x9f>
      return ip;
80106310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106313:	e9 1f 01 00 00       	jmp    80106437 <create+0x1be>
    iunlockput(ip);
80106318:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010631b:	89 04 24             	mov    %eax,(%esp)
8010631e:	e8 c9 b7 ff ff       	call   80101aec <iunlockput>
    return 0;
80106323:	b8 00 00 00 00       	mov    $0x0,%eax
80106328:	e9 0a 01 00 00       	jmp    80106437 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010632d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106334:	8b 00                	mov    (%eax),%eax
80106336:	89 54 24 04          	mov    %edx,0x4(%esp)
8010633a:	89 04 24             	mov    %eax,(%esp)
8010633d:	e8 8b b2 ff ff       	call   801015cd <ialloc>
80106342:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106345:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106349:	75 0c                	jne    80106357 <create+0xde>
    panic("create: ialloc");
8010634b:	c7 04 24 b5 8f 10 80 	movl   $0x80108fb5,(%esp)
80106352:	e8 e3 a1 ff ff       	call   8010053a <panic>

  ilock(ip);
80106357:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010635a:	89 04 24             	mov    %eax,(%esp)
8010635d:	e8 06 b5 ff ff       	call   80101868 <ilock>
  ip->major = major;
80106362:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106365:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106369:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010636d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106370:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106374:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637b:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106384:	89 04 24             	mov    %eax,(%esp)
80106387:	e8 20 b3 ff ff       	call   801016ac <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010638c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106391:	75 6a                	jne    801063fd <create+0x184>
    dp->nlink++;  // for ".."
80106393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106396:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010639a:	8d 50 01             	lea    0x1(%eax),%edx
8010639d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a0:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801063a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a7:	89 04 24             	mov    %eax,(%esp)
801063aa:	e8 fd b2 ff ff       	call   801016ac <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801063af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b2:	8b 40 04             	mov    0x4(%eax),%eax
801063b5:	89 44 24 08          	mov    %eax,0x8(%esp)
801063b9:	c7 44 24 04 8f 8f 10 	movl   $0x80108f8f,0x4(%esp)
801063c0:	80 
801063c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c4:	89 04 24             	mov    %eax,(%esp)
801063c7:	e8 87 bd ff ff       	call   80102153 <dirlink>
801063cc:	85 c0                	test   %eax,%eax
801063ce:	78 21                	js     801063f1 <create+0x178>
801063d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d3:	8b 40 04             	mov    0x4(%eax),%eax
801063d6:	89 44 24 08          	mov    %eax,0x8(%esp)
801063da:	c7 44 24 04 91 8f 10 	movl   $0x80108f91,0x4(%esp)
801063e1:	80 
801063e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e5:	89 04 24             	mov    %eax,(%esp)
801063e8:	e8 66 bd ff ff       	call   80102153 <dirlink>
801063ed:	85 c0                	test   %eax,%eax
801063ef:	79 0c                	jns    801063fd <create+0x184>
      panic("create dots");
801063f1:	c7 04 24 c4 8f 10 80 	movl   $0x80108fc4,(%esp)
801063f8:	e8 3d a1 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801063fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106400:	8b 40 04             	mov    0x4(%eax),%eax
80106403:	89 44 24 08          	mov    %eax,0x8(%esp)
80106407:	8d 45 de             	lea    -0x22(%ebp),%eax
8010640a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010640e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106411:	89 04 24             	mov    %eax,(%esp)
80106414:	e8 3a bd ff ff       	call   80102153 <dirlink>
80106419:	85 c0                	test   %eax,%eax
8010641b:	79 0c                	jns    80106429 <create+0x1b0>
    panic("create: dirlink");
8010641d:	c7 04 24 d0 8f 10 80 	movl   $0x80108fd0,(%esp)
80106424:	e8 11 a1 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80106429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642c:	89 04 24             	mov    %eax,(%esp)
8010642f:	e8 b8 b6 ff ff       	call   80101aec <iunlockput>

  return ip;
80106434:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106437:	c9                   	leave  
80106438:	c3                   	ret    

80106439 <sys_open>:

int
sys_open(void)
{
80106439:	55                   	push   %ebp
8010643a:	89 e5                	mov    %esp,%ebp
8010643c:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010643f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106442:	89 44 24 04          	mov    %eax,0x4(%esp)
80106446:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010644d:	e8 d9 f6 ff ff       	call   80105b2b <argstr>
80106452:	85 c0                	test   %eax,%eax
80106454:	78 17                	js     8010646d <sys_open+0x34>
80106456:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106459:	89 44 24 04          	mov    %eax,0x4(%esp)
8010645d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106464:	e8 32 f6 ff ff       	call   80105a9b <argint>
80106469:	85 c0                	test   %eax,%eax
8010646b:	79 0a                	jns    80106477 <sys_open+0x3e>
    return -1;
8010646d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106472:	e9 5c 01 00 00       	jmp    801065d3 <sys_open+0x19a>

  begin_op();
80106477:	e8 a1 cf ff ff       	call   8010341d <begin_op>

  if(omode & O_CREATE){
8010647c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010647f:	25 00 02 00 00       	and    $0x200,%eax
80106484:	85 c0                	test   %eax,%eax
80106486:	74 3b                	je     801064c3 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106488:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010648b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106492:	00 
80106493:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010649a:	00 
8010649b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801064a2:	00 
801064a3:	89 04 24             	mov    %eax,(%esp)
801064a6:	e8 ce fd ff ff       	call   80106279 <create>
801064ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801064ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064b2:	75 6b                	jne    8010651f <sys_open+0xe6>
      end_op();
801064b4:	e8 e8 cf ff ff       	call   801034a1 <end_op>
      return -1;
801064b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064be:	e9 10 01 00 00       	jmp    801065d3 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
801064c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064c6:	89 04 24             	mov    %eax,(%esp)
801064c9:	e8 45 bf ff ff       	call   80102413 <namei>
801064ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064d5:	75 0f                	jne    801064e6 <sys_open+0xad>
      end_op();
801064d7:	e8 c5 cf ff ff       	call   801034a1 <end_op>
      return -1;
801064dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e1:	e9 ed 00 00 00       	jmp    801065d3 <sys_open+0x19a>
    }
    ilock(ip);
801064e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e9:	89 04 24             	mov    %eax,(%esp)
801064ec:	e8 77 b3 ff ff       	call   80101868 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801064f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801064f8:	66 83 f8 01          	cmp    $0x1,%ax
801064fc:	75 21                	jne    8010651f <sys_open+0xe6>
801064fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106501:	85 c0                	test   %eax,%eax
80106503:	74 1a                	je     8010651f <sys_open+0xe6>
      iunlockput(ip);
80106505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106508:	89 04 24             	mov    %eax,(%esp)
8010650b:	e8 dc b5 ff ff       	call   80101aec <iunlockput>
      end_op();
80106510:	e8 8c cf ff ff       	call   801034a1 <end_op>
      return -1;
80106515:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651a:	e9 b4 00 00 00       	jmp    801065d3 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010651f:	e8 0f aa ff ff       	call   80100f33 <filealloc>
80106524:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106527:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010652b:	74 14                	je     80106541 <sys_open+0x108>
8010652d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106530:	89 04 24             	mov    %eax,(%esp)
80106533:	e8 2e f7 ff ff       	call   80105c66 <fdalloc>
80106538:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010653b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010653f:	79 28                	jns    80106569 <sys_open+0x130>
    if(f)
80106541:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106545:	74 0b                	je     80106552 <sys_open+0x119>
      fileclose(f);
80106547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010654a:	89 04 24             	mov    %eax,(%esp)
8010654d:	e8 89 aa ff ff       	call   80100fdb <fileclose>
    iunlockput(ip);
80106552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106555:	89 04 24             	mov    %eax,(%esp)
80106558:	e8 8f b5 ff ff       	call   80101aec <iunlockput>
    end_op();
8010655d:	e8 3f cf ff ff       	call   801034a1 <end_op>
    return -1;
80106562:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106567:	eb 6a                	jmp    801065d3 <sys_open+0x19a>
  }
  iunlock(ip);
80106569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656c:	89 04 24             	mov    %eax,(%esp)
8010656f:	e8 42 b4 ff ff       	call   801019b6 <iunlock>
  end_op();
80106574:	e8 28 cf ff ff       	call   801034a1 <end_op>

  f->type = FD_INODE;
80106579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010657c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106582:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106585:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106588:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010658b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010658e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106595:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106598:	83 e0 01             	and    $0x1,%eax
8010659b:	85 c0                	test   %eax,%eax
8010659d:	0f 94 c0             	sete   %al
801065a0:	89 c2                	mov    %eax,%edx
801065a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801065a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065ab:	83 e0 01             	and    $0x1,%eax
801065ae:	85 c0                	test   %eax,%eax
801065b0:	75 0a                	jne    801065bc <sys_open+0x183>
801065b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065b5:	83 e0 02             	and    $0x2,%eax
801065b8:	85 c0                	test   %eax,%eax
801065ba:	74 07                	je     801065c3 <sys_open+0x18a>
801065bc:	b8 01 00 00 00       	mov    $0x1,%eax
801065c1:	eb 05                	jmp    801065c8 <sys_open+0x18f>
801065c3:	b8 00 00 00 00       	mov    $0x0,%eax
801065c8:	89 c2                	mov    %eax,%edx
801065ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065cd:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801065d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801065d3:	c9                   	leave  
801065d4:	c3                   	ret    

801065d5 <sys_mkdir>:

int
sys_mkdir(void)
{
801065d5:	55                   	push   %ebp
801065d6:	89 e5                	mov    %esp,%ebp
801065d8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801065db:	e8 3d ce ff ff       	call   8010341d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801065e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801065e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065ee:	e8 38 f5 ff ff       	call   80105b2b <argstr>
801065f3:	85 c0                	test   %eax,%eax
801065f5:	78 2c                	js     80106623 <sys_mkdir+0x4e>
801065f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106601:	00 
80106602:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106609:	00 
8010660a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106611:	00 
80106612:	89 04 24             	mov    %eax,(%esp)
80106615:	e8 5f fc ff ff       	call   80106279 <create>
8010661a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010661d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106621:	75 0c                	jne    8010662f <sys_mkdir+0x5a>
    end_op();
80106623:	e8 79 ce ff ff       	call   801034a1 <end_op>
    return -1;
80106628:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662d:	eb 15                	jmp    80106644 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010662f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106632:	89 04 24             	mov    %eax,(%esp)
80106635:	e8 b2 b4 ff ff       	call   80101aec <iunlockput>
  end_op();
8010663a:	e8 62 ce ff ff       	call   801034a1 <end_op>
  return 0;
8010663f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106644:	c9                   	leave  
80106645:	c3                   	ret    

80106646 <sys_mknod>:

int
sys_mknod(void)
{
80106646:	55                   	push   %ebp
80106647:	89 e5                	mov    %esp,%ebp
80106649:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010664c:	e8 cc cd ff ff       	call   8010341d <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106651:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106654:	89 44 24 04          	mov    %eax,0x4(%esp)
80106658:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010665f:	e8 c7 f4 ff ff       	call   80105b2b <argstr>
80106664:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106667:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010666b:	78 5e                	js     801066cb <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010666d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106670:	89 44 24 04          	mov    %eax,0x4(%esp)
80106674:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010667b:	e8 1b f4 ff ff       	call   80105a9b <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106680:	85 c0                	test   %eax,%eax
80106682:	78 47                	js     801066cb <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106684:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106687:	89 44 24 04          	mov    %eax,0x4(%esp)
8010668b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106692:	e8 04 f4 ff ff       	call   80105a9b <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106697:	85 c0                	test   %eax,%eax
80106699:	78 30                	js     801066cb <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010669b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010669e:	0f bf c8             	movswl %ax,%ecx
801066a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066a4:	0f bf d0             	movswl %ax,%edx
801066a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801066aa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801066ae:	89 54 24 08          	mov    %edx,0x8(%esp)
801066b2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801066b9:	00 
801066ba:	89 04 24             	mov    %eax,(%esp)
801066bd:	e8 b7 fb ff ff       	call   80106279 <create>
801066c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066c9:	75 0c                	jne    801066d7 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801066cb:	e8 d1 cd ff ff       	call   801034a1 <end_op>
    return -1;
801066d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066d5:	eb 15                	jmp    801066ec <sys_mknod+0xa6>
  }
  iunlockput(ip);
801066d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066da:	89 04 24             	mov    %eax,(%esp)
801066dd:	e8 0a b4 ff ff       	call   80101aec <iunlockput>
  end_op();
801066e2:	e8 ba cd ff ff       	call   801034a1 <end_op>
  return 0;
801066e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066ec:	c9                   	leave  
801066ed:	c3                   	ret    

801066ee <sys_chdir>:

int
sys_chdir(void)
{
801066ee:	55                   	push   %ebp
801066ef:	89 e5                	mov    %esp,%ebp
801066f1:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801066f4:	e8 24 cd ff ff       	call   8010341d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801066f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106700:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106707:	e8 1f f4 ff ff       	call   80105b2b <argstr>
8010670c:	85 c0                	test   %eax,%eax
8010670e:	78 14                	js     80106724 <sys_chdir+0x36>
80106710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106713:	89 04 24             	mov    %eax,(%esp)
80106716:	e8 f8 bc ff ff       	call   80102413 <namei>
8010671b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010671e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106722:	75 0c                	jne    80106730 <sys_chdir+0x42>
    end_op();
80106724:	e8 78 cd ff ff       	call   801034a1 <end_op>
    return -1;
80106729:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010672e:	eb 61                	jmp    80106791 <sys_chdir+0xa3>
  }
  ilock(ip);
80106730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106733:	89 04 24             	mov    %eax,(%esp)
80106736:	e8 2d b1 ff ff       	call   80101868 <ilock>
  if(ip->type != T_DIR){
8010673b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106742:	66 83 f8 01          	cmp    $0x1,%ax
80106746:	74 17                	je     8010675f <sys_chdir+0x71>
    iunlockput(ip);
80106748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674b:	89 04 24             	mov    %eax,(%esp)
8010674e:	e8 99 b3 ff ff       	call   80101aec <iunlockput>
    end_op();
80106753:	e8 49 cd ff ff       	call   801034a1 <end_op>
    return -1;
80106758:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010675d:	eb 32                	jmp    80106791 <sys_chdir+0xa3>
  }
  iunlock(ip);
8010675f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106762:	89 04 24             	mov    %eax,(%esp)
80106765:	e8 4c b2 ff ff       	call   801019b6 <iunlock>
  iput(proc->cwd);
8010676a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106770:	8b 40 68             	mov    0x68(%eax),%eax
80106773:	89 04 24             	mov    %eax,(%esp)
80106776:	e8 a0 b2 ff ff       	call   80101a1b <iput>
  end_op();
8010677b:	e8 21 cd ff ff       	call   801034a1 <end_op>
  proc->cwd = ip;
80106780:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106786:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106789:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010678c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106791:	c9                   	leave  
80106792:	c3                   	ret    

80106793 <sys_exec>:

int
sys_exec(void)
{
80106793:	55                   	push   %ebp
80106794:	89 e5                	mov    %esp,%ebp
80106796:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010679c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010679f:	89 44 24 04          	mov    %eax,0x4(%esp)
801067a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067aa:	e8 7c f3 ff ff       	call   80105b2b <argstr>
801067af:	85 c0                	test   %eax,%eax
801067b1:	78 1a                	js     801067cd <sys_exec+0x3a>
801067b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801067b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801067bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801067c4:	e8 d2 f2 ff ff       	call   80105a9b <argint>
801067c9:	85 c0                	test   %eax,%eax
801067cb:	79 0a                	jns    801067d7 <sys_exec+0x44>
    return -1;
801067cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d2:	e9 c8 00 00 00       	jmp    8010689f <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
801067d7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801067de:	00 
801067df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801067e6:	00 
801067e7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801067ed:	89 04 24             	mov    %eax,(%esp)
801067f0:	e8 64 ef ff ff       	call   80105759 <memset>
  for(i=0;; i++){
801067f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801067fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ff:	83 f8 1f             	cmp    $0x1f,%eax
80106802:	76 0a                	jbe    8010680e <sys_exec+0x7b>
      return -1;
80106804:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106809:	e9 91 00 00 00       	jmp    8010689f <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010680e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106811:	c1 e0 02             	shl    $0x2,%eax
80106814:	89 c2                	mov    %eax,%edx
80106816:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010681c:	01 c2                	add    %eax,%edx
8010681e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106824:	89 44 24 04          	mov    %eax,0x4(%esp)
80106828:	89 14 24             	mov    %edx,(%esp)
8010682b:	e8 cf f1 ff ff       	call   801059ff <fetchint>
80106830:	85 c0                	test   %eax,%eax
80106832:	79 07                	jns    8010683b <sys_exec+0xa8>
      return -1;
80106834:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106839:	eb 64                	jmp    8010689f <sys_exec+0x10c>
    if(uarg == 0){
8010683b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106841:	85 c0                	test   %eax,%eax
80106843:	75 26                	jne    8010686b <sys_exec+0xd8>
      argv[i] = 0;
80106845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106848:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010684f:	00 00 00 00 
      break;
80106853:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106854:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106857:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010685d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106861:	89 04 24             	mov    %eax,(%esp)
80106864:	e8 86 a2 ff ff       	call   80100aef <exec>
80106869:	eb 34                	jmp    8010689f <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010686b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106871:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106874:	c1 e2 02             	shl    $0x2,%edx
80106877:	01 c2                	add    %eax,%edx
80106879:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010687f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106883:	89 04 24             	mov    %eax,(%esp)
80106886:	e8 ae f1 ff ff       	call   80105a39 <fetchstr>
8010688b:	85 c0                	test   %eax,%eax
8010688d:	79 07                	jns    80106896 <sys_exec+0x103>
      return -1;
8010688f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106894:	eb 09                	jmp    8010689f <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106896:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010689a:	e9 5d ff ff ff       	jmp    801067fc <sys_exec+0x69>
  return exec(path, argv);
}
8010689f:	c9                   	leave  
801068a0:	c3                   	ret    

801068a1 <sys_pipe>:

int
sys_pipe(void)
{
801068a1:	55                   	push   %ebp
801068a2:	89 e5                	mov    %esp,%ebp
801068a4:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801068a7:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801068ae:	00 
801068af:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801068b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068bd:	e8 07 f2 ff ff       	call   80105ac9 <argptr>
801068c2:	85 c0                	test   %eax,%eax
801068c4:	79 0a                	jns    801068d0 <sys_pipe+0x2f>
    return -1;
801068c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cb:	e9 9b 00 00 00       	jmp    8010696b <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801068d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801068d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801068d7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801068da:	89 04 24             	mov    %eax,(%esp)
801068dd:	e8 4c d6 ff ff       	call   80103f2e <pipealloc>
801068e2:	85 c0                	test   %eax,%eax
801068e4:	79 07                	jns    801068ed <sys_pipe+0x4c>
    return -1;
801068e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068eb:	eb 7e                	jmp    8010696b <sys_pipe+0xca>
  fd0 = -1;
801068ed:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801068f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068f7:	89 04 24             	mov    %eax,(%esp)
801068fa:	e8 67 f3 ff ff       	call   80105c66 <fdalloc>
801068ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106902:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106906:	78 14                	js     8010691c <sys_pipe+0x7b>
80106908:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010690b:	89 04 24             	mov    %eax,(%esp)
8010690e:	e8 53 f3 ff ff       	call   80105c66 <fdalloc>
80106913:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106916:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010691a:	79 37                	jns    80106953 <sys_pipe+0xb2>
    if(fd0 >= 0)
8010691c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106920:	78 14                	js     80106936 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106922:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106928:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010692b:	83 c2 08             	add    $0x8,%edx
8010692e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106935:	00 
    fileclose(rf);
80106936:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106939:	89 04 24             	mov    %eax,(%esp)
8010693c:	e8 9a a6 ff ff       	call   80100fdb <fileclose>
    fileclose(wf);
80106941:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106944:	89 04 24             	mov    %eax,(%esp)
80106947:	e8 8f a6 ff ff       	call   80100fdb <fileclose>
    return -1;
8010694c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106951:	eb 18                	jmp    8010696b <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106953:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106956:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106959:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010695b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010695e:	8d 50 04             	lea    0x4(%eax),%edx
80106961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106964:	89 02                	mov    %eax,(%edx)
  return 0;
80106966:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010696b:	c9                   	leave  
8010696c:	c3                   	ret    

8010696d <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010696d:	55                   	push   %ebp
8010696e:	89 e5                	mov    %esp,%ebp
80106970:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106973:	e8 dc dc ff ff       	call   80104654 <fork>
}
80106978:	c9                   	leave  
80106979:	c3                   	ret    

8010697a <sys_exit>:

int
sys_exit(void)
{
8010697a:	55                   	push   %ebp
8010697b:	89 e5                	mov    %esp,%ebp
8010697d:	83 ec 08             	sub    $0x8,%esp
  exit();
80106980:	e8 6f de ff ff       	call   801047f4 <exit>
  return 0;  // not reached
80106985:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010698a:	c9                   	leave  
8010698b:	c3                   	ret    

8010698c <sys_wait>:

int
sys_wait(void)
{
8010698c:	55                   	push   %ebp
8010698d:	89 e5                	mov    %esp,%ebp
8010698f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106992:	e8 a2 df ff ff       	call   80104939 <wait>
}
80106997:	c9                   	leave  
80106998:	c3                   	ret    

80106999 <sys_kill>:

int
sys_kill(void)
{
80106999:	55                   	push   %ebp
8010699a:	89 e5                	mov    %esp,%ebp
8010699c:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010699f:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801069a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069ad:	e8 e9 f0 ff ff       	call   80105a9b <argint>
801069b2:	85 c0                	test   %eax,%eax
801069b4:	79 07                	jns    801069bd <sys_kill+0x24>
    return -1;
801069b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069bb:	eb 0b                	jmp    801069c8 <sys_kill+0x2f>
  return kill(pid);
801069bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c0:	89 04 24             	mov    %eax,(%esp)
801069c3:	e8 ae e4 ff ff       	call   80104e76 <kill>
}
801069c8:	c9                   	leave  
801069c9:	c3                   	ret    

801069ca <sys_getpid>:

int
sys_getpid(void)
{
801069ca:	55                   	push   %ebp
801069cb:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801069cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069d3:	8b 40 10             	mov    0x10(%eax),%eax
}
801069d6:	5d                   	pop    %ebp
801069d7:	c3                   	ret    

801069d8 <sys_sbrk>:

int
sys_sbrk(void)
{
801069d8:	55                   	push   %ebp
801069d9:	89 e5                	mov    %esp,%ebp
801069db:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801069de:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801069e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069ec:	e8 aa f0 ff ff       	call   80105a9b <argint>
801069f1:	85 c0                	test   %eax,%eax
801069f3:	79 07                	jns    801069fc <sys_sbrk+0x24>
    return -1;
801069f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069fa:	eb 24                	jmp    80106a20 <sys_sbrk+0x48>
  addr = proc->sz;
801069fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a02:	8b 00                	mov    (%eax),%eax
80106a04:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a0a:	89 04 24             	mov    %eax,(%esp)
80106a0d:	e8 9d db ff ff       	call   801045af <growproc>
80106a12:	85 c0                	test   %eax,%eax
80106a14:	79 07                	jns    80106a1d <sys_sbrk+0x45>
    return -1;
80106a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a1b:	eb 03                	jmp    80106a20 <sys_sbrk+0x48>
  return addr;
80106a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a20:	c9                   	leave  
80106a21:	c3                   	ret    

80106a22 <sys_sleep>:

int
sys_sleep(void)
{
80106a22:	55                   	push   %ebp
80106a23:	89 e5                	mov    %esp,%ebp
80106a25:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106a28:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a36:	e8 60 f0 ff ff       	call   80105a9b <argint>
80106a3b:	85 c0                	test   %eax,%eax
80106a3d:	79 07                	jns    80106a46 <sys_sleep+0x24>
    return -1;
80106a3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a44:	eb 6c                	jmp    80106ab2 <sys_sleep+0x90>
  acquire(&tickslock);
80106a46:	c7 04 24 c0 a1 11 80 	movl   $0x8011a1c0,(%esp)
80106a4d:	e8 b3 ea ff ff       	call   80105505 <acquire>
  ticks0 = ticks;
80106a52:	a1 00 aa 11 80       	mov    0x8011aa00,%eax
80106a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106a5a:	eb 34                	jmp    80106a90 <sys_sleep+0x6e>
    if(proc->killed){
80106a5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a62:	8b 40 24             	mov    0x24(%eax),%eax
80106a65:	85 c0                	test   %eax,%eax
80106a67:	74 13                	je     80106a7c <sys_sleep+0x5a>
      release(&tickslock);
80106a69:	c7 04 24 c0 a1 11 80 	movl   $0x8011a1c0,(%esp)
80106a70:	e8 f2 ea ff ff       	call   80105567 <release>
      return -1;
80106a75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a7a:	eb 36                	jmp    80106ab2 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106a7c:	c7 44 24 04 c0 a1 11 	movl   $0x8011a1c0,0x4(%esp)
80106a83:	80 
80106a84:	c7 04 24 00 aa 11 80 	movl   $0x8011aa00,(%esp)
80106a8b:	e8 c1 e2 ff ff       	call   80104d51 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106a90:	a1 00 aa 11 80       	mov    0x8011aa00,%eax
80106a95:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106a98:	89 c2                	mov    %eax,%edx
80106a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a9d:	39 c2                	cmp    %eax,%edx
80106a9f:	72 bb                	jb     80106a5c <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106aa1:	c7 04 24 c0 a1 11 80 	movl   $0x8011a1c0,(%esp)
80106aa8:	e8 ba ea ff ff       	call   80105567 <release>
  return 0;
80106aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ab2:	c9                   	leave  
80106ab3:	c3                   	ret    

80106ab4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106ab4:	55                   	push   %ebp
80106ab5:	89 e5                	mov    %esp,%ebp
80106ab7:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106aba:	c7 04 24 c0 a1 11 80 	movl   $0x8011a1c0,(%esp)
80106ac1:	e8 3f ea ff ff       	call   80105505 <acquire>
  xticks = ticks;
80106ac6:	a1 00 aa 11 80       	mov    0x8011aa00,%eax
80106acb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106ace:	c7 04 24 c0 a1 11 80 	movl   $0x8011a1c0,(%esp)
80106ad5:	e8 8d ea ff ff       	call   80105567 <release>
  return xticks;
80106ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106add:	c9                   	leave  
80106ade:	c3                   	ret    

80106adf <sys_sigset>:

int
sys_sigset(void)
{
80106adf:	55                   	push   %ebp
80106ae0:	89 e5                	mov    %esp,%ebp
80106ae2:	83 ec 28             	sub    $0x28,%esp
  sig_handler new_handler;

  if(argptr(0, (char**)&new_handler, sizeof(sig_handler)) < 0)
80106ae5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106aec:	00 
80106aed:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106af0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106af4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106afb:	e8 c9 ef ff ff       	call   80105ac9 <argptr>
80106b00:	85 c0                	test   %eax,%eax
80106b02:	79 07                	jns    80106b0b <sys_sigset+0x2c>
    return -1;
80106b04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b09:	eb 0b                	jmp    80106b16 <sys_sigset+0x37>
  return (int) sigset(new_handler);
80106b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b0e:	89 04 24             	mov    %eax,(%esp)
80106b11:	e8 eb e4 ff ff       	call   80105001 <sigset>
}
80106b16:	c9                   	leave  
80106b17:	c3                   	ret    

80106b18 <sys_sigsend>:

int
sys_sigsend(void)
{
80106b18:	55                   	push   %ebp
80106b19:	89 e5                	mov    %esp,%ebp
80106b1b:	83 ec 28             	sub    $0x28,%esp
  int dest_pid;
  int value;

  if(argint(0, &dest_pid) < 0 || argint(1, &value) < 0)
80106b1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b21:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b2c:	e8 6a ef ff ff       	call   80105a9b <argint>
80106b31:	85 c0                	test   %eax,%eax
80106b33:	78 17                	js     80106b4c <sys_sigsend+0x34>
80106b35:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b38:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b43:	e8 53 ef ff ff       	call   80105a9b <argint>
80106b48:	85 c0                	test   %eax,%eax
80106b4a:	79 07                	jns    80106b53 <sys_sigsend+0x3b>
    return -1;
80106b4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b51:	eb 12                	jmp    80106b65 <sys_sigsend+0x4d>
  return sigsend(dest_pid, value);
80106b53:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b59:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b5d:	89 04 24             	mov    %eax,(%esp)
80106b60:	e8 bf e4 ff ff       	call   80105024 <sigsend>
}
80106b65:	c9                   	leave  
80106b66:	c3                   	ret    

80106b67 <sys_sigret>:

int
sys_sigret(void)
{
80106b67:	55                   	push   %ebp
80106b68:	89 e5                	mov    %esp,%ebp
80106b6a:	83 ec 08             	sub    $0x8,%esp
  return sigret();
80106b6d:	e8 2a e5 ff ff       	call   8010509c <sigret>
}
80106b72:	c9                   	leave  
80106b73:	c3                   	ret    

80106b74 <sys_sigpause>:

int
sys_sigpause(void)
{
80106b74:	55                   	push   %ebp
80106b75:	89 e5                	mov    %esp,%ebp
80106b77:	83 ec 08             	sub    $0x8,%esp
  return sigpause();
80106b7a:	e8 7c e5 ff ff       	call   801050fb <sigpause>
}
80106b7f:	c9                   	leave  
80106b80:	c3                   	ret    

80106b81 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b81:	55                   	push   %ebp
80106b82:	89 e5                	mov    %esp,%ebp
80106b84:	83 ec 08             	sub    $0x8,%esp
80106b87:	8b 55 08             	mov    0x8(%ebp),%edx
80106b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b8d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b91:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b94:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b98:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b9c:	ee                   	out    %al,(%dx)
}
80106b9d:	c9                   	leave  
80106b9e:	c3                   	ret    

80106b9f <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106b9f:	55                   	push   %ebp
80106ba0:	89 e5                	mov    %esp,%ebp
80106ba2:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106ba5:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106bac:	00 
80106bad:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106bb4:	e8 c8 ff ff ff       	call   80106b81 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106bb9:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106bc0:	00 
80106bc1:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106bc8:	e8 b4 ff ff ff       	call   80106b81 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106bcd:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106bd4:	00 
80106bd5:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106bdc:	e8 a0 ff ff ff       	call   80106b81 <outb>
  picenable(IRQ_TIMER);
80106be1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106be8:	e8 d4 d1 ff ff       	call   80103dc1 <picenable>
}
80106bed:	c9                   	leave  
80106bee:	c3                   	ret    

80106bef <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106bef:	1e                   	push   %ds
  pushl %es
80106bf0:	06                   	push   %es
  pushl %fs
80106bf1:	0f a0                	push   %fs
  pushl %gs
80106bf3:	0f a8                	push   %gs
  pushal
80106bf5:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106bf6:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106bfa:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106bfc:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106bfe:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106c02:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106c04:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106c06:	54                   	push   %esp
  call trap
80106c07:	e8 dd 01 00 00       	call   80106de9 <trap>
  addl $4, %esp
80106c0c:	83 c4 04             	add    $0x4,%esp

80106c0f <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  call fix_tf
80106c0f:	e8 f1 e6 ff ff       	call   80105305 <fix_tf>
  popal
80106c14:	61                   	popa   
  popl %gs
80106c15:	0f a9                	pop    %gs
  popl %fs
80106c17:	0f a1                	pop    %fs
  popl %es
80106c19:	07                   	pop    %es
  popl %ds
80106c1a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106c1b:	83 c4 08             	add    $0x8,%esp
  iret
80106c1e:	cf                   	iret   

80106c1f <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106c1f:	55                   	push   %ebp
80106c20:	89 e5                	mov    %esp,%ebp
80106c22:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c28:	83 e8 01             	sub    $0x1,%eax
80106c2b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80106c32:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106c36:	8b 45 08             	mov    0x8(%ebp),%eax
80106c39:	c1 e8 10             	shr    $0x10,%eax
80106c3c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106c40:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106c43:	0f 01 18             	lidtl  (%eax)
}
80106c46:	c9                   	leave  
80106c47:	c3                   	ret    

80106c48 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106c48:	55                   	push   %ebp
80106c49:	89 e5                	mov    %esp,%ebp
80106c4b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106c4e:	0f 20 d0             	mov    %cr2,%eax
80106c51:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106c54:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106c57:	c9                   	leave  
80106c58:	c3                   	ret    

80106c59 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106c59:	55                   	push   %ebp
80106c5a:	89 e5                	mov    %esp,%ebp
80106c5c:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106c5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c66:	e9 c3 00 00 00       	jmp    80106d2e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c6e:	8b 04 85 e8 c0 10 80 	mov    -0x7fef3f18(,%eax,4),%eax
80106c75:	89 c2                	mov    %eax,%edx
80106c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c7a:	66 89 14 c5 00 a2 11 	mov    %dx,-0x7fee5e00(,%eax,8)
80106c81:	80 
80106c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c85:	66 c7 04 c5 02 a2 11 	movw   $0x8,-0x7fee5dfe(,%eax,8)
80106c8c:	80 08 00 
80106c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c92:	0f b6 14 c5 04 a2 11 	movzbl -0x7fee5dfc(,%eax,8),%edx
80106c99:	80 
80106c9a:	83 e2 e0             	and    $0xffffffe0,%edx
80106c9d:	88 14 c5 04 a2 11 80 	mov    %dl,-0x7fee5dfc(,%eax,8)
80106ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca7:	0f b6 14 c5 04 a2 11 	movzbl -0x7fee5dfc(,%eax,8),%edx
80106cae:	80 
80106caf:	83 e2 1f             	and    $0x1f,%edx
80106cb2:	88 14 c5 04 a2 11 80 	mov    %dl,-0x7fee5dfc(,%eax,8)
80106cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cbc:	0f b6 14 c5 05 a2 11 	movzbl -0x7fee5dfb(,%eax,8),%edx
80106cc3:	80 
80106cc4:	83 e2 f0             	and    $0xfffffff0,%edx
80106cc7:	83 ca 0e             	or     $0xe,%edx
80106cca:	88 14 c5 05 a2 11 80 	mov    %dl,-0x7fee5dfb(,%eax,8)
80106cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cd4:	0f b6 14 c5 05 a2 11 	movzbl -0x7fee5dfb(,%eax,8),%edx
80106cdb:	80 
80106cdc:	83 e2 ef             	and    $0xffffffef,%edx
80106cdf:	88 14 c5 05 a2 11 80 	mov    %dl,-0x7fee5dfb(,%eax,8)
80106ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ce9:	0f b6 14 c5 05 a2 11 	movzbl -0x7fee5dfb(,%eax,8),%edx
80106cf0:	80 
80106cf1:	83 e2 9f             	and    $0xffffff9f,%edx
80106cf4:	88 14 c5 05 a2 11 80 	mov    %dl,-0x7fee5dfb(,%eax,8)
80106cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cfe:	0f b6 14 c5 05 a2 11 	movzbl -0x7fee5dfb(,%eax,8),%edx
80106d05:	80 
80106d06:	83 ca 80             	or     $0xffffff80,%edx
80106d09:	88 14 c5 05 a2 11 80 	mov    %dl,-0x7fee5dfb(,%eax,8)
80106d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d13:	8b 04 85 e8 c0 10 80 	mov    -0x7fef3f18(,%eax,4),%eax
80106d1a:	c1 e8 10             	shr    $0x10,%eax
80106d1d:	89 c2                	mov    %eax,%edx
80106d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d22:	66 89 14 c5 06 a2 11 	mov    %dx,-0x7fee5dfa(,%eax,8)
80106d29:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106d2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d2e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106d35:	0f 8e 30 ff ff ff    	jle    80106c6b <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106d3b:	a1 e8 c1 10 80       	mov    0x8010c1e8,%eax
80106d40:	66 a3 00 a4 11 80    	mov    %ax,0x8011a400
80106d46:	66 c7 05 02 a4 11 80 	movw   $0x8,0x8011a402
80106d4d:	08 00 
80106d4f:	0f b6 05 04 a4 11 80 	movzbl 0x8011a404,%eax
80106d56:	83 e0 e0             	and    $0xffffffe0,%eax
80106d59:	a2 04 a4 11 80       	mov    %al,0x8011a404
80106d5e:	0f b6 05 04 a4 11 80 	movzbl 0x8011a404,%eax
80106d65:	83 e0 1f             	and    $0x1f,%eax
80106d68:	a2 04 a4 11 80       	mov    %al,0x8011a404
80106d6d:	0f b6 05 05 a4 11 80 	movzbl 0x8011a405,%eax
80106d74:	83 c8 0f             	or     $0xf,%eax
80106d77:	a2 05 a4 11 80       	mov    %al,0x8011a405
80106d7c:	0f b6 05 05 a4 11 80 	movzbl 0x8011a405,%eax
80106d83:	83 e0 ef             	and    $0xffffffef,%eax
80106d86:	a2 05 a4 11 80       	mov    %al,0x8011a405
80106d8b:	0f b6 05 05 a4 11 80 	movzbl 0x8011a405,%eax
80106d92:	83 c8 60             	or     $0x60,%eax
80106d95:	a2 05 a4 11 80       	mov    %al,0x8011a405
80106d9a:	0f b6 05 05 a4 11 80 	movzbl 0x8011a405,%eax
80106da1:	83 c8 80             	or     $0xffffff80,%eax
80106da4:	a2 05 a4 11 80       	mov    %al,0x8011a405
80106da9:	a1 e8 c1 10 80       	mov    0x8010c1e8,%eax
80106dae:	c1 e8 10             	shr    $0x10,%eax
80106db1:	66 a3 06 a4 11 80    	mov    %ax,0x8011a406
  
  initlock(&tickslock, "time");
80106db7:	c7 44 24 04 e0 8f 10 	movl   $0x80108fe0,0x4(%esp)
80106dbe:	80 
80106dbf:	c7 04 24 c0 a1 11 80 	movl   $0x8011a1c0,(%esp)
80106dc6:	e8 19 e7 ff ff       	call   801054e4 <initlock>
}
80106dcb:	c9                   	leave  
80106dcc:	c3                   	ret    

80106dcd <idtinit>:

void
idtinit(void)
{
80106dcd:	55                   	push   %ebp
80106dce:	89 e5                	mov    %esp,%ebp
80106dd0:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106dd3:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106dda:	00 
80106ddb:	c7 04 24 00 a2 11 80 	movl   $0x8011a200,(%esp)
80106de2:	e8 38 fe ff ff       	call   80106c1f <lidt>
}
80106de7:	c9                   	leave  
80106de8:	c3                   	ret    

80106de9 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106de9:	55                   	push   %ebp
80106dea:	89 e5                	mov    %esp,%ebp
80106dec:	57                   	push   %edi
80106ded:	56                   	push   %esi
80106dee:	53                   	push   %ebx
80106def:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106df2:	8b 45 08             	mov    0x8(%ebp),%eax
80106df5:	8b 40 30             	mov    0x30(%eax),%eax
80106df8:	83 f8 40             	cmp    $0x40,%eax
80106dfb:	75 3f                	jne    80106e3c <trap+0x53>
    if(proc->killed)
80106dfd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e03:	8b 40 24             	mov    0x24(%eax),%eax
80106e06:	85 c0                	test   %eax,%eax
80106e08:	74 05                	je     80106e0f <trap+0x26>
      exit();
80106e0a:	e8 e5 d9 ff ff       	call   801047f4 <exit>
    proc->tf = tf;
80106e0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e15:	8b 55 08             	mov    0x8(%ebp),%edx
80106e18:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106e1b:	e8 42 ed ff ff       	call   80105b62 <syscall>
    if(proc->killed)
80106e20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e26:	8b 40 24             	mov    0x24(%eax),%eax
80106e29:	85 c0                	test   %eax,%eax
80106e2b:	74 0a                	je     80106e37 <trap+0x4e>
      exit();
80106e2d:	e8 c2 d9 ff ff       	call   801047f4 <exit>
    return;
80106e32:	e9 2d 02 00 00       	jmp    80107064 <trap+0x27b>
80106e37:	e9 28 02 00 00       	jmp    80107064 <trap+0x27b>
  }

  switch(tf->trapno){
80106e3c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e3f:	8b 40 30             	mov    0x30(%eax),%eax
80106e42:	83 e8 20             	sub    $0x20,%eax
80106e45:	83 f8 1f             	cmp    $0x1f,%eax
80106e48:	0f 87 bc 00 00 00    	ja     80106f0a <trap+0x121>
80106e4e:	8b 04 85 88 90 10 80 	mov    -0x7fef6f78(,%eax,4),%eax
80106e55:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106e57:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e5d:	0f b6 00             	movzbl (%eax),%eax
80106e60:	84 c0                	test   %al,%al
80106e62:	75 31                	jne    80106e95 <trap+0xac>
      acquire(&tickslock);
80106e64:	c7 04 24 c0 a1 11 80 	movl   $0x8011a1c0,(%esp)
80106e6b:	e8 95 e6 ff ff       	call   80105505 <acquire>
      ticks++;
80106e70:	a1 00 aa 11 80       	mov    0x8011aa00,%eax
80106e75:	83 c0 01             	add    $0x1,%eax
80106e78:	a3 00 aa 11 80       	mov    %eax,0x8011aa00
      wakeup(&ticks);
80106e7d:	c7 04 24 00 aa 11 80 	movl   $0x8011aa00,(%esp)
80106e84:	e8 d0 df ff ff       	call   80104e59 <wakeup>
      release(&tickslock);
80106e89:	c7 04 24 c0 a1 11 80 	movl   $0x8011a1c0,(%esp)
80106e90:	e8 d2 e6 ff ff       	call   80105567 <release>
    }
    lapiceoi();
80106e95:	e8 43 c0 ff ff       	call   80102edd <lapiceoi>
    break;
80106e9a:	e9 41 01 00 00       	jmp    80106fe0 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106e9f:	e8 47 b8 ff ff       	call   801026eb <ideintr>
    lapiceoi();
80106ea4:	e8 34 c0 ff ff       	call   80102edd <lapiceoi>
    break;
80106ea9:	e9 32 01 00 00       	jmp    80106fe0 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106eae:	e8 f9 bd ff ff       	call   80102cac <kbdintr>
    lapiceoi();
80106eb3:	e8 25 c0 ff ff       	call   80102edd <lapiceoi>
    break;
80106eb8:	e9 23 01 00 00       	jmp    80106fe0 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106ebd:	e8 97 03 00 00       	call   80107259 <uartintr>
    lapiceoi();
80106ec2:	e8 16 c0 ff ff       	call   80102edd <lapiceoi>
    break;
80106ec7:	e9 14 01 00 00       	jmp    80106fe0 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80106ecf:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ed9:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106edc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ee2:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ee5:	0f b6 c0             	movzbl %al,%eax
80106ee8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106eec:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ef4:	c7 04 24 e8 8f 10 80 	movl   $0x80108fe8,(%esp)
80106efb:	e8 a0 94 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106f00:	e8 d8 bf ff ff       	call   80102edd <lapiceoi>
    break;
80106f05:	e9 d6 00 00 00       	jmp    80106fe0 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106f0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f10:	85 c0                	test   %eax,%eax
80106f12:	74 11                	je     80106f25 <trap+0x13c>
80106f14:	8b 45 08             	mov    0x8(%ebp),%eax
80106f17:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f1b:	0f b7 c0             	movzwl %ax,%eax
80106f1e:	83 e0 03             	and    $0x3,%eax
80106f21:	85 c0                	test   %eax,%eax
80106f23:	75 46                	jne    80106f6b <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106f25:	e8 1e fd ff ff       	call   80106c48 <rcr2>
80106f2a:	8b 55 08             	mov    0x8(%ebp),%edx
80106f2d:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106f30:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106f37:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106f3a:	0f b6 ca             	movzbl %dl,%ecx
80106f3d:	8b 55 08             	mov    0x8(%ebp),%edx
80106f40:	8b 52 30             	mov    0x30(%edx),%edx
80106f43:	89 44 24 10          	mov    %eax,0x10(%esp)
80106f47:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106f4b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106f4f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f53:	c7 04 24 0c 90 10 80 	movl   $0x8010900c,(%esp)
80106f5a:	e8 41 94 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106f5f:	c7 04 24 3e 90 10 80 	movl   $0x8010903e,(%esp)
80106f66:	e8 cf 95 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f6b:	e8 d8 fc ff ff       	call   80106c48 <rcr2>
80106f70:	89 c2                	mov    %eax,%edx
80106f72:	8b 45 08             	mov    0x8(%ebp),%eax
80106f75:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106f78:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106f7e:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f81:	0f b6 f0             	movzbl %al,%esi
80106f84:	8b 45 08             	mov    0x8(%ebp),%eax
80106f87:	8b 58 34             	mov    0x34(%eax),%ebx
80106f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f8d:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106f90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f96:	83 c0 6c             	add    $0x6c,%eax
80106f99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106f9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106fa2:	8b 40 10             	mov    0x10(%eax),%eax
80106fa5:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106fa9:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106fad:	89 74 24 14          	mov    %esi,0x14(%esp)
80106fb1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106fb5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106fb9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106fbc:	89 74 24 08          	mov    %esi,0x8(%esp)
80106fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fc4:	c7 04 24 44 90 10 80 	movl   $0x80109044,(%esp)
80106fcb:	e8 d0 93 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106fd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fd6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106fdd:	eb 01                	jmp    80106fe0 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106fdf:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106fe0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fe6:	85 c0                	test   %eax,%eax
80106fe8:	74 24                	je     8010700e <trap+0x225>
80106fea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ff0:	8b 40 24             	mov    0x24(%eax),%eax
80106ff3:	85 c0                	test   %eax,%eax
80106ff5:	74 17                	je     8010700e <trap+0x225>
80106ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80106ffa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ffe:	0f b7 c0             	movzwl %ax,%eax
80107001:	83 e0 03             	and    $0x3,%eax
80107004:	83 f8 03             	cmp    $0x3,%eax
80107007:	75 05                	jne    8010700e <trap+0x225>
    exit();
80107009:	e8 e6 d7 ff ff       	call   801047f4 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
8010700e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107014:	85 c0                	test   %eax,%eax
80107016:	74 1e                	je     80107036 <trap+0x24d>
80107018:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010701e:	8b 40 0c             	mov    0xc(%eax),%eax
80107021:	83 f8 04             	cmp    $0x4,%eax
80107024:	75 10                	jne    80107036 <trap+0x24d>
80107026:	8b 45 08             	mov    0x8(%ebp),%eax
80107029:	8b 40 30             	mov    0x30(%eax),%eax
8010702c:	83 f8 20             	cmp    $0x20,%eax
8010702f:	75 05                	jne    80107036 <trap+0x24d>
    yield();
80107031:	e8 be dc ff ff       	call   80104cf4 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107036:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010703c:	85 c0                	test   %eax,%eax
8010703e:	74 24                	je     80107064 <trap+0x27b>
80107040:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107046:	8b 40 24             	mov    0x24(%eax),%eax
80107049:	85 c0                	test   %eax,%eax
8010704b:	74 17                	je     80107064 <trap+0x27b>
8010704d:	8b 45 08             	mov    0x8(%ebp),%eax
80107050:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107054:	0f b7 c0             	movzwl %ax,%eax
80107057:	83 e0 03             	and    $0x3,%eax
8010705a:	83 f8 03             	cmp    $0x3,%eax
8010705d:	75 05                	jne    80107064 <trap+0x27b>
    exit();
8010705f:	e8 90 d7 ff ff       	call   801047f4 <exit>
}
80107064:	83 c4 3c             	add    $0x3c,%esp
80107067:	5b                   	pop    %ebx
80107068:	5e                   	pop    %esi
80107069:	5f                   	pop    %edi
8010706a:	5d                   	pop    %ebp
8010706b:	c3                   	ret    

8010706c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010706c:	55                   	push   %ebp
8010706d:	89 e5                	mov    %esp,%ebp
8010706f:	83 ec 14             	sub    $0x14,%esp
80107072:	8b 45 08             	mov    0x8(%ebp),%eax
80107075:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107079:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010707d:	89 c2                	mov    %eax,%edx
8010707f:	ec                   	in     (%dx),%al
80107080:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107083:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107087:	c9                   	leave  
80107088:	c3                   	ret    

80107089 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107089:	55                   	push   %ebp
8010708a:	89 e5                	mov    %esp,%ebp
8010708c:	83 ec 08             	sub    $0x8,%esp
8010708f:	8b 55 08             	mov    0x8(%ebp),%edx
80107092:	8b 45 0c             	mov    0xc(%ebp),%eax
80107095:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107099:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010709c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801070a0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801070a4:	ee                   	out    %al,(%dx)
}
801070a5:	c9                   	leave  
801070a6:	c3                   	ret    

801070a7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801070a7:	55                   	push   %ebp
801070a8:	89 e5                	mov    %esp,%ebp
801070aa:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801070ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801070b4:	00 
801070b5:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801070bc:	e8 c8 ff ff ff       	call   80107089 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801070c1:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801070c8:	00 
801070c9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801070d0:	e8 b4 ff ff ff       	call   80107089 <outb>
  outb(COM1+0, 115200/9600);
801070d5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801070dc:	00 
801070dd:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801070e4:	e8 a0 ff ff ff       	call   80107089 <outb>
  outb(COM1+1, 0);
801070e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801070f0:	00 
801070f1:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801070f8:	e8 8c ff ff ff       	call   80107089 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801070fd:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107104:	00 
80107105:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010710c:	e8 78 ff ff ff       	call   80107089 <outb>
  outb(COM1+4, 0);
80107111:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107118:	00 
80107119:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107120:	e8 64 ff ff ff       	call   80107089 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107125:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010712c:	00 
8010712d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107134:	e8 50 ff ff ff       	call   80107089 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107139:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107140:	e8 27 ff ff ff       	call   8010706c <inb>
80107145:	3c ff                	cmp    $0xff,%al
80107147:	75 02                	jne    8010714b <uartinit+0xa4>
    return;
80107149:	eb 6a                	jmp    801071b5 <uartinit+0x10e>
  uart = 1;
8010714b:	c7 05 ac c6 10 80 01 	movl   $0x1,0x8010c6ac
80107152:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107155:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010715c:	e8 0b ff ff ff       	call   8010706c <inb>
  inb(COM1+0);
80107161:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107168:	e8 ff fe ff ff       	call   8010706c <inb>
  picenable(IRQ_COM1);
8010716d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107174:	e8 48 cc ff ff       	call   80103dc1 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107179:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107180:	00 
80107181:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107188:	e8 dd b7 ff ff       	call   8010296a <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010718d:	c7 45 f4 08 91 10 80 	movl   $0x80109108,-0xc(%ebp)
80107194:	eb 15                	jmp    801071ab <uartinit+0x104>
    uartputc(*p);
80107196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107199:	0f b6 00             	movzbl (%eax),%eax
8010719c:	0f be c0             	movsbl %al,%eax
8010719f:	89 04 24             	mov    %eax,(%esp)
801071a2:	e8 10 00 00 00       	call   801071b7 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801071a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801071ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ae:	0f b6 00             	movzbl (%eax),%eax
801071b1:	84 c0                	test   %al,%al
801071b3:	75 e1                	jne    80107196 <uartinit+0xef>
    uartputc(*p);
}
801071b5:	c9                   	leave  
801071b6:	c3                   	ret    

801071b7 <uartputc>:

void
uartputc(int c)
{
801071b7:	55                   	push   %ebp
801071b8:	89 e5                	mov    %esp,%ebp
801071ba:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801071bd:	a1 ac c6 10 80       	mov    0x8010c6ac,%eax
801071c2:	85 c0                	test   %eax,%eax
801071c4:	75 02                	jne    801071c8 <uartputc+0x11>
    return;
801071c6:	eb 4b                	jmp    80107213 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801071c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801071cf:	eb 10                	jmp    801071e1 <uartputc+0x2a>
    microdelay(10);
801071d1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801071d8:	e8 25 bd ff ff       	call   80102f02 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801071dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801071e1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801071e5:	7f 16                	jg     801071fd <uartputc+0x46>
801071e7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801071ee:	e8 79 fe ff ff       	call   8010706c <inb>
801071f3:	0f b6 c0             	movzbl %al,%eax
801071f6:	83 e0 20             	and    $0x20,%eax
801071f9:	85 c0                	test   %eax,%eax
801071fb:	74 d4                	je     801071d1 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801071fd:	8b 45 08             	mov    0x8(%ebp),%eax
80107200:	0f b6 c0             	movzbl %al,%eax
80107203:	89 44 24 04          	mov    %eax,0x4(%esp)
80107207:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010720e:	e8 76 fe ff ff       	call   80107089 <outb>
}
80107213:	c9                   	leave  
80107214:	c3                   	ret    

80107215 <uartgetc>:

static int
uartgetc(void)
{
80107215:	55                   	push   %ebp
80107216:	89 e5                	mov    %esp,%ebp
80107218:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010721b:	a1 ac c6 10 80       	mov    0x8010c6ac,%eax
80107220:	85 c0                	test   %eax,%eax
80107222:	75 07                	jne    8010722b <uartgetc+0x16>
    return -1;
80107224:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107229:	eb 2c                	jmp    80107257 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010722b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107232:	e8 35 fe ff ff       	call   8010706c <inb>
80107237:	0f b6 c0             	movzbl %al,%eax
8010723a:	83 e0 01             	and    $0x1,%eax
8010723d:	85 c0                	test   %eax,%eax
8010723f:	75 07                	jne    80107248 <uartgetc+0x33>
    return -1;
80107241:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107246:	eb 0f                	jmp    80107257 <uartgetc+0x42>
  return inb(COM1+0);
80107248:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010724f:	e8 18 fe ff ff       	call   8010706c <inb>
80107254:	0f b6 c0             	movzbl %al,%eax
}
80107257:	c9                   	leave  
80107258:	c3                   	ret    

80107259 <uartintr>:

void
uartintr(void)
{
80107259:	55                   	push   %ebp
8010725a:	89 e5                	mov    %esp,%ebp
8010725c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010725f:	c7 04 24 15 72 10 80 	movl   $0x80107215,(%esp)
80107266:	e8 42 95 ff ff       	call   801007ad <consoleintr>
}
8010726b:	c9                   	leave  
8010726c:	c3                   	ret    

8010726d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $0
8010726f:	6a 00                	push   $0x0
  jmp alltraps
80107271:	e9 79 f9 ff ff       	jmp    80106bef <alltraps>

80107276 <vector1>:
.globl vector1
vector1:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $1
80107278:	6a 01                	push   $0x1
  jmp alltraps
8010727a:	e9 70 f9 ff ff       	jmp    80106bef <alltraps>

8010727f <vector2>:
.globl vector2
vector2:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $2
80107281:	6a 02                	push   $0x2
  jmp alltraps
80107283:	e9 67 f9 ff ff       	jmp    80106bef <alltraps>

80107288 <vector3>:
.globl vector3
vector3:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $3
8010728a:	6a 03                	push   $0x3
  jmp alltraps
8010728c:	e9 5e f9 ff ff       	jmp    80106bef <alltraps>

80107291 <vector4>:
.globl vector4
vector4:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $4
80107293:	6a 04                	push   $0x4
  jmp alltraps
80107295:	e9 55 f9 ff ff       	jmp    80106bef <alltraps>

8010729a <vector5>:
.globl vector5
vector5:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $5
8010729c:	6a 05                	push   $0x5
  jmp alltraps
8010729e:	e9 4c f9 ff ff       	jmp    80106bef <alltraps>

801072a3 <vector6>:
.globl vector6
vector6:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $6
801072a5:	6a 06                	push   $0x6
  jmp alltraps
801072a7:	e9 43 f9 ff ff       	jmp    80106bef <alltraps>

801072ac <vector7>:
.globl vector7
vector7:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $7
801072ae:	6a 07                	push   $0x7
  jmp alltraps
801072b0:	e9 3a f9 ff ff       	jmp    80106bef <alltraps>

801072b5 <vector8>:
.globl vector8
vector8:
  pushl $8
801072b5:	6a 08                	push   $0x8
  jmp alltraps
801072b7:	e9 33 f9 ff ff       	jmp    80106bef <alltraps>

801072bc <vector9>:
.globl vector9
vector9:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $9
801072be:	6a 09                	push   $0x9
  jmp alltraps
801072c0:	e9 2a f9 ff ff       	jmp    80106bef <alltraps>

801072c5 <vector10>:
.globl vector10
vector10:
  pushl $10
801072c5:	6a 0a                	push   $0xa
  jmp alltraps
801072c7:	e9 23 f9 ff ff       	jmp    80106bef <alltraps>

801072cc <vector11>:
.globl vector11
vector11:
  pushl $11
801072cc:	6a 0b                	push   $0xb
  jmp alltraps
801072ce:	e9 1c f9 ff ff       	jmp    80106bef <alltraps>

801072d3 <vector12>:
.globl vector12
vector12:
  pushl $12
801072d3:	6a 0c                	push   $0xc
  jmp alltraps
801072d5:	e9 15 f9 ff ff       	jmp    80106bef <alltraps>

801072da <vector13>:
.globl vector13
vector13:
  pushl $13
801072da:	6a 0d                	push   $0xd
  jmp alltraps
801072dc:	e9 0e f9 ff ff       	jmp    80106bef <alltraps>

801072e1 <vector14>:
.globl vector14
vector14:
  pushl $14
801072e1:	6a 0e                	push   $0xe
  jmp alltraps
801072e3:	e9 07 f9 ff ff       	jmp    80106bef <alltraps>

801072e8 <vector15>:
.globl vector15
vector15:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $15
801072ea:	6a 0f                	push   $0xf
  jmp alltraps
801072ec:	e9 fe f8 ff ff       	jmp    80106bef <alltraps>

801072f1 <vector16>:
.globl vector16
vector16:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $16
801072f3:	6a 10                	push   $0x10
  jmp alltraps
801072f5:	e9 f5 f8 ff ff       	jmp    80106bef <alltraps>

801072fa <vector17>:
.globl vector17
vector17:
  pushl $17
801072fa:	6a 11                	push   $0x11
  jmp alltraps
801072fc:	e9 ee f8 ff ff       	jmp    80106bef <alltraps>

80107301 <vector18>:
.globl vector18
vector18:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $18
80107303:	6a 12                	push   $0x12
  jmp alltraps
80107305:	e9 e5 f8 ff ff       	jmp    80106bef <alltraps>

8010730a <vector19>:
.globl vector19
vector19:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $19
8010730c:	6a 13                	push   $0x13
  jmp alltraps
8010730e:	e9 dc f8 ff ff       	jmp    80106bef <alltraps>

80107313 <vector20>:
.globl vector20
vector20:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $20
80107315:	6a 14                	push   $0x14
  jmp alltraps
80107317:	e9 d3 f8 ff ff       	jmp    80106bef <alltraps>

8010731c <vector21>:
.globl vector21
vector21:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $21
8010731e:	6a 15                	push   $0x15
  jmp alltraps
80107320:	e9 ca f8 ff ff       	jmp    80106bef <alltraps>

80107325 <vector22>:
.globl vector22
vector22:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $22
80107327:	6a 16                	push   $0x16
  jmp alltraps
80107329:	e9 c1 f8 ff ff       	jmp    80106bef <alltraps>

8010732e <vector23>:
.globl vector23
vector23:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $23
80107330:	6a 17                	push   $0x17
  jmp alltraps
80107332:	e9 b8 f8 ff ff       	jmp    80106bef <alltraps>

80107337 <vector24>:
.globl vector24
vector24:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $24
80107339:	6a 18                	push   $0x18
  jmp alltraps
8010733b:	e9 af f8 ff ff       	jmp    80106bef <alltraps>

80107340 <vector25>:
.globl vector25
vector25:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $25
80107342:	6a 19                	push   $0x19
  jmp alltraps
80107344:	e9 a6 f8 ff ff       	jmp    80106bef <alltraps>

80107349 <vector26>:
.globl vector26
vector26:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $26
8010734b:	6a 1a                	push   $0x1a
  jmp alltraps
8010734d:	e9 9d f8 ff ff       	jmp    80106bef <alltraps>

80107352 <vector27>:
.globl vector27
vector27:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $27
80107354:	6a 1b                	push   $0x1b
  jmp alltraps
80107356:	e9 94 f8 ff ff       	jmp    80106bef <alltraps>

8010735b <vector28>:
.globl vector28
vector28:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $28
8010735d:	6a 1c                	push   $0x1c
  jmp alltraps
8010735f:	e9 8b f8 ff ff       	jmp    80106bef <alltraps>

80107364 <vector29>:
.globl vector29
vector29:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $29
80107366:	6a 1d                	push   $0x1d
  jmp alltraps
80107368:	e9 82 f8 ff ff       	jmp    80106bef <alltraps>

8010736d <vector30>:
.globl vector30
vector30:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $30
8010736f:	6a 1e                	push   $0x1e
  jmp alltraps
80107371:	e9 79 f8 ff ff       	jmp    80106bef <alltraps>

80107376 <vector31>:
.globl vector31
vector31:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $31
80107378:	6a 1f                	push   $0x1f
  jmp alltraps
8010737a:	e9 70 f8 ff ff       	jmp    80106bef <alltraps>

8010737f <vector32>:
.globl vector32
vector32:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $32
80107381:	6a 20                	push   $0x20
  jmp alltraps
80107383:	e9 67 f8 ff ff       	jmp    80106bef <alltraps>

80107388 <vector33>:
.globl vector33
vector33:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $33
8010738a:	6a 21                	push   $0x21
  jmp alltraps
8010738c:	e9 5e f8 ff ff       	jmp    80106bef <alltraps>

80107391 <vector34>:
.globl vector34
vector34:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $34
80107393:	6a 22                	push   $0x22
  jmp alltraps
80107395:	e9 55 f8 ff ff       	jmp    80106bef <alltraps>

8010739a <vector35>:
.globl vector35
vector35:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $35
8010739c:	6a 23                	push   $0x23
  jmp alltraps
8010739e:	e9 4c f8 ff ff       	jmp    80106bef <alltraps>

801073a3 <vector36>:
.globl vector36
vector36:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $36
801073a5:	6a 24                	push   $0x24
  jmp alltraps
801073a7:	e9 43 f8 ff ff       	jmp    80106bef <alltraps>

801073ac <vector37>:
.globl vector37
vector37:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $37
801073ae:	6a 25                	push   $0x25
  jmp alltraps
801073b0:	e9 3a f8 ff ff       	jmp    80106bef <alltraps>

801073b5 <vector38>:
.globl vector38
vector38:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $38
801073b7:	6a 26                	push   $0x26
  jmp alltraps
801073b9:	e9 31 f8 ff ff       	jmp    80106bef <alltraps>

801073be <vector39>:
.globl vector39
vector39:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $39
801073c0:	6a 27                	push   $0x27
  jmp alltraps
801073c2:	e9 28 f8 ff ff       	jmp    80106bef <alltraps>

801073c7 <vector40>:
.globl vector40
vector40:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $40
801073c9:	6a 28                	push   $0x28
  jmp alltraps
801073cb:	e9 1f f8 ff ff       	jmp    80106bef <alltraps>

801073d0 <vector41>:
.globl vector41
vector41:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $41
801073d2:	6a 29                	push   $0x29
  jmp alltraps
801073d4:	e9 16 f8 ff ff       	jmp    80106bef <alltraps>

801073d9 <vector42>:
.globl vector42
vector42:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $42
801073db:	6a 2a                	push   $0x2a
  jmp alltraps
801073dd:	e9 0d f8 ff ff       	jmp    80106bef <alltraps>

801073e2 <vector43>:
.globl vector43
vector43:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $43
801073e4:	6a 2b                	push   $0x2b
  jmp alltraps
801073e6:	e9 04 f8 ff ff       	jmp    80106bef <alltraps>

801073eb <vector44>:
.globl vector44
vector44:
  pushl $0
801073eb:	6a 00                	push   $0x0
  pushl $44
801073ed:	6a 2c                	push   $0x2c
  jmp alltraps
801073ef:	e9 fb f7 ff ff       	jmp    80106bef <alltraps>

801073f4 <vector45>:
.globl vector45
vector45:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $45
801073f6:	6a 2d                	push   $0x2d
  jmp alltraps
801073f8:	e9 f2 f7 ff ff       	jmp    80106bef <alltraps>

801073fd <vector46>:
.globl vector46
vector46:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $46
801073ff:	6a 2e                	push   $0x2e
  jmp alltraps
80107401:	e9 e9 f7 ff ff       	jmp    80106bef <alltraps>

80107406 <vector47>:
.globl vector47
vector47:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $47
80107408:	6a 2f                	push   $0x2f
  jmp alltraps
8010740a:	e9 e0 f7 ff ff       	jmp    80106bef <alltraps>

8010740f <vector48>:
.globl vector48
vector48:
  pushl $0
8010740f:	6a 00                	push   $0x0
  pushl $48
80107411:	6a 30                	push   $0x30
  jmp alltraps
80107413:	e9 d7 f7 ff ff       	jmp    80106bef <alltraps>

80107418 <vector49>:
.globl vector49
vector49:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $49
8010741a:	6a 31                	push   $0x31
  jmp alltraps
8010741c:	e9 ce f7 ff ff       	jmp    80106bef <alltraps>

80107421 <vector50>:
.globl vector50
vector50:
  pushl $0
80107421:	6a 00                	push   $0x0
  pushl $50
80107423:	6a 32                	push   $0x32
  jmp alltraps
80107425:	e9 c5 f7 ff ff       	jmp    80106bef <alltraps>

8010742a <vector51>:
.globl vector51
vector51:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $51
8010742c:	6a 33                	push   $0x33
  jmp alltraps
8010742e:	e9 bc f7 ff ff       	jmp    80106bef <alltraps>

80107433 <vector52>:
.globl vector52
vector52:
  pushl $0
80107433:	6a 00                	push   $0x0
  pushl $52
80107435:	6a 34                	push   $0x34
  jmp alltraps
80107437:	e9 b3 f7 ff ff       	jmp    80106bef <alltraps>

8010743c <vector53>:
.globl vector53
vector53:
  pushl $0
8010743c:	6a 00                	push   $0x0
  pushl $53
8010743e:	6a 35                	push   $0x35
  jmp alltraps
80107440:	e9 aa f7 ff ff       	jmp    80106bef <alltraps>

80107445 <vector54>:
.globl vector54
vector54:
  pushl $0
80107445:	6a 00                	push   $0x0
  pushl $54
80107447:	6a 36                	push   $0x36
  jmp alltraps
80107449:	e9 a1 f7 ff ff       	jmp    80106bef <alltraps>

8010744e <vector55>:
.globl vector55
vector55:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $55
80107450:	6a 37                	push   $0x37
  jmp alltraps
80107452:	e9 98 f7 ff ff       	jmp    80106bef <alltraps>

80107457 <vector56>:
.globl vector56
vector56:
  pushl $0
80107457:	6a 00                	push   $0x0
  pushl $56
80107459:	6a 38                	push   $0x38
  jmp alltraps
8010745b:	e9 8f f7 ff ff       	jmp    80106bef <alltraps>

80107460 <vector57>:
.globl vector57
vector57:
  pushl $0
80107460:	6a 00                	push   $0x0
  pushl $57
80107462:	6a 39                	push   $0x39
  jmp alltraps
80107464:	e9 86 f7 ff ff       	jmp    80106bef <alltraps>

80107469 <vector58>:
.globl vector58
vector58:
  pushl $0
80107469:	6a 00                	push   $0x0
  pushl $58
8010746b:	6a 3a                	push   $0x3a
  jmp alltraps
8010746d:	e9 7d f7 ff ff       	jmp    80106bef <alltraps>

80107472 <vector59>:
.globl vector59
vector59:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $59
80107474:	6a 3b                	push   $0x3b
  jmp alltraps
80107476:	e9 74 f7 ff ff       	jmp    80106bef <alltraps>

8010747b <vector60>:
.globl vector60
vector60:
  pushl $0
8010747b:	6a 00                	push   $0x0
  pushl $60
8010747d:	6a 3c                	push   $0x3c
  jmp alltraps
8010747f:	e9 6b f7 ff ff       	jmp    80106bef <alltraps>

80107484 <vector61>:
.globl vector61
vector61:
  pushl $0
80107484:	6a 00                	push   $0x0
  pushl $61
80107486:	6a 3d                	push   $0x3d
  jmp alltraps
80107488:	e9 62 f7 ff ff       	jmp    80106bef <alltraps>

8010748d <vector62>:
.globl vector62
vector62:
  pushl $0
8010748d:	6a 00                	push   $0x0
  pushl $62
8010748f:	6a 3e                	push   $0x3e
  jmp alltraps
80107491:	e9 59 f7 ff ff       	jmp    80106bef <alltraps>

80107496 <vector63>:
.globl vector63
vector63:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $63
80107498:	6a 3f                	push   $0x3f
  jmp alltraps
8010749a:	e9 50 f7 ff ff       	jmp    80106bef <alltraps>

8010749f <vector64>:
.globl vector64
vector64:
  pushl $0
8010749f:	6a 00                	push   $0x0
  pushl $64
801074a1:	6a 40                	push   $0x40
  jmp alltraps
801074a3:	e9 47 f7 ff ff       	jmp    80106bef <alltraps>

801074a8 <vector65>:
.globl vector65
vector65:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $65
801074aa:	6a 41                	push   $0x41
  jmp alltraps
801074ac:	e9 3e f7 ff ff       	jmp    80106bef <alltraps>

801074b1 <vector66>:
.globl vector66
vector66:
  pushl $0
801074b1:	6a 00                	push   $0x0
  pushl $66
801074b3:	6a 42                	push   $0x42
  jmp alltraps
801074b5:	e9 35 f7 ff ff       	jmp    80106bef <alltraps>

801074ba <vector67>:
.globl vector67
vector67:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $67
801074bc:	6a 43                	push   $0x43
  jmp alltraps
801074be:	e9 2c f7 ff ff       	jmp    80106bef <alltraps>

801074c3 <vector68>:
.globl vector68
vector68:
  pushl $0
801074c3:	6a 00                	push   $0x0
  pushl $68
801074c5:	6a 44                	push   $0x44
  jmp alltraps
801074c7:	e9 23 f7 ff ff       	jmp    80106bef <alltraps>

801074cc <vector69>:
.globl vector69
vector69:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $69
801074ce:	6a 45                	push   $0x45
  jmp alltraps
801074d0:	e9 1a f7 ff ff       	jmp    80106bef <alltraps>

801074d5 <vector70>:
.globl vector70
vector70:
  pushl $0
801074d5:	6a 00                	push   $0x0
  pushl $70
801074d7:	6a 46                	push   $0x46
  jmp alltraps
801074d9:	e9 11 f7 ff ff       	jmp    80106bef <alltraps>

801074de <vector71>:
.globl vector71
vector71:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $71
801074e0:	6a 47                	push   $0x47
  jmp alltraps
801074e2:	e9 08 f7 ff ff       	jmp    80106bef <alltraps>

801074e7 <vector72>:
.globl vector72
vector72:
  pushl $0
801074e7:	6a 00                	push   $0x0
  pushl $72
801074e9:	6a 48                	push   $0x48
  jmp alltraps
801074eb:	e9 ff f6 ff ff       	jmp    80106bef <alltraps>

801074f0 <vector73>:
.globl vector73
vector73:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $73
801074f2:	6a 49                	push   $0x49
  jmp alltraps
801074f4:	e9 f6 f6 ff ff       	jmp    80106bef <alltraps>

801074f9 <vector74>:
.globl vector74
vector74:
  pushl $0
801074f9:	6a 00                	push   $0x0
  pushl $74
801074fb:	6a 4a                	push   $0x4a
  jmp alltraps
801074fd:	e9 ed f6 ff ff       	jmp    80106bef <alltraps>

80107502 <vector75>:
.globl vector75
vector75:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $75
80107504:	6a 4b                	push   $0x4b
  jmp alltraps
80107506:	e9 e4 f6 ff ff       	jmp    80106bef <alltraps>

8010750b <vector76>:
.globl vector76
vector76:
  pushl $0
8010750b:	6a 00                	push   $0x0
  pushl $76
8010750d:	6a 4c                	push   $0x4c
  jmp alltraps
8010750f:	e9 db f6 ff ff       	jmp    80106bef <alltraps>

80107514 <vector77>:
.globl vector77
vector77:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $77
80107516:	6a 4d                	push   $0x4d
  jmp alltraps
80107518:	e9 d2 f6 ff ff       	jmp    80106bef <alltraps>

8010751d <vector78>:
.globl vector78
vector78:
  pushl $0
8010751d:	6a 00                	push   $0x0
  pushl $78
8010751f:	6a 4e                	push   $0x4e
  jmp alltraps
80107521:	e9 c9 f6 ff ff       	jmp    80106bef <alltraps>

80107526 <vector79>:
.globl vector79
vector79:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $79
80107528:	6a 4f                	push   $0x4f
  jmp alltraps
8010752a:	e9 c0 f6 ff ff       	jmp    80106bef <alltraps>

8010752f <vector80>:
.globl vector80
vector80:
  pushl $0
8010752f:	6a 00                	push   $0x0
  pushl $80
80107531:	6a 50                	push   $0x50
  jmp alltraps
80107533:	e9 b7 f6 ff ff       	jmp    80106bef <alltraps>

80107538 <vector81>:
.globl vector81
vector81:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $81
8010753a:	6a 51                	push   $0x51
  jmp alltraps
8010753c:	e9 ae f6 ff ff       	jmp    80106bef <alltraps>

80107541 <vector82>:
.globl vector82
vector82:
  pushl $0
80107541:	6a 00                	push   $0x0
  pushl $82
80107543:	6a 52                	push   $0x52
  jmp alltraps
80107545:	e9 a5 f6 ff ff       	jmp    80106bef <alltraps>

8010754a <vector83>:
.globl vector83
vector83:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $83
8010754c:	6a 53                	push   $0x53
  jmp alltraps
8010754e:	e9 9c f6 ff ff       	jmp    80106bef <alltraps>

80107553 <vector84>:
.globl vector84
vector84:
  pushl $0
80107553:	6a 00                	push   $0x0
  pushl $84
80107555:	6a 54                	push   $0x54
  jmp alltraps
80107557:	e9 93 f6 ff ff       	jmp    80106bef <alltraps>

8010755c <vector85>:
.globl vector85
vector85:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $85
8010755e:	6a 55                	push   $0x55
  jmp alltraps
80107560:	e9 8a f6 ff ff       	jmp    80106bef <alltraps>

80107565 <vector86>:
.globl vector86
vector86:
  pushl $0
80107565:	6a 00                	push   $0x0
  pushl $86
80107567:	6a 56                	push   $0x56
  jmp alltraps
80107569:	e9 81 f6 ff ff       	jmp    80106bef <alltraps>

8010756e <vector87>:
.globl vector87
vector87:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $87
80107570:	6a 57                	push   $0x57
  jmp alltraps
80107572:	e9 78 f6 ff ff       	jmp    80106bef <alltraps>

80107577 <vector88>:
.globl vector88
vector88:
  pushl $0
80107577:	6a 00                	push   $0x0
  pushl $88
80107579:	6a 58                	push   $0x58
  jmp alltraps
8010757b:	e9 6f f6 ff ff       	jmp    80106bef <alltraps>

80107580 <vector89>:
.globl vector89
vector89:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $89
80107582:	6a 59                	push   $0x59
  jmp alltraps
80107584:	e9 66 f6 ff ff       	jmp    80106bef <alltraps>

80107589 <vector90>:
.globl vector90
vector90:
  pushl $0
80107589:	6a 00                	push   $0x0
  pushl $90
8010758b:	6a 5a                	push   $0x5a
  jmp alltraps
8010758d:	e9 5d f6 ff ff       	jmp    80106bef <alltraps>

80107592 <vector91>:
.globl vector91
vector91:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $91
80107594:	6a 5b                	push   $0x5b
  jmp alltraps
80107596:	e9 54 f6 ff ff       	jmp    80106bef <alltraps>

8010759b <vector92>:
.globl vector92
vector92:
  pushl $0
8010759b:	6a 00                	push   $0x0
  pushl $92
8010759d:	6a 5c                	push   $0x5c
  jmp alltraps
8010759f:	e9 4b f6 ff ff       	jmp    80106bef <alltraps>

801075a4 <vector93>:
.globl vector93
vector93:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $93
801075a6:	6a 5d                	push   $0x5d
  jmp alltraps
801075a8:	e9 42 f6 ff ff       	jmp    80106bef <alltraps>

801075ad <vector94>:
.globl vector94
vector94:
  pushl $0
801075ad:	6a 00                	push   $0x0
  pushl $94
801075af:	6a 5e                	push   $0x5e
  jmp alltraps
801075b1:	e9 39 f6 ff ff       	jmp    80106bef <alltraps>

801075b6 <vector95>:
.globl vector95
vector95:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $95
801075b8:	6a 5f                	push   $0x5f
  jmp alltraps
801075ba:	e9 30 f6 ff ff       	jmp    80106bef <alltraps>

801075bf <vector96>:
.globl vector96
vector96:
  pushl $0
801075bf:	6a 00                	push   $0x0
  pushl $96
801075c1:	6a 60                	push   $0x60
  jmp alltraps
801075c3:	e9 27 f6 ff ff       	jmp    80106bef <alltraps>

801075c8 <vector97>:
.globl vector97
vector97:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $97
801075ca:	6a 61                	push   $0x61
  jmp alltraps
801075cc:	e9 1e f6 ff ff       	jmp    80106bef <alltraps>

801075d1 <vector98>:
.globl vector98
vector98:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $98
801075d3:	6a 62                	push   $0x62
  jmp alltraps
801075d5:	e9 15 f6 ff ff       	jmp    80106bef <alltraps>

801075da <vector99>:
.globl vector99
vector99:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $99
801075dc:	6a 63                	push   $0x63
  jmp alltraps
801075de:	e9 0c f6 ff ff       	jmp    80106bef <alltraps>

801075e3 <vector100>:
.globl vector100
vector100:
  pushl $0
801075e3:	6a 00                	push   $0x0
  pushl $100
801075e5:	6a 64                	push   $0x64
  jmp alltraps
801075e7:	e9 03 f6 ff ff       	jmp    80106bef <alltraps>

801075ec <vector101>:
.globl vector101
vector101:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $101
801075ee:	6a 65                	push   $0x65
  jmp alltraps
801075f0:	e9 fa f5 ff ff       	jmp    80106bef <alltraps>

801075f5 <vector102>:
.globl vector102
vector102:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $102
801075f7:	6a 66                	push   $0x66
  jmp alltraps
801075f9:	e9 f1 f5 ff ff       	jmp    80106bef <alltraps>

801075fe <vector103>:
.globl vector103
vector103:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $103
80107600:	6a 67                	push   $0x67
  jmp alltraps
80107602:	e9 e8 f5 ff ff       	jmp    80106bef <alltraps>

80107607 <vector104>:
.globl vector104
vector104:
  pushl $0
80107607:	6a 00                	push   $0x0
  pushl $104
80107609:	6a 68                	push   $0x68
  jmp alltraps
8010760b:	e9 df f5 ff ff       	jmp    80106bef <alltraps>

80107610 <vector105>:
.globl vector105
vector105:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $105
80107612:	6a 69                	push   $0x69
  jmp alltraps
80107614:	e9 d6 f5 ff ff       	jmp    80106bef <alltraps>

80107619 <vector106>:
.globl vector106
vector106:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $106
8010761b:	6a 6a                	push   $0x6a
  jmp alltraps
8010761d:	e9 cd f5 ff ff       	jmp    80106bef <alltraps>

80107622 <vector107>:
.globl vector107
vector107:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $107
80107624:	6a 6b                	push   $0x6b
  jmp alltraps
80107626:	e9 c4 f5 ff ff       	jmp    80106bef <alltraps>

8010762b <vector108>:
.globl vector108
vector108:
  pushl $0
8010762b:	6a 00                	push   $0x0
  pushl $108
8010762d:	6a 6c                	push   $0x6c
  jmp alltraps
8010762f:	e9 bb f5 ff ff       	jmp    80106bef <alltraps>

80107634 <vector109>:
.globl vector109
vector109:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $109
80107636:	6a 6d                	push   $0x6d
  jmp alltraps
80107638:	e9 b2 f5 ff ff       	jmp    80106bef <alltraps>

8010763d <vector110>:
.globl vector110
vector110:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $110
8010763f:	6a 6e                	push   $0x6e
  jmp alltraps
80107641:	e9 a9 f5 ff ff       	jmp    80106bef <alltraps>

80107646 <vector111>:
.globl vector111
vector111:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $111
80107648:	6a 6f                	push   $0x6f
  jmp alltraps
8010764a:	e9 a0 f5 ff ff       	jmp    80106bef <alltraps>

8010764f <vector112>:
.globl vector112
vector112:
  pushl $0
8010764f:	6a 00                	push   $0x0
  pushl $112
80107651:	6a 70                	push   $0x70
  jmp alltraps
80107653:	e9 97 f5 ff ff       	jmp    80106bef <alltraps>

80107658 <vector113>:
.globl vector113
vector113:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $113
8010765a:	6a 71                	push   $0x71
  jmp alltraps
8010765c:	e9 8e f5 ff ff       	jmp    80106bef <alltraps>

80107661 <vector114>:
.globl vector114
vector114:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $114
80107663:	6a 72                	push   $0x72
  jmp alltraps
80107665:	e9 85 f5 ff ff       	jmp    80106bef <alltraps>

8010766a <vector115>:
.globl vector115
vector115:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $115
8010766c:	6a 73                	push   $0x73
  jmp alltraps
8010766e:	e9 7c f5 ff ff       	jmp    80106bef <alltraps>

80107673 <vector116>:
.globl vector116
vector116:
  pushl $0
80107673:	6a 00                	push   $0x0
  pushl $116
80107675:	6a 74                	push   $0x74
  jmp alltraps
80107677:	e9 73 f5 ff ff       	jmp    80106bef <alltraps>

8010767c <vector117>:
.globl vector117
vector117:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $117
8010767e:	6a 75                	push   $0x75
  jmp alltraps
80107680:	e9 6a f5 ff ff       	jmp    80106bef <alltraps>

80107685 <vector118>:
.globl vector118
vector118:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $118
80107687:	6a 76                	push   $0x76
  jmp alltraps
80107689:	e9 61 f5 ff ff       	jmp    80106bef <alltraps>

8010768e <vector119>:
.globl vector119
vector119:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $119
80107690:	6a 77                	push   $0x77
  jmp alltraps
80107692:	e9 58 f5 ff ff       	jmp    80106bef <alltraps>

80107697 <vector120>:
.globl vector120
vector120:
  pushl $0
80107697:	6a 00                	push   $0x0
  pushl $120
80107699:	6a 78                	push   $0x78
  jmp alltraps
8010769b:	e9 4f f5 ff ff       	jmp    80106bef <alltraps>

801076a0 <vector121>:
.globl vector121
vector121:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $121
801076a2:	6a 79                	push   $0x79
  jmp alltraps
801076a4:	e9 46 f5 ff ff       	jmp    80106bef <alltraps>

801076a9 <vector122>:
.globl vector122
vector122:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $122
801076ab:	6a 7a                	push   $0x7a
  jmp alltraps
801076ad:	e9 3d f5 ff ff       	jmp    80106bef <alltraps>

801076b2 <vector123>:
.globl vector123
vector123:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $123
801076b4:	6a 7b                	push   $0x7b
  jmp alltraps
801076b6:	e9 34 f5 ff ff       	jmp    80106bef <alltraps>

801076bb <vector124>:
.globl vector124
vector124:
  pushl $0
801076bb:	6a 00                	push   $0x0
  pushl $124
801076bd:	6a 7c                	push   $0x7c
  jmp alltraps
801076bf:	e9 2b f5 ff ff       	jmp    80106bef <alltraps>

801076c4 <vector125>:
.globl vector125
vector125:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $125
801076c6:	6a 7d                	push   $0x7d
  jmp alltraps
801076c8:	e9 22 f5 ff ff       	jmp    80106bef <alltraps>

801076cd <vector126>:
.globl vector126
vector126:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $126
801076cf:	6a 7e                	push   $0x7e
  jmp alltraps
801076d1:	e9 19 f5 ff ff       	jmp    80106bef <alltraps>

801076d6 <vector127>:
.globl vector127
vector127:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $127
801076d8:	6a 7f                	push   $0x7f
  jmp alltraps
801076da:	e9 10 f5 ff ff       	jmp    80106bef <alltraps>

801076df <vector128>:
.globl vector128
vector128:
  pushl $0
801076df:	6a 00                	push   $0x0
  pushl $128
801076e1:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801076e6:	e9 04 f5 ff ff       	jmp    80106bef <alltraps>

801076eb <vector129>:
.globl vector129
vector129:
  pushl $0
801076eb:	6a 00                	push   $0x0
  pushl $129
801076ed:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801076f2:	e9 f8 f4 ff ff       	jmp    80106bef <alltraps>

801076f7 <vector130>:
.globl vector130
vector130:
  pushl $0
801076f7:	6a 00                	push   $0x0
  pushl $130
801076f9:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801076fe:	e9 ec f4 ff ff       	jmp    80106bef <alltraps>

80107703 <vector131>:
.globl vector131
vector131:
  pushl $0
80107703:	6a 00                	push   $0x0
  pushl $131
80107705:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010770a:	e9 e0 f4 ff ff       	jmp    80106bef <alltraps>

8010770f <vector132>:
.globl vector132
vector132:
  pushl $0
8010770f:	6a 00                	push   $0x0
  pushl $132
80107711:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107716:	e9 d4 f4 ff ff       	jmp    80106bef <alltraps>

8010771b <vector133>:
.globl vector133
vector133:
  pushl $0
8010771b:	6a 00                	push   $0x0
  pushl $133
8010771d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107722:	e9 c8 f4 ff ff       	jmp    80106bef <alltraps>

80107727 <vector134>:
.globl vector134
vector134:
  pushl $0
80107727:	6a 00                	push   $0x0
  pushl $134
80107729:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010772e:	e9 bc f4 ff ff       	jmp    80106bef <alltraps>

80107733 <vector135>:
.globl vector135
vector135:
  pushl $0
80107733:	6a 00                	push   $0x0
  pushl $135
80107735:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010773a:	e9 b0 f4 ff ff       	jmp    80106bef <alltraps>

8010773f <vector136>:
.globl vector136
vector136:
  pushl $0
8010773f:	6a 00                	push   $0x0
  pushl $136
80107741:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107746:	e9 a4 f4 ff ff       	jmp    80106bef <alltraps>

8010774b <vector137>:
.globl vector137
vector137:
  pushl $0
8010774b:	6a 00                	push   $0x0
  pushl $137
8010774d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107752:	e9 98 f4 ff ff       	jmp    80106bef <alltraps>

80107757 <vector138>:
.globl vector138
vector138:
  pushl $0
80107757:	6a 00                	push   $0x0
  pushl $138
80107759:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010775e:	e9 8c f4 ff ff       	jmp    80106bef <alltraps>

80107763 <vector139>:
.globl vector139
vector139:
  pushl $0
80107763:	6a 00                	push   $0x0
  pushl $139
80107765:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010776a:	e9 80 f4 ff ff       	jmp    80106bef <alltraps>

8010776f <vector140>:
.globl vector140
vector140:
  pushl $0
8010776f:	6a 00                	push   $0x0
  pushl $140
80107771:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107776:	e9 74 f4 ff ff       	jmp    80106bef <alltraps>

8010777b <vector141>:
.globl vector141
vector141:
  pushl $0
8010777b:	6a 00                	push   $0x0
  pushl $141
8010777d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107782:	e9 68 f4 ff ff       	jmp    80106bef <alltraps>

80107787 <vector142>:
.globl vector142
vector142:
  pushl $0
80107787:	6a 00                	push   $0x0
  pushl $142
80107789:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010778e:	e9 5c f4 ff ff       	jmp    80106bef <alltraps>

80107793 <vector143>:
.globl vector143
vector143:
  pushl $0
80107793:	6a 00                	push   $0x0
  pushl $143
80107795:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010779a:	e9 50 f4 ff ff       	jmp    80106bef <alltraps>

8010779f <vector144>:
.globl vector144
vector144:
  pushl $0
8010779f:	6a 00                	push   $0x0
  pushl $144
801077a1:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801077a6:	e9 44 f4 ff ff       	jmp    80106bef <alltraps>

801077ab <vector145>:
.globl vector145
vector145:
  pushl $0
801077ab:	6a 00                	push   $0x0
  pushl $145
801077ad:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801077b2:	e9 38 f4 ff ff       	jmp    80106bef <alltraps>

801077b7 <vector146>:
.globl vector146
vector146:
  pushl $0
801077b7:	6a 00                	push   $0x0
  pushl $146
801077b9:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801077be:	e9 2c f4 ff ff       	jmp    80106bef <alltraps>

801077c3 <vector147>:
.globl vector147
vector147:
  pushl $0
801077c3:	6a 00                	push   $0x0
  pushl $147
801077c5:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801077ca:	e9 20 f4 ff ff       	jmp    80106bef <alltraps>

801077cf <vector148>:
.globl vector148
vector148:
  pushl $0
801077cf:	6a 00                	push   $0x0
  pushl $148
801077d1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801077d6:	e9 14 f4 ff ff       	jmp    80106bef <alltraps>

801077db <vector149>:
.globl vector149
vector149:
  pushl $0
801077db:	6a 00                	push   $0x0
  pushl $149
801077dd:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801077e2:	e9 08 f4 ff ff       	jmp    80106bef <alltraps>

801077e7 <vector150>:
.globl vector150
vector150:
  pushl $0
801077e7:	6a 00                	push   $0x0
  pushl $150
801077e9:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801077ee:	e9 fc f3 ff ff       	jmp    80106bef <alltraps>

801077f3 <vector151>:
.globl vector151
vector151:
  pushl $0
801077f3:	6a 00                	push   $0x0
  pushl $151
801077f5:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801077fa:	e9 f0 f3 ff ff       	jmp    80106bef <alltraps>

801077ff <vector152>:
.globl vector152
vector152:
  pushl $0
801077ff:	6a 00                	push   $0x0
  pushl $152
80107801:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107806:	e9 e4 f3 ff ff       	jmp    80106bef <alltraps>

8010780b <vector153>:
.globl vector153
vector153:
  pushl $0
8010780b:	6a 00                	push   $0x0
  pushl $153
8010780d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107812:	e9 d8 f3 ff ff       	jmp    80106bef <alltraps>

80107817 <vector154>:
.globl vector154
vector154:
  pushl $0
80107817:	6a 00                	push   $0x0
  pushl $154
80107819:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010781e:	e9 cc f3 ff ff       	jmp    80106bef <alltraps>

80107823 <vector155>:
.globl vector155
vector155:
  pushl $0
80107823:	6a 00                	push   $0x0
  pushl $155
80107825:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010782a:	e9 c0 f3 ff ff       	jmp    80106bef <alltraps>

8010782f <vector156>:
.globl vector156
vector156:
  pushl $0
8010782f:	6a 00                	push   $0x0
  pushl $156
80107831:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107836:	e9 b4 f3 ff ff       	jmp    80106bef <alltraps>

8010783b <vector157>:
.globl vector157
vector157:
  pushl $0
8010783b:	6a 00                	push   $0x0
  pushl $157
8010783d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107842:	e9 a8 f3 ff ff       	jmp    80106bef <alltraps>

80107847 <vector158>:
.globl vector158
vector158:
  pushl $0
80107847:	6a 00                	push   $0x0
  pushl $158
80107849:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010784e:	e9 9c f3 ff ff       	jmp    80106bef <alltraps>

80107853 <vector159>:
.globl vector159
vector159:
  pushl $0
80107853:	6a 00                	push   $0x0
  pushl $159
80107855:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010785a:	e9 90 f3 ff ff       	jmp    80106bef <alltraps>

8010785f <vector160>:
.globl vector160
vector160:
  pushl $0
8010785f:	6a 00                	push   $0x0
  pushl $160
80107861:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107866:	e9 84 f3 ff ff       	jmp    80106bef <alltraps>

8010786b <vector161>:
.globl vector161
vector161:
  pushl $0
8010786b:	6a 00                	push   $0x0
  pushl $161
8010786d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107872:	e9 78 f3 ff ff       	jmp    80106bef <alltraps>

80107877 <vector162>:
.globl vector162
vector162:
  pushl $0
80107877:	6a 00                	push   $0x0
  pushl $162
80107879:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010787e:	e9 6c f3 ff ff       	jmp    80106bef <alltraps>

80107883 <vector163>:
.globl vector163
vector163:
  pushl $0
80107883:	6a 00                	push   $0x0
  pushl $163
80107885:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010788a:	e9 60 f3 ff ff       	jmp    80106bef <alltraps>

8010788f <vector164>:
.globl vector164
vector164:
  pushl $0
8010788f:	6a 00                	push   $0x0
  pushl $164
80107891:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107896:	e9 54 f3 ff ff       	jmp    80106bef <alltraps>

8010789b <vector165>:
.globl vector165
vector165:
  pushl $0
8010789b:	6a 00                	push   $0x0
  pushl $165
8010789d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801078a2:	e9 48 f3 ff ff       	jmp    80106bef <alltraps>

801078a7 <vector166>:
.globl vector166
vector166:
  pushl $0
801078a7:	6a 00                	push   $0x0
  pushl $166
801078a9:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801078ae:	e9 3c f3 ff ff       	jmp    80106bef <alltraps>

801078b3 <vector167>:
.globl vector167
vector167:
  pushl $0
801078b3:	6a 00                	push   $0x0
  pushl $167
801078b5:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801078ba:	e9 30 f3 ff ff       	jmp    80106bef <alltraps>

801078bf <vector168>:
.globl vector168
vector168:
  pushl $0
801078bf:	6a 00                	push   $0x0
  pushl $168
801078c1:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801078c6:	e9 24 f3 ff ff       	jmp    80106bef <alltraps>

801078cb <vector169>:
.globl vector169
vector169:
  pushl $0
801078cb:	6a 00                	push   $0x0
  pushl $169
801078cd:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801078d2:	e9 18 f3 ff ff       	jmp    80106bef <alltraps>

801078d7 <vector170>:
.globl vector170
vector170:
  pushl $0
801078d7:	6a 00                	push   $0x0
  pushl $170
801078d9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801078de:	e9 0c f3 ff ff       	jmp    80106bef <alltraps>

801078e3 <vector171>:
.globl vector171
vector171:
  pushl $0
801078e3:	6a 00                	push   $0x0
  pushl $171
801078e5:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801078ea:	e9 00 f3 ff ff       	jmp    80106bef <alltraps>

801078ef <vector172>:
.globl vector172
vector172:
  pushl $0
801078ef:	6a 00                	push   $0x0
  pushl $172
801078f1:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801078f6:	e9 f4 f2 ff ff       	jmp    80106bef <alltraps>

801078fb <vector173>:
.globl vector173
vector173:
  pushl $0
801078fb:	6a 00                	push   $0x0
  pushl $173
801078fd:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107902:	e9 e8 f2 ff ff       	jmp    80106bef <alltraps>

80107907 <vector174>:
.globl vector174
vector174:
  pushl $0
80107907:	6a 00                	push   $0x0
  pushl $174
80107909:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010790e:	e9 dc f2 ff ff       	jmp    80106bef <alltraps>

80107913 <vector175>:
.globl vector175
vector175:
  pushl $0
80107913:	6a 00                	push   $0x0
  pushl $175
80107915:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010791a:	e9 d0 f2 ff ff       	jmp    80106bef <alltraps>

8010791f <vector176>:
.globl vector176
vector176:
  pushl $0
8010791f:	6a 00                	push   $0x0
  pushl $176
80107921:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107926:	e9 c4 f2 ff ff       	jmp    80106bef <alltraps>

8010792b <vector177>:
.globl vector177
vector177:
  pushl $0
8010792b:	6a 00                	push   $0x0
  pushl $177
8010792d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107932:	e9 b8 f2 ff ff       	jmp    80106bef <alltraps>

80107937 <vector178>:
.globl vector178
vector178:
  pushl $0
80107937:	6a 00                	push   $0x0
  pushl $178
80107939:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010793e:	e9 ac f2 ff ff       	jmp    80106bef <alltraps>

80107943 <vector179>:
.globl vector179
vector179:
  pushl $0
80107943:	6a 00                	push   $0x0
  pushl $179
80107945:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010794a:	e9 a0 f2 ff ff       	jmp    80106bef <alltraps>

8010794f <vector180>:
.globl vector180
vector180:
  pushl $0
8010794f:	6a 00                	push   $0x0
  pushl $180
80107951:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107956:	e9 94 f2 ff ff       	jmp    80106bef <alltraps>

8010795b <vector181>:
.globl vector181
vector181:
  pushl $0
8010795b:	6a 00                	push   $0x0
  pushl $181
8010795d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107962:	e9 88 f2 ff ff       	jmp    80106bef <alltraps>

80107967 <vector182>:
.globl vector182
vector182:
  pushl $0
80107967:	6a 00                	push   $0x0
  pushl $182
80107969:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010796e:	e9 7c f2 ff ff       	jmp    80106bef <alltraps>

80107973 <vector183>:
.globl vector183
vector183:
  pushl $0
80107973:	6a 00                	push   $0x0
  pushl $183
80107975:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010797a:	e9 70 f2 ff ff       	jmp    80106bef <alltraps>

8010797f <vector184>:
.globl vector184
vector184:
  pushl $0
8010797f:	6a 00                	push   $0x0
  pushl $184
80107981:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107986:	e9 64 f2 ff ff       	jmp    80106bef <alltraps>

8010798b <vector185>:
.globl vector185
vector185:
  pushl $0
8010798b:	6a 00                	push   $0x0
  pushl $185
8010798d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107992:	e9 58 f2 ff ff       	jmp    80106bef <alltraps>

80107997 <vector186>:
.globl vector186
vector186:
  pushl $0
80107997:	6a 00                	push   $0x0
  pushl $186
80107999:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010799e:	e9 4c f2 ff ff       	jmp    80106bef <alltraps>

801079a3 <vector187>:
.globl vector187
vector187:
  pushl $0
801079a3:	6a 00                	push   $0x0
  pushl $187
801079a5:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801079aa:	e9 40 f2 ff ff       	jmp    80106bef <alltraps>

801079af <vector188>:
.globl vector188
vector188:
  pushl $0
801079af:	6a 00                	push   $0x0
  pushl $188
801079b1:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801079b6:	e9 34 f2 ff ff       	jmp    80106bef <alltraps>

801079bb <vector189>:
.globl vector189
vector189:
  pushl $0
801079bb:	6a 00                	push   $0x0
  pushl $189
801079bd:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801079c2:	e9 28 f2 ff ff       	jmp    80106bef <alltraps>

801079c7 <vector190>:
.globl vector190
vector190:
  pushl $0
801079c7:	6a 00                	push   $0x0
  pushl $190
801079c9:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801079ce:	e9 1c f2 ff ff       	jmp    80106bef <alltraps>

801079d3 <vector191>:
.globl vector191
vector191:
  pushl $0
801079d3:	6a 00                	push   $0x0
  pushl $191
801079d5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801079da:	e9 10 f2 ff ff       	jmp    80106bef <alltraps>

801079df <vector192>:
.globl vector192
vector192:
  pushl $0
801079df:	6a 00                	push   $0x0
  pushl $192
801079e1:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801079e6:	e9 04 f2 ff ff       	jmp    80106bef <alltraps>

801079eb <vector193>:
.globl vector193
vector193:
  pushl $0
801079eb:	6a 00                	push   $0x0
  pushl $193
801079ed:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801079f2:	e9 f8 f1 ff ff       	jmp    80106bef <alltraps>

801079f7 <vector194>:
.globl vector194
vector194:
  pushl $0
801079f7:	6a 00                	push   $0x0
  pushl $194
801079f9:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801079fe:	e9 ec f1 ff ff       	jmp    80106bef <alltraps>

80107a03 <vector195>:
.globl vector195
vector195:
  pushl $0
80107a03:	6a 00                	push   $0x0
  pushl $195
80107a05:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107a0a:	e9 e0 f1 ff ff       	jmp    80106bef <alltraps>

80107a0f <vector196>:
.globl vector196
vector196:
  pushl $0
80107a0f:	6a 00                	push   $0x0
  pushl $196
80107a11:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107a16:	e9 d4 f1 ff ff       	jmp    80106bef <alltraps>

80107a1b <vector197>:
.globl vector197
vector197:
  pushl $0
80107a1b:	6a 00                	push   $0x0
  pushl $197
80107a1d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107a22:	e9 c8 f1 ff ff       	jmp    80106bef <alltraps>

80107a27 <vector198>:
.globl vector198
vector198:
  pushl $0
80107a27:	6a 00                	push   $0x0
  pushl $198
80107a29:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107a2e:	e9 bc f1 ff ff       	jmp    80106bef <alltraps>

80107a33 <vector199>:
.globl vector199
vector199:
  pushl $0
80107a33:	6a 00                	push   $0x0
  pushl $199
80107a35:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107a3a:	e9 b0 f1 ff ff       	jmp    80106bef <alltraps>

80107a3f <vector200>:
.globl vector200
vector200:
  pushl $0
80107a3f:	6a 00                	push   $0x0
  pushl $200
80107a41:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107a46:	e9 a4 f1 ff ff       	jmp    80106bef <alltraps>

80107a4b <vector201>:
.globl vector201
vector201:
  pushl $0
80107a4b:	6a 00                	push   $0x0
  pushl $201
80107a4d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107a52:	e9 98 f1 ff ff       	jmp    80106bef <alltraps>

80107a57 <vector202>:
.globl vector202
vector202:
  pushl $0
80107a57:	6a 00                	push   $0x0
  pushl $202
80107a59:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107a5e:	e9 8c f1 ff ff       	jmp    80106bef <alltraps>

80107a63 <vector203>:
.globl vector203
vector203:
  pushl $0
80107a63:	6a 00                	push   $0x0
  pushl $203
80107a65:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107a6a:	e9 80 f1 ff ff       	jmp    80106bef <alltraps>

80107a6f <vector204>:
.globl vector204
vector204:
  pushl $0
80107a6f:	6a 00                	push   $0x0
  pushl $204
80107a71:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107a76:	e9 74 f1 ff ff       	jmp    80106bef <alltraps>

80107a7b <vector205>:
.globl vector205
vector205:
  pushl $0
80107a7b:	6a 00                	push   $0x0
  pushl $205
80107a7d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107a82:	e9 68 f1 ff ff       	jmp    80106bef <alltraps>

80107a87 <vector206>:
.globl vector206
vector206:
  pushl $0
80107a87:	6a 00                	push   $0x0
  pushl $206
80107a89:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107a8e:	e9 5c f1 ff ff       	jmp    80106bef <alltraps>

80107a93 <vector207>:
.globl vector207
vector207:
  pushl $0
80107a93:	6a 00                	push   $0x0
  pushl $207
80107a95:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107a9a:	e9 50 f1 ff ff       	jmp    80106bef <alltraps>

80107a9f <vector208>:
.globl vector208
vector208:
  pushl $0
80107a9f:	6a 00                	push   $0x0
  pushl $208
80107aa1:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107aa6:	e9 44 f1 ff ff       	jmp    80106bef <alltraps>

80107aab <vector209>:
.globl vector209
vector209:
  pushl $0
80107aab:	6a 00                	push   $0x0
  pushl $209
80107aad:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107ab2:	e9 38 f1 ff ff       	jmp    80106bef <alltraps>

80107ab7 <vector210>:
.globl vector210
vector210:
  pushl $0
80107ab7:	6a 00                	push   $0x0
  pushl $210
80107ab9:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107abe:	e9 2c f1 ff ff       	jmp    80106bef <alltraps>

80107ac3 <vector211>:
.globl vector211
vector211:
  pushl $0
80107ac3:	6a 00                	push   $0x0
  pushl $211
80107ac5:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107aca:	e9 20 f1 ff ff       	jmp    80106bef <alltraps>

80107acf <vector212>:
.globl vector212
vector212:
  pushl $0
80107acf:	6a 00                	push   $0x0
  pushl $212
80107ad1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107ad6:	e9 14 f1 ff ff       	jmp    80106bef <alltraps>

80107adb <vector213>:
.globl vector213
vector213:
  pushl $0
80107adb:	6a 00                	push   $0x0
  pushl $213
80107add:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107ae2:	e9 08 f1 ff ff       	jmp    80106bef <alltraps>

80107ae7 <vector214>:
.globl vector214
vector214:
  pushl $0
80107ae7:	6a 00                	push   $0x0
  pushl $214
80107ae9:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107aee:	e9 fc f0 ff ff       	jmp    80106bef <alltraps>

80107af3 <vector215>:
.globl vector215
vector215:
  pushl $0
80107af3:	6a 00                	push   $0x0
  pushl $215
80107af5:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107afa:	e9 f0 f0 ff ff       	jmp    80106bef <alltraps>

80107aff <vector216>:
.globl vector216
vector216:
  pushl $0
80107aff:	6a 00                	push   $0x0
  pushl $216
80107b01:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107b06:	e9 e4 f0 ff ff       	jmp    80106bef <alltraps>

80107b0b <vector217>:
.globl vector217
vector217:
  pushl $0
80107b0b:	6a 00                	push   $0x0
  pushl $217
80107b0d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107b12:	e9 d8 f0 ff ff       	jmp    80106bef <alltraps>

80107b17 <vector218>:
.globl vector218
vector218:
  pushl $0
80107b17:	6a 00                	push   $0x0
  pushl $218
80107b19:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107b1e:	e9 cc f0 ff ff       	jmp    80106bef <alltraps>

80107b23 <vector219>:
.globl vector219
vector219:
  pushl $0
80107b23:	6a 00                	push   $0x0
  pushl $219
80107b25:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107b2a:	e9 c0 f0 ff ff       	jmp    80106bef <alltraps>

80107b2f <vector220>:
.globl vector220
vector220:
  pushl $0
80107b2f:	6a 00                	push   $0x0
  pushl $220
80107b31:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107b36:	e9 b4 f0 ff ff       	jmp    80106bef <alltraps>

80107b3b <vector221>:
.globl vector221
vector221:
  pushl $0
80107b3b:	6a 00                	push   $0x0
  pushl $221
80107b3d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107b42:	e9 a8 f0 ff ff       	jmp    80106bef <alltraps>

80107b47 <vector222>:
.globl vector222
vector222:
  pushl $0
80107b47:	6a 00                	push   $0x0
  pushl $222
80107b49:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107b4e:	e9 9c f0 ff ff       	jmp    80106bef <alltraps>

80107b53 <vector223>:
.globl vector223
vector223:
  pushl $0
80107b53:	6a 00                	push   $0x0
  pushl $223
80107b55:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107b5a:	e9 90 f0 ff ff       	jmp    80106bef <alltraps>

80107b5f <vector224>:
.globl vector224
vector224:
  pushl $0
80107b5f:	6a 00                	push   $0x0
  pushl $224
80107b61:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107b66:	e9 84 f0 ff ff       	jmp    80106bef <alltraps>

80107b6b <vector225>:
.globl vector225
vector225:
  pushl $0
80107b6b:	6a 00                	push   $0x0
  pushl $225
80107b6d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107b72:	e9 78 f0 ff ff       	jmp    80106bef <alltraps>

80107b77 <vector226>:
.globl vector226
vector226:
  pushl $0
80107b77:	6a 00                	push   $0x0
  pushl $226
80107b79:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107b7e:	e9 6c f0 ff ff       	jmp    80106bef <alltraps>

80107b83 <vector227>:
.globl vector227
vector227:
  pushl $0
80107b83:	6a 00                	push   $0x0
  pushl $227
80107b85:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107b8a:	e9 60 f0 ff ff       	jmp    80106bef <alltraps>

80107b8f <vector228>:
.globl vector228
vector228:
  pushl $0
80107b8f:	6a 00                	push   $0x0
  pushl $228
80107b91:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107b96:	e9 54 f0 ff ff       	jmp    80106bef <alltraps>

80107b9b <vector229>:
.globl vector229
vector229:
  pushl $0
80107b9b:	6a 00                	push   $0x0
  pushl $229
80107b9d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107ba2:	e9 48 f0 ff ff       	jmp    80106bef <alltraps>

80107ba7 <vector230>:
.globl vector230
vector230:
  pushl $0
80107ba7:	6a 00                	push   $0x0
  pushl $230
80107ba9:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107bae:	e9 3c f0 ff ff       	jmp    80106bef <alltraps>

80107bb3 <vector231>:
.globl vector231
vector231:
  pushl $0
80107bb3:	6a 00                	push   $0x0
  pushl $231
80107bb5:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107bba:	e9 30 f0 ff ff       	jmp    80106bef <alltraps>

80107bbf <vector232>:
.globl vector232
vector232:
  pushl $0
80107bbf:	6a 00                	push   $0x0
  pushl $232
80107bc1:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107bc6:	e9 24 f0 ff ff       	jmp    80106bef <alltraps>

80107bcb <vector233>:
.globl vector233
vector233:
  pushl $0
80107bcb:	6a 00                	push   $0x0
  pushl $233
80107bcd:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107bd2:	e9 18 f0 ff ff       	jmp    80106bef <alltraps>

80107bd7 <vector234>:
.globl vector234
vector234:
  pushl $0
80107bd7:	6a 00                	push   $0x0
  pushl $234
80107bd9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107bde:	e9 0c f0 ff ff       	jmp    80106bef <alltraps>

80107be3 <vector235>:
.globl vector235
vector235:
  pushl $0
80107be3:	6a 00                	push   $0x0
  pushl $235
80107be5:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107bea:	e9 00 f0 ff ff       	jmp    80106bef <alltraps>

80107bef <vector236>:
.globl vector236
vector236:
  pushl $0
80107bef:	6a 00                	push   $0x0
  pushl $236
80107bf1:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107bf6:	e9 f4 ef ff ff       	jmp    80106bef <alltraps>

80107bfb <vector237>:
.globl vector237
vector237:
  pushl $0
80107bfb:	6a 00                	push   $0x0
  pushl $237
80107bfd:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107c02:	e9 e8 ef ff ff       	jmp    80106bef <alltraps>

80107c07 <vector238>:
.globl vector238
vector238:
  pushl $0
80107c07:	6a 00                	push   $0x0
  pushl $238
80107c09:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107c0e:	e9 dc ef ff ff       	jmp    80106bef <alltraps>

80107c13 <vector239>:
.globl vector239
vector239:
  pushl $0
80107c13:	6a 00                	push   $0x0
  pushl $239
80107c15:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107c1a:	e9 d0 ef ff ff       	jmp    80106bef <alltraps>

80107c1f <vector240>:
.globl vector240
vector240:
  pushl $0
80107c1f:	6a 00                	push   $0x0
  pushl $240
80107c21:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107c26:	e9 c4 ef ff ff       	jmp    80106bef <alltraps>

80107c2b <vector241>:
.globl vector241
vector241:
  pushl $0
80107c2b:	6a 00                	push   $0x0
  pushl $241
80107c2d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107c32:	e9 b8 ef ff ff       	jmp    80106bef <alltraps>

80107c37 <vector242>:
.globl vector242
vector242:
  pushl $0
80107c37:	6a 00                	push   $0x0
  pushl $242
80107c39:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107c3e:	e9 ac ef ff ff       	jmp    80106bef <alltraps>

80107c43 <vector243>:
.globl vector243
vector243:
  pushl $0
80107c43:	6a 00                	push   $0x0
  pushl $243
80107c45:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107c4a:	e9 a0 ef ff ff       	jmp    80106bef <alltraps>

80107c4f <vector244>:
.globl vector244
vector244:
  pushl $0
80107c4f:	6a 00                	push   $0x0
  pushl $244
80107c51:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107c56:	e9 94 ef ff ff       	jmp    80106bef <alltraps>

80107c5b <vector245>:
.globl vector245
vector245:
  pushl $0
80107c5b:	6a 00                	push   $0x0
  pushl $245
80107c5d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107c62:	e9 88 ef ff ff       	jmp    80106bef <alltraps>

80107c67 <vector246>:
.globl vector246
vector246:
  pushl $0
80107c67:	6a 00                	push   $0x0
  pushl $246
80107c69:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107c6e:	e9 7c ef ff ff       	jmp    80106bef <alltraps>

80107c73 <vector247>:
.globl vector247
vector247:
  pushl $0
80107c73:	6a 00                	push   $0x0
  pushl $247
80107c75:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107c7a:	e9 70 ef ff ff       	jmp    80106bef <alltraps>

80107c7f <vector248>:
.globl vector248
vector248:
  pushl $0
80107c7f:	6a 00                	push   $0x0
  pushl $248
80107c81:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107c86:	e9 64 ef ff ff       	jmp    80106bef <alltraps>

80107c8b <vector249>:
.globl vector249
vector249:
  pushl $0
80107c8b:	6a 00                	push   $0x0
  pushl $249
80107c8d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107c92:	e9 58 ef ff ff       	jmp    80106bef <alltraps>

80107c97 <vector250>:
.globl vector250
vector250:
  pushl $0
80107c97:	6a 00                	push   $0x0
  pushl $250
80107c99:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107c9e:	e9 4c ef ff ff       	jmp    80106bef <alltraps>

80107ca3 <vector251>:
.globl vector251
vector251:
  pushl $0
80107ca3:	6a 00                	push   $0x0
  pushl $251
80107ca5:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107caa:	e9 40 ef ff ff       	jmp    80106bef <alltraps>

80107caf <vector252>:
.globl vector252
vector252:
  pushl $0
80107caf:	6a 00                	push   $0x0
  pushl $252
80107cb1:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107cb6:	e9 34 ef ff ff       	jmp    80106bef <alltraps>

80107cbb <vector253>:
.globl vector253
vector253:
  pushl $0
80107cbb:	6a 00                	push   $0x0
  pushl $253
80107cbd:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107cc2:	e9 28 ef ff ff       	jmp    80106bef <alltraps>

80107cc7 <vector254>:
.globl vector254
vector254:
  pushl $0
80107cc7:	6a 00                	push   $0x0
  pushl $254
80107cc9:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107cce:	e9 1c ef ff ff       	jmp    80106bef <alltraps>

80107cd3 <vector255>:
.globl vector255
vector255:
  pushl $0
80107cd3:	6a 00                	push   $0x0
  pushl $255
80107cd5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107cda:	e9 10 ef ff ff       	jmp    80106bef <alltraps>

80107cdf <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107cdf:	55                   	push   %ebp
80107ce0:	89 e5                	mov    %esp,%ebp
80107ce2:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ce8:	83 e8 01             	sub    $0x1,%eax
80107ceb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107cef:	8b 45 08             	mov    0x8(%ebp),%eax
80107cf2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80107cf9:	c1 e8 10             	shr    $0x10,%eax
80107cfc:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107d00:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107d03:	0f 01 10             	lgdtl  (%eax)
}
80107d06:	c9                   	leave  
80107d07:	c3                   	ret    

80107d08 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107d08:	55                   	push   %ebp
80107d09:	89 e5                	mov    %esp,%ebp
80107d0b:	83 ec 04             	sub    $0x4,%esp
80107d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80107d11:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107d15:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107d19:	0f 00 d8             	ltr    %ax
}
80107d1c:	c9                   	leave  
80107d1d:	c3                   	ret    

80107d1e <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107d1e:	55                   	push   %ebp
80107d1f:	89 e5                	mov    %esp,%ebp
80107d21:	83 ec 04             	sub    $0x4,%esp
80107d24:	8b 45 08             	mov    0x8(%ebp),%eax
80107d27:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107d2b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107d2f:	8e e8                	mov    %eax,%gs
}
80107d31:	c9                   	leave  
80107d32:	c3                   	ret    

80107d33 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107d33:	55                   	push   %ebp
80107d34:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107d36:	8b 45 08             	mov    0x8(%ebp),%eax
80107d39:	0f 22 d8             	mov    %eax,%cr3
}
80107d3c:	5d                   	pop    %ebp
80107d3d:	c3                   	ret    

80107d3e <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107d3e:	55                   	push   %ebp
80107d3f:	89 e5                	mov    %esp,%ebp
80107d41:	8b 45 08             	mov    0x8(%ebp),%eax
80107d44:	05 00 00 00 80       	add    $0x80000000,%eax
80107d49:	5d                   	pop    %ebp
80107d4a:	c3                   	ret    

80107d4b <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107d4b:	55                   	push   %ebp
80107d4c:	89 e5                	mov    %esp,%ebp
80107d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80107d51:	05 00 00 00 80       	add    $0x80000000,%eax
80107d56:	5d                   	pop    %ebp
80107d57:	c3                   	ret    

80107d58 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107d58:	55                   	push   %ebp
80107d59:	89 e5                	mov    %esp,%ebp
80107d5b:	53                   	push   %ebx
80107d5c:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107d5f:	e8 21 b1 ff ff       	call   80102e85 <cpunum>
80107d64:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107d6a:	05 c0 33 11 80       	add    $0x801133c0,%eax
80107d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d75:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d87:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d92:	83 e2 f0             	and    $0xfffffff0,%edx
80107d95:	83 ca 0a             	or     $0xa,%edx
80107d98:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107da2:	83 ca 10             	or     $0x10,%edx
80107da5:	88 50 7d             	mov    %dl,0x7d(%eax)
80107da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dab:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107daf:	83 e2 9f             	and    $0xffffff9f,%edx
80107db2:	88 50 7d             	mov    %dl,0x7d(%eax)
80107db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107dbc:	83 ca 80             	or     $0xffffff80,%edx
80107dbf:	88 50 7d             	mov    %dl,0x7d(%eax)
80107dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107dc9:	83 ca 0f             	or     $0xf,%edx
80107dcc:	88 50 7e             	mov    %dl,0x7e(%eax)
80107dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107dd6:	83 e2 ef             	and    $0xffffffef,%edx
80107dd9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107de3:	83 e2 df             	and    $0xffffffdf,%edx
80107de6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dec:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107df0:	83 ca 40             	or     $0x40,%edx
80107df3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107dfd:	83 ca 80             	or     $0xffffff80,%edx
80107e00:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e06:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107e14:	ff ff 
80107e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e19:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107e20:	00 00 
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e36:	83 e2 f0             	and    $0xfffffff0,%edx
80107e39:	83 ca 02             	or     $0x2,%edx
80107e3c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e45:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e4c:	83 ca 10             	or     $0x10,%edx
80107e4f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e5f:	83 e2 9f             	and    $0xffffff9f,%edx
80107e62:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e72:	83 ca 80             	or     $0xffffff80,%edx
80107e75:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e85:	83 ca 0f             	or     $0xf,%edx
80107e88:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e91:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e98:	83 e2 ef             	and    $0xffffffef,%edx
80107e9b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107eab:	83 e2 df             	and    $0xffffffdf,%edx
80107eae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ebe:	83 ca 40             	or     $0x40,%edx
80107ec1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eca:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ed1:	83 ca 80             	or     $0xffffff80,%edx
80107ed4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edd:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee7:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107eee:	ff ff 
80107ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107efa:	00 00 
80107efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eff:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f09:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f10:	83 e2 f0             	and    $0xfffffff0,%edx
80107f13:	83 ca 0a             	or     $0xa,%edx
80107f16:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f26:	83 ca 10             	or     $0x10,%edx
80107f29:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f32:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f39:	83 ca 60             	or     $0x60,%edx
80107f3c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f45:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f4c:	83 ca 80             	or     $0xffffff80,%edx
80107f4f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f5f:	83 ca 0f             	or     $0xf,%edx
80107f62:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f72:	83 e2 ef             	and    $0xffffffef,%edx
80107f75:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f85:	83 e2 df             	and    $0xffffffdf,%edx
80107f88:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f91:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f98:	83 ca 40             	or     $0x40,%edx
80107f9b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fab:	83 ca 80             	or     $0xffffff80,%edx
80107fae:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb7:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc1:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107fc8:	ff ff 
80107fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcd:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107fd4:	00 00 
80107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd9:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107fea:	83 e2 f0             	and    $0xfffffff0,%edx
80107fed:	83 ca 02             	or     $0x2,%edx
80107ff0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108000:	83 ca 10             	or     $0x10,%edx
80108003:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108013:	83 ca 60             	or     $0x60,%edx
80108016:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010801c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108026:	83 ca 80             	or     $0xffffff80,%edx
80108029:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010802f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108032:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108039:	83 ca 0f             	or     $0xf,%edx
8010803c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108045:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010804c:	83 e2 ef             	and    $0xffffffef,%edx
8010804f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108058:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010805f:	83 e2 df             	and    $0xffffffdf,%edx
80108062:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108072:	83 ca 40             	or     $0x40,%edx
80108075:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010807b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108085:	83 ca 80             	or     $0xffffff80,%edx
80108088:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010808e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108091:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809b:	05 b4 00 00 00       	add    $0xb4,%eax
801080a0:	89 c3                	mov    %eax,%ebx
801080a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a5:	05 b4 00 00 00       	add    $0xb4,%eax
801080aa:	c1 e8 10             	shr    $0x10,%eax
801080ad:	89 c1                	mov    %eax,%ecx
801080af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b2:	05 b4 00 00 00       	add    $0xb4,%eax
801080b7:	c1 e8 18             	shr    $0x18,%eax
801080ba:	89 c2                	mov    %eax,%edx
801080bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bf:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801080c6:	00 00 
801080c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cb:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d5:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801080db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080de:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801080e5:	83 e1 f0             	and    $0xfffffff0,%ecx
801080e8:	83 c9 02             	or     $0x2,%ecx
801080eb:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801080f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f4:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801080fb:	83 c9 10             	or     $0x10,%ecx
801080fe:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108107:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010810e:	83 e1 9f             	and    $0xffffff9f,%ecx
80108111:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811a:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108121:	83 c9 80             	or     $0xffffff80,%ecx
80108124:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010812a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812d:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108134:	83 e1 f0             	and    $0xfffffff0,%ecx
80108137:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010813d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108140:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108147:	83 e1 ef             	and    $0xffffffef,%ecx
8010814a:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108153:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010815a:	83 e1 df             	and    $0xffffffdf,%ecx
8010815d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108166:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010816d:	83 c9 40             	or     $0x40,%ecx
80108170:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108179:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108180:	83 c9 80             	or     $0xffffff80,%ecx
80108183:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108189:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818c:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108195:	83 c0 70             	add    $0x70,%eax
80108198:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
8010819f:	00 
801081a0:	89 04 24             	mov    %eax,(%esp)
801081a3:	e8 37 fb ff ff       	call   80107cdf <lgdt>
  loadgs(SEG_KCPU << 3);
801081a8:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
801081af:	e8 6a fb ff ff       	call   80107d1e <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
801081b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b7:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801081bd:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801081c4:	00 00 00 00 
}
801081c8:	83 c4 24             	add    $0x24,%esp
801081cb:	5b                   	pop    %ebx
801081cc:	5d                   	pop    %ebp
801081cd:	c3                   	ret    

801081ce <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801081ce:	55                   	push   %ebp
801081cf:	89 e5                	mov    %esp,%ebp
801081d1:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801081d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801081d7:	c1 e8 16             	shr    $0x16,%eax
801081da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801081e1:	8b 45 08             	mov    0x8(%ebp),%eax
801081e4:	01 d0                	add    %edx,%eax
801081e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801081e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ec:	8b 00                	mov    (%eax),%eax
801081ee:	83 e0 01             	and    $0x1,%eax
801081f1:	85 c0                	test   %eax,%eax
801081f3:	74 17                	je     8010820c <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801081f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f8:	8b 00                	mov    (%eax),%eax
801081fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081ff:	89 04 24             	mov    %eax,(%esp)
80108202:	e8 44 fb ff ff       	call   80107d4b <p2v>
80108207:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010820a:	eb 4b                	jmp    80108257 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010820c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108210:	74 0e                	je     80108220 <walkpgdir+0x52>
80108212:	e8 d8 a8 ff ff       	call   80102aef <kalloc>
80108217:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010821a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010821e:	75 07                	jne    80108227 <walkpgdir+0x59>
      return 0;
80108220:	b8 00 00 00 00       	mov    $0x0,%eax
80108225:	eb 47                	jmp    8010826e <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108227:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010822e:	00 
8010822f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108236:	00 
80108237:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823a:	89 04 24             	mov    %eax,(%esp)
8010823d:	e8 17 d5 ff ff       	call   80105759 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108245:	89 04 24             	mov    %eax,(%esp)
80108248:	e8 f1 fa ff ff       	call   80107d3e <v2p>
8010824d:	83 c8 07             	or     $0x7,%eax
80108250:	89 c2                	mov    %eax,%edx
80108252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108255:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108257:	8b 45 0c             	mov    0xc(%ebp),%eax
8010825a:	c1 e8 0c             	shr    $0xc,%eax
8010825d:	25 ff 03 00 00       	and    $0x3ff,%eax
80108262:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826c:	01 d0                	add    %edx,%eax
}
8010826e:	c9                   	leave  
8010826f:	c3                   	ret    

80108270 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108270:	55                   	push   %ebp
80108271:	89 e5                	mov    %esp,%ebp
80108273:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108276:	8b 45 0c             	mov    0xc(%ebp),%eax
80108279:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010827e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108281:	8b 55 0c             	mov    0xc(%ebp),%edx
80108284:	8b 45 10             	mov    0x10(%ebp),%eax
80108287:	01 d0                	add    %edx,%eax
80108289:	83 e8 01             	sub    $0x1,%eax
8010828c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108291:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108294:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010829b:	00 
8010829c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829f:	89 44 24 04          	mov    %eax,0x4(%esp)
801082a3:	8b 45 08             	mov    0x8(%ebp),%eax
801082a6:	89 04 24             	mov    %eax,(%esp)
801082a9:	e8 20 ff ff ff       	call   801081ce <walkpgdir>
801082ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082b1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082b5:	75 07                	jne    801082be <mappages+0x4e>
      return -1;
801082b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082bc:	eb 48                	jmp    80108306 <mappages+0x96>
    if(*pte & PTE_P)
801082be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082c1:	8b 00                	mov    (%eax),%eax
801082c3:	83 e0 01             	and    $0x1,%eax
801082c6:	85 c0                	test   %eax,%eax
801082c8:	74 0c                	je     801082d6 <mappages+0x66>
      panic("remap");
801082ca:	c7 04 24 10 91 10 80 	movl   $0x80109110,(%esp)
801082d1:	e8 64 82 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
801082d6:	8b 45 18             	mov    0x18(%ebp),%eax
801082d9:	0b 45 14             	or     0x14(%ebp),%eax
801082dc:	83 c8 01             	or     $0x1,%eax
801082df:	89 c2                	mov    %eax,%edx
801082e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e4:	89 10                	mov    %edx,(%eax)
    if(a == last)
801082e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801082ec:	75 08                	jne    801082f6 <mappages+0x86>
      break;
801082ee:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801082ef:	b8 00 00 00 00       	mov    $0x0,%eax
801082f4:	eb 10                	jmp    80108306 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801082f6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801082fd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108304:	eb 8e                	jmp    80108294 <mappages+0x24>
  return 0;
}
80108306:	c9                   	leave  
80108307:	c3                   	ret    

80108308 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108308:	55                   	push   %ebp
80108309:	89 e5                	mov    %esp,%ebp
8010830b:	53                   	push   %ebx
8010830c:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010830f:	e8 db a7 ff ff       	call   80102aef <kalloc>
80108314:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108317:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010831b:	75 0a                	jne    80108327 <setupkvm+0x1f>
    return 0;
8010831d:	b8 00 00 00 00       	mov    $0x0,%eax
80108322:	e9 98 00 00 00       	jmp    801083bf <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108327:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010832e:	00 
8010832f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108336:	00 
80108337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010833a:	89 04 24             	mov    %eax,(%esp)
8010833d:	e8 17 d4 ff ff       	call   80105759 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108342:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108349:	e8 fd f9 ff ff       	call   80107d4b <p2v>
8010834e:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108353:	76 0c                	jbe    80108361 <setupkvm+0x59>
    panic("PHYSTOP too high");
80108355:	c7 04 24 16 91 10 80 	movl   $0x80109116,(%esp)
8010835c:	e8 d9 81 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108361:	c7 45 f4 00 c5 10 80 	movl   $0x8010c500,-0xc(%ebp)
80108368:	eb 49                	jmp    801083b3 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010836a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836d:	8b 48 0c             	mov    0xc(%eax),%ecx
80108370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108373:	8b 50 04             	mov    0x4(%eax),%edx
80108376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108379:	8b 58 08             	mov    0x8(%eax),%ebx
8010837c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837f:	8b 40 04             	mov    0x4(%eax),%eax
80108382:	29 c3                	sub    %eax,%ebx
80108384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108387:	8b 00                	mov    (%eax),%eax
80108389:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010838d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108391:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108395:	89 44 24 04          	mov    %eax,0x4(%esp)
80108399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010839c:	89 04 24             	mov    %eax,(%esp)
8010839f:	e8 cc fe ff ff       	call   80108270 <mappages>
801083a4:	85 c0                	test   %eax,%eax
801083a6:	79 07                	jns    801083af <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801083a8:	b8 00 00 00 00       	mov    $0x0,%eax
801083ad:	eb 10                	jmp    801083bf <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801083af:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801083b3:	81 7d f4 40 c5 10 80 	cmpl   $0x8010c540,-0xc(%ebp)
801083ba:	72 ae                	jb     8010836a <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801083bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801083bf:	83 c4 34             	add    $0x34,%esp
801083c2:	5b                   	pop    %ebx
801083c3:	5d                   	pop    %ebp
801083c4:	c3                   	ret    

801083c5 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801083c5:	55                   	push   %ebp
801083c6:	89 e5                	mov    %esp,%ebp
801083c8:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801083cb:	e8 38 ff ff ff       	call   80108308 <setupkvm>
801083d0:	a3 58 aa 11 80       	mov    %eax,0x8011aa58
  switchkvm();
801083d5:	e8 02 00 00 00       	call   801083dc <switchkvm>
}
801083da:	c9                   	leave  
801083db:	c3                   	ret    

801083dc <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801083dc:	55                   	push   %ebp
801083dd:	89 e5                	mov    %esp,%ebp
801083df:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801083e2:	a1 58 aa 11 80       	mov    0x8011aa58,%eax
801083e7:	89 04 24             	mov    %eax,(%esp)
801083ea:	e8 4f f9 ff ff       	call   80107d3e <v2p>
801083ef:	89 04 24             	mov    %eax,(%esp)
801083f2:	e8 3c f9 ff ff       	call   80107d33 <lcr3>
}
801083f7:	c9                   	leave  
801083f8:	c3                   	ret    

801083f9 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801083f9:	55                   	push   %ebp
801083fa:	89 e5                	mov    %esp,%ebp
801083fc:	53                   	push   %ebx
801083fd:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108400:	e8 54 d2 ff ff       	call   80105659 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108405:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010840b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108412:	83 c2 08             	add    $0x8,%edx
80108415:	89 d3                	mov    %edx,%ebx
80108417:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010841e:	83 c2 08             	add    $0x8,%edx
80108421:	c1 ea 10             	shr    $0x10,%edx
80108424:	89 d1                	mov    %edx,%ecx
80108426:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010842d:	83 c2 08             	add    $0x8,%edx
80108430:	c1 ea 18             	shr    $0x18,%edx
80108433:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010843a:	67 00 
8010843c:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108443:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108449:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108450:	83 e1 f0             	and    $0xfffffff0,%ecx
80108453:	83 c9 09             	or     $0x9,%ecx
80108456:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010845c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108463:	83 c9 10             	or     $0x10,%ecx
80108466:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010846c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108473:	83 e1 9f             	and    $0xffffff9f,%ecx
80108476:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010847c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108483:	83 c9 80             	or     $0xffffff80,%ecx
80108486:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010848c:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108493:	83 e1 f0             	and    $0xfffffff0,%ecx
80108496:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010849c:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801084a3:	83 e1 ef             	and    $0xffffffef,%ecx
801084a6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801084ac:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801084b3:	83 e1 df             	and    $0xffffffdf,%ecx
801084b6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801084bc:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801084c3:	83 c9 40             	or     $0x40,%ecx
801084c6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801084cc:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801084d3:	83 e1 7f             	and    $0x7f,%ecx
801084d6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801084dc:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801084e2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801084e8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801084ef:	83 e2 ef             	and    $0xffffffef,%edx
801084f2:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801084f8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801084fe:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108504:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010850a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108511:	8b 52 08             	mov    0x8(%edx),%edx
80108514:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010851a:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010851d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108524:	e8 df f7 ff ff       	call   80107d08 <ltr>
  if(p->pgdir == 0)
80108529:	8b 45 08             	mov    0x8(%ebp),%eax
8010852c:	8b 40 04             	mov    0x4(%eax),%eax
8010852f:	85 c0                	test   %eax,%eax
80108531:	75 0c                	jne    8010853f <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108533:	c7 04 24 27 91 10 80 	movl   $0x80109127,(%esp)
8010853a:	e8 fb 7f ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010853f:	8b 45 08             	mov    0x8(%ebp),%eax
80108542:	8b 40 04             	mov    0x4(%eax),%eax
80108545:	89 04 24             	mov    %eax,(%esp)
80108548:	e8 f1 f7 ff ff       	call   80107d3e <v2p>
8010854d:	89 04 24             	mov    %eax,(%esp)
80108550:	e8 de f7 ff ff       	call   80107d33 <lcr3>
  popcli();
80108555:	e8 43 d1 ff ff       	call   8010569d <popcli>
}
8010855a:	83 c4 14             	add    $0x14,%esp
8010855d:	5b                   	pop    %ebx
8010855e:	5d                   	pop    %ebp
8010855f:	c3                   	ret    

80108560 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108560:	55                   	push   %ebp
80108561:	89 e5                	mov    %esp,%ebp
80108563:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108566:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010856d:	76 0c                	jbe    8010857b <inituvm+0x1b>
    panic("inituvm: more than a page");
8010856f:	c7 04 24 3b 91 10 80 	movl   $0x8010913b,(%esp)
80108576:	e8 bf 7f ff ff       	call   8010053a <panic>
  mem = kalloc();
8010857b:	e8 6f a5 ff ff       	call   80102aef <kalloc>
80108580:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108583:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010858a:	00 
8010858b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108592:	00 
80108593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108596:	89 04 24             	mov    %eax,(%esp)
80108599:	e8 bb d1 ff ff       	call   80105759 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010859e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a1:	89 04 24             	mov    %eax,(%esp)
801085a4:	e8 95 f7 ff ff       	call   80107d3e <v2p>
801085a9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801085b0:	00 
801085b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
801085b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085bc:	00 
801085bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801085c4:	00 
801085c5:	8b 45 08             	mov    0x8(%ebp),%eax
801085c8:	89 04 24             	mov    %eax,(%esp)
801085cb:	e8 a0 fc ff ff       	call   80108270 <mappages>
  memmove(mem, init, sz);
801085d0:	8b 45 10             	mov    0x10(%ebp),%eax
801085d3:	89 44 24 08          	mov    %eax,0x8(%esp)
801085d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801085da:	89 44 24 04          	mov    %eax,0x4(%esp)
801085de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e1:	89 04 24             	mov    %eax,(%esp)
801085e4:	e8 3f d2 ff ff       	call   80105828 <memmove>
}
801085e9:	c9                   	leave  
801085ea:	c3                   	ret    

801085eb <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801085eb:	55                   	push   %ebp
801085ec:	89 e5                	mov    %esp,%ebp
801085ee:	53                   	push   %ebx
801085ef:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801085f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801085f5:	25 ff 0f 00 00       	and    $0xfff,%eax
801085fa:	85 c0                	test   %eax,%eax
801085fc:	74 0c                	je     8010860a <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801085fe:	c7 04 24 58 91 10 80 	movl   $0x80109158,(%esp)
80108605:	e8 30 7f ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010860a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108611:	e9 a9 00 00 00       	jmp    801086bf <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108619:	8b 55 0c             	mov    0xc(%ebp),%edx
8010861c:	01 d0                	add    %edx,%eax
8010861e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108625:	00 
80108626:	89 44 24 04          	mov    %eax,0x4(%esp)
8010862a:	8b 45 08             	mov    0x8(%ebp),%eax
8010862d:	89 04 24             	mov    %eax,(%esp)
80108630:	e8 99 fb ff ff       	call   801081ce <walkpgdir>
80108635:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108638:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010863c:	75 0c                	jne    8010864a <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010863e:	c7 04 24 7b 91 10 80 	movl   $0x8010917b,(%esp)
80108645:	e8 f0 7e ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
8010864a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010864d:	8b 00                	mov    (%eax),%eax
8010864f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108654:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865a:	8b 55 18             	mov    0x18(%ebp),%edx
8010865d:	29 c2                	sub    %eax,%edx
8010865f:	89 d0                	mov    %edx,%eax
80108661:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108666:	77 0f                	ja     80108677 <loaduvm+0x8c>
      n = sz - i;
80108668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866b:	8b 55 18             	mov    0x18(%ebp),%edx
8010866e:	29 c2                	sub    %eax,%edx
80108670:	89 d0                	mov    %edx,%eax
80108672:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108675:	eb 07                	jmp    8010867e <loaduvm+0x93>
    else
      n = PGSIZE;
80108677:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010867e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108681:	8b 55 14             	mov    0x14(%ebp),%edx
80108684:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108687:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010868a:	89 04 24             	mov    %eax,(%esp)
8010868d:	e8 b9 f6 ff ff       	call   80107d4b <p2v>
80108692:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108695:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108699:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010869d:	89 44 24 04          	mov    %eax,0x4(%esp)
801086a1:	8b 45 10             	mov    0x10(%ebp),%eax
801086a4:	89 04 24             	mov    %eax,(%esp)
801086a7:	e8 c9 96 ff ff       	call   80101d75 <readi>
801086ac:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801086af:	74 07                	je     801086b8 <loaduvm+0xcd>
      return -1;
801086b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801086b6:	eb 18                	jmp    801086d0 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801086b8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c2:	3b 45 18             	cmp    0x18(%ebp),%eax
801086c5:	0f 82 4b ff ff ff    	jb     80108616 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801086cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086d0:	83 c4 24             	add    $0x24,%esp
801086d3:	5b                   	pop    %ebx
801086d4:	5d                   	pop    %ebp
801086d5:	c3                   	ret    

801086d6 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801086d6:	55                   	push   %ebp
801086d7:	89 e5                	mov    %esp,%ebp
801086d9:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801086dc:	8b 45 10             	mov    0x10(%ebp),%eax
801086df:	85 c0                	test   %eax,%eax
801086e1:	79 0a                	jns    801086ed <allocuvm+0x17>
    return 0;
801086e3:	b8 00 00 00 00       	mov    $0x0,%eax
801086e8:	e9 c1 00 00 00       	jmp    801087ae <allocuvm+0xd8>
  if(newsz < oldsz)
801086ed:	8b 45 10             	mov    0x10(%ebp),%eax
801086f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086f3:	73 08                	jae    801086fd <allocuvm+0x27>
    return oldsz;
801086f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801086f8:	e9 b1 00 00 00       	jmp    801087ae <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801086fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108700:	05 ff 0f 00 00       	add    $0xfff,%eax
80108705:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010870a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010870d:	e9 8d 00 00 00       	jmp    8010879f <allocuvm+0xc9>
    mem = kalloc();
80108712:	e8 d8 a3 ff ff       	call   80102aef <kalloc>
80108717:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010871a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010871e:	75 2c                	jne    8010874c <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108720:	c7 04 24 99 91 10 80 	movl   $0x80109199,(%esp)
80108727:	e8 74 7c ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010872c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010872f:	89 44 24 08          	mov    %eax,0x8(%esp)
80108733:	8b 45 10             	mov    0x10(%ebp),%eax
80108736:	89 44 24 04          	mov    %eax,0x4(%esp)
8010873a:	8b 45 08             	mov    0x8(%ebp),%eax
8010873d:	89 04 24             	mov    %eax,(%esp)
80108740:	e8 6b 00 00 00       	call   801087b0 <deallocuvm>
      return 0;
80108745:	b8 00 00 00 00       	mov    $0x0,%eax
8010874a:	eb 62                	jmp    801087ae <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010874c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108753:	00 
80108754:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010875b:	00 
8010875c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010875f:	89 04 24             	mov    %eax,(%esp)
80108762:	e8 f2 cf ff ff       	call   80105759 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108767:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010876a:	89 04 24             	mov    %eax,(%esp)
8010876d:	e8 cc f5 ff ff       	call   80107d3e <v2p>
80108772:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108775:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010877c:	00 
8010877d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108781:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108788:	00 
80108789:	89 54 24 04          	mov    %edx,0x4(%esp)
8010878d:	8b 45 08             	mov    0x8(%ebp),%eax
80108790:	89 04 24             	mov    %eax,(%esp)
80108793:	e8 d8 fa ff ff       	call   80108270 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108798:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010879f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a2:	3b 45 10             	cmp    0x10(%ebp),%eax
801087a5:	0f 82 67 ff ff ff    	jb     80108712 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801087ab:	8b 45 10             	mov    0x10(%ebp),%eax
}
801087ae:	c9                   	leave  
801087af:	c3                   	ret    

801087b0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801087b0:	55                   	push   %ebp
801087b1:	89 e5                	mov    %esp,%ebp
801087b3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801087b6:	8b 45 10             	mov    0x10(%ebp),%eax
801087b9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087bc:	72 08                	jb     801087c6 <deallocuvm+0x16>
    return oldsz;
801087be:	8b 45 0c             	mov    0xc(%ebp),%eax
801087c1:	e9 a4 00 00 00       	jmp    8010886a <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801087c6:	8b 45 10             	mov    0x10(%ebp),%eax
801087c9:	05 ff 0f 00 00       	add    $0xfff,%eax
801087ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801087d6:	e9 80 00 00 00       	jmp    8010885b <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801087db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087e5:	00 
801087e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801087ea:	8b 45 08             	mov    0x8(%ebp),%eax
801087ed:	89 04 24             	mov    %eax,(%esp)
801087f0:	e8 d9 f9 ff ff       	call   801081ce <walkpgdir>
801087f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801087f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087fc:	75 09                	jne    80108807 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801087fe:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108805:	eb 4d                	jmp    80108854 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010880a:	8b 00                	mov    (%eax),%eax
8010880c:	83 e0 01             	and    $0x1,%eax
8010880f:	85 c0                	test   %eax,%eax
80108811:	74 41                	je     80108854 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108816:	8b 00                	mov    (%eax),%eax
80108818:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010881d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108820:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108824:	75 0c                	jne    80108832 <deallocuvm+0x82>
        panic("kfree");
80108826:	c7 04 24 b1 91 10 80 	movl   $0x801091b1,(%esp)
8010882d:	e8 08 7d ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108832:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108835:	89 04 24             	mov    %eax,(%esp)
80108838:	e8 0e f5 ff ff       	call   80107d4b <p2v>
8010883d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108840:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108843:	89 04 24             	mov    %eax,(%esp)
80108846:	e8 0b a2 ff ff       	call   80102a56 <kfree>
      *pte = 0;
8010884b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010884e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108854:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010885b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108861:	0f 82 74 ff ff ff    	jb     801087db <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108867:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010886a:	c9                   	leave  
8010886b:	c3                   	ret    

8010886c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010886c:	55                   	push   %ebp
8010886d:	89 e5                	mov    %esp,%ebp
8010886f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108872:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108876:	75 0c                	jne    80108884 <freevm+0x18>
    panic("freevm: no pgdir");
80108878:	c7 04 24 b7 91 10 80 	movl   $0x801091b7,(%esp)
8010887f:	e8 b6 7c ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108884:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010888b:	00 
8010888c:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108893:	80 
80108894:	8b 45 08             	mov    0x8(%ebp),%eax
80108897:	89 04 24             	mov    %eax,(%esp)
8010889a:	e8 11 ff ff ff       	call   801087b0 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010889f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088a6:	eb 48                	jmp    801088f0 <freevm+0x84>
    if(pgdir[i] & PTE_P){
801088a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801088b2:	8b 45 08             	mov    0x8(%ebp),%eax
801088b5:	01 d0                	add    %edx,%eax
801088b7:	8b 00                	mov    (%eax),%eax
801088b9:	83 e0 01             	and    $0x1,%eax
801088bc:	85 c0                	test   %eax,%eax
801088be:	74 2c                	je     801088ec <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801088c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801088ca:	8b 45 08             	mov    0x8(%ebp),%eax
801088cd:	01 d0                	add    %edx,%eax
801088cf:	8b 00                	mov    (%eax),%eax
801088d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088d6:	89 04 24             	mov    %eax,(%esp)
801088d9:	e8 6d f4 ff ff       	call   80107d4b <p2v>
801088de:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801088e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e4:	89 04 24             	mov    %eax,(%esp)
801088e7:	e8 6a a1 ff ff       	call   80102a56 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801088ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088f0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801088f7:	76 af                	jbe    801088a8 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801088f9:	8b 45 08             	mov    0x8(%ebp),%eax
801088fc:	89 04 24             	mov    %eax,(%esp)
801088ff:	e8 52 a1 ff ff       	call   80102a56 <kfree>
}
80108904:	c9                   	leave  
80108905:	c3                   	ret    

80108906 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108906:	55                   	push   %ebp
80108907:	89 e5                	mov    %esp,%ebp
80108909:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010890c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108913:	00 
80108914:	8b 45 0c             	mov    0xc(%ebp),%eax
80108917:	89 44 24 04          	mov    %eax,0x4(%esp)
8010891b:	8b 45 08             	mov    0x8(%ebp),%eax
8010891e:	89 04 24             	mov    %eax,(%esp)
80108921:	e8 a8 f8 ff ff       	call   801081ce <walkpgdir>
80108926:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108929:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010892d:	75 0c                	jne    8010893b <clearpteu+0x35>
    panic("clearpteu");
8010892f:	c7 04 24 c8 91 10 80 	movl   $0x801091c8,(%esp)
80108936:	e8 ff 7b ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
8010893b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893e:	8b 00                	mov    (%eax),%eax
80108940:	83 e0 fb             	and    $0xfffffffb,%eax
80108943:	89 c2                	mov    %eax,%edx
80108945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108948:	89 10                	mov    %edx,(%eax)
}
8010894a:	c9                   	leave  
8010894b:	c3                   	ret    

8010894c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010894c:	55                   	push   %ebp
8010894d:	89 e5                	mov    %esp,%ebp
8010894f:	53                   	push   %ebx
80108950:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108953:	e8 b0 f9 ff ff       	call   80108308 <setupkvm>
80108958:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010895b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010895f:	75 0a                	jne    8010896b <copyuvm+0x1f>
    return 0;
80108961:	b8 00 00 00 00       	mov    $0x0,%eax
80108966:	e9 fd 00 00 00       	jmp    80108a68 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010896b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108972:	e9 d0 00 00 00       	jmp    80108a47 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108981:	00 
80108982:	89 44 24 04          	mov    %eax,0x4(%esp)
80108986:	8b 45 08             	mov    0x8(%ebp),%eax
80108989:	89 04 24             	mov    %eax,(%esp)
8010898c:	e8 3d f8 ff ff       	call   801081ce <walkpgdir>
80108991:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108994:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108998:	75 0c                	jne    801089a6 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010899a:	c7 04 24 d2 91 10 80 	movl   $0x801091d2,(%esp)
801089a1:	e8 94 7b ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
801089a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089a9:	8b 00                	mov    (%eax),%eax
801089ab:	83 e0 01             	and    $0x1,%eax
801089ae:	85 c0                	test   %eax,%eax
801089b0:	75 0c                	jne    801089be <copyuvm+0x72>
      panic("copyuvm: page not present");
801089b2:	c7 04 24 ec 91 10 80 	movl   $0x801091ec,(%esp)
801089b9:	e8 7c 7b ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801089be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c1:	8b 00                	mov    (%eax),%eax
801089c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801089cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ce:	8b 00                	mov    (%eax),%eax
801089d0:	25 ff 0f 00 00       	and    $0xfff,%eax
801089d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801089d8:	e8 12 a1 ff ff       	call   80102aef <kalloc>
801089dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
801089e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801089e4:	75 02                	jne    801089e8 <copyuvm+0x9c>
      goto bad;
801089e6:	eb 70                	jmp    80108a58 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801089e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089eb:	89 04 24             	mov    %eax,(%esp)
801089ee:	e8 58 f3 ff ff       	call   80107d4b <p2v>
801089f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801089fa:	00 
801089fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801089ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a02:	89 04 24             	mov    %eax,(%esp)
80108a05:	e8 1e ce ff ff       	call   80105828 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108a0a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108a0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a10:	89 04 24             	mov    %eax,(%esp)
80108a13:	e8 26 f3 ff ff       	call   80107d3e <v2p>
80108a18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a1b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108a1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108a23:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108a2a:	00 
80108a2b:	89 54 24 04          	mov    %edx,0x4(%esp)
80108a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a32:	89 04 24             	mov    %eax,(%esp)
80108a35:	e8 36 f8 ff ff       	call   80108270 <mappages>
80108a3a:	85 c0                	test   %eax,%eax
80108a3c:	79 02                	jns    80108a40 <copyuvm+0xf4>
      goto bad;
80108a3e:	eb 18                	jmp    80108a58 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108a40:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a4d:	0f 82 24 ff ff ff    	jb     80108977 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a56:	eb 10                	jmp    80108a68 <copyuvm+0x11c>

bad:
  freevm(d);
80108a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5b:	89 04 24             	mov    %eax,(%esp)
80108a5e:	e8 09 fe ff ff       	call   8010886c <freevm>
  return 0;
80108a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a68:	83 c4 44             	add    $0x44,%esp
80108a6b:	5b                   	pop    %ebx
80108a6c:	5d                   	pop    %ebp
80108a6d:	c3                   	ret    

80108a6e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108a6e:	55                   	push   %ebp
80108a6f:	89 e5                	mov    %esp,%ebp
80108a71:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108a74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a7b:	00 
80108a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a83:	8b 45 08             	mov    0x8(%ebp),%eax
80108a86:	89 04 24             	mov    %eax,(%esp)
80108a89:	e8 40 f7 ff ff       	call   801081ce <walkpgdir>
80108a8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a94:	8b 00                	mov    (%eax),%eax
80108a96:	83 e0 01             	and    $0x1,%eax
80108a99:	85 c0                	test   %eax,%eax
80108a9b:	75 07                	jne    80108aa4 <uva2ka+0x36>
    return 0;
80108a9d:	b8 00 00 00 00       	mov    $0x0,%eax
80108aa2:	eb 25                	jmp    80108ac9 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa7:	8b 00                	mov    (%eax),%eax
80108aa9:	83 e0 04             	and    $0x4,%eax
80108aac:	85 c0                	test   %eax,%eax
80108aae:	75 07                	jne    80108ab7 <uva2ka+0x49>
    return 0;
80108ab0:	b8 00 00 00 00       	mov    $0x0,%eax
80108ab5:	eb 12                	jmp    80108ac9 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aba:	8b 00                	mov    (%eax),%eax
80108abc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ac1:	89 04 24             	mov    %eax,(%esp)
80108ac4:	e8 82 f2 ff ff       	call   80107d4b <p2v>
}
80108ac9:	c9                   	leave  
80108aca:	c3                   	ret    

80108acb <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108acb:	55                   	push   %ebp
80108acc:	89 e5                	mov    %esp,%ebp
80108ace:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108ad1:	8b 45 10             	mov    0x10(%ebp),%eax
80108ad4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108ad7:	e9 87 00 00 00       	jmp    80108b63 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108adc:	8b 45 0c             	mov    0xc(%ebp),%eax
80108adf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ae4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108ae7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aea:	89 44 24 04          	mov    %eax,0x4(%esp)
80108aee:	8b 45 08             	mov    0x8(%ebp),%eax
80108af1:	89 04 24             	mov    %eax,(%esp)
80108af4:	e8 75 ff ff ff       	call   80108a6e <uva2ka>
80108af9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108afc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108b00:	75 07                	jne    80108b09 <copyout+0x3e>
      return -1;
80108b02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b07:	eb 69                	jmp    80108b72 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108b09:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b0c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108b0f:	29 c2                	sub    %eax,%edx
80108b11:	89 d0                	mov    %edx,%eax
80108b13:	05 00 10 00 00       	add    $0x1000,%eax
80108b18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b1e:	3b 45 14             	cmp    0x14(%ebp),%eax
80108b21:	76 06                	jbe    80108b29 <copyout+0x5e>
      n = len;
80108b23:	8b 45 14             	mov    0x14(%ebp),%eax
80108b26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108b29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b2f:	29 c2                	sub    %eax,%edx
80108b31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b34:	01 c2                	add    %eax,%edx
80108b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b39:	89 44 24 08          	mov    %eax,0x8(%esp)
80108b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b40:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b44:	89 14 24             	mov    %edx,(%esp)
80108b47:	e8 dc cc ff ff       	call   80105828 <memmove>
    len -= n;
80108b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b4f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b55:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108b58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b5b:	05 00 10 00 00       	add    $0x1000,%eax
80108b60:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108b63:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108b67:	0f 85 6f ff ff ff    	jne    80108adc <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108b6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b72:	c9                   	leave  
80108b73:	c3                   	ret    
