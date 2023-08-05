VARFILE = archlinux.auto.pkrvars.hcl

init:
	packer init .

validate:
  packer validate -var-file $(VARFILE) .

build:
  packer build -on-error=ask -timestamp-ui -var-file $(VARFILE) .
