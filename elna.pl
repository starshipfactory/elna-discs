#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($outfile, $steps, $help, $func, $interpolate) = ("disc.scad", 24, undef, undef, 0);
GetOptions(
	"output=s" => \$outfile,
	"steps=i" => \$steps,
	"function=s" => \$func,
	"interpolate" => \$interpolate,
	"help" => \$help,
);

if (!defined($outfile) || $help) {
	print(STDERR "Usage: elna.pl --output <output.scad> [--steps <steps>] [--continuous] [--help] {--function <function> | <radius1> <radius2> ... <radius18>}\n");
	print(STDERR "help           This help\n");
	print(STDERR "output.scad    Output file\n");
	print(STDERR "steps          Number of steps per edge (default: 1)\n");
	print(STDERR "continuous     Apply the wave function continuously, i.e. do not use interpolation for intermediate points\n");
	print(STDERR "function       Function to evaluate over the range of 0 to 1, should produce values between 0 and 1\n");
	print(STDERR "               Function will be evaluated using Perl eval(), \$_ holds the input\n");
	print(STDERR "radiusN        List of radii (usually between 0 and 1)\n");
	print(STDERR "Examples:      elna.pl --output disc.scad --steps 24 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9\n");
	print(STDERR "               elna.pl --output disc.scad --steps 24 1 1 1 0.9 0.9 0.9 1 1 1 0.9 0.9 0.9 1 1 1 0.9 0.9 0.9\n");
	print(STDERR "               elna.pl --output disc.scad --steps 24 --function 'sin(\$_*2*3.141592654*12)*0.05+0.95'\n");
	exit(1);
}

# Ensure we have either a function or 18 control points
if (!defined($func) and @ARGV < 18) {
	die("Not enough points: 18 required, " . scalar(@ARGV) . " given\n");
}
# ensure steps is > 0
$steps = 1 unless $steps;

open(my $out, '>', $outfile) or die("Can't open output file");

sub polar {
	my ($radius, $angle) = @_;
	return [$radius * cos($angle), $radius * sin($angle)];
}

sub spline {
	my ($p0, $p1, $p2, $p3, $t) = @_;
	# Slope at each of the endpoints of the middle spline segment is calculated as the average slope over the adjacent segments
	my $m0 = abs($p2 - $p0) / 2;
	my $m1 = abs($p3 - $p1) / 2;
	# Calculate a 3rd order Hermite spline over the middle segment
	#return (2 * $t * $t * $t - 3 * $t * $t + 1) * $p1 + ($t * $t * $t - 2 * $t * $t + $t) * $m0 + (-2 * $t * $t * $t + 3 * $t * $t) * $p2 +($t * $t * $t - $t * $t) * $m1; 
	# Optimized
	return (((-2*$p2+2*$p1+$m1+$m0)*$t+(3*$p2-3*$p1-$m1-2*$m0))*$t+$m0)*$t+$p1;
}

my @radii;
if (!defined($func)) {
	@radii = ($ARGV[-1], @ARGV, $ARGV[0], $ARGV[1]);
}

my @coords;
for (my $i = 0; $i < 18; $i++) {
	my @p;
	if (defined($func)) {
		if ($interpolate) {
			local $_;
			$_ = ($i + 0) / 18; $p[0] = eval($func);
			$_ = ($i + 1) / 18; $p[1] = eval($func);
			$_ = ($i + 2) / 18; $p[2] = eval($func);
			$_ = ($i + 3) / 18; $p[3] = eval($func);
		}
	} else {
		@p = ($radii[$i], $radii[$i + 1], $radii[$i + 2], $radii[$i + 3]);
	}
	for (my $j = 0; $j < $steps; $j++) {
		my $r;
		if (defined($func) && !$interpolate) {
			$_ = ($i + $j / $steps) / 18; $r = eval($func);
		} else {
			$r = spline(@p, $j / $steps);
		}
		#print("$radii[$i - 1], $radii[$i], $radii[$i + 1], $radii[$i + 2], $j, $r\n");
		push(@coords, polar($r, ($i + $j / $steps) * 20 * 3.141592654 / 180));
	}
}

print($out "// Generated by elna.pl\n");
print($out "// Command line:" . ($outfile ? " --output $outfile" : '') . " --steps $steps" . ($interpolate ? " --interpolate" : '') . ($func ? " --function '$func'" : " " . join(' ', @ARGV)) . "\n");
print($out "module disc() {\n");
print($out "\tpolygon(points=[");
print($out "[$coords[0]->[0],$coords[0]->[1]]");
for (my $index = 1; $index < @coords; $index++) {
	print($out ", [$coords[$index]->[0],$coords[$index]->[1]]");
}
print($out "], paths=[[0");
for (my $index = 1; $index < @coords; $index++) {
	print($out ", $index");
}
print($out "]]);\n");
print($out "}\n");

