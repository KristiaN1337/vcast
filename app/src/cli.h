#ifndef vcast_CLI_H
#define vcast_CLI_H

#include <stdbool.h>

#include "config.h"
#include "vcast.h"

struct vcast_cli_args {
    struct vcast_options opts;
    bool help;
    bool version;
};

void
vcast_print_usage(const char *arg0);

bool
vcast_parse_args(struct vcast_cli_args *args, int argc, char *argv[]);

#endif
