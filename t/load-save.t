 # -*- perl -*-
# test that clear(), load(), merge(), save() and all_commands() work

use Test::More tests => 9;
use warnings;
use strict;

BEGIN { use_ok 'Test::MockCommand'; }

my @cmds = Test::MockCommand->all_commands();
ok @cmds == 0, 'no commands by default';

# turn on recording
Test::MockCommand->recording(1);

# run two recordable commands
my $fh; open($fh, "echo test |") && close $fh;
system("echo hello");

# save db to test1.db
Test::MockCommand->save('test1.db');
ok -s 'test1.db', 'check that save wrote something to test1.db';

# clear the database
Test::MockCommand->clear();

# run one command
readpipe('echo world');

# save db to test2.db
Test::MockCommand->save('test2.db');
ok -s 'test2.db', 'check that save wrote something to test2.db';

# check there's just one command in the database at the moment
is scalar(Test::MockCommand->all_commands()), 1, 'should be only 1 command';

# load (not merge) test1.db
Test::MockCommand->load('test1.db');

# check there's 2 commands (1 cleared, 2 loaded)
is scalar(Test::MockCommand->all_commands()), 2, 'two commands after load';

# merge test2.db
Test::MockCommand->merge('test2.db');

# check there's 3 commands (1 cleared, 2 loaded)
is scalar(Test::MockCommand->all_commands()), 3, 'three commands after merge';

# save all 3 commands to test3.db and merge it back in -> 6 commands
Test::MockCommand->save('test3.db');
ok -s 'test1.db', 'check that save wrote something to test3.db';
Test::MockCommand->merge('test3.db');
is scalar(Test::MockCommand->all_commands()), 6, 'six commands after merge';

# clean up
map { die "deleting $_: $!" unless unlink $_ } qw(test1.db test2.db test3.db);
