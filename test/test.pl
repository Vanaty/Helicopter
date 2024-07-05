use Tkx;
use DBI;
require "../Util.pl";
my $mw = Tkx::widget->new(".");
our $f = $mw->new_ttk__frame; $f->g_grid();
our $b = $f->new_ttk__button(-text => "Start!", -command => sub{start()}); $b->g_grid(-column => 1, -row => 0, -padx => 5, -pady => 5);
our $l = $f->new_ttk__label(-text => "No Answer"); $l->g_grid(-column => 0, -row => 0, -padx => 5, -pady => 5);
our $p = $f->new_ttk__progressbar(-orient => "horizontal", -mode => "determinate", -maximum => 20); 
$p->g_grid(-column => 0, -row => 1, -padx => 5, -pady => 5);

our $interrupt;
sub start {
    $b->configure(-text => "Stop", -command => sub{stop()});
    $l->configure(-text => "Working...");
    $interrupt = 0;
    Tkx::after(1, sub{step()});
}
    
sub stop {
    $interrupt = 1;
}

sub step {
    my ($count) = @_;
    $count //= 0;
    $p->configure(-value => $count);
    if ($interrupt) {result(""); return;}
    Tkx::after(100);  # next step in our operation; don't take too long!
    print $count,"\n";
    if ($count==20) {result(42); return;}  # done!
    Tkx::after(1, sub {step($count + 1)});
}
    
sub result {
    my ($answer) = @_;
    $p->configure(-value => 0);
    $b->configure(-text => "Start!", -command => sub{start()});
    $l->configure(-text => $answer ? "Answer: " . $answer : "No Answer");
}

my @rect= (0,0,800,600);
my @rectb= (295 ,595 ,345 ,645);
# print Util->check_collision(\@rect, \@rectb), "\n";
print Util->insideRect(\@rect, \@rectb),"\n";
# Tkx::MainLoop();

my $dbh = DBI->connect("DBI:Pg:database=cin;host=localhost","cin","cin")
or die "Connection lost $DBI::errstr";
my $query = "SELECT * FROM obstacle";
my $sth = $dbh->prepare($query);
$sth->execute();
$dbh->disconnect;