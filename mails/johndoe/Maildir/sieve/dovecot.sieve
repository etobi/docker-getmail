require ["fileinto", "envelope", "subaddress", "regex", "imap4flags"];

# if address :regex "to" "[+]*+test@.*" {
if envelope :detail "to" "test" {
    fileinto "test";
    stop;
}

if allof(
    header :contains "X-Spam" "Yes",
    header :contains "X-Bogosity" "Yes"
) {
    setflag "\\seen";
}

if anyof(
    header :contains "X-Spam" "Yes",
    header :contains "X-Spam-Status" "Yes",
    header :contains "X-Bogosity" "Yes",
    header :contains "X-Bogosity" "Unsure"
) {
    addflag "\\Seen";
    fileinto "9_SPAM";
    stop;
}

keep;
