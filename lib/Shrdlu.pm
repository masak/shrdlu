use v6;

grammar Shrdlu::Language {
    token TOP { ^ <order> $ }

    rule order { <pick_up> <noun_phrase> '.'? }

    token pick_up { 'pick up' | grasp }

    rule noun_phrase { <article> [<attribute> \h*]* <noun> }

    token article { a | the }
    token attribute { <color> | <size> }
    token color { red }
    token size { big }
    token noun { block | pyramid }
}

class Shrdlu::Object {
    has $.size;
    has $.shape;
    has $.color;
}

class Shrdlu {
    has @!blocks;
    has @.reply;

    submethod BUILD() {
        @!blocks =
            .new( :size<big>, :color<red>, :shape<block> ),
            .new( :size<big>, :color<red>, :shape<pyramid> ),
            .new( :size<small>, :color<green>, :shape<pyramid> )
                given Shrdlu::Object;
    }

    method tell(Str $sentence) {
        if Shrdlu::Language.parse($sentence.lc) {
            my @possible-objects;
            my ($desired-shape, $desired-size, $desired-color);
            given $<order><noun_phrase> {
                $desired-shape = ~.<noun>;
                if .<attribute> {
                    for .<attribute>.list {
                        if .<color> {
                            $desired-color = .Str;
                        }
                        elsif .<size> {
                            $desired-size = .Str;
                        }
                        else {
                            die "Unknown type of attribute.";
                        }
                    }
                }
            }
            $desired-color //= *;
            $desired-size  //= *;
            @possible-objects = grep {
                all(        (        .shape,         .size,         .color)
                     >>~~<< ($desired-shape, $desired-size, $desired-color) )
            }, @!blocks;
            @!reply = @possible-objects == 1
                        ?? 'OK.'
                        !! "I don't understand which $desired-shape you mean.";
        }
        else {
            @!reply = 'I don\'t understand';
        }
    }
}
