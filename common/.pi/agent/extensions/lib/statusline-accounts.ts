export function getActiveAccountLabelFromStatus(status: string): string | undefined {
	const match = /^account:([A-Za-z0-9._-]+)(?: auth error)?$/.exec(status);
	return match?.[1];
}
