const std = @import("std");
const assert = @import("assert");

pub const ZERO_POS: Position = .{.row = 0, .col = 0};
pub const ZERO_POS_F: Vec2 = .{.x = 0.0, .y = 0.0};
pub const ZERO_SIZED: Sized = .{.cols = 3, .pos = ZERO_POS};

pub fn min(a: f64, b: f64) f64 {
    return if (a > b) b else a;
}

pub fn usizeToIsizeSub(a: usize, b: usize) isize {
    const ai: isize = @intCast(a);
    const bi: isize = @intCast(b);
    return ai - bi;
}

pub fn absUsize(a: usize, b: usize) usize {
    if (a > b) {
        return a - b;
    }
    return b - a;
}

const needle: [1]u8 = .{','};

pub const Position = struct {
    row: usize,
    col: usize,

    pub fn vec2(self: Position) Vec2 {
        return .{
            .x = @floatFromInt(self.col),
            .y = @floatFromInt(self.row),
        };
    }

    pub fn toIdx(self: Position, cols: usize) usize {
        return self.row * cols + self.col;
    }

    pub fn fromIdx(idx: usize, cols: usize) Position {
        return .{
            .row = idx / cols,
            .col = idx % cols,
        };
    }

    pub fn init(str: []const u8) ?Position {
        const idxMaybe = std.mem.indexOf(u8, str, ",");
        if (idxMaybe == null) {
            return null;
        }

        const idx = idxMaybe.?;
        const row = std.fmt.parseInt(usize, str[0..idx], 10) catch {
            return null;
        };
        const col = std.fmt.parseInt(usize, str[idx + 1..], 10) catch {
            return null;
        };

        return .{
            .row = row,
            .col = col,
        };
    }

    pub fn string(self: Position, buf: []u8) !usize {
        const out = try std.fmt.bufPrint(buf, "vec(r = {}, c = {})", self.row, self.col);
        return out.len;
    }
};

pub const Sized = struct {
    cols: usize,
    pos: Position,
};

pub const Coord = struct {
    pos: Position,
    team: u8,

    pub fn string(self: Coord, buf: []u8) !usize {
        assert(buf.len < 30, "needed buf with at least 20 characters");
        var out = try std.fmt.bufPrint(buf, "choord(team = {} pos", .{self.team, self.pos});
        var len = out.len;
        len += try self.pos.string(buf[len..]);
        out = try std.fmt.bufPrint(buf[len..], ")", .{});

        return len + out.len;
    }

    pub fn init(msg: []const u8) ?Coord {
        const teamNumber = msg[0];
        if (teamNumber != '1' and teamNumber != '2') {
            return null;
        }
        const pos = Position.init(msg[1..]);
        if (pos == null) {
            return null;
        }

        return .{
            .pos = pos.?,
            .team = teamNumber,
        };
    }
};

pub const Vec2 = struct {
    x: f64,
    y: f64,

    pub fn eql(self: Vec2, b: Vec2) bool {
        return self.x == b.x and self.y == b.y;
    }

    pub fn norm(self: Vec2) Vec2 {
        const l = self.len();
        return .{
            .x = self.x / l,
            .y = self.y / l,
        };
    }

    pub fn subP(self: Vec2, b: Position) Vec2 {
        const rf: f64 = @floatFromInt(b.row);
        const cf: f64 = @floatFromInt(b.col);

        return .{
            .x = self.x - cf,
            .y = self.y - rf,
        };
    }

    pub fn len(self: Vec2) f64 {
        return std.math.sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn add(self: Vec2, b: Vec2) Vec2 {
        return .{
            .x = self.x + b.x,
            .y = self.y + b.y,
        };
    }

    pub fn scale(self: Vec2, s: f64) Vec2 {
        return .{
            .x = self.x * s,
            .y = self.y * s,
        };
    }

    pub fn position(self: *Vec2) Position {
        assert(self.x >= 0, "x cannot be negative");
        assert(self.y >= 0, "y cannot be negative");

        return .{
            .row = @intFromFloat(self.y),
            .col = @intFromFloat(self.x),
        };
    }

    pub fn fromPosition(pos: Position) Vec2 {
        return .{
            .y = @floatFromInt(pos.row),
            .x = @floatFromInt(pos.col),
        };
    }

    pub fn string(self: Vec2, buf: []u8) !usize {
        const out = try std.fmt.bufPrint(buf, "x = {}, y = {}", .{self.x, self.y});
        return out.len;
    }

};

const t = std.testing;
test "vec2 add" {
    const a = Vec2{.x = 1, .y = 2};
    const b = Vec2{.x = 68, .y = 418};
    try t.expect(a.add(b).eql(Vec2{.x = 69, .y = 420}));
}
