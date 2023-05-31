const PERIPH_BASE = 0x40000000;
// const PERIPH_BASE_APB1 = PERIPH_BASE + 0x00000;
const PERIPH_BASE_APB2 = PERIPH_BASE + 0x10000;
const PERIPH_BASE_AHB = PERIPH_BASE + 0x20000;

const GPIO_PORT_B_BASE = PERIPH_BASE_APB2 + 0x0C00;

const RCC_BASE = PERIPH_BASE_AHB + 0x1000;

const APB2ENR = RCC_BASE + 0x18;

fn GPIO(comptime base: usize) type {
    return struct {
        // Port configuration
        const CRL = @intToPtr(*volatile u32, base + 0x00);
        const CRH = @intToPtr(*volatile u32, base + 0x04);
        // Port input
        const IDR = @intToPtr(*volatile u32, base + 0x08);
        // Port output
        const ODR = @intToPtr(*volatile u32, base + 0x0c);

        pub fn init() void {
            CRH.* = 0x100;
        }

        pub fn read() u16 {
            return @truncate(u16, IDR.*);
        }

        pub fn write(val: u16) void {
            ODR.* = @as(u32, val);
        }
    };
}

export fn main() void {
    const APB2EN = @intToPtr(*volatile u32, APB2ENR);
    // GPIOB 开启
    APB2EN.* = 1 << 3;
    const GPIOB = GPIO(GPIO_PORT_B_BASE);
    // GPIOB 初始化
    GPIOB.init();
    while (true) {
        // Toggle LED (PB10)
        GPIOB.write(GPIOB.read() ^ (1 << 10));
        // Sleep for some time
        var i: usize = 0;
        while (i < 600000) : (i += 1) {
            asm volatile ("nop");
        }
    }
}
