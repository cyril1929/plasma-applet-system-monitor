// No .pragma library to allow access to i18n

// Constant for the minimum display unit (1 = KiB)
const MIN_UNIT_INDEX = 1;

// Global list of units for translation
function getUnitSymbol(unitIndex) {
    switch (unitIndex) {
    case 0:
        return i18n("B");
    case 1:
        return i18n("KiB");
    case 2:
        return i18n("MiB");
    case 3:
        return i18n("GiB");
    case 4:
        return i18n("TiB");
    }
}

/**
 * Determines the best unit index (0 to 4) for a group of values.
 * @param {number[]} values - List of values in bytes.
 * @returns {number} Unit index.
 */
function getBestUnitIndex(values) {
    if (!values || values.length === 0) {
        return MIN_UNIT_INDEX;
    }

    // Find the maximum value
    let maxValue = 0;
    for (let i = 0; i < values.length; i++) {
        const val = values[i] || 0;
        if (val > maxValue) {
            maxValue = val;
        }
    }

    let unitIndex = 0;
    let scaledValue = maxValue;

    // Scale up unit as long as the max value exceeds 1024 (max unit 4 = TiB)
    while (scaledValue >= 1024 && unitIndex < 4) {
        scaledValue /= 1024;
        unitIndex++;
    }

    // Return at least the minimum defined unit index
    return Math.max(MIN_UNIT_INDEX, unitIndex);
}

/**
 * Formats a number of bytes into the unit corresponding to the provided index.
 * @param {number} bytes - Value in bytes.
 * @param {number} unitIndex - Target unit index.
 * @param {number} [decimals=1] - Number of decimals.
 * @returns {string} Formatted value without unit symbol.
 */
function formatBytesWithUnit(bytes, unitIndex, decimals = 1) {
    bytes = bytes || 0;
    const factor = Math.pow(1024, unitIndex);
    return (bytes / factor).toLocaleString(Qt.locale(), 'f', decimals);
}

/**
 * Directly formats a single value into an object containing value and unit.
 * @param {number} bytes - Value in bytes.
 * @param {number} [decimals=1] - Number of decimals.
 * @returns {{value: string, unit: string}} Formatted value and unit symbol.
 */
function formatBytes(bytes, decimals = 1) {
    const unitIndex = getBestUnitIndex([bytes]);
    const value = formatBytesWithUnit(bytes, unitIndex, decimals);
    const unit = getUnitSymbol(unitIndex);
    return {
        value: value,
        unit: unit
    };
}
