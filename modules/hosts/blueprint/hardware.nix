{ inputs, ... }: {
  imports = [ inputs.microvm.nixosModules.microvm ];
  microvm = {
    hypervisor = "qemu";
    vcpu = 2;
    mem = 4096;
  };
}
