all: clean debt-slackers email

clean:
	rm email

report.json:
	hy cli.hy generate-report report.json

debt-slackers: report.json
	hy cli.hy debt-slackers $(shell date +%Y_%m_%d) report.json ledger

email: report.json
	hy cli.hy generate-email $(shell date +%Y_%m_%d) report.json email
