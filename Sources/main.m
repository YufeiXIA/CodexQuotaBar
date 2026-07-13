#import <Cocoa/Cocoa.h>

@interface UsageDashboardView : NSView
@property NSArray<NSDictionary *> *rows;
@property NSDate *updatedAt;
@property NSNumber *resetCredits;
@property NSArray<NSDictionary *> *resetCreditDetails;
- (instancetype)initWithRows:(NSArray<NSDictionary *> *)rows updatedAt:(NSDate *)updatedAt resetCredits:(NSNumber *)resetCredits resetCreditDetails:(NSArray<NSDictionary *> *)resetCreditDetails;
@end

@implementation UsageDashboardView

- (instancetype)initWithRows:(NSArray<NSDictionary *> *)rows updatedAt:(NSDate *)updatedAt resetCredits:(NSNumber *)resetCredits resetCreditDetails:(NSArray<NSDictionary *> *)resetCreditDetails {
    CGFloat resetHeight = resetCredits ? (resetCreditDetails ? 33 + resetCreditDetails.count * 21 : 49) : 10;
    CGFloat height = 42 + MAX(1, rows.count) * 57 + resetHeight;
    if (self = [super initWithFrame:NSMakeRect(0, 0, 308, height)]) {
        _rows = rows;
        _updatedAt = updatedAt;
        _resetCredits = resetCredits;
        _resetCreditDetails = resetCreditDetails;
    }
    return self;
}

- (BOOL)isFlipped { return YES; }

- (NSColor *)accentForRemaining:(double)remaining {
    if (remaining >= 50) return NSColor.systemGreenColor;
    if (remaining >= 20) return NSColor.systemOrangeColor;
    return NSColor.systemRedColor;
}

- (void)drawText:(NSString *)text in:(NSRect)rect font:(NSFont *)font color:(NSColor *)color alignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = alignment;
    [text drawInRect:rect withAttributes:@{NSFontAttributeName: font,
                                            NSForegroundColorAttributeName: color,
                                            NSParagraphStyleAttributeName: style}];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSRect card = NSInsetRect(self.bounds, 7, 4);
    NSBezierPath *cardPath = [NSBezierPath bezierPathWithRoundedRect:card xRadius:12 yRadius:12];
    NSColor *top = [NSColor.controlBackgroundColor blendedColorWithFraction:0.10 ofColor:NSColor.windowBackgroundColor];
    NSColor *bottom = [NSColor.controlBackgroundColor blendedColorWithFraction:0.28 ofColor:NSColor.windowBackgroundColor];
    [[[NSGradient alloc] initWithStartingColor:top endingColor:bottom] drawInBezierPath:cardPath angle:90];
    [[NSColor.separatorColor colorWithAlphaComponent:0.55] setStroke];
    cardPath.lineWidth = 1;
    [cardPath stroke];

    [self drawText:@"CODEX  用量" in:NSMakeRect(card.origin.x + 16, card.origin.y + 12, 160, 18)
                 font:[NSFont systemFontOfSize:12 weight:NSFontWeightSemibold]
                color:NSColor.labelColor alignment:NSTextAlignmentLeft];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"HH:mm";
    NSString *updated = [NSString stringWithFormat:@"实时 · %@", [formatter stringFromDate:self.updatedAt ?: NSDate.date]];
    [self drawText:updated in:NSMakeRect(NSMaxX(card) - 104, card.origin.y + 13, 88, 16)
                 font:[NSFont systemFontOfSize:10 weight:NSFontWeightRegular]
                color:NSColor.secondaryLabelColor alignment:NSTextAlignmentRight];

    CGFloat y = card.origin.y + 39;
    for (NSDictionary *row in self.rows) {
        NSDictionary *window = row[@"window"];
        double remaining = MAX(0, MIN(100, 100 - [window[@"used_percent"] doubleValue]));
        NSInteger seconds = [window[@"limit_window_seconds"] integerValue];
        NSString *windowName = seconds % 86400 == 0 ? [NSString stringWithFormat:@"%ld 天窗口", (long)(seconds / 86400)] : [NSString stringWithFormat:@"%ld 小时窗口", (long)(seconds / 3600)];
        NSString *title = [NSString stringWithFormat:@"%@ · %@", row[@"name"], windowName];
        NSColor *accent = [self accentForRemaining:remaining];
        [self drawText:title in:NSMakeRect(card.origin.x + 16, y, 185, 16)
                     font:[NSFont systemFontOfSize:11.5 weight:NSFontWeightMedium]
                    color:NSColor.labelColor alignment:NSTextAlignmentLeft];
        NSString *percentage = [NSString stringWithFormat:@"%.0f%%", remaining];
        [self drawText:percentage in:NSMakeRect(NSMaxX(card) - 64, y - 4, 48, 22)
                     font:[NSFont monospacedDigitSystemFontOfSize:17 weight:NSFontWeightSemibold]
                    color:accent alignment:NSTextAlignmentRight];

        NSRect track = NSMakeRect(card.origin.x + 16, y + 23, card.size.width - 32, 8);
        NSBezierPath *trackPath = [NSBezierPath bezierPathWithRoundedRect:track xRadius:4 yRadius:4];
        [[NSColor.separatorColor colorWithAlphaComponent:0.72] setFill];
        [trackPath fill];
        if (remaining > 0) {
            NSRect fill = track;
            fill.size.width = MAX(3, track.size.width * remaining / 100.0);
            NSBezierPath *fillPath = [NSBezierPath bezierPathWithRoundedRect:fill xRadius:4 yRadius:4];
            NSColor *highlight = [accent highlightWithLevel:0.18];
            [[[NSGradient alloc] initWithStartingColor:accent endingColor:highlight] drawInBezierPath:fillPath angle:0];
        }
        NSString *detail = [NSString stringWithFormat:@"已用 %.0f%%  ·  %@", [window[@"used_percent"] doubleValue], [self resetTextForWindow:window]];
        [self drawText:detail in:NSMakeRect(card.origin.x + 16, y + 36, card.size.width - 32, 14)
                     font:[NSFont systemFontOfSize:10.5 weight:NSFontWeightRegular]
                    color:NSColor.secondaryLabelColor alignment:NSTextAlignmentLeft];
        y += 57;
    }
    if (self.resetCredits) {
        [[NSColor.separatorColor colorWithAlphaComponent:0.55] setStroke];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(card.origin.x + 16, y - 2) toPoint:NSMakePoint(NSMaxX(card) - 16, y - 2)];
        [self drawText:@"限额重置卡" in:NSMakeRect(card.origin.x + 16, y + 7, 130, 17)
                     font:[NSFont systemFontOfSize:11.5 weight:NSFontWeightMedium]
                    color:NSColor.labelColor alignment:NSTextAlignmentLeft];
        [self drawText:[NSString stringWithFormat:@"%@ 张", self.resetCredits] in:NSMakeRect(NSMaxX(card) - 64, y + 2, 48, 22)
                     font:[NSFont monospacedDigitSystemFontOfSize:17 weight:NSFontWeightSemibold]
                    color:NSColor.systemBlueColor alignment:NSTextAlignmentRight];
        if (!self.resetCreditDetails) {
            [self drawText:@"正在读取每张卡的到期日…" in:NSMakeRect(card.origin.x + 16, y + 26, card.size.width - 32, 14)
                         font:[NSFont systemFontOfSize:10.5 weight:NSFontWeightRegular]
                        color:NSColor.secondaryLabelColor alignment:NSTextAlignmentLeft];
        } else {
            CGFloat creditY = y + 27;
            NSUInteger number = 1;
            for (NSDictionary *credit in self.resetCreditDetails) {
                [self drawText:[NSString stringWithFormat:@"卡 %lu", (unsigned long)number++] in:NSMakeRect(card.origin.x + 16, creditY, 38, 14)
                             font:[NSFont systemFontOfSize:10.5 weight:NSFontWeightMedium]
                            color:NSColor.secondaryLabelColor alignment:NSTextAlignmentLeft];
                [self drawText:[self resetCardExpiryText:[self dateForCredit:credit]] in:NSMakeRect(card.origin.x + 55, creditY, card.size.width - 71, 14)
                             font:[NSFont systemFontOfSize:10.5 weight:NSFontWeightRegular]
                            color:NSColor.secondaryLabelColor alignment:NSTextAlignmentRight];
                creditY += 21;
            }
        }
    }
}

- (NSString *)resetTextForWindow:(NSDictionary *)window {
    NSTimeInterval resetAt = [window[@"reset_at"] doubleValue];
    NSInteger seconds = MAX(0, (NSInteger)(resetAt - NSDate.date.timeIntervalSince1970));
    NSInteger days = seconds / 86400, hours = (seconds % 86400) / 3600, minutes = (seconds % 3600) / 60;
    if (days) return [NSString stringWithFormat:@"%ld天%ld小时后重置", (long)days, (long)hours];
    if (hours) return [NSString stringWithFormat:@"%ld小时%ld分后重置", (long)hours, (long)minutes];
    return seconds ? [NSString stringWithFormat:@"%ld分钟后重置", (long)MAX(1, minutes)] : @"即将重置";
}

- (NSString *)resetCardExpiryText:(NSDate *)date {
    if (!date) return @"到期日未知";
    NSInteger seconds = MAX(0, (NSInteger)[date timeIntervalSinceNow]);
    NSInteger days = seconds / 86400, hours = (seconds % 86400) / 3600;
    if (seconds == 0) return @"已到期";
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"M月d日 HH:mm";
    NSString *dateText = [formatter stringFromDate:date];
    if (days) return [NSString stringWithFormat:@"%@ · %ld天%ld小时后到期", dateText, (long)days, (long)hours];
    return [NSString stringWithFormat:@"%@ · %ld小时后到期", dateText, (long)MAX(1, hours)];
}

- (NSDate *)dateForCredit:(NSDictionary *)credit {
    NSString *rawDate = [credit[@"expires_at"] isKindOfClass:NSString.class] ? credit[@"expires_at"] : nil;
    return rawDate ? [[NSISO8601DateFormatter new] dateFromString:rawDate] : nil;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property NSStatusItem *statusItem;
@property NSTimer *refreshTimer;
@property NSTimer *displayTimer;
@property NSDictionary *usage;
@property NSArray<NSDictionary *> *resetCreditDetails;
@property NSString *lastError;
@property BOOL refreshing;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.image = [NSImage imageWithSystemSymbolName:@"gauge.with.dots.needle.67percent" accessibilityDescription:@"Codex 用量"];
    self.statusItem.button.image.template = YES;
    self.statusItem.button.title = @" --";
    self.statusItem.button.toolTip = @"Codex 用量余额";
    [self rebuildMenu];
    [self refreshUsage];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(refreshUsage) userInfo:nil repeats:YES];
    self.displayTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateDisplay) userInfo:nil repeats:YES];
}

- (void)refreshUsage {
    if (self.refreshing) return;
    self.refreshing = YES;
    self.lastError = nil;
    [self rebuildMenu];

    NSURL *authURL = [[[NSFileManager defaultManager] homeDirectoryForCurrentUser] URLByAppendingPathComponent:@".codex/auth.json"];
    NSError *error = nil;
    NSData *authData = [NSData dataWithContentsOfURL:authURL options:0 error:&error];
    NSDictionary *auth = authData ? [NSJSONSerialization JSONObjectWithData:authData options:0 error:&error] : nil;
    NSDictionary *tokens = [auth[@"tokens"] isKindOfClass:NSDictionary.class] ? auth[@"tokens"] : nil;
    NSString *token = tokens[@"access_token"];
    if (!token.length) {
        self.refreshing = NO;
        self.lastError = @"未找到 Codex 登录凭据";
        [self updateDisplay];
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://chatgpt.com/backend-api/wham/usage"]];
    [request setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    if ([tokens[@"account_id"] isKindOfClass:NSString.class]) [request setValue:tokens[@"account_id"] forHTTPHeaderField:@"ChatGPT-Account-Id"];
    request.timeoutInterval = 20;

    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *networkError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *self = weakSelf;
            if (!self) return;
            self.refreshing = NO;
            NSHTTPURLResponse *http = [response isKindOfClass:NSHTTPURLResponse.class] ? (NSHTTPURLResponse *)response : nil;
            NSError *jsonError = nil;
            NSDictionary *result = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;
            if (networkError || http.statusCode != 200 || ![result isKindOfClass:NSDictionary.class]) {
                self.lastError = networkError.localizedDescription ?: [NSString stringWithFormat:@"用量接口返回 HTTP %ld", (long)http.statusCode];
            } else {
                self.usage = result;
                self.lastError = nil;
                self.usage = [self.usage mutableCopy];
                [(NSMutableDictionary *)self.usage setObject:[NSDate date] forKey:@"_fetchedAt"];
                [self fetchResetCreditDetailsWithToken:token accountID:tokens[@"account_id"]];
            }
            [self updateDisplay];
        });
    }] resume];
}

- (void)fetchResetCreditDetailsWithToken:(NSString *)token accountID:(NSString *)accountID {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://chatgpt.com/backend-api/wham/rate-limit-reset-credits"]];
    [request setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    if ([accountID isKindOfClass:NSString.class]) [request setValue:accountID forHTTPHeaderField:@"ChatGPT-Account-Id"];
    [request setValue:@"Codex Desktop" forHTTPHeaderField:@"Originator"];
    request.timeoutInterval = 20;

    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *http = [response isKindOfClass:NSHTTPURLResponse.class] ? (NSHTTPURLResponse *)response : nil;
        NSError *jsonError = nil;
        NSDictionary *result = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;
        NSArray *credits = [result[@"credits"] isKindOfClass:NSArray.class] ? result[@"credits"] : nil;
        if (error || http.statusCode != 200 || !credits) return;
        NSPredicate *available = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *credit, NSDictionary *bindings) {
            return [credit[@"status"] isEqualToString:@"available"];
        }];
        NSArray *filtered = [credits filteredArrayUsingPredicate:available];
        NSArray *sorted = [filtered sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *left, NSDictionary *right) {
            return [left[@"expires_at"] compare:right[@"expires_at"]];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *self = weakSelf;
            if (!self) return;
            self.resetCreditDetails = sorted;
            [self updateDisplay];
        });
    }] resume];
}

- (NSArray<NSDictionary *> *)windowsForLimit:(NSDictionary *)limit {
    NSMutableArray *windows = [NSMutableArray array];
    for (NSString *key in @[@"primary_window", @"secondary_window"]) {
        NSDictionary *window = [limit[key] isKindOfClass:NSDictionary.class] ? limit[key] : nil;
        if ([window[@"used_percent"] respondsToSelector:@selector(doubleValue)]) [windows addObject:window];
    }
    return windows;
}

- (NSString *)windowName:(NSDictionary *)window {
    NSInteger seconds = [window[@"limit_window_seconds"] integerValue];
    if (seconds > 0 && seconds % 604800 == 0) return [NSString stringWithFormat:@"%ld 天窗口", (long)(seconds / 86400)];
    if (seconds > 0 && seconds % 86400 == 0) return [NSString stringWithFormat:@"%ld 天窗口", (long)(seconds / 86400)];
    if (seconds > 0 && seconds % 3600 == 0) return [NSString stringWithFormat:@"%ld 小时窗口", (long)(seconds / 3600)];
    return @"限额窗口";
}

- (double)remaining:(NSDictionary *)window { return MAX(0, MIN(100, 100 - [window[@"used_percent"] doubleValue])); }

- (NSString *)percent:(double)value {
    return fabs(round(value) - value) < 0.01 ? [NSString stringWithFormat:@"%.0f%%", value] : [NSString stringWithFormat:@"%.1f%%", value];
}

- (NSString *)progress:(double)remaining {
    NSInteger filled = MAX(0, MIN(10, (NSInteger)llround(remaining / 10.0)));
    return [[@"●●●●●●●●●●" substringToIndex:filled] stringByAppendingString:[@"○○○○○○○○○○" substringToIndex:10 - filled]];
}

- (NSString *)resetText:(NSDictionary *)window {
    NSTimeInterval resetAt = [window[@"reset_at"] doubleValue];
    if (resetAt <= 0) return @"重置时间未知";
    NSInteger seconds = MAX(0, (NSInteger)(resetAt - NSDate.date.timeIntervalSince1970));
    if (seconds == 0) return @"即将重置";
    NSInteger days = seconds / 86400, hours = (seconds % 86400) / 3600, minutes = (seconds % 3600) / 60;
    if (days) return [NSString stringWithFormat:@"%ld天%ld小时后重置", (long)days, (long)hours];
    if (hours) return [NSString stringWithFormat:@"%ld小时%ld分后重置", (long)hours, (long)minutes];
    return [NSString stringWithFormat:@"%ld分钟后重置", (long)MAX(1, minutes)];
}

- (void)addDisabled:(NSString *)title to:(NSMenu *)menu {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
    item.enabled = NO;
    [menu addItem:item];
}

- (void)updateDisplay {
    NSDictionary *limit = [self.usage[@"rate_limit"] isKindOfClass:NSDictionary.class] ? self.usage[@"rate_limit"] : nil;
    NSArray *windows = [self windowsForLimit:limit ?: @{}];
    if (windows.count) {
        double minimum = 100;
        for (NSDictionary *window in windows) minimum = MIN(minimum, [self remaining:window]);
        self.statusItem.button.title = [NSString stringWithFormat:@" %@", [self percent:minimum]];
    } else self.statusItem.button.title = @" --";
    [self rebuildMenu];
}

- (NSArray<NSDictionary *> *)dashboardRows {
    NSMutableArray *rows = [NSMutableArray array];
    NSDictionary *limit = [self.usage[@"rate_limit"] isKindOfClass:NSDictionary.class] ? self.usage[@"rate_limit"] : nil;
    for (NSDictionary *window in [self windowsForLimit:limit ?: @{}]) {
        [rows addObject:@{ @"name": @"Codex", @"window": window }];
    }
    NSArray *additional = [self.usage[@"additional_rate_limits"] isKindOfClass:NSArray.class] ? self.usage[@"additional_rate_limits"] : @[];
    for (NSDictionary *entry in additional) {
        NSDictionary *extraLimit = [entry[@"rate_limit"] isKindOfClass:NSDictionary.class] ? entry[@"rate_limit"] : nil;
        for (NSDictionary *window in [self windowsForLimit:extraLimit ?: @{}]) {
            NSString *name = entry[@"limit_name"] ?: @"附加限额";
            [rows addObject:@{ @"name": name, @"window": window }];
        }
    }
    return rows;
}

- (void)rebuildMenu {
    NSMenu *menu = [NSMenu new];
    [self addDisabled:@"Codex 用量余额" to:menu];
    [menu addItem:NSMenuItem.separatorItem];
    NSDictionary *limit = [self.usage[@"rate_limit"] isKindOfClass:NSDictionary.class] ? self.usage[@"rate_limit"] : nil;
    NSArray *mainWindows = [self windowsForLimit:limit ?: @{}];
    if (mainWindows.count) {
        NSDictionary *resetCreditInfo = [self.usage[@"rate_limit_reset_credits"] isKindOfClass:NSDictionary.class] ? self.usage[@"rate_limit_reset_credits"] : nil;
        NSNumber *resetCredits = [resetCreditInfo[@"available_count"] respondsToSelector:@selector(integerValue)] ? resetCreditInfo[@"available_count"] : nil;
        UsageDashboardView *dashboard = [[UsageDashboardView alloc] initWithRows:[self dashboardRows] updatedAt:self.usage[@"_fetchedAt"] resetCredits:resetCredits resetCreditDetails:self.resetCreditDetails];
        NSMenuItem *dashboardItem = [NSMenuItem new];
        dashboardItem.view = dashboard;
        [menu addItem:dashboardItem];
        [menu addItem:NSMenuItem.separatorItem];
        NSString *plan = self.usage[@"plan_type"] ?: @"未知";
        [self addDisabled:[NSString stringWithFormat:@"套餐：%@", [plan.lowercaseString isEqualToString:@"prolite"] ? @"Pro" : plan] to:menu];
        NSDictionary *credits = [self.usage[@"credits"] isKindOfClass:NSDictionary.class] ? self.usage[@"credits"] : nil;
        if (credits) [self addDisabled:[NSString stringWithFormat:@"额外点数：%@", [credits[@"has_credits"] boolValue] ? (credits[@"balance"] ?: @"可用") : @"未启用"] to:menu];
        NSDateFormatter *formatter = [NSDateFormatter new]; formatter.dateFormat = @"HH:mm";
        [self addDisabled:[NSString stringWithFormat:@"实时数据 · 更新于 %@", [formatter stringFromDate:self.usage[@"_fetchedAt"] ?: NSDate.date]] to:menu];
    } else {
        [self addDisabled:self.refreshing ? @"正在读取…" : @"暂无用量数据" to:menu];
    }
    if (self.lastError.length) [self addDisabled:[@"⚠︎ " stringByAppendingString:self.lastError] to:menu];
    [menu addItem:NSMenuItem.separatorItem];
    NSMenuItem *refresh = [[NSMenuItem alloc] initWithTitle:self.refreshing ? @"正在刷新…" : @"立即刷新" action:@selector(refreshUsage) keyEquivalent:@"r"];
    refresh.target = self; refresh.enabled = !self.refreshing; [menu addItem:refresh];
    NSMenuItem *open = [[NSMenuItem alloc] initWithTitle:@"打开 Codex 用量页面" action:@selector(openUsagePage) keyEquivalent:@""];
    open.target = self; [menu addItem:open];
    [menu addItem:NSMenuItem.separatorItem];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"退出" action:@selector(quitApp) keyEquivalent:@"q"];
    quit.target = self; [menu addItem:quit];
    self.statusItem.menu = menu;
}

- (void)openUsagePage { [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://chatgpt.com/codex/settings/usage"]]; }
- (void)quitApp { [NSApp terminate:nil]; }
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [AppDelegate new];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [app run];
    }
    return 0;
}
