require ["include", "variables", "envelope", "regex", "vnd.dovecot.execute"];

if envelope :matches "from" "*" { set "from" "${1}"; }

if allof(
    header :contains "X-Spam-Status" "No",
    header :contains "X-Bogosity" "Ham,"
) {
	execute :pipe "statsd.sh" ["ham", "ham", "${from}"];
}

if allof(
    header :contains "X-Spam-Status" "No",
    header :contains "X-Bogosity" "Spam,"
) {
	execute :pipe "statsd.sh" ["ham", "spam", "${from}"];
}

if allof(
    header :contains "X-Spam-Status" "No",
    header :contains "X-Bogosity" "Unsure"
) {
	execute :pipe "statsd.sh" ["ham", "unsure", "${from}"];
}

if allof(
    header :contains "X-Spam-Status" "Yes",
    header :contains "X-Bogosity" "Ham,"
) {
	execute :pipe "statsd.sh" ["spam", "ham", "${from}"];
}

if allof(
    header :contains "X-Spam-Status" "Yes",
    header :contains "X-Bogosity" "Spam,"
) {
	execute :pipe "statsd.sh" ["spam", "spam", "${from}"];
}

if allof(
    header :contains "X-Spam-Status" "Yes",
    header :contains "X-Bogosity" "Unsure"
) {
	execute :pipe "statsd.sh" ["spam", "unsure", "${from}"];
}
