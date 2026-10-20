// =============================================================
//  Teleskopická váza v3 – OBRÁTENÁ (najširší segment hore)
//  SMVIT projekt, parametrický model (OpenSCAD 2021+)
//
//  Spodok (najužší, s dnom a pätkou) -> stred -> vrch (najširší).
//  Vyšší segment sa nasúva ZVONKA na nižší.
//
//  Tesnenie: O-krúžok vo vnútornej drážke golieru na spodku
//  vyššieho segmentu, tesní o hladký VONKAJŠÍ povrch nižšieho
//  segmentu ("tesnenie na tyči"). Voda je nad tesnením.
//
//  Bajonet: kolíky sú na krúžku, ktorý sa zaskrutkuje do vrchu
//  nižšieho segmentu (zarovno s jeho stenou). L-drážky sú vo
//  vnútri golieru vyššieho segmentu, otvorené smerom hore,
//  takže neprerušujú tesniacu plochu pod nimi.
// =============================================================

/* [Zobrazenie] */
// assembly, section, exploded, test_set, test_section, bottom, middle, top, ring_bottom, ring_middle, test_lower, test_upper
part = "assembly";
extended = true;

/* [Rozmery] */
R1      = 40;    // vonkajší polomer spodku (tesniaci priemer 80 mm)
H1      = 60;    // výška spodku
H2      = 72;    // výška stredu
H3      = 80;    // výška vrchu
wall    = 2.4;   // stena segmentu
clr     = 0.3;   // radiálna vôľa (doladiť testom!)
floor_t = 3;
foot_r  = 60;    // pätka (stabilita)
foot_h  = 5;

/* [O-krúžok] */
oring_cs  = 3;     // prierez
squeeze   = 0.6;   // stlačenie 20 %
groove_z  = 1.5;
groove_w  = 4.0;

/* [Bajonet] */
lug_n   = 3;
lug_w   = 6;
lug_d   = 3;
lug_h   = 6;     // = výška príruby krúžku (tlač bez podpier)
lock_angle = 30;
F_floor = 7.5;   // dno vodorovnej vetvy v golieri

/* [Závit krúžku] */
thread_h = 10;
pitch    = 4;
th_e     = 0.7;
ow       = 2.0;   // stena za vnútorným závitom
sp_wall  = 1.6;   // stena čapu krúžku

/* [Dekorácia vrchu] */
decoration_on = true;       // false = vrch bez dekorácie
hearts_count = 9;           // počet srdiečok (jeden rad okolo vázy)
heart_size = 20;            // veľkosť srdiečka
heart_z = 0.55;             // výška radu (podiel výšky vrchu)
relief = 1.5;               // výška reliéfu
deco_color = "Gold";        // len na zobrazenie

$fn = 120;

// ---------- odvodené ----------
C_ceil  = F_floor + lug_h + 0.6;      // strop vetvy
P_ceil  = C_ceil + 1;                 // poistné lôžko (o 1 mm vyššie)
collar_T = C_ceil + 4;                // výška golieru
function rb(Rl)  = Rl + lug_d + clr + 0.2;   // vŕtanie vyššieho segmentu
function Rup(Rl) = rb(Rl) + wall;
function rt_hole(R) = R - ow - th_e;
function rt_sp(R)   = rt_hole(R) - clr;
function sp_in(R)   = rt_sp(R) - th_e - sp_wall;
drop = lug_h - P_ceil;                // poloha vyššieho segm. voči vrchu nižšieho

R2 = Rup(R1);
R3 = Rup(R2);
ext_h = H1 + H2 + H3 + 2 * drop;
col_h = foot_h + max(H3, H2 + lug_h, H1 + lug_h);

echo(str("Spodok OD=", 2*R1, " ID=", 2*(R1-wall)));
echo(str("Stred  OD=", 2*R2, " ID=", 2*rb(R1)));
echo(str("Vrch   OD=", 2*R3, " ID=", 2*rb(R2), " (limit 100)"));
echo(str("O-kruzok spodok/stred: tyc ", 2*R1, " mm -> kup 78x3"));
echo(str("O-kruzok stred/vrch: tyc ", 2*R2, " mm -> kup 90x3"));
echo(str("Vyska vysunuta=", ext_h, " mm, zlozena=", col_h, " mm"));
assert(2*rb(R2) <= 100, "Vnutorny priemer vrchu > 100 mm");

// ---------- bloky ----------
module ring_shape(ro, ri, h) difference() {
    cylinder(r = ro, h = h);
    translate([0, 0, -1]) cylinder(r = ri, h = h + 2);
}

module thread_solid(rt, h)
    linear_extrude(height = h, twist = -360 * h / pitch, slices = h * 6)
        translate([th_e, 0]) circle(r = rt);

// golier s drážkou pre O-krúžok a L-drážkami bajonetu (Rl = polomer nižšieho segm.)
module collar_cuts(Rl) {
    ri = Rl + clr;
    a  = (lug_w / 2 + 0.4) / Rl * 180 / PI;
    // drážka O-krúžku
    translate([0, 0, groove_z]) ring_shape(Rl + oring_cs - squeeze, ri - 1, groove_w);
    // nábeh na spodku
    translate([0, 0, -0.01]) cylinder(r1 = ri + 0.8, r2 = ri, h = 0.8);
    for (i = [0 : lug_n - 1]) rotate([0, 0, i * 360 / lug_n]) {
        rotate([0, 0, -a]) rotate_extrude(angle = 2 * a)
            translate([ri - 1, F_floor]) square([rb(Rl) - ri + 1, collar_T]);
        rotate([0, 0, -a]) rotate_extrude(angle = lock_angle + 2 * a)
            translate([ri - 1, F_floor]) square([rb(Rl) - ri + 1, C_ceil - F_floor]);
        rotate([0, 0, lock_angle - a]) rotate_extrude(angle = 2 * a)
            translate([ri - 1, F_floor]) square([rb(Rl) - ri + 1, P_ceil - F_floor]);
    }
}

// vnútorný závit na vrchu segmentu (R = vonkajší polomer, rbore = vŕtanie, h = výška)
module top_band(R, rbore, h) {
    difference() {
        union() {
            translate([0, 0, h - thread_h]) ring_shape(R, 1, thread_h);
            // 45° zrazenie pod pásom (tlač bez podpier)
            d = rbore - (rt_hole(R) - th_e);
            if (d > 0) translate([0, 0, h - thread_h - d])
                difference() {
                    cylinder(r = R - 0.01, h = d);
                    translate([0, 0, -0.01]) cylinder(r1 = rbore, r2 = rbore - d, h = d + 0.02);
                }
        }
        translate([0, 0, h - thread_h - 0.01]) thread_solid(rt_hole(R), thread_h + 1);
    }
}

// krúžok s kolíkmi: príruba zarovno + čap so závitom dolu
module lug_ring(R) {
    si = sp_in(R);
    difference() {
        union() {
            cylinder(r = R, h = lug_h);
            translate([0, 0, -thread_h + 0.4]) thread_solid(rt_sp(R), thread_h - 0.4);
            for (i = [0 : lug_n - 1]) rotate([0, 0, i * 360 / lug_n])
                translate([R - 0.5, -lug_w / 2, 0]) cube([lug_d + 0.5, lug_w, lug_h]);
        }
        translate([0, 0, -thread_h - 1]) cylinder(r = si, h = thread_h + lug_h + 2);
        translate([0, 0, -thread_h + 0.39]) cylinder(r1 = si + 0.8, r2 = si, h = 0.8);
    }
}

// ---------- srdiečko (2D) ----------
module heart2d(s) translate([0, -s * 0.12]) rotate(-45) union() {
    square(s * 0.55, center = true);
    translate([-s * 0.275, 0]) circle(d = s * 0.55);
    translate([0, s * 0.275]) circle(d = s * 0.55);
}

// reliéf: jeden rad srdiečok na valci s polomerom R, výškou h
module decoration(R, h)
    intersection() {
        ring_shape(R + relief, R - 1.5, h);
        union() for (k = [0 : hearts_count - 1])
            rotate([0, 0, k * 360 / hearts_count])
                translate([R - 1.5, 0, h * heart_z]) rotate([90, 0, 90])
                    linear_extrude(relief + 3) heart2d(heart_size);
    }

// ---------- diely ----------
module bottom() {
    rbore = R1 - wall;
    difference() {
        union() {
            cylinder(r = R1, h = H1 - thread_h);
            cylinder(r1 = foot_r, r2 = foot_r - 1.5, h = foot_h);
        }
        translate([0, 0, floor_t]) cylinder(r = rbore, h = H1);
    }
    top_band(R1, rbore, H1);
}

// vyšší segment: Rl = polomer nižšieho segmentu, h = výška, band = má závit hore
module upper_segment(Rl, h, band) {
    R = Rup(Rl);
    difference() {
        union() {
            ring_shape(R, rb(Rl), band ? h - thread_h : h);
            ring_shape(R, Rl + clr, collar_T);
        }
        collar_cuts(Rl);
    }
    if (band) top_band(R, rb(Rl), h);
}

module middle() upper_segment(R1, H2, true);
module top() {
    upper_segment(R2, H3, false);
    if (decoration_on) color(deco_color) decoration(R3, H3);
}
module ring_bottom() lug_ring(R1);
module ring_middle() lug_ring(R2);

// testovacia sada = spoj spodok/stred v skrátenej verzii
TH = 30;
module test_lower() {
    rbore = R1 - wall;
    difference() {
        cylinder(r = R1, h = TH - thread_h);
        translate([0, 0, floor_t]) cylinder(r = rbore, h = TH);
    }
    top_band(R1, rbore, TH);
}
module test_upper() upper_segment(R1, collar_T + 8, false);

module oring(Rl) translate([0, 0, groove_z + groove_w / 2])
    rotate_extrude() translate([Rl + oring_cs / 2 - squeeze / 2, 0]) circle(d = oring_cs);

// ---------- zostavy ----------
module assembly(ext = extended, ex = 0) {
    zm = ext ? H1 + drop : foot_h;
    zt = ext ? zm + H2 + drop : foot_h;
    a  = ext ? lock_angle : 0;
    color("SteelBlue") bottom();
    color("Black") translate([0, 0, zm + ex * 1.6]) oring(R1);
    color("DarkOrange") translate([0, 0, H1 + ex * 0.8]) rotate([0, 0, a]) ring_bottom();
    color("LightSteelBlue") translate([0, 0, zm + ex * 2.6]) middle();
    color("Black") translate([0, 0, zt + ex * 3]) oring(R2);
    color("Orange") translate([0, 0, zm + H2 + ex * 3.4]) rotate([0, 0, a]) ring_middle();
    translate([0, 0, zt + ex * 4]) {
        color("AliceBlue") upper_segment(R2, H3, false);
        if (decoration_on) color(deco_color) decoration(R3, H3);
    }
}

module test_set(ex) {
    zu = TH + drop;
    color("SteelBlue") test_lower();
    color("DarkOrange") translate([0, 0, TH + ex * 1.2]) rotate([0, 0, ex > 0 ? 0 : lock_angle]) ring_bottom();
    color("Black") translate([0, 0, zu + ex * 2]) oring(R1);
    color("AliceBlue") translate([0, 0, zu + ex * 2.6]) test_upper();
}

module cut() difference() { children(); translate([0, -300, -50]) cube([600, 600, 600]); }

if (part == "assembly") assembly();
else if (part == "section") cut() assembly();
else if (part == "exploded") assembly(true, 25);
else if (part == "test_set") test_set(25);
else if (part == "test_section") cut() test_set(0);
else if (part == "bottom") bottom();
else if (part == "middle") middle();
else if (part == "top") top();
else if (part == "ring_bottom") ring_bottom();
else if (part == "ring_middle") ring_middle();
else if (part == "test_lower") test_lower();
else if (part == "test_upper") test_upper();
