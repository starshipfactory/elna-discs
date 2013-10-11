#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($outfile, $steps, $help) = (undef, 1, undef);
GetOptions(
	"output=s" => \$outfile,
	"steps=i" => \$steps,
	"help" => \$help,
);

if (!defined($outfile) || $help) {
	print(STDERR "Usage: elna.pl --output <output.scad> [--steps <steps>] [--help] <radius1> <radius2> ... <radius18>\n");
	print(STDERR "output.scad    Output file\n");
	print(STDERR "steps          Number of steps per edge (default: 1)\n");
	print(STDERR "radiusN        List of radii (usually between 0.0 and 1.0)\n");
	print(STDERR "Example: elna.pl --output disc.scad --steps 24 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9 1 0.9\n");
	print(STDERR "         elna.pl --output disc.scad --steps 24 1 1 1 0.9 0.9 0.9 1 1 1 0.9 0.9 0.9 1 1 1 0.9 0.9 0.9\n");
	exit(1);
}
if (@ARGV < 18) {
	die("Not enough points: 18 required, " . scalar(@ARGV) . " given\n");
}
$steps = 1 unless $steps;

open(my $out, '>', $outfile) || die("Can't open output file");

sub polar {
	my ($radius, $angle) = @_;
	return [$radius * cos($angle), $radius * sin($angle)];
}

sub spline {
	my ($p0, $p1, $p2, $p3, $t) = @_;
	#my $m0 = ($p0 + $p2) / 2;
	#my $m1 = ($p1 + $p3) / 2;
	# Slope at each point = 0 gives best results
	my ($m0, $m1) = (0, 0);
	# 3rd order Hermite spline
	return (2 * $t * $t * $t - 3 * $t * $t + 1) * $p1 + ($t * $t * $t - 2 * $t * $t + $t) * $m0 + (-2 * $t * $t * $t + 3 * $t * $t) * $p2 +($t * $t * $t - $t * $t) * $m1; 
}

my @radii = (@ARGV, $ARGV[0], $ARGV[1], $ARGV[-1]);

my @coords;
for (my $i = 0; $i < 18; $i++) {
	for (my $j = 0; $j < 1; $j += 1 / $steps) {
		my $r = spline($radii[$i - 1], $radii[$i], $radii[$i + 1], $radii[$i + 2], $j);
		#print("$radii[$i - 1], $radii[$i], $radii[$i + 1], $radii[$i + 2], $j, $r\n");
		push(@coords, polar($r, ($i + $j) * 20 * 3.141592654 / 180));
	}
}

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

