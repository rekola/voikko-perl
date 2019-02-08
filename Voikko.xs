#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <libvoikko/voikko.h>

MODULE = Lingua::Voikko		PACKAGE = Lingua::Voikko		

void
new_voikko(lang, path)
        char * lang
        char * path
    INIT:
        struct VoikkoHandle * rawstruct;
    PPCODE:
	const char * error;
	rawstruct = voikkoInit(&error, lang, path);

        if (rawstruct == NULL) {
	    EXTEND(SP, 3);
	    PUSHs(&PL_sv_undef);
	    PUSHs(sv_2mortal(newSViv(0)));
	    PUSHs(sv_2mortal(newSVpv(error,0)));
	} else {
	    SV *object = newSV(0);
	    sv_setref_pv(object, "Lingua::Voikko", (void *)rawstruct);
	    XPUSHs(sv_2mortal(object));
	}

int
spell_voikko(voikko, word)
        struct VoikkoHandle * voikko
        char * word
    PROTOTYPE: $$
    CODE:
        RETVAL = voikkoSpellCstr(voikko, word);
    OUTPUT:
        RETVAL

void
suggest_voikko(voikko, word)
        struct VoikkoHandle * voikko
        char * word
    PROTOTYPE: $$
    INIT:
	SV * sv;
	AV  *  retlist;
	unsigned int i;
	char ** r;
	
    PPCODE:
        retlist = (AV *)sv_2mortal((SV *)newAV());

        r = voikkoSuggestCstr(voikko, word);
        if (r) {
            for (i = 0; r[i] != 0; i++) {
	      	sv = newSVpv(r[i], 0);
		SvUTF8_on(sv);
	        av_push(retlist, sv);
	    }
            voikkoFreeCstrArray(r);
	}

        XPUSHs(newRV_noinc((SV *)retlist));

void
hyphenate(voikko, word)
        struct VoikkoHandle * voikko
        char * word
    PROTOTYPE: $$
    INIT:
	SV * rv;
	char * r;
	
    PPCODE:
	r = voikkoHyphenateCstr(voikko, word);
        if (r) {
	    XPUSHs(sv_2mortal(newSVpv(r, 0)));
	    voikkoFreeCstr(r);
        } else {
	    EXTEND(SP, 3);
	    PUSHs(&PL_sv_undef);
	    PUSHs(sv_2mortal(newSViv(0)));
	    PUSHs(sv_2mortal(newSVpv("Error",0)));
        }

void
analyze_voikko(voikko, word)
        struct VoikkoHandle * voikko
        char * word
   PROTOTYPE: $$
   INIT:
	AV  *  retlist;
	struct voikko_mor_analysis ** analysis;
	const char ** keys;
	char * value;
	unsigned int i, j;
	HV * hash;
	SV * sv;
   PPCODE:
	retlist = (AV *)sv_2mortal((SV *)newAV());
	analysis = voikkoAnalyzeWordCstr(voikko, word);
        for (i = 0; analysis[i] != 0; i++) {
            keys = voikko_mor_analysis_keys(analysis[i]);
	    hash = (HV *) sv_2mortal ((SV *) newHV ());
            for (j = 0; keys[j] != 0; j++) {
	        value = voikko_mor_analysis_value_cstr(analysis[i], keys[j]);
		sv = newSVpv(value, 0);
		SvUTF8_on(sv);
		hv_store(hash, keys[j], strlen(keys[j]), sv, 0);
	        voikko_free_mor_analysis_value_cstr(value);
	    }
	    
	    av_push(retlist, newRV((SV *)hash));
	}
        voikko_free_mor_analysis(analysis);

        XPUSHs(newRV_noinc((SV *)retlist));

int
set_boolean_option_voikko(voikko, option, value)
        struct VoikkoHandle * voikko
        int option
        int value
    PROTOTYPE: $$$
    CODE:
	RETVAL = voikkoSetBooleanOption(voikko, option, value);
    OUTPUT:
        RETVAL

int
set_integer_option_voikko(voikko, option, value)
        struct VoikkoHandle * voikko
        int option
        int value
    PROTOTYPE: $$$
    CODE:
	RETVAL = voikkoSetIntegerOption(voikko, option, value);
    OUTPUT:
        RETVAL
