const std = @import("std");

const Lifegame = struct {
    alloc: std.mem.Allocator,
    row: usize,
    col: usize,
    grid: std.ArrayList(std.ArrayList(bool)),

    const Self = @This();

    pub fn init(alloc: std.mem.Allocator, row: usize, col: usize) !Self {
        var grid = try initGrid(alloc, row, col);

        for (grid.items) |r| {
            for (r.items) |*el| {
                if (std.crypto.random.int(usize) % 10 == 0) {
                    el.* = true;
                }
            }
        }

        return Self{
            .alloc = alloc,
            .row = row,
            .col = col,
            .grid = grid,
        };
    }

    pub fn deinit(self: *Self) void {
        for (self.grid.items) |row| {
            row.deinit();
        }

        self.grid.deinit();
    }

    pub fn render(self: *Self) void {
        std.debug.print("\x1b[0;0H", .{});

        for (self.grid.items) |row| {
            for (row.items) |el| {
                if (el) {
                    std.debug.print("{s}", .{"■"});
                } else {
                    std.debug.print("{s}", .{" "});
                }
            }

            std.debug.print("\n", .{});
        }
    }

    pub fn update(self: *Self) !void {
        var new = try initGrid(self.alloc, self.row, self.col);

        for (new.items) |row, i| {
            for (row.items) |*el, j| {
                el.* = self.deriveState(i, j);
            }
        }

        self.deinit();
        self.grid = new;
    }

    fn deriveState(self: *Self, r: usize, c: usize) bool {
        const row = @intCast(i32, r);
        const col = @intCast(i32, c);

        var state = self.countNeighbor(row - 1, col - 1) +
            self.countNeighbor(row - 1, col) +
            self.countNeighbor(row - 1, col + 1) +
            self.countNeighbor(row, col - 1) +
            self.countNeighbor(row, col + 1) +
            self.countNeighbor(row + 1, col - 1) +
            self.countNeighbor(row + 1, col) +
            self.countNeighbor(row + 1, col + 1);

        switch (state) {
            2 => return self.grid.items[r].items[c],
            3 => return true,
            else => return false,
        }
    }

    fn countNeighbor(self: *Self, row: i32, col: i32) usize {
        if (row < 0 or self.row <= row) {
            return 0;
        }

        if (col < 0 or self.col <= col) {
            return 0;
        }

        const r = @intCast(usize, row);
        const c = @intCast(usize, col);

        if (self.grid.items[r].items[c]) {
            return 1;
        } else {
            return 0;
        }
    }

    fn initGrid(alloc: std.mem.Allocator, row: usize, col: usize) !std.ArrayList(std.ArrayList(bool)) {
        var grid = std.ArrayList(std.ArrayList(bool)).init(alloc);
        var r: usize = 0;
        while (r < row) : (r += 1) {
            var a = std.ArrayList(bool).init(alloc);
            var c: usize = 0;
            while (c < col) : (c += 1) {
                try a.append(false);
            }

            try grid.append(a);
        }

        return grid;
    }
};

pub fn main() anyerror!void {
    var lg = try Lifegame.init(std.heap.page_allocator, 100, 100);
    defer lg.deinit();

    lg.render();

    while (true) {
        std.time.sleep(1000 * 1000 * 500);
        try lg.update();
        lg.render();
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
