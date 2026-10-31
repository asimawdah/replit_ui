// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: (decoder, codeUnits) => decoder.decode(codeUnits),
      AC: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      AD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      AE: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      AF: (x0,x1) => { x0.method = x1 },
      AG: x0 => x0.changedTouches,
      AH: x0 => x0.innerHeight,
      AI: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      AJ: x0 => x0.offsetX,
      AK: x0 => x0.size,
      AL: (x0,x1) => { x0.multiple = x1 },
      B: s => printToConsole(s),
      BB: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      BC: Function.prototype.call.bind(DataView.prototype.setFloat64),
      BD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      BE: (x0,x1) => x0.removeProperty(x1),
      BF: (x0,x1) => { x0.noValidate = x1 },
      BG: x0 => x0.offsetY,
      BH: x0 => x0.height,
      BI: () => Date.now(),
      BJ: x0 => x0.button,
      BK: (x0,x1) => globalThis.window.open(x0,x1),
      BL: (x0,x1) => { x0.accept = x1 },
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: () => new TextDecoder("utf-8", {fatal: true}),
      CC: o => o.byteOffset,
      CD: x0 => x0.state,
      CE: (x0,x1) => x0.appendChild(x1),
      CF: (x0,x1) => x0.removeAttribute(x1),
      CG: x0 => x0.offsetX,
      CH: x0 => x0.clientHeight,
      CI: x0 => new WeakRef(x0),
      CJ: x0 => x0.classList,
      CK: x0 => globalThis.window.location.assign(x0),
      CL: (x0,x1) => { x0.type = x1 },
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: () => new TextDecoder("utf-8", {fatal: false}),
      DC: o => o.buffer,
      DD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      DE: x0 => x0.debugShowSemanticsNodes,
      DF: x0 => x0.isConnected,
      DG: x0 => x0.type,
      DH: x0 => x0.innerWidth,
      DI: x0 => x0.deref(),
      DJ: (x0,x1) => { x0.height = x1 },
      DK: (x0,x1,x2) => x0.insertBefore(x1,x2),
      DL: () => globalThis.document,
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: s => s.trimLeft(),
      EC: (b, o) => new DataView(b, o),
      ED: (x0,x1) => x0.go(x1),
      EE: (o, c) => o instanceof c,
      EF: x0 => x0.click(),
      EG: x0 => x0.hasFocus(),
      EH: x0 => x0.width,
      EI: () => globalThis.WeakRef,
      EJ: (x0,x1) => { x0.width = x1 },
      EK: x0 => x0.id,
      EL: (x0,x1) => x0.querySelector(x1),
      F: () => new Error().stack,
      FB: (l, r) => l === r,
      FC: (b, o, l) => new DataView(b, o, l),
      FD: x0 => x0.hash,
      FE: x0 => x0.vendor,
      FF: (x0,x1) => x0.getElementsByClassName(x1),
      FG: x0 => x0.shiftKey,
      FH: x0 => x0.clientWidth,
      FI: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      FJ: x0 => x0.style,
      FK: x0 => x0.offsetHeight,
      FL: x0 => x0.length,
      G: s => JSON.stringify(s),
      GB: (x0,x1) => x0[x1],
      GC: Function.prototype.call.bind(DataView.prototype.getUint8),
      GD: x0 => x0.location,
      GE: (x0,x1) => x0.createTextNode(x1),
      GF: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      GG: x0 => x0.visibilityState,
      GH: (x0,x1) => x0.removeChild(x1),
      GI: (a, s, e) => a.slice(s, e),
      GJ: x0 => x0.sheet,
      GK: x0 => x0.offsetWidth,
      GL: x0 => x0.getReader(),
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: x0 => x0.index,
      HC: Function.prototype.call.bind(DataView.prototype.setUint8),
      HD: x0 => x0.search,
      HE: (x0,x1) => { x0.nonce = x1 },
      HF: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      HG: x0 => x0.disconnect(),
      HH: x0 => x0.firstChild,
      HI: (o, p) => p in o,
      HJ: x0 => x0.head,
      HK: x0 => x0.stopPropagation(),
      HL: x0 => x0.value,
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: (o, p, r) => o.replace(p, () => r),
      IC: Function.prototype.call.bind(DataView.prototype.getFloat64),
      ID: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      IE: x0 => x0.nonce,
      IF: (x0,x1) => x0.contains(x1),
      IG: x0 => new Intl.Locale(x0),
      IH: x0 => x0.viewConstraints,
      II: x0 => x0.groups,
      IJ: () => globalThis.document,
      IK: x0 => x0.disabled,
      IL: x0 => x0.done,
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: s => s.toUpperCase(),
      JC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      JD: x0 => x0.pathname,
      JE: () => globalThis.window.flutterConfiguration,
      JF: (s) => +s,
      JG: x0 => x0.region,
      JH: x0 => x0.hostElement,
      JI: (x0,x1) => x0.revokeObjectURL(x1),
      JJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      JK: (x0,x1) => { x0.min = x1 },
      JL: x0 => x0.read(),
      K: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      KB: Object.is,
      KC: (t, s) => t.set(s),
      KD: (x0,x1) => x0.append(x1),
      KE: (x0,x1) => x0.attachShadow(x1),
      KF: x0 => x0.target,
      KG: x0 => x0.script,
      KH: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      KI: (x0,x1) => { x0.src = x1 },
      KJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      KK: (x0,x1) => { x0.max = x1 },
      KL: x0 => x0.body,
      L: o => o === undefined,
      LB: (x0,x1) => x0.test(x1),
      LC: Function.prototype.call.bind(DataView.prototype.setFloat32),
      LD: (x0,x1) => { x0.textContent = x1 },
      LE: x0 => x0.preventDefault(),
      LF: (x0,x1) => x0.dispatchEvent(x1),
      LG: x0 => x0.language,
      LH: x0 => ({runApp: x0}),
      LI: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      LJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      LK: (x0,x1) => { x0.disabled = x1 },
      LL: (x0,x1) => new OffscreenCanvas(x0,x1),
      M: o => String(o),
      MB: (a, i, v) => a[i] = v,
      MC: Function.prototype.call.bind(DataView.prototype.getFloat32),
      MD: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      ME: (x0,x1) => x0.contains(x1),
      MF: (x0,x1) => x0.createEvent(x1),
      MG: x0 => x0.languages,
      MH: x0 => x0.baseURI,
      MI: x0 => x0.naturalHeight,
      MJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      MK: (x0,x1) => { x0.scrollLeft = x1 },
      ML: x0 => x0.assetBase,
      N: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      NB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      NC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      ND: x0 => x0.parentElement,
      NE: (x0,x1) => x0.focus(x1),
      NF: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      NG: (x0,x1) => x0.observe(x1),
      NH: () => typeof dartUseDateNowForTicks !== "undefined",
      NI: x0 => x0.naturalWidth,
      NJ: (x0,x1,x2) => x0.addEventListener(x1,x2),
      NK: (x0,x1) => { x0.spellcheck = x1 },
      NL: x0 => x0.loader,
      O: (x0,x1) => x0.didCreateEngineInitializer(x1),
      OB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      OC: Function.prototype.call.bind(DataView.prototype.getUint32),
      OD: (x0,x1) => x0.querySelectorAll(x1),
      OE: (x0,x1) => x0.closest(x1),
      OF: () => globalThis.window,
      OG: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      OH: () => Date.now(),
      OI: x0 => x0.decode(),
      OJ: x0 => x0.preventDefault(),
      OK: (x0,x1) => { x0.disabled = x1 },
      OL: () => globalThis._flutter,
      P: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      PC: Function.prototype.call.bind(DataView.prototype.setUint32),
      PD: x0 => x0.length,
      PE: (x0,x1) => x0.getAttribute(x1),
      PF: x0 => x0.readText(),
      PG: x0 => new ResizeObserver(x0),
      PH: () => 1000 * performance.now(),
      PI: (x0,x1) => { x0.decoding = x1 },
      PJ: (x0,x1) => x0.item(x1),
      PK: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      Q: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      QB: Function.prototype.call.bind(String.prototype.toLowerCase),
      QC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      QD: (x0,x1) => x0.item(x1),
      QE: x0 => x0.activeElement,
      QF: x0 => x0.clipboard,
      QG: x0 => globalThis.parseFloat(x0),
      QH: x0 => new Uint8Array(x0),
      QI: (x0,x1) => { x0.crossOrigin = x1 },
      QJ: x0 => x0.arrayBuffer(),
      QK: (x0,x1) => x0.transferFromImageBitmap(x1),
      R: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      RB: (o, p, r) => o.replaceAll(p, () => r),
      RC: Function.prototype.call.bind(DataView.prototype.getInt32),
      RD: x0 => x0.userAgent,
      RE: (x0,x1) => x0.add(x1),
      RF: (x0,x1) => x0.writeText(x1),
      RG: (x0,x1) => x0.getComputedStyle(x1),
      RH: (x0,x1,x2) => x0.slice(x1,x2),
      RI: (x0,x1) => x0.createObjectURL(x1),
      RJ: x0 => x0.size,
      RK: (x0,x1) => x0.getContext(x1),
      S: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      SB: x0 => x0.pop(),
      SC: Function.prototype.call.bind(DataView.prototype.setInt32),
      SD: x0 => x0.maxTouchPoints,
      SE: x0 => x0.classList,
      SF: x0 => x0.unlock(),
      SG: x0 => x0.documentElement,
      SH: (x0,x1) => x0.decode(x1),
      SI: x0 => x0.URL,
      SJ: x0 => x0.name,
      SK: (x0,x1) => { x0.height = x1 },
      T: x0 => new Promise(x0),
      TB: x0 => x0.flags,
      TC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      TD: x0 => x0.platform,
      TE: x0 => x0.data,
      TF: (x0,x1) => x0.lock(x1),
      TG: x0 => x0.computedStyleMap(),
      TH: (x0,x1) => x0.adoptText(x1),
      TI: x0 => new Blob(x0),
      TJ: x0 => x0.type,
      TK: (x0,x1) => { x0.width = x1 },
      U: (x0,x1,x2) => x0.call(x1,x2),
      UB: s => s.trim(),
      UC: o => o instanceof Uint16Array,
      UD: x0 => x0.navigator,
      UE: x0 => x0.scrollTop,
      UF: x0 => x0.orientation,
      UG: (x0,x1) => x0.get(x1),
      UH: x0 => x0.first(),
      UI: x0 => x0.close(),
      UJ: x0 => x0.length,
      UK: x0 => x0.height,
      V: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      VB: (a, s) => a.join(s),
      VC: Function.prototype.call.bind(DataView.prototype.getUint16),
      VD: s => new Date(s * 1000).getTimezoneOffset() * 60,
      VE: (handle) => clearTimeout(handle),
      VF: (x0,x1) => x0.querySelector(x1),
      VG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      VH: x0 => x0.next(),
      VI: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      VJ: x0 => x0.files,
      VK: x0 => x0.width,
      W: x0 => new Array(x0),
      WB: x0 => x0.random(),
      WC: Function.prototype.call.bind(DataView.prototype.setUint16),
      WD: Date.now,
      WE: (x0,x1) => { x0.scrollTop = x1 },
      WF: (x0,x1) => { x0.content = x1 },
      WG: x0 => x0.matches,
      WH: x0 => x0.current(),
      WI: (x0,x1) => x0.decode(x1),
      WJ: x0 => x0.dataTransfer,
      WK: x0 => x0.rasterEndMilliseconds,
      X: o => [o],
      XB: () => globalThis.Math,
      XC: o => o instanceof Int16Array,
      XD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      XE: x0 => x0.tagName,
      XF: x0 => x0.head,
      XG: (x0,x1) => x0.matchMedia(x1),
      XH: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      XI: x0 => x0.displayHeight,
      XJ: x0 => x0.getBoundingClientRect(),
      XK: x0 => x0.rasterStartMilliseconds,
      Y: (o0, o1) => [o0, o1],
      YB: (x0,x1) => x0.error(x1),
      YC: Function.prototype.call.bind(DataView.prototype.getInt16),
      YD: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      YE: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      YF: (x0,x1) => { x0.name = x1 },
      YG: x0 => x0.matches,
      YH: x0 => x0.v8BreakIterator,
      YI: x0 => x0.displayWidth,
      YJ: x0 => x0.top,
      YK: x0 => x0.imageBitmaps,
      Z: (o0, o1, o2) => [o0, o1, o2],
      ZB: () => globalThis.console,
      ZC: Function.prototype.call.bind(DataView.prototype.setInt16),
      ZD: x0 => x0.style,
      ZE: (x0,x1) => { x0.value = x1 },
      ZF: (x0,x1) => { x0.title = x1 },
      ZG: x0 => x0.timeStamp,
      ZH: () => globalThis.Intl,
      ZI: x0 => x0.duration,
      ZJ: x0 => x0.clientY,
      ZK: x0 => x0.canvasKitMaximumSurfaces,
      a: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      aB: s => s.trimRight(),
      aC: o => o instanceof Uint8ClampedArray,
      aD: (x0,x1) => x0.createElement(x1),
      aE: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      aF: () => globalThis.document,
      aG: (x0,x1) => x0.hasAttribute(x1),
      aH: (x0,x1) => x0.segment(x1),
      aI: x0 => x0.image,
      aJ: x0 => x0.left,
      aK: x0 => x0.nextSibling,
      b: (x0,x1,x2) => { x0[x1] = x2 },
      bB: (a, i) => a.push(i),
      bC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      bD: x0 => x0.body,
      bE: (x0,x1) => { x0.value = x1 },
      bF: (x0,x1) => x0.vibrate(x1),
      bG: x0 => x0.buttons,
      bH: x0 => x0.index,
      bI: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      bJ: x0 => x0.clientX,
      bK: (x0,x1) => x0.debug(x1),
      c: o => o,
      cB: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      cC: Function.prototype.call.bind(DataView.prototype.setInt8),
      cD: x0 => x0.remove(),
      cE: x0 => x0.relatedTarget,
      cF: (o, p) => p in o,
      cG: x0 => x0.ctrlKey,
      cH: x0 => x0.next(),
      cI: x0 => new window.ImageDecoder(x0),
      cJ: x0 => x0.types,
      cK: x0 => x0.hostElement,
      d: (o, p) => o[p],
      dB: () => ({}),
      dC: Function.prototype.call.bind(DataView.prototype.getInt8),
      dD: (x0,x1) => x0.getPropertyValue(x1),
      dE: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      dF: x0 => x0.arrayBuffer(),
      dG: x0 => x0.y,
      dH: x0 => x0.value,
      dI: x0 => x0.name,
      dJ: (x0,x1) => { x0.dropEffect = x1 },
      dK: x0 => x0.location,
      e: () => globalThis,
      eB: (o, p, v) => o[p] = v,
      eC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      eD: (x0,x1) => x0.warn(x1),
      eE: x0 => x0.value,
      eF: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      eG: x0 => x0.x,
      eH: x0 => x0.done,
      eI: x0 => x0.repetitionCount,
      eJ: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      eK: (x0,x1) => x0.getModifierState(x1),
      f: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fB: () => [],
      fC: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      fD: x0 => x0.console,
      fE: x0 => x0.selectionDirection,
      fF: x0 => x0.status,
      fG: x0 => x0.offsetTop,
      fH: (o, m, a) => o[m].apply(o, a),
      fI: x0 => x0.frameCount,
      fJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fK: x0 => x0.metaKey,
      g: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gB: b => !!b,
      gC: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      gD: (x0,x1) => { x0.id = x1 },
      gE: x0 => x0.selectionStart,
      gF: (x0,x1) => x0.fetch(x1),
      gG: x0 => x0.scrollLeft,
      gH: x0 => x0.iterator,
      gI: x0 => x0.selectedTrack,
      gJ: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      gK: x0 => x0.altKey,
      h: (x0,x1) => ({addView: x0,removeView: x1}),
      hB: x0 => new Int8Array(x0),
      hC: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      hD: (x0,x1) => x0.requestAnimationFrame(x1),
      hE: x0 => x0.selectionEnd,
      hF: x0 => x0.content,
      hG: x0 => x0.offsetLeft,
      hH: () => globalThis.Symbol,
      hI: x0 => x0.completed,
      hJ: () => globalThis.document,
      hK: x0 => x0.ctrlKey,
      i: (x0,x1) => x0.exec(x1),
      iB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      iC: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      iD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      iE: x0 => x0.value,
      iF: x0 => x0.document,
      iG: x0 => x0.offsetParent,
      iH: (x0,x1) => new Intl.Segmenter(x0,x1),
      iI: x0 => x0.ready,
      iJ: x0 => x0.clipboardData,
      iK: x0 => x0.isComposing,
      j: x0 => x0.length,
      jB: x0 => new Uint8Array(x0),
      jC: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      jD: x0 => x0.now(),
      jE: x0 => x0.selectionDirection,
      jF: x0 => x0.language,
      jG: x0 => x0.deltaMode,
      jH: x0 => x0.Segmenter,
      jI: x0 => x0.tracks,
      jJ: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      jK: x0 => x0.code,
      k: o => o,
      kB: x0 => new Uint8ClampedArray(x0),
      kC: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      kD: x0 => x0.performance,
      kE: x0 => x0.selectionStart,
      kF: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      kG: x0 => x0.deltaY,
      kH: x0 => x0.buffer,
      kI: () => globalThis.window.ImageDecoder,
      kJ: () => new FileReader(),
      kK: x0 => x0.repeat,
      l: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      lB: x0 => new Int16Array(x0),
      lC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      lD: (x0,x1) => x0.unregister(x1),
      lE: x0 => x0.selectionEnd,
      lF: (x0,x1) => x0.prepend(x1),
      lG: x0 => x0.deltaX,
      lH: x0 => x0.wasmMemory,
      lI: (x0,x1) => x0.createElement(x1),
      lJ: (x0,x1) => x0.readAsArrayBuffer(x1),
      lK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      m: (x0,x1) => { x0.lastIndex = x1 },
      mB: x0 => new Uint16Array(x0),
      mC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      mD: () => globalThis.window.FinalizationRegistry,
      mE: x0 => x0.keyCode,
      mF: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      mG: x0 => x0.wheelDeltaY,
      mH: () => globalThis.window._flutter_skwasmInstance,
      mI: (x0,x1) => x0.append(x1),
      mJ: x0 => x0.result,
      mK: (x0,x1) => x0.createElement(x1),
      n: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      nB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      nC: x0 => x0.history,
      nD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      nE: (x0,x1) => x0.scrollIntoView(x1),
      nF: (x0,x1) => x0.querySelector(x1),
      nG: x0 => x0.wheelDeltaX,
      nH: () => new TextDecoder(),
      nI: (x0,x1,x2) => x0.insertRule(x1,x2),
      nJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      nK: (x0,x1) => x0.appendChild(x1),
      o: o => o instanceof RegExp,
      oB: x0 => new Int32Array(x0),
      oC: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      oD: x0 => new window.FinalizationRegistry(x0),
      oE: x0 => x0.multiViewEnabled,
      oF: (x0,x1) => x0.querySelectorAll(x1),
      oG: x0 => x0.key,
      oH: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      oI: (x0,x1) => x0.add(x1),
      oJ: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      oK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      p: o => o,
      pB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      pC: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      pD: x0 => x0.scale,
      pE: x0 => x0.parent,
      pF: x0 => x0.tabIndex,
      pG: x0 => x0.identifier,
      pH: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      pI: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      pJ: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      pK: (x0,x1,x2) => x0.addEventListener(x1,x2),
      q: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      qB: x0 => new Uint32Array(x0),
      qC: o => Object.keys(o),
      qD: x0 => x0.visualViewport,
      qE: (x0,x1) => x0.replaceWith(x1),
      qF: x0 => x0.parentNode,
      qG: x0 => x0.touches,
      qH: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      qI: (x0,x1,x2) => x0.addEventListener(x1,x2),
      qJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      qK: x0 => x0.click(),
      r: x0 => x0.dotAll,
      rB: x0 => new Float32Array(x0),
      rC: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      rD: x0 => x0.devicePixelRatio,
      rE: (x0,x1) => { x0.type = x1 },
      rF: x0 => x0.clientY,
      rG: x0 => x0.pressure,
      rH: (a, i) => a.splice(i, 1),
      rI: x0 => x0.preventDefault(),
      rJ: () => new XMLHttpRequest(),
      rK: x0 => x0.remove(),
      s: x0 => x0.unicode,
      sB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      sC: f => f.dartFunction,
      sD: (d, digits) => d.toFixed(digits),
      sE: (x0,x1) => { x0.className = x1 },
      sF: x0 => x0.clientX,
      sG: x0 => x0.tiltY,
      sH: a => a.pop(),
      sI: x0 => x0.createRange(),
      sJ: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      sK: x0 => x0.message,
      t: x0 => x0.ignoreCase,
      tB: x0 => new Float64Array(x0),
      tC: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      tD: x0 => x0.maxHeight,
      tE: (x0,x1) => { x0.tabIndex = x1 },
      tF: x0 => x0.getBoundingClientRect(),
      tG: x0 => x0.tiltX,
      tH: (map, o, v) => map.set(o, v),
      tI: (x0,x1) => x0.selectNode(x1),
      tJ: x0 => x0.send(),
      tK: x0 => globalThis.URL.createObjectURL(x0),
      u: x0 => x0.multiline,
      uB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      uC: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      uD: x0 => x0.maxWidth,
      uE: (x0,x1) => { x0.name = x1 },
      uF: x0 => x0.bottom,
      uG: x0 => x0.pointerType,
      uH: (map, o) => map.get(o),
      uI: x0 => x0.getSelection(),
      uJ: x0 => x0.type,
      uK: x0 => x0.lastModified,
      v: (string, token) => string.split(token),
      vB: x0 => new ArrayBuffer(x0),
      vC: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      vD: x0 => x0.minHeight,
      vE: (x0,x1) => { x0.placeholder = x1 },
      vF: x0 => x0.top,
      vG: x0 => x0.pointerId,
      vH: () => new WeakMap(),
      vI: x0 => x0.removeAllRanges(),
      vJ: x0 => x0.response,
      vK: x0 => x0.name,
      w: o => o instanceof Array,
      wB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      wC: (o, i) => o[i],
      wD: x0 => x0.minWidth,
      wE: (x0,x1) => { x0.autocomplete = x1 },
      wF: x0 => x0.right,
      wG: x0 => x0.getCoalescedEvents(),
      wH: x0 => x0.debugSkipFontRetryDelay,
      wI: (x0,x1) => x0.addRange(x1),
      wJ: (x0,x1) => { x0.responseType = x1 },
      wK: x0 => x0.type,
      x: (a, i) => a[i],
      xB: (x0,x1,x2) => new DataView(x0,x1,x2),
      xC: o => o.length,
      xD: x0 => x0.height,
      xE: (x0,x1) => { x0.name = x1 },
      xF: x0 => x0.left,
      xG: (x0,x1) => x0.getModifierState(x1),
      xH: (x0,x1,x2) => x0.set(x1,x2),
      xI: () => globalThis.window,
      xJ: x0 => x0.vendor,
      xK: (x0,x1) => x0.item(x1),
      y: a => a.length,
      yB: (o, p) => o[p],
      yC: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      yD: x0 => x0.width,
      yE: (x0,x1) => { x0.placeholder = x1 },
      yF: x0 => x0.clientY,
      yG: x0 => x0.blur(),
      yH: x0 => x0.fontFallbackBaseUrl,
      yI: (x0,x1) => { x0.innerText = x1 },
      yJ: x0 => x0.navigator,
      yK: x0 => x0.length,
      z: (string, times) => string.repeat(times),
      zB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      zC: x0 => x0.state,
      zD: x0 => x0.screen,
      zE: (x0,x1) => { x0.action = x1 },
      zF: x0 => x0.clientX,
      zG: x0 => x0.button,
      zH: (handle) => clearInterval(handle),
      zI: x0 => x0.offsetY,
      zJ: () => globalThis.window,
      zK: x0 => x0.files,

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
