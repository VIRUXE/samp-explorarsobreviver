
stock isalphabetic(chr)
{
	if('a' <= chr <= 'z' || 'A' <= chr <= 'Z')
		return 1;

	return 0;
}

stock isalphanumeric(chr)
{
	if('a' <= chr <= 'z' || 'A' <= chr <= 'Z' || '0' <= chr <= '9')
		return 1;

	return 0;
}

FormatSpecifier<'T'>(output[], timestamp)
{
	strcat(output, TimestampToDateTime(timestamp, "%A %b %d %Y at %X"));
}

FormatSpecifier<'M'>(output[], millisecond)
{
	strcat(output, MsToString(millisecond, "%h:%m:%s.%d"));
}

stock atos(a[], size, s[], len = sizeof(s))
{
	s[0] = '[';

	for(new i; i < size; i++)
	{
		if(i != 0)
			strcat(s, ", ", len);

		format(s, len, "%s%d", s, a[i]);
	}

	s[strlen(s)] = ']';
}

stock atosr(a[], size = sizeof(a))
{
	new s[256];
	atos(a, size, s);
	return s;
}

stock RemoveAccents(text[])
{
	new const accentTable[] = "AAAAAAACEEEEIIIIDNOOOOO×OUUUUYpBaaaaaaaceeeeiiiionooooo+ouuuuyby";

    for (new i = 0; text[i] != '\0'; i++)
	{
        if(text[i] < 192) continue;

        text[i] = accentTable[text[i]-192];
    }
}