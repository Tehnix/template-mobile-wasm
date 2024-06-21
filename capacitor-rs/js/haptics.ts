/**
 * https://capacitorjs.com/docs/apis/haptics
 */
import type { ImpactOptions } from "@capacitor/haptics";
import { Haptics, ImpactStyle } from "@capacitor/haptics";

export const haptics_impact = async (options?: ImpactOptions | undefined) => {
  await Haptics.impact(options);
};

export const haptics_impact_medium = async () => {
  await Haptics.impact({ style: ImpactStyle.Medium });
};

export const haptics_impact_light = async () => {
  await Haptics.impact({ style: ImpactStyle.Light });
};

export const haptics_vibrate = async () => {
  await Haptics.vibrate();
};

export const haptics_selection_start = async () => {
  await Haptics.selectionStart();
};

export const haptics_selection_changed = async () => {
  await Haptics.selectionChanged();
};

export const haptics_selection_end = async () => {
  await Haptics.selectionEnd();
};
