import {
  Directive,
  EventEmitter,
  HostBinding,
  HostListener,
  Output,
} from '@angular/core';

@Directive({
  selector: '[appDragNDrop]',
})
export class DragNDropDirective {
  @HostBinding('class.fileover') fileOver!: boolean;

  @Output() fileDropped = new EventEmitter<any>();

  @HostListener('dragover', ['$event'])
  public onDragOver(evt: DragEvent): void {
    evt.preventDefault();
    evt.stopPropagation();
    this.fileOver = true;
  }

  @HostListener('dragleave', ['$event'])
  public onDragLeave(evt: DragEvent): void {
    evt.preventDefault();
    evt.stopPropagation();
    this.fileOver = false;
  }

  @HostListener('drop', ['$event'])
  public ondrop(evt: DragEvent): void {
    evt.preventDefault();
    evt.stopPropagation();
    this.fileOver = false;
    const files = evt.dataTransfer?.files;
    if (files?.length !== undefined && files?.length > 0) {
      this.fileDropped.emit(files);
    }
  }
}
