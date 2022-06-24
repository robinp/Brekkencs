package rts;

import rts.DataDefs;

class Env {

  private var dataDefs: DataDefs = emptyDataDefs();

  public function new() {
  }

  public function addDataDef(d: DataDef) {
    dataDefs[d.name] = d;
  }
}
