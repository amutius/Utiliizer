#!/usr/bin/perl
#
# IMPORTS
#

use strict;
use warnings;

#
# CLASSES
#

# File class
package File;
# File Constructor
# IN string path - path to file
sub new {
    my $class = shift;
    my $self = {
        path => shift,
    };
    bless $self, $class;
    return $self;
}
# Reads the file till end
# OUT string content - content of file
sub Read {
    my ($self) = @_;
    local $/ = undef;
    open my $fhandle, "<", $self->{path}
        or print "Can't open file!" && return;
    
    my $ret = <$fhandle>;
    
    close $fhandle;
    return $ret;
}
# Parses the file with given regex and returns matches
# IN compiled regex - the regex to match
# OUT string match - regex match
sub Parse {
    my ($self, $regex) = @_;
    my $data = $self->Read();
    my $array;

    foreach my $line (split('\n', $data)) {
        if (my @matches = $line =~ /$regex/) {
            print @matches;
            push @$array, \@matches;
        }
    }
    return $array;
}

# Table class
package Table;
# Table Constructor
# IN ARRAY ref column header - title of different columns
# IN ARRAY ref array - array of data to fill table with
sub new {
    my $class = shift;
    my $self = {
        "columns" => shift,
        "data" => shift,
    };
    bless $self, $class;
    return $self;
}

# Prints the table
# IN INT mode - 0 markdown, 1 rsf table default: 0
# IN INT margin - margin from data to border default: 1
# IN BOOL array index - shows the index / "row number" default: 0
sub print {
    my ($self, $mode, $margin, $index) = @_;
    my $columns = $self->{"columns"};
    my $data = $self->{"data"};

    if ($index) {
        unshift(@$columns, '#');
    }
    # set to 0 if undef
    $margin //= 1;
    $index //= 0;

    my $length = scalar @$columns;
    my $space = " " x $margin;

    my %lines;
    my $header_row;
   
    for (my $i = 0; $i < $length; $i++) {
        my $cell;
        my $sep;
        my $data_longest = 0;
        my $diff = 0;
        my $data_i = 0;
        my $start_cell = $i == 0 ? "|" : "";
        my $start_sep = $i == 0 ? $mode == 0 ? "|" : "+" : "";
        my $middle_sep = "-";
        my $middle_sep_2 = "-";
        my $end_sep = $mode == 0 ? "|" : "+";
        for (@$data) {
            if ($i == 0 && $index) {
                unshift @$_, $data_i;
            }
            my $data_length = length(@$_[$i]);
            if ($data_length > $data_longest) {
                $data_longest = $data_length
            }
            $data_i++;
        }
        # check the alignment
        my $alignment = 0;
        my @regex = split(/^(_+)(.*)/, @$columns[$i]);
        
        foreach (@regex) {
            if ($_ eq "_") {
                $alignment = 1;
                @$columns[$i] = $regex[2];
            } elsif ($_ eq "__") {
                $alignment = 2;
                @$columns[$i] = $regex[2];
            }
        }
        if ($mode == 0) {
            if ($alignment >= 1) {
                $middle_sep_2 = ":";
            }
            if ($alignment == 2) {
                $middle_sep = ":";
            }
        }
        $diff = $data_longest - length(@$columns[$i]);
        if ($diff < 0) {
            $diff = 0;
            $data_longest = length(@$columns[$i]);
        }
        $data_i = 0;
        @$columns[$i] .= " " x $diff;
        $cell .= $start_cell . $space . @$columns[$i] . $space . "|";
        # first sep
        my $content_length = length($space) * 2 + length(@$columns[$i]);
        $sep .= $start_sep . $middle_sep . "-" x ($content_length - 2) . $middle_sep_2 . $end_sep;
        if ($mode == 1) {
            $lines{$data_i} .= $sep;
            $data_i++;
        }
        $lines{$data_i} .= $cell;
        $data_i++;
        for (@$data) {
            $diff = $data_longest - length(@$_[$i]);
            $diff = $diff < 0 ? 0 : $diff;
            @$_[$i] .= " " x $diff;
            my $data_cell;
            my $data_sep;
            $data_cell .= $start_cell . $space . @$_[$i] . $space . "|";
            $content_length = length($space) * 2 + length(@$_[$i]);
            $data_sep .= $start_sep . ("-" x $content_length) . $end_sep;
            if ($mode == 1 || $data_i == 1) {
                $lines{$data_i} .= $sep;
                $data_i++;
            }
            $lines{$data_i} .= $data_cell;
            $data_i++;
        }
        # last sep
        if ($mode == 1) {
            $lines{$data_i} .= $sep;
            $data_i++;
        }
    }
    foreach my $key (sort { $a <=> $b} keys %lines) {
        print $lines{$key} . "\n";
    }
}

# EXAMPLE

my @header = ("__Zentriert", "_Rechts", "Links/Normal", "*Cool*");
my @entry1 = (0, 1, 2, 434);
my @entry2 = (2, 232434,34, 2);
my @entry3 = (24, 2, 2, 4334);
my @data;
push @data, \@entry1, \@entry2, \@entry3;

my $tb = Table->new(\@header, \@data);
$tb->print(0, 1);
