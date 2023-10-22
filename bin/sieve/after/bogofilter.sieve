require ["include", "fileinto", "envelope", "subaddress", "regex", "imap4flags", "mailbox", "date"];

if allof(
    header :contains "X-Bogosity" "Unsure"
) {
    fileinto :create "MaybeJunk";
    stop;
}

if anyof(
    header :contains "X-Spam-Status" "Yes,",
    header :contains "X-Bogosity" "Yes,",
    header :contains "X-Bogosity" "Spam,"
) {
    fileinto :create "Junk";
    stop;
}

keep;
