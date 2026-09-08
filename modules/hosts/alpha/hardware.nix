{ inputs, ... }: {
  imports = [ inputs.microvm.nixosModules.microvm ];
  microvm = {
    hypervisor = "qemu";
    vcpu = 1;
    mem = 1024;
  };
}
